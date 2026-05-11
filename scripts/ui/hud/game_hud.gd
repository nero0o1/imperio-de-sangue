class_name GameHUD
extends Control

@export var player_inventory_path: NodePath
@export var warehouse_path: NodePath
@export var building_site_path: NodePath
@export var build_controller_path: NodePath
@export var population_manager_path: NodePath
@export var update_interval: float = 0.25

## Estado inicial: false = fechada ao iniciar (comportamento de jogo padrao).
## Pode ser definido como true temporariamente na cena-laboratorio para debug.
@export var start_open: bool = false

var _elapsed := 0.0
var _search_box: LineEdit
var _population_label: Label
var _player_inventory_panel: PlayerInventoryPanel
var _warehouse_panel: WarehousePanel
var _building_status_panel: BuildingStatusPanel

# Cache dos nos de dominio. Evita get_node_or_null() repetido a cada refresh (0.25s).
# Populado em _cache_nodes() com guard is_instance_valid().
var _cached_player_inventory: InventoryContainer = null
var _cached_warehouse: Warehouse = null
var _cached_building_site: BuildingSite = null
var _cached_build_controller: BuildPlacementController = null
var _cached_population_manager: Node = null
var _logged_missing_player_inventory := false
var _logged_missing_warehouse := false
var _logged_missing_build_controller := false
var _logged_missing_building_site := false
var _logged_missing_population_manager := false


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

	if _population_label != null:
		_population_label.text = _get_population_status_text()


func _cache_nodes() -> void:
	# UI nodes: lazy, chamado no _ready e opcionalmente no refresh_all.
	if _search_box == null:
		_search_box = get_node_or_null("MarginContainer/Frame/Root/SearchBox") as LineEdit

	if _population_label == null:
		_population_label = get_node_or_null("MarginContainer/Frame/Root/PopulationLabel") as Label
		if _population_label == null:
			_population_label = Label.new()
			_population_label.name = "PopulationLabel"
			_population_label.text = "Populacao: -- / --"
			_population_label.add_theme_font_size_override("font_size", 13)
			var root := get_node_or_null("MarginContainer/Frame/Root")
			if root != null:
				root.add_child(_population_label)

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
		_cached_player_inventory = _resolve_player_inventory()
		if _cached_player_inventory == null and not _logged_missing_player_inventory:
			_logged_missing_player_inventory = true
			push_warning("[HUD] PlayerInventory ausente: configure player_inventory_path, grupo player_inventory ou um InventoryContainer na cena.")

	if _cached_warehouse == null or not is_instance_valid(_cached_warehouse):
		_cached_warehouse = _resolve_warehouse()
		if _cached_warehouse == null and not _logged_missing_warehouse:
			_logged_missing_warehouse = true
			push_warning("[HUD] Warehouse ausente: configure warehouse_path, grupo warehouse ou um Warehouse na cena.")

	if _cached_build_controller == null or not is_instance_valid(_cached_build_controller):
		_cached_build_controller = _resolve_build_controller()
		if _cached_build_controller == null and not _logged_missing_build_controller:
			_logged_missing_build_controller = true
			push_warning("[HUD] BuildController ausente: configure build_controller_path, grupo build_controller ou um BuildPlacementController na cena.")

	if _cached_building_site == null or not is_instance_valid(_cached_building_site):
		_cached_building_site = _resolve_building_site()
		if _cached_building_site == null and _cached_build_controller == null and not _logged_missing_building_site:
			_logged_missing_building_site = true
			push_warning("[HUD] BuildingSite ausente: configure building_site_path, grupo building_site ou um BuildingSite na cena.")

	if _cached_population_manager == null or not is_instance_valid(_cached_population_manager):
		if not population_manager_path.is_empty():
			var node := get_node_or_null(population_manager_path)
			if _is_valid_population_manager(node):
				_cached_population_manager = node
		if _cached_population_manager == null:
			var managers := get_tree().get_nodes_in_group("population_manager")
			for manager in managers:
				if _is_valid_population_manager(manager):
					_cached_population_manager = manager
					break
		if _cached_population_manager == null and not _logged_missing_population_manager:
			_logged_missing_population_manager = true
			push_warning("[HUD] PopulationManager ausente: configure population_manager_path ou grupo population_manager.")


func _get_player_inventory() -> InventoryContainer:
	return _cached_player_inventory


func _get_warehouse() -> Warehouse:
	return _cached_warehouse


func _get_building_site() -> BuildingSite:
	return _cached_building_site


func _get_population_status_text() -> String:
	if _cached_population_manager == null or not is_instance_valid(_cached_population_manager):
		return "Populacao: -- / --"
	return String(_cached_population_manager.call("get_status_text"))


func _is_valid_population_manager(node: Variant) -> bool:
	var manager := node as Node
	return manager != null and manager.has_method("get_status_text")


func _resolve_player_inventory() -> InventoryContainer:
	var explicit := _resolve_explicit_node(player_inventory_path)
	if explicit is InventoryContainer:
		return explicit
	for node in get_tree().get_nodes_in_group("player_inventory"):
		if node is InventoryContainer:
			return node
	var found := _find_first_domain_node(get_tree().current_scene, Callable(self, "_is_inventory_node"))
	return found as InventoryContainer


func _resolve_warehouse() -> Warehouse:
	var explicit := _resolve_explicit_node(warehouse_path)
	if explicit is Warehouse:
		return explicit
	for node in get_tree().get_nodes_in_group("warehouse"):
		if node is Warehouse:
			return node
	var found := _find_first_domain_node(get_tree().current_scene, Callable(self, "_is_warehouse_node"))
	return found as Warehouse


func _resolve_building_site() -> BuildingSite:
	var explicit := _resolve_explicit_node(building_site_path)
	if explicit is BuildingSite:
		return explicit
	var best: BuildingSite = null
	for node in get_tree().get_nodes_in_group("building_site"):
		if node is BuildingSite:
			if not bool(node.get("is_completed")):
				return node
			if best == null:
				best = node
	if best != null:
		return best
	var found := _find_first_domain_node(get_tree().current_scene, Callable(self, "_is_building_site_node"))
	return found as BuildingSite


func _resolve_build_controller() -> BuildPlacementController:
	var explicit := _resolve_explicit_node(build_controller_path)
	if explicit is BuildPlacementController:
		return explicit
	for node in get_tree().get_nodes_in_group("build_controller"):
		if node is BuildPlacementController:
			return node
	var found := _find_first_domain_node(get_tree().current_scene, Callable(self, "_is_build_controller_node"))
	return found as BuildPlacementController


func _resolve_explicit_node(path: NodePath) -> Node:
	if path.is_empty():
		return null
	return get_node_or_null(path)


func _find_first_domain_node(root: Node, predicate: Callable) -> Node:
	if root == null:
		return null
	if predicate.call(root):
		return root
	for child in root.get_children():
		var found := _find_first_domain_node(child, predicate)
		if found != null:
			return found
	return null


func _is_inventory_node(node: Node) -> bool:
	return node is InventoryContainer


func _is_warehouse_node(node: Node) -> bool:
	return node is Warehouse


func _is_building_site_node(node: Node) -> bool:
	return node is BuildingSite


func _is_build_controller_node(node: Node) -> bool:
	return node is BuildPlacementController
