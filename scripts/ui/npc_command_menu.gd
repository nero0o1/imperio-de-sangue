## NPCCommandMenu — Wave 4.5.1
## Menu completo de ordens semânticas com painel de debug integrado.
## Ordens com execução real, PARTIAL e UNSUPPORTED estão todas expostas.
class_name NPCCommandMenu
extends PanelContainer

# ─── Sinais (compatibilidade com scene controller) ─────────────────────────
signal move_requested(npc: NPCBase)
signal patrol_requested(npc: NPCBase)
signal follow_player_requested(npc: NPCBase)
signal stop_requested(npc: NPCBase)
signal deselect_requested(npc: NPCBase)

# ─── Estado ────────────────────────────────────────────────────────────────
var current_npc: NPCBase = null
var queue_mode: bool = false  # true = próxima ordem é enfileirada

var _previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var _has_saved_mouse_mode := false

# ─── Referências UI (criadas em _build_ui) ─────────────────────────────────
var _name_label: Label = null
var _state_label: Label = null
var _queue_toggle: CheckButton = null
var _debug_order_label: Label = null
var _debug_queue_label: Label = null
var _debug_tactical_label: Label = null
var _debug_reason_label: Label = null
var _debug_status_label: Label = null
var _debug_inv_label: Label = null

# Temporários para buscas recursivas (evita passar por referência em GDScript)
var _nearest_building_site: BuildingSite = null
var _nearest_dist_tmp: float = INF
var _nearest_pickup: Node3D = null
var _nearest_pickup_dist: float = INF
var _nearest_warehouse_interactable: Node3D = null
var _nearest_wi_dist: float = INF
var _nearest_garrison: Node3D = null
var _nearest_garrison_dist: float = INF


func _ready() -> void:
	add_to_group("gameplay_input_blocker")
	visible = false
	_build_ui()


func _process(_delta: float) -> void:
	if not visible:
		return
	if not _has_valid_current_npc():
		close_menu()
		return
	if not current_npc.selected:
		close_menu()
		return
	_refresh_header()
	_refresh_debug_panel()


# ─── API pública ───────────────────────────────────────────────────────────

func open_for_npc(npc: NPCBase) -> void:
	if npc == null or not is_instance_valid(npc):
		close_menu()
		return
	var was_open_for_same := visible and current_npc == npc
	if not visible:
		_previous_mouse_mode = Input.get_mouse_mode()
		_has_saved_mouse_mode = true
	current_npc = npc
	_refresh_header()
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not was_open_for_same:
		print("[NPC] Menu contextual aberto para %s." % current_npc.npc_name)


func close_menu(restore_mouse_mode: bool = true) -> void:
	if visible and _has_valid_current_npc():
		print("[NPC] Menu contextual fechado para %s." % current_npc.npc_name)
	visible = false
	current_npc = null
	if restore_mouse_mode and _has_saved_mouse_mode and not _has_other_open_input_blocker():
		Input.set_mouse_mode(_previous_mouse_mode)
		_has_saved_mouse_mode = false
	elif restore_mouse_mode and _has_saved_mouse_mode and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		_has_saved_mouse_mode = false


func is_command_menu_open() -> bool:
	return visible


func is_inventory_ui_open() -> bool:
	return is_command_menu_open()


