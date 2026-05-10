class_name DomainEventLogger
extends RefCounted

static var _seen_idempotency_keys: Dictionary = {}
static var _sequence_number: int = 0
static var _previous_integrity_hash: String = ""

## Limite de profundidade de recursão para canonicalize().
## Payloads mais profundos que este valor retornam o marcador "[MAX_DEPTH]".
const _MAX_CANONICALIZE_DEPTH: int = 16


static func clear_idempotency_keys() -> void:
	_seen_idempotency_keys.clear()
	_sequence_number = 0
	_previous_integrity_hash = ""


static func make_operation_id(event_name: String, entity_id: String = "") -> String:
	return "%s:%s:%d" % [event_name, entity_id, Time.get_ticks_usec()]


static func make_idempotency_key(operation_id: String, event_name: String) -> String:
	return "%s:%s" % [operation_id, event_name]


static func calculate_delta(before: Dictionary, after: Dictionary) -> Dictionary:
	return calculate_economic_delta(before, after)


static func calculate_economic_delta(before: Dictionary, after: Dictionary) -> Dictionary:
	var delta := {}
	var keys := _merged_keys(before, after)

	for key in keys:
		var before_value = before.get(key, 0)
		var after_value = after.get(key, 0)

		if before_value is Dictionary or after_value is Dictionary:
			var before_dictionary: Dictionary = before_value if before_value is Dictionary else {}
			var after_dictionary: Dictionary = after_value if after_value is Dictionary else {}
			var nested_delta := calculate_economic_delta(before_dictionary, after_dictionary)
			if not nested_delta.is_empty():
				delta[key] = nested_delta
		elif _is_number(before_value) or _is_number(after_value):
			var numeric_delta = _number_or_zero(after_value) - _number_or_zero(before_value)
			if numeric_delta != 0:
				delta[key] = numeric_delta

	return delta


static func validate_reconciliation(before: Dictionary, after: Dictionary, delta: Dictionary) -> bool:
	for key in delta.keys():
		var delta_value = delta[key]
		var before_value = before.get(key)
		var after_value = after.get(key)

		if delta_value is Dictionary:
			var before_dictionary: Dictionary = before_value if before_value is Dictionary else {}
			var after_dictionary: Dictionary = after_value if after_value is Dictionary else {}
			if not validate_reconciliation(before_dictionary, after_dictionary, delta_value):
				return false
		elif _is_number(delta_value):
			if _number_or_zero(before_value) + delta_value != _number_or_zero(after_value):
				return false

	return true


static func has_negative_numbers(state: Dictionary) -> bool:
	for key in state.keys():
		var value = state[key]
		if value is Dictionary:
			if has_negative_numbers(value):
				return true
		elif _is_number(value) and value < 0:
			return true

	return false


static func emit_event(
	event_name: String,
	operation_id: String,
	idempotency_key: String,
	entity_type: String,
	entity_id: String,
	policy: String,
	result: String,
	before: Dictionary,
	after: Dictionary,
	delta: Dictionary,
	semantic_integrity: String = "pass",
	failure_reason: String = "",
	severity_text: String = "INFO",
	extra_attributes: Dictionary = {}
) -> Dictionary:
	var resolved_integrity := semantic_integrity
	var resolved_failure := failure_reason

	if not validate_reconciliation(before, after, delta):
		resolved_integrity = "fail"
		resolved_failure = _append_failure(resolved_failure, "state_reconciliation_failed")

	if has_negative_numbers(after):
		resolved_integrity = "fail"
		resolved_failure = _append_failure(resolved_failure, "negative_state_detected")

	if not idempotency_key.is_empty():
		if _seen_idempotency_keys.has(idempotency_key):
			resolved_integrity = "fail"
			resolved_failure = _append_failure(resolved_failure, "duplicate_idempotency_key")
		else:
			_seen_idempotency_keys[idempotency_key] = true

	var attributes := {
		"event_name": event_name,
		"operation_id": operation_id,
		"idempotency_key": idempotency_key,
		"entity.type": entity_type,
		"entity.id": entity_id,
		"policy": policy,
		"result": result,
		"state.before": before,
		"state.after": after,
		"delta": delta,
		"semantic_integrity": resolved_integrity,
		"failure_reason": resolved_failure,
	}

	for key in extra_attributes.keys():
		attributes[key] = extra_attributes[key]

	_sequence_number += 1
	attributes["sequence_number"] = _sequence_number
	attributes["previous_integrity_hash"] = _previous_integrity_hash

	var event := {
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"severity_text": severity_text,
		"body": "named_domain_event",
		"attributes": attributes,
	}
	attributes["integrity_hash"] = _make_integrity_hash(event)
	_previous_integrity_hash = attributes["integrity_hash"]

	var schema_errors := validate_event_schema(event)
	if not schema_errors.is_empty():
		event["severity_text"] = "ERROR"
		event["attributes"]["semantic_integrity"] = "fail"
		event["attributes"]["failure_reason"] = _append_failure(
			str(event["attributes"]["failure_reason"]),
			"schema_validation_failed:%s" % ",".join(schema_errors)
		)

	print(JSON.stringify(event))
	return event


