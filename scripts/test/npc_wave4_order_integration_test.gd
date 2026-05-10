## Wave 4.5.1 — Cena de Integração de Ordens
## Controla a cena NPCWave4OrderIntegrationTest.tscn.
## NPCs pré-colocados, armazém pré-populado, BuildingSites configurados.
## Suporta: menu contextual completo, comandos debug opcionais por teclado.
extends Node3D

@export var player_path: NodePath = NodePath("Player")
@export var command_menu_path: NodePath = NodePath("NPCCommandMenuLayer/NPCCommandMenu")
@export var creation_menu_path: NodePath = NodePath("NPCCreationMenuLayer/NPCCreationMenu")
@export var warehouse_path: NodePath = NodePath("Warehouse")
@export var move_distance: float = 6.0
@export var patrol_radius: float = 8.0
@export var debug_keyboard_commands_enabled: bool = false

## Recursos iniciais pré-carregados no armazém.
@export var initial_wood: int = 200
@export var initial_stone: int = 100

var _selected_npc: NPCBase = null

@onready var _player: Node3D = get_node_or_null(player_path) as Node3D
@onready var _command_menu: NPCCommandMenu = get_node_or_null(command_menu_path) as NPCCommandMenu
@onready var _creation_menu: NPCCreationMenu = get_node_or_null(creation_menu_path) as NPCCreationMenu
@onready var _warehouse = get_node_or_null(warehouse_path)


func _ready() -> void:
	_prepopulate_warehouse()
	_connect_npc_signals()
	_connect_house_signals()
	_connect_command_menu()
	_connect_creation_menu()
	var debug_status := "ativadas" if debug_keyboard_commands_enabled else "desativadas"
	print("[OrderTest] Cena Wave 4.5.1 pronta. Armazem: %d wood, %d stone. Teclas debug: %s." % [
		initial_wood, initial_stone, debug_status
	])


# ─── Teclado debug ──────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not debug_keyboard_commands_enabled:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				_select_npc_by_index(0)
			KEY_2:
				_select_npc_by_index(1)
			KEY_3:
				_select_npc_by_index(2)
			KEY_M:
				_order_move_forward()
			KEY_P:
				_order_patrol_forward()
			KEY_F:
				_order_follow_player()
			KEY_X:
				_order_stop()
			KEY_C:
				_deselect_current()


# ─── Armazém ────────────────────────────────────────────────────────────────

func _prepopulate_warehouse() -> void:
	if _warehouse == null or not _warehouse.has_method("add_resource"):
		print("[OrderTest] Armazem nao encontrado — recursos iniciais nao carregados.")
		return
	if initial_wood > 0:
		_warehouse.add_resource("wood", initial_wood)
	if initial_stone > 0:
		_warehouse.add_resource("stone", initial_stone)
	print("[OrderTest] Armazem populado: wood=%d, stone=%d." % [initial_wood, initial_stone])


# ─── Seleção de NPC ──────────────────────────────────────────────────────────

func _select_npc_by_index(index: int) -> void:
	var npcs := _get_npcs()
	if index < 0 or index >= npcs.size():
		print("[OrderTest] Indice de NPC invalido: %d." % index)
		return
	_select_npc(npcs[index])


func _select_npc(npc: NPCBase) -> void:
	if not _is_valid_npc(npc):
		print("[OrderTest] Tentativa de selecionar NPC invalido.")
		return

	if _is_valid_npc(_selected_npc) and _selected_npc != npc:
		_selected_npc.deselect()

	_selected_npc = npc
	_selected_npc.select()
	_open_command_menu_for_selected()
	print("[OrderTest] Selecionado: %s." % _selected_npc.npc_name)


func _deselect_current() -> void:
	if not _is_valid_npc(_selected_npc):
		_selected_npc = null
		if _command_menu != null:
			_command_menu.close_menu()
		return

	_selected_npc.deselect()
	_selected_npc = null
	if _command_menu != null:
		_command_menu.close_menu()
	print("[OrderTest] Selecao limpa.")


# ─── Ordens ─────────────────────────────────────────────────────────────────

func _order_move_forward() -> void:
	if not _has_selected_npc():
		return

	var ref_basis := _player.global_transform.basis if _player != null else global_transform.basis
	var origin := _selected_npc.global_position
	var forward := -ref_basis.z
	forward.y = 0.0
	if forward.length() <= 0.001:
		print("[OrderTest] Direcao invalida para MOVE.")
		return
	forward = forward.normalized()
	_selected_npc.issue_order(NPCOrder.move_to_position(origin + forward * move_distance, _player))


func _order_patrol_forward() -> void:
	if not _has_selected_npc():
		return

	var ref_basis := _player.global_transform.basis if _player != null else global_transform.basis
	var origin := _selected_npc.global_position
	var forward := -ref_basis.z
	forward.y = 0.0
	if forward.length() <= 0.001:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	# Ponto de patrulha: frente do NPC pelo raio configurado.
	var dest := origin + forward * patrol_radius
	_selected_npc.issue_order(NPCOrder.make(NPCEnums.OrderType.PATROL, dest, null, _player))
	print("[OrderTest] Patrulha emitida para %s -> %s." % [_selected_npc.npc_name, str(dest)])


func _order_follow_player() -> void:
	if not _has_selected_npc():
		return
	if _player == null:
		print("[OrderTest] Jogador nao encontrado para FOLLOW.")
		return
	_selected_npc.issue_order(NPCOrder.follow_player(_player, _player))


func _order_stop() -> void:
	if not _has_selected_npc():
		return
	_selected_npc.issue_order(NPCOrder.stop(_player))


