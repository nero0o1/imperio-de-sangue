class_name BuildingVisualState
extends Node3D

@export var building_site_path: NodePath

var building_site: BuildingSite

# Dirty flag: evita chamar _set_exclusive_visual() quando o estado visual nao mudou.
# building_visual_state nao tem acesso a sinais de BuildingSite; usa _process() com guard.
var _last_progress: float = -1.0
var _last_completed: bool = false

@onready var foundation_visual: Node3D = $FoundationVisual
@onready var under_construction_visual: Node3D = $UnderConstructionVisual
@onready var completed_visual: Node3D = $CompletedVisual
@onready var status_label: Label3D = get_node_or_null("StatusLabel") as Label3D


func _ready() -> void:
	if not building_site_path.is_empty():
		building_site = get_node_or_null(building_site_path) as BuildingSite
	refresh_visual_state()


func _process(_delta: float) -> void:
	refresh_visual_state()


func refresh_visual_state() -> void:
	if building_site == null or not is_instance_valid(building_site):
		building_site = null
		_set_exclusive_visual(false, false, false, "")
		return

	var progress := clampf(building_site.build_progress, 0.0, 100.0)
	var completed := building_site.is_completed or progress >= 100.0

	# Guard: evita atualizar visuais e labels quando o estado nao mudou desde o ultimo frame.
	# Elimina ~60 chamadas desnecessarias por segundo quando a construcao esta parada.
	if progress == _last_progress and completed == _last_completed:
		return

	_last_progress = progress
	_last_completed = completed

	var showing_foundation := progress <= 0.0 and not completed
	var showing_under_construction := progress > 0.0 and progress < 100.0 and not completed
	var showing_completed := completed

	_set_exclusive_visual(
		showing_foundation,
		showing_under_construction,
		showing_completed,
		_get_status_text(progress, completed)
	)


func _set_exclusive_visual(
	show_foundation: bool,
	show_under_construction: bool,
	show_completed: bool,
	status_text: String
) -> void:
	foundation_visual.visible = show_foundation
	under_construction_visual.visible = show_under_construction
	completed_visual.visible = show_completed

	if status_label != null:
		status_label.text = status_text
		status_label.visible = not status_text.is_empty()


func _get_status_text(progress: float, completed: bool) -> String:
	if completed:
		return "100%"
	if progress <= 0.0:
		return "0%"
	return "%d%%" % int(round(progress))
