class_name NPCCreationMenu
extends PanelContainer

signal create_civil_requested(source: NPCHouse, actor: Node)
signal close_requested(source: NPCHouse)

var current_house: NPCHouse = null
var current_actor: Node = null
var _previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var _has_saved_mouse_mode := false

@onready var _title_label: Label = $MarginContainer/Root/Header/TitleLabel
@onready var _status_label: Label = $MarginContainer/Root/Header/StatusLabel
@onready var _create_button: Button = $MarginContainer/Root/Buttons/CreateCivilButton
@onready var _close_button: Button = $MarginContainer/Root/Buttons/CloseButton


func _ready() -> void:
	add_to_group("gameplay_input_blocker")
	visible = false
	_connect_buttons()


func _process(_delta: float) -> void:
	if not visible:
		return
	if not _has_valid_current_house():
		close_menu()
		return

	_refresh_labels()


func open_for_house(target_house: NPCHouse, actor: Node = null) -> void:
	if target_house == null or not is_instance_valid(target_house):
		close_menu()
		return

	var was_open_for_same_house := visible and current_house == target_house
	if not visible:
		_previous_mouse_mode = Input.get_mouse_mode()
		_has_saved_mouse_mode = true

	current_house = target_house
	current_actor = actor
	_refresh_labels()
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not was_open_for_same_house:
		print("[NPC] Menu de criacao aberto para %s." % current_house.house_name)


func close_menu(restore_mouse_mode: bool = true) -> void:
	if visible and _has_valid_current_house():
		print("[NPC] Menu de criacao fechado para %s." % current_house.house_name)
	var closed_house := current_house
	visible = false
	current_house = null
	current_actor = null
	if restore_mouse_mode and _has_saved_mouse_mode and not _has_other_open_input_blocker():
		Input.set_mouse_mode(_previous_mouse_mode)
		_has_saved_mouse_mode = false
	elif restore_mouse_mode and _has_saved_mouse_mode and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		_has_saved_mouse_mode = false
	if closed_house != null and is_instance_valid(closed_house):
		close_requested.emit(closed_house)


func is_creation_menu_open() -> bool:
	return visible


func is_inventory_ui_open() -> bool:
	return is_creation_menu_open()


func _connect_buttons() -> void:
	if not _create_button.pressed.is_connected(_on_create_pressed):
		_create_button.pressed.connect(_on_create_pressed)
	if not _close_button.pressed.is_connected(_on_close_pressed):
		_close_button.pressed.connect(_on_close_pressed)


func _refresh_labels() -> void:
	if not _has_valid_current_house():
		return

	_title_label.text = current_house.house_name
	_status_label.text = current_house.get_creation_status()
	_create_button.disabled = not current_house.can_create_npc()


func _has_valid_current_house() -> bool:
	return current_house != null and is_instance_valid(current_house)


func _has_other_open_input_blocker() -> bool:
	for blocker in get_tree().get_nodes_in_group("gameplay_input_blocker"):
		if blocker == self:
			continue
		if blocker.has_method("is_inventory_ui_open") and blocker.is_inventory_ui_open():
			return true
	return false


func _on_create_pressed() -> void:
	if not _has_valid_current_house():
		return
	if not current_house.can_create_npc():
		print("[NPC] Menu de criacao: limite atingido para %s." % current_house.house_name)
		_refresh_labels()
		return

	create_civil_requested.emit(current_house, current_actor)
	_refresh_labels()


func _on_close_pressed() -> void:
	close_menu()