# ─── Auxiliares de seleção ───────────────────────────────────────────────────

func _has_selected_npc() -> bool:
	_sync_selected_npc_from_scene()
	if _is_valid_npc(_selected_npc):
		return true
	print("[OrderTest] Nenhum NPC selecionado.")
	return false


func _sync_selected_npc_from_scene() -> void:
	if _is_valid_npc(_selected_npc) and _selected_npc.selected:
		return

	for npc in _get_npcs():
		if npc.selected:
			_selected_npc = npc
			_open_command_menu_for_selected()
			return

	_selected_npc = null
	if _command_menu != null:
		_command_menu.close_menu()


func _is_valid_npc(npc: NPCBase) -> bool:
	return npc != null and is_instance_valid(npc)


func _get_npcs() -> Array[NPCBase]:
	var result: Array[NPCBase] = []
	for node in get_tree().get_nodes_in_group("npc"):
		if node is NPCBase:
			result.append(node)
	return result


func _get_houses() -> Array[NPCHouse]:
	var result: Array[NPCHouse] = []
	for node in get_tree().get_nodes_in_group("npc_house"):
		if node is NPCHouse:
			result.append(node)
	return result


# ─── Conexão de sinais ───────────────────────────────────────────────────────

func _connect_npc_signals() -> void:
	for npc in _get_npcs():
		_connect_npc_signal(npc)


func _connect_npc_signal(npc: NPCBase) -> void:
	if npc == null or not is_instance_valid(npc):
		return
	if not npc.selection_changed.is_connected(_on_npc_selection_changed):
		npc.selection_changed.connect(_on_npc_selection_changed)


func _connect_house_signals() -> void:
	for npc_house in _get_houses():
		if not npc_house.creation_requested.is_connected(_on_house_creation_requested):
			npc_house.creation_requested.connect(_on_house_creation_requested)
		if not npc_house.npc_created.is_connected(_on_house_npc_created):
			npc_house.npc_created.connect(_on_house_npc_created)


func _connect_command_menu() -> void:
	if _command_menu == null:
		print("[OrderTest] Menu de comandos nao encontrado.")
		return

	if not _command_menu.move_requested.is_connected(_on_menu_move_requested):
		_command_menu.move_requested.connect(_on_menu_move_requested)
	if not _command_menu.patrol_requested.is_connected(_on_menu_patrol_requested):
		_command_menu.patrol_requested.connect(_on_menu_patrol_requested)
	if not _command_menu.follow_player_requested.is_connected(_on_menu_follow_requested):
		_command_menu.follow_player_requested.connect(_on_menu_follow_requested)
	if not _command_menu.stop_requested.is_connected(_on_menu_stop_requested):
		_command_menu.stop_requested.connect(_on_menu_stop_requested)
	if not _command_menu.deselect_requested.is_connected(_on_menu_deselect_requested):
		_command_menu.deselect_requested.connect(_on_menu_deselect_requested)


func _connect_creation_menu() -> void:
	if _creation_menu == null:
		print("[OrderTest] Menu de criacao nao encontrado.")
		return
	if not _creation_menu.create_civil_requested.is_connected(_on_creation_menu_create_requested):
		_creation_menu.create_civil_requested.connect(_on_creation_menu_create_requested)


func _open_command_menu_for_selected() -> void:
	if _command_menu != null and _is_valid_npc(_selected_npc):
		_command_menu.open_for_npc(_selected_npc)


# ─── Handlers de eventos ─────────────────────────────────────────────────────

func _on_npc_selection_changed(npc: NPCBase, is_selected: bool) -> void:
	if not _is_valid_npc(npc):
		return

	if is_selected:
		_selected_npc = npc
		if _creation_menu != null:
			_creation_menu.close_menu()
		_open_command_menu_for_selected()
	elif _selected_npc == npc:
		_selected_npc = null
		if _command_menu != null:
			_command_menu.close_menu()


func _on_house_creation_requested(source: NPCHouse, actor: Node) -> void:
	if source == null or not is_instance_valid(source):
		return
	_deselect_current()
	if _creation_menu != null:
		_creation_menu.open_for_house(source, actor)


func _on_house_npc_created(npc: NPCBase) -> void:
	_connect_npc_signal(npc)
	if npc != null and is_instance_valid(npc):
		print("[OrderTest] Civil criado conectado ao menu: %s." % npc.npc_name)


func _on_creation_menu_create_requested(source: NPCHouse, actor: Node) -> void:
	if source == null or not is_instance_valid(source):
		return
	var npc := source.create_npc(actor)
	if npc == null:
		return
	_connect_npc_signal(npc)
	if _creation_menu != null:
		_creation_menu.close_menu()
	_select_npc(npc)


func _on_menu_move_requested(npc: NPCBase) -> void:
	if not _is_valid_npc(npc):
		return
	_selected_npc = npc
	_order_move_forward()


func _on_menu_patrol_requested(npc: NPCBase) -> void:
	if not _is_valid_npc(npc):
		return
	_selected_npc = npc
	_order_patrol_forward()


func _on_menu_follow_requested(npc: NPCBase) -> void:
	if not _is_valid_npc(npc):
		return
	_selected_npc = npc
	_order_follow_player()


func _on_menu_stop_requested(npc: NPCBase) -> void:
	if not _is_valid_npc(npc):
		return
	_selected_npc = npc
	_order_stop()


func _on_menu_deselect_requested(npc: NPCBase) -> void:
	if _selected_npc == null:
		_selected_npc = npc
	_deselect_current()