static func validate_event_schema(event: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	for key in ["timestamp", "severity_text", "body", "attributes"]:
		if not event.has(key):
			errors.append("missing_%s" % key)

	if not (event.get("attributes") is Dictionary):
		errors.append("attributes_not_dictionary")
		return errors

	var attributes: Dictionary = event["attributes"]
	for key in [
		"event_name",
		"operation_id",
		"idempotency_key",
		"entity.type",
		"entity.id",
		"policy",
		"result",
		"state.before",
		"state.after",
		"delta",
		"semantic_integrity",
		"failure_reason",
	]:
		if not attributes.has(key):
			errors.append("missing_attribute_%s" % key)

	if not (attributes.get("state.before") is Dictionary):
		errors.append("state_before_not_dictionary")
	if not (attributes.get("state.after") is Dictionary):
		errors.append("state_after_not_dictionary")
	if not (attributes.get("delta") is Dictionary):
		errors.append("delta_not_dictionary")

	return errors


static func _merged_keys(left: Dictionary, right: Dictionary) -> Array:
	# O(N) via Dictionary como conjunto. Evita Array.has() O(N) no loop interno.
	var seen: Dictionary = {}
	var keys: Array = []

	for key in left.keys():
		if not seen.has(key):
			seen[key] = true
			keys.append(key)

	for key in right.keys():
		if not seen.has(key):
			seen[key] = true
			keys.append(key)

	return keys


static func _is_number(value) -> bool:
	return value is int or value is float


static func _number_or_zero(value):
	if _is_number(value):
		return value

	return 0


static func _append_failure(current: String, next_reason: String) -> String:
	if current.is_empty():
		return next_reason

	return "%s;%s" % [current, next_reason]


## Serialização canônica determinística de qualquer valor suportado nos eventos.
## Dictionary: chaves ordenadas alfabeticamente antes de serializar.
## Array: ordem preservada.
## Primitivos: representação estável via JSON.stringify.
## Objetivo: garantir que dois estados logicamente iguais com ordens de chave
## diferentes produzam exatamente a mesma string — e portanto o mesmo hash.
## Serializa value de forma canônica e determinística com limite de profundidade.
## Parâmetro _depth é interno; chamadores externos devem omiti-lo.
static func canonicalize(value, _depth: int = 0) -> String:
	if _depth >= _MAX_CANONICALIZE_DEPTH:
		push_warning("[DomainEventLogger] canonicalize: limite de profundidade %d atingido." % _MAX_CANONICALIZE_DEPTH)
		return '"[MAX_DEPTH]"'

	if value == null:
		return "null"
	elif value is bool:
		return "true" if value else "false"
	elif value is int or value is float:
		return str(value)
	elif value is String or value is StringName:
		return JSON.stringify(str(value))
	elif value is Dictionary:
		var sorted_keys: Array = value.keys()
		sorted_keys.sort()
		var parts: Array[String] = []
		for key in sorted_keys:
			parts.append(JSON.stringify(str(key)) + ":" + canonicalize(value[key], _depth + 1))
		return "{" + ",".join(parts) + "}"
	elif value is Array:
		var parts: Array[String] = []
		for item in value:
			parts.append(canonicalize(item, _depth + 1))
		return "[" + ",".join(parts) + "]"
	else:
		return JSON.stringify(value)


static func _make_integrity_hash(event: Dictionary) -> String:
	# Marcador leve de integridade de evento via SHA-256 sobre representação canônica.
	# Não é boundary de segurança nem anti-cheat. Objetivo: rastreabilidade e diagnóstico.
	var canonical := canonicalize(event)
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(canonical.to_utf8_buffer())
	return ctx.finish().hex_encode()
