class_name BuildingStatusPanel
extends PanelContainer

@export var title: String = "Construcao"

var _building_site: BuildingSite
var _title_label: Label
var _id_label: Label
var _progress_label: Label
var _completed_label: Label
var _costs_label: Label
var _status_label: Label


func _ready() -> void:
	_ensure_layout()
	refresh()


func set_building_site(building_site: BuildingSite) -> void:
	_building_site = building_site
	refresh()


func refresh() -> void:
	_ensure_layout()
	_title_label.text = title

	if _building_site == null:
		_id_label.text = "Building: nenhum alvo selecionado"
		_progress_label.text = "(posicione uma construcao para monitorar)"
		_completed_label.text = ""
		_costs_label.text = ""
		_status_label.text = ""
		return

	_id_label.text = "ID: %s" % String(_building_site.building_id)
	_progress_label.text = "Progresso: %s %.1f%%" % [
		_progress_bar(_building_site.build_progress),
		_building_site.build_progress,
	]
	_completed_label.text = "Concluida: %s" % str(_building_site.is_completed)
	_costs_label.text = "Requer: %s | etapa: %s" % [
		_format_costs(_building_site.required_resources),
		_format_costs(_building_site.get_step_cost()),
	]
	_status_label.text = "Status: %s" % _status_text()


func _ensure_layout() -> void:
	if _title_label != null:
		return

	add_theme_constant_override("content_margin_left", 10)
	add_theme_constant_override("content_margin_top", 8)
	add_theme_constant_override("content_margin_right", 10)
	add_theme_constant_override("content_margin_bottom", 8)

	var root := VBoxContainer.new()
	root.name = "Content"
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.add_theme_font_size_override("font_size", 15)
	root.add_child(_title_label)

	_id_label = Label.new()
	_id_label.name = "BuildingId"
	root.add_child(_id_label)

	_progress_label = Label.new()
	_progress_label.name = "Progress"
	root.add_child(_progress_label)

	_completed_label = Label.new()
	_completed_label.name = "Completed"
	root.add_child(_completed_label)

	_costs_label = Label.new()
	_costs_label.name = "RequiredCosts"
	root.add_child(_costs_label)

	_status_label = Label.new()
	_status_label.name = "Status"
	root.add_child(_status_label)


func _status_text() -> String:
	if _building_site == null:
		return "nao configurado"
	if _building_site.is_completed:
		return "concluida"
	if _building_site.build_progress > 0.0 and _building_site.build_progress < 100.0:
		return "em construcao"
	return "aguardando recurso"


func _format_costs(costs: Dictionary) -> String:
	if costs.is_empty():
		return "sem custo"

	var keys := costs.keys()
	keys.sort_custom(func(a, b): return String(a) < String(b))

	var parts: Array[String] = []
	for item_id in keys:
		parts.append("%s x%d" % [String(item_id), int(costs[item_id])])

	return _join_parts(parts)


func _progress_bar(value: float) -> String:
	var clamped_value := clampf(value, 0.0, 100.0)
	var filled := int(round(clamped_value / 10.0))
	var result := "["
	for index in range(10):
		result += "#" if index < filled else "."
	result += "]"
	return result


func _join_parts(parts: Array[String]) -> String:
	var result := ""
	for part in parts:
		if not result.is_empty():
			result += ", "
		result += part
	return result