# ─── Construção dinâmica da UI ─────────────────────────────────────────────

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	offset_left = 10.0
	offset_top = 10.0
	offset_right = 370.0
	offset_bottom = 700.0

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root := VBoxContainer.new()
	root.name = "Root"
	root.add_theme_constant_override("separation", 4)
	margin.add_child(root)

	# --- Cabeçalho ---
	var header := HBoxContainer.new()
	root.add_child(header)

	_name_label = Label.new()
	_name_label.text = "NPC"
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.add_theme_font_size_override("font_size", 16)
	header.add_child(_name_label)

	_state_label = Label.new()
	_state_label.text = "IDLE"
	header.add_child(_state_label)

	var close_btn := Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(_on_close_pressed)
	header.add_child(close_btn)

	root.add_child(HSeparator.new())

	# --- Fila ---
	var queue_row := HBoxContainer.new()
	root.add_child(queue_row)

	var queue_lbl := Label.new()
	queue_lbl.text = "Fila:"
	queue_row.add_child(queue_lbl)

	_queue_toggle = CheckButton.new()
	_queue_toggle.text = "OFF"
	_queue_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_queue_toggle.toggled.connect(_on_queue_toggled)
	queue_row.add_child(_queue_toggle)

	var clear_btn := Button.new()
	clear_btn.text = "Limpar Fila"
	clear_btn.pressed.connect(_on_clear_queue_pressed)
	queue_row.add_child(clear_btn)

	root.add_child(HSeparator.new())

	# --- Área de scroll com botões ---
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 240)
	root.add_child(scroll)

	var btn_box := VBoxContainer.new()
	btn_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_box.add_theme_constant_override("separation", 3)
	scroll.add_child(btn_box)

	_add_section(btn_box, "── MOVIMENTO ──")
	_add_button(btn_box, "Mover", _on_move_pressed)
	_add_button(btn_box, "Seguir voce", _on_follow_pressed)
	_add_button(btn_box, "Parar (STOP)", _on_stop_pressed)
	_add_button(btn_box, "Manter posicao", _on_hold_position_pressed)
	_add_button(btn_box, "Patrulhar", _on_patrol_pressed)

	_add_section(btn_box, "── CONSTRUCAO / ECONOMIA ──")
	_add_button(btn_box, "Ajudar construcao (ASSIST_BUILD)", _on_assist_build_pressed)
	_add_button(btn_box, "Coletar recurso (GATHER)", _on_gather_pressed)
	_add_button(btn_box, "Depositar / Force Drop", _on_force_drop_pressed)
	_add_button(btn_box, "Reparar [UNSUPPORTED]", _on_repair_pressed)

	_add_section(btn_box, "── POSTURAS / COMBATE ──")
	_add_button(btn_box, "Attack Move [PARTIAL]", _on_attack_move_pressed)
	_add_button(btn_box, "Fire at Will [PARTIAL]", _on_fire_at_will_pressed)
	_add_button(btn_box, "Hold Fire [PARTIAL]", _on_hold_fire_pressed)
	_add_button(btn_box, "Focus Fire [UNSUPPORTED]", _on_focus_fire_pressed)

	_add_section(btn_box, "── FORMACAO ──")
	_add_button(btn_box, "Shield Wall [PARTIAL]", _on_shield_wall_pressed)
	_add_button(btn_box, "Brace Pikes [PARTIAL]", _on_brace_pikes_pressed)

	_add_section(btn_box, "── ESTRUTURA / CERCO ──")
	_add_button(btn_box, "Garrison [PARTIAL/UNSUP]", _on_garrison_pressed)
	_add_button(btn_box, "Volley Fire [UNSUPPORTED]", _on_volley_fire_pressed)
	_add_button(btn_box, "Man Siege Ram [UNSUPPORTED]", _on_man_siege_ram_pressed)
	_add_button(btn_box, "Scale Walls [UNSUPPORTED]", _on_scale_walls_pressed)
	_add_button(btn_box, "Sap Foundation [UNSUPPORTED]", _on_sap_foundation_pressed)
	_add_button(btn_box, "Pour Murder Holes [UNSUPPORTED]", _on_pour_murder_holes_pressed)
	_add_button(btn_box, "Sally Out [UNSUPPORTED]", _on_sally_out_pressed)

	root.add_child(HSeparator.new())

	# --- Painel de debug ---
	var debug_box := VBoxContainer.new()
	debug_box.add_theme_constant_override("separation", 2)
	root.add_child(debug_box)

	var debug_title := Label.new()
	debug_title.text = "=== DEBUG DE ORDENS ==="
	debug_title.add_theme_font_size_override("font_size", 11)
	debug_box.add_child(debug_title)

	_debug_order_label   = _make_debug_label(debug_box, "Ordem: --")
	_debug_queue_label   = _make_debug_label(debug_box, "Fila: 0 pendentes | Modo: SUBSTITUIR")
	_debug_tactical_label = _make_debug_label(debug_box, "Tatico: idle | postura: --")
	_debug_status_label  = _make_debug_label(debug_box, "Ultimo status: --")
	_debug_reason_label  = _make_debug_label(debug_box, "Motivo: --")
	_debug_inv_label     = _make_debug_label(debug_box, "Inv NPC: vazio")

	root.add_child(HSeparator.new())

	var deselect_btn := Button.new()
	deselect_btn.text = "Dispensar NPC"
	deselect_btn.pressed.connect(_on_close_pressed)
	root.add_child(deselect_btn)


