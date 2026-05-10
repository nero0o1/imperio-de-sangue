class_name WarehousePanel
extends PanelContainer

@export var title: String = "Armazem"

var _warehouse: Warehouse
var _filter_text := ""
var _title_label: Label
var _status_label: Label
var _items_label: Label


func _ready() -> void:
	_ensure_layout()
	refresh()


func set_warehouse(warehouse: Warehouse) -> void:
	_warehouse = warehouse
	refresh()


func set_filter_text(filter_text: String) -> void:
	_filter_text = filter_text.strip_edges().to_lower()
	refresh()


func refresh() -> void:
	_ensure_layout()
	_title_label.text = title

	if _warehouse == null:
		_status_label.text = "Warehouse: aguardando construcao"
		_items_label.text = "(nenhum armazem conectado)"
		return

	var items := _warehouse.get_stock_snapshot()
	var item_lines := _format_items(items)
	_status_label.text = "Estoque compartilhado"
	_items_label.text = "vazio" if item_lines.is_empty() else _join_lines(item_lines)


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

	_status_label = Label.new()
	_status_label.name = "Status"
	root.add_child(_status_label)

	_items_label = Label.new()
	_items_label.name = "Items"
	_items_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_items_label)


func _format_items(items: Dictionary) -> Array[String]:
	var keys := items.keys()
	keys.sort_custom(func(a, b): return String(a) < String(b))

	var lines: Array[String] = []
	for item_id in keys:
		var item_name := String(item_id)
		if not _matches_filter(item_name):
			continue

		lines.append("%-12s | %-9s | qtd %03d | peso - | valor - | comum" % [
			item_name,
			_category_for(item_name),
			int(items[item_id]),
		])

	return lines


func _matches_filter(item_name: String) -> bool:
	return _filter_text.is_empty() or item_name.to_lower().contains(_filter_text)


func _category_for(item_name: String) -> String:
	match item_name:
		"wood", "stone":
			return "recurso"
		_:
			return "item"


func _join_lines(lines: Array[String]) -> String:
	var result := ""
	for line in lines:
		if not result.is_empty():
			result += "\n"
		result += line
	return result
