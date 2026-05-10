class_name GameHUD
extends Control

@export var player_inventory_path: NodePath
@export var warehouse_path: NodePath
@export var building_site_path: NodePath
@export var update_interval: float = 0.25

## Estado inicial: false = fechada ao iniciar (comportamento de jogo padrao).
## Pode ser definido como true temporariamente na cena-laboratorio para debug.
@export var start_open: bool = false

var _elapsed := 0.0
var _search_box: LineEdit
var _player_inventory_panel: PlayerInventoryPanel
var _warehouse_panel: WarehousePanel
var _building_status_panel: BuildingStatusPanel

# Cache dos nos de dominio. Evita get_node_or_null() repetido a cada refresh (0.25s).
# Populado em _cache_nodes() com guard is_instance_valid().
var _cached_player_inventory: InventoryContainer = null
var _cached_warehouse: Warehouse = null
var _cached_building_site: BuildingSite = null


func _ready() -> void:
	_cache_nodes()
	# Conecta o botao Fechar, se existir na cena.
	var close_btn := get_node_or_null(
		"MarginContainer/Frame/Root/HeaderRow/CloseButton"
	) as Button
	if close_btn != null and not close_btn.pressed.is_connected(close_inventory_ui):
		close_btn.pressed.connect(close_inventory_ui)
	# Estado inicial controlado pelo export.
	visible = start_open
	if start_open:
		# Se abre no inicio, sincroniza o modo do mouse.
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	refresh_all()


func _process(delta: float) -> void:
	# So atualiza dados quando a HUD esta visivel.
	if not visible:
		return

	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_elapsed += delta
	if _elapsed < update_interval:
		return

	_elapsed = 0.0
	refresh_all()


func _unhandled_input(event: InputEvent) -> void:
	# Captura inventory_toggle apenas no press, sem eco.
	# Usa _unhandled_input para nao roubar teclas enquanto SearchBox esta focado.
	if event.is_action_pressed("inventory_toggle") and not event.is_echo():
		toggle_inventory_ui()
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------------------
# API publica de toggle
# ---------------------------------------------------------------------------

func open_inventory_ui() -> void:
	visible = true
	refresh_all()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Foco opcional no SearchBox para permitir busca imediata.
	if _search_box != null:
		_search_box.grab_focus()


func close_inventory_ui() -> void:
	# Libera foco de qualquer controle de UI antes de esconder.
	if _search_box != null and _search_box.has_focus():
		_search_box.release_focus()
	visible = false
	# Restaura modo de captura do mouse do Player FPS.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func toggle_inventory_ui() -> void:
	if visible:
		close_inventory_ui()
	else:
		open_inventory_ui()


func is_inventory_ui_open() -> bool:
	return visible


# ---------------------------------------------------------------------------
# Logica interna de refresh (somente leitura — nenhuma mutacao de dominio)
# ---------------------------------------------------------------------------

func refresh_all() -> void:
	_cache_nodes()

	var filter_text := _search_box.text if _search_box != null else ""

	if _player_inventory_panel != null:
		_player_inventory_panel.set_inventory(_get_player_inventory())
		_player_inventory_panel.set_filter_text(filter_text)

	if _warehouse_panel != null:
		_warehouse_panel.set_warehouse(_get_warehouse())
		_warehouse_panel.set_filter_text(filter_text)

	if _building_status_panel != null:
		_building_status_panel.set_building_site(_get_building_site())


func _cache_nodes() -> void:
	# UI nodes: lazy, chamado no _ready e opcionalmente no refresh_all.
	if _search_box == null:
		_search_box = get_node_or_null("MarginContainer/Frame/Root/SearchBox") as LineEdit

	if _player_inventory_panel == null:
		_player_inventory_panel = get_node_or_null(
			"MarginContainer/Frame/Root/Panels/PlayerInventoryPanel"
		) as PlayerInventoryPanel

	if _warehouse_panel == null:
		_warehouse_panel = get_node_or_null(
			"MarginContainer/Frame/Root/Panels/WarehousePanel"
		) as WarehousePanel

	if _building_status_panel == null:
		_building_status_panel = get_node_or_null(
			"MarginContainer/Frame/Root/Panels/BuildingStatusPanel"
		) as BuildingStatusPanel

	# Nos de dominio: cached com guard is_instance_valid() para tolerar queue_free().
	# Evita get_node_or_null() a cada refresh (0.25s).
	if _cached_player_inventory == null or not is_instance_valid(_cached_player_inventory):
		if not player_inventory_path.is_empty():
			var node := get_node_or_null(player_inventory_path)
			if node is InventoryContainer:
				_cached_player_inventory = node

	if _cached_warehouse == null or not is_instance_valid(_cached_warehouse):
		if not warehouse_path.is_empty():
			var node := get_node_or_null(warehouse_path)
			if node is Warehouse:
				_cached_warehouse = node

	if _cached_building_site == null or not is_instance_valid(_cached_building_site):
		if not building_site_path.is_empty():
			var node := get_node_or_null(building_site_path)
			if node is BuildingSite:
				_cached_building_site = node


func _get_player_inventory() -> InventoryContainer:
	return _cached_player_inventory


func _get_warehouse() -> Warehouse:
	return _cached_warehouse


func _get_building_site() -> BuildingSite:
	return _cached_building_site