func _add_section(parent: Control, title: String) -> void:
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	parent.add_child(lbl)


func _add_button(parent: Control, label: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(callback)
	parent.add_child(btn)
	return btn


func _make_debug_label(parent: Control, initial_text: String) -> Label:
	var lbl := Label.new()
	lbl.text = initial_text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(lbl)
	return lbl


# ─── Refresh ───────────────────────────────────────────────────────────────

func _refresh_header() -> void:
	if not _has_valid_current_npc():
		return
	if _name_label != null:
		_name_label.text = current_npc.npc_name
	if _state_label != null:
		_state_label.text = NPCEnums.state_to_string(current_npc.current_state)


func _refresh_debug_panel() -> void:
	if not _has_valid_current_npc():
		return

	# Ordem atual
	if _debug_order_label != null:
		if current_npc.current_order != null:
			var ot := NPCEnums.order_type_to_string(current_npc.current_order.order_type)
			var st := NPCEnums.order_status_to_string(current_npc.current_order.status)
			_debug_order_label.text = "Ordem: %s [%s]" % [ot, st]
		else:
			_debug_order_label.text = "Ordem: nenhuma"

	# Fila
	if _debug_queue_label != null:
		var pending_count := 0
		if current_npc.order_queue != null:
			pending_count = current_npc.order_queue.pending_orders.size()
		_debug_queue_label.text = "Fila: %d pendente(s) | Modo: %s" % [
			pending_count,
			"ENFILEIRAR" if queue_mode else "SUBSTITUIR",
		]

	# Estado tático
	if _debug_tactical_label != null and current_npc.tactical_state != null:
		var postura := current_npc.tactical_state.posture
		_debug_tactical_label.text = "Tatico: %s | postura: %s" % [
			current_npc.tactical_state.state,
			postura if not postura.is_empty() else "--",
		]

	# Último status e motivo — olha a ordem atual ou a da fila
	var last_order: NPCOrder = current_npc.current_order
	if last_order == null and current_npc.order_queue != null:
		last_order = current_npc.order_queue.current_order
	if last_order != null:
		if _debug_status_label != null:
			_debug_status_label.text = "Ultimo status: %s" % NPCEnums.order_status_to_string(last_order.status)
		if _debug_reason_label != null:
			var reason := last_order.failure_reason
			_debug_reason_label.text = "Motivo: %s" % (reason if not reason.is_empty() else "--")
	elif current_npc.tactical_state != null and not current_npc.tactical_state.last_reason.is_empty():
		if _debug_reason_label != null:
			_debug_reason_label.text = "Motivo: %s" % current_npc.tactical_state.last_reason

	# Inventário do NPC
	if _debug_inv_label != null:
		if current_npc.has_method("get_inventory"):
			var inv := current_npc.get_inventory()
			if inv != null:
				var resources := inv.get_all_resources()
				if resources.is_empty():
					_debug_inv_label.text = "Inv NPC: vazio"
				else:
					var parts: Array[String] = []
					for k in resources.keys():
						parts.append("%s=%d" % [String(k), int(resources[k])])
					_debug_inv_label.text = "Inv NPC: %s" % ", ".join(parts)
			else:
				_debug_inv_label.text = "Inv NPC: null"
		else:
			_debug_inv_label.text = "Inv NPC: N/A"


# ─── Handlers de botões ────────────────────────────────────────────────────

func _on_move_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked MOVE_TO_POSITION" % current_npc.npc_name)
	move_requested.emit(current_npc)


func _on_follow_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked FOLLOW_PLAYER" % current_npc.npc_name)
	follow_player_requested.emit(current_npc)


func _on_stop_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked STOP" % current_npc.npc_name)
	stop_requested.emit(current_npc)


func _on_hold_position_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked HOLD_POSITION" % current_npc.npc_name)
	current_npc.issue_hold_position_order()


func _on_patrol_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked PATROL" % current_npc.npc_name)
	patrol_requested.emit(current_npc)


func _on_clear_queue_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked CLEAR_QUEUE" % current_npc.npc_name)
	current_npc.issue_order(NPCOrder.clear_queue(current_npc))


func _on_assist_build_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked ASSIST_BUILD" % current_npc.npc_name)
	var target := _find_nearest_building_site()
	if target == null:
		print("[Order] %s FAILED ASSIST_BUILD: no valid BuildingSite found in scene." % current_npc.npc_name)
		return
	print("[Order] %s ASSIST_BUILD -> target=%s" % [current_npc.npc_name, target.name])
	current_npc.issue_assist_build_order(target, queue_mode)


func _on_gather_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked GATHER_RESOURCE" % current_npc.npc_name)
	var target := _find_nearest_resource_pickup()
	if target == null:
		print("[Order] %s FAILED GATHER_RESOURCE: no valid ResourcePickup found in scene." % current_npc.npc_name)
		return
	print("[Order] %s GATHER_RESOURCE -> target=%s" % [current_npc.npc_name, target.name])
	var order := NPCOrder.make(NPCEnums.OrderType.GATHER_RESOURCE, Vector3.ZERO, target, current_npc, queue_mode)
	current_npc.issue_order(order)


func _on_force_drop_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked FORCE_DROP" % current_npc.npc_name)
	var target := _find_nearest_warehouse_interactable()
	if target == null:
		print("[Order] %s FAILED FORCE_DROP: no valid WarehouseInteractable found in scene." % current_npc.npc_name)
		return
	print("[Order] %s FORCE_DROP -> target=%s" % [current_npc.npc_name, target.name])
	var order := NPCOrder.make(NPCEnums.OrderType.FORCE_DROP, Vector3.ZERO, target, current_npc, queue_mode)
	current_npc.issue_order(order)


func _on_repair_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked REPAIR" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.REPAIR)


func _on_attack_move_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked ATTACK_MOVE" % current_npc.npc_name)
	var forward := -current_npc.global_transform.basis.z
	forward.y = 0.0
	if forward.length() > 0.001:
		forward = forward.normalized()
	else:
		forward = Vector3(1, 0, 0)
	var dest := current_npc.global_position + forward * 8.0
	var order := NPCOrder.make(NPCEnums.OrderType.ATTACK_MOVE, dest, null, current_npc, queue_mode)
	current_npc.issue_order(order)


func _on_fire_at_will_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked FIRE_AT_WILL" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.FIRE_AT_WILL)


func _on_hold_fire_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked HOLD_FIRE" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.HOLD_FIRE)


func _on_focus_fire_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked FOCUS_FIRE" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.FOCUS_FIRE)


func _on_shield_wall_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked FORM_SHIELD_WALL" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.FORM_SHIELD_WALL)


func _on_brace_pikes_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked BRACE_PIKES" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.BRACE_PIKES)


func _on_garrison_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked GARRISON" % current_npc.npc_name)
	var target := _find_nearest_garrison_target()
	var order: NPCOrder
	if target != null:
		order = NPCOrder.make(NPCEnums.OrderType.GARRISON, Vector3.ZERO, target, current_npc, queue_mode)
	else:
		# Sem alvo: UNSUPPORTED será retornado pelo executor
		order = NPCOrder.make(NPCEnums.OrderType.GARRISON, current_npc.global_position, null, current_npc, queue_mode)
	current_npc.issue_order(order)


func _on_volley_fire_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked VOLLEY_FIRE" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.VOLLEY_FIRE)


func _on_man_siege_ram_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked MAN_SIEGE_RAM" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.MAN_SIEGE_RAM)


func _on_scale_walls_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked SCALE_WALLS" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.SCALE_WALLS)


func _on_sap_foundation_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked SAP_FOUNDATION" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.SAP_FOUNDATION)


func _on_pour_murder_holes_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked POUR_MURDER_HOLES" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.POUR_MURDER_HOLES)


func _on_sally_out_pressed() -> void:
	if not _has_valid_current_npc():
		return
	print("[UIOrder] %s clicked SALLY_OUT" % current_npc.npc_name)
	current_npc.issue_test_order_by_type(NPCEnums.OrderType.SALLY_OUT)


func _on_queue_toggled(pressed: bool) -> void:
	queue_mode = pressed
	if _queue_toggle != null:
		_queue_toggle.text = "ON" if pressed else "OFF"
	print("[UIOrder] Modo de fila: %s" % ("ENFILEIRAR" if pressed else "SUBSTITUIR"))


func _on_close_pressed() -> void:
	var npc := current_npc
	if _has_valid_current_npc():
		deselect_requested.emit(npc)
	close_menu()


# ─── Busca de alvos na cena ────────────────────────────────────────────────

func _find_nearest_building_site() -> BuildingSite:
	if not _has_valid_current_npc():
		return null
	_nearest_building_site = null
	_nearest_dist_tmp = INF
	_search_building_sites(get_tree().current_scene, current_npc.global_position)
	return _nearest_building_site


func _search_building_sites(node: Node, from: Vector3) -> void:
	if node is BuildingSite:
		var bs := node as BuildingSite
		if not bs.is_completed:
			var d := bs.global_position.distance_to(from)
			if d < _nearest_dist_tmp:
				_nearest_building_site = bs
				_nearest_dist_tmp = d
	for child in node.get_children():
		_search_building_sites(child, from)


func _find_nearest_resource_pickup() -> Node3D:
	if not _has_valid_current_npc():
		return null
	_nearest_pickup = null
	_nearest_pickup_dist = INF
	_search_pickups(get_tree().current_scene, current_npc.global_position)
	return _nearest_pickup


func _search_pickups(node: Node, from: Vector3) -> void:
	if node is Node3D and _is_resource_pickup(node as Node3D):
		var d := (node as Node3D).global_position.distance_to(from)
		if d < _nearest_pickup_dist:
			_nearest_pickup = node as Node3D
			_nearest_pickup_dist = d
	for child in node.get_children():
		_search_pickups(child, from)


func _is_resource_pickup(node: Node3D) -> bool:
	return "resource_id" in node and "amount" in node and node.has_method("interact") and int(node.get("amount")) > 0


func _find_nearest_warehouse_interactable() -> Node3D:
	if not _has_valid_current_npc():
		return null
	_nearest_warehouse_interactable = null
	_nearest_wi_dist = INF
	_search_warehouse_interactables(get_tree().current_scene, current_npc.global_position)
	return _nearest_warehouse_interactable


func _search_warehouse_interactables(node: Node, from: Vector3) -> void:
	if node is Node3D and _is_warehouse_interactable(node as Node3D):
		var d := (node as Node3D).global_position.distance_to(from)
		if d < _nearest_wi_dist:
			_nearest_warehouse_interactable = node as Node3D
			_nearest_wi_dist = d
	for child in node.get_children():
		_search_warehouse_interactables(child, from)


func _is_warehouse_interactable(node: Node3D) -> bool:
	return "warehouse_path" in node and node.has_method("interact")


func _find_nearest_garrison_target() -> Node3D:
	if not _has_valid_current_npc():
		return null
	_nearest_garrison = null
	_nearest_garrison_dist = INF
	_search_garrison_targets(get_tree().current_scene, current_npc.global_position)
	return _nearest_garrison


func _search_garrison_targets(node: Node, from: Vector3) -> void:
	if node is Node3D:
		var n3d := node as Node3D
		if n3d.has_method("garrison") or n3d.has_method("add_garrisoned_unit") or ("supports_garrison" in n3d):
			var d := n3d.global_position.distance_to(from)
			if d < _nearest_garrison_dist:
				_nearest_garrison = n3d
				_nearest_garrison_dist = d
	for child in node.get_children():
		_search_garrison_targets(child, from)


# ─── Helpers ───────────────────────────────────────────────────────────────

func _has_valid_current_npc() -> bool:
	return current_npc != null and is_instance_valid(current_npc)


func _has_other_open_input_blocker() -> bool:
	for blocker in get_tree().get_nodes_in_group("gameplay_input_blocker"):
		if blocker == self:
			continue
		if blocker.has_method("is_inventory_ui_open") and blocker.is_inventory_ui_open():
			return true
	return false
