class_name BuildMenu
extends PanelContainer

signal build_selected(building_id: StringName)
signal close_requested()

var _previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var _has_saved_mouse_mode := false

@onready var _warehouse_button: Button = $MarginContainer/Root/Buttons/WarehouseButton
@onready var _civil_house_button: Button = $MarginContainer/Root/Buttons/CivilHouseButton
@onready var _close_button: Button = $MarginContainer/Root/Buttons/CloseButton


func _ready() -> void:
	add_to_group("gameplay_input_blocker")
	visible = false
	_connect_buttons()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func open_menu() -> void:
	if not visible:
		_previous_mouse_mode = Input.get_mouse_mode()
		_has_saved_mouse_mode = true

	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_warehouse_button.grab_focus()
	print("[BUILD] Menu de construcao aberto.")


func close_menu(restore_mouse_mode: bool = true) -> void:
	if visible:
		print("[BUILD] Menu de construcao fechado.")

	visible = false
	if restore_mouse_mode and _has_saved_mouse_mode and not _has_other_open_input_blocker():
		Input.set_mouse_mode(_previous_mouse_mode)
		_has_saved_mouse_mode = false
	elif restore_mouse_mode and _has_saved_mouse_mode and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		_has_saved_mouse_mode = false

	close_requested.emit()


func is_inventory_ui_open() -> bool:
	return visible


func _connect_buttons() -> void:
	if not _warehouse_button.pressed.is_connected(_on_warehouse_pressed):
		_warehouse_button.pressed.connect(_on_warehouse_pressed)
	if not _civil_house_button.pressed.is_connected(_on_civil_house_pressed):
		_civil_house_button.pressed.connect(_on_civil_house_pressed)
	if not _close_button.pressed.is_connected(_on_close_pressed):
		_close_button.pressed.connect(_on_close_pressed)


func _has_other_open_input_blocker() -> bool:
	for blocker in get_tree().get_nodes_in_group("gameplay_input_blocker"):
		if blocker == self:
			continue
		if blocker.has_method("is_inventory_ui_open") and blocker.is_inventory_ui_open():
			return true
	return false


func _on_warehouse_pressed() -> void:
	close_menu()
	build_selected.emit(&"warehouse")


func _on_civil_house_pressed() -> void:
	close_menu()
	build_selected.emit(&"civil_house")


func _on_close_pressed() -> void:
	close_menu()
