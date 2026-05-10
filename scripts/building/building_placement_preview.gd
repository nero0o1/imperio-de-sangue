class_name BuildingPlacementPreview
extends Node3D

@export var footprint_size: Vector3 = Vector3(4.0, 2.0, 4.0)

var _valid_material: StandardMaterial3D
var _invalid_material: StandardMaterial3D
var _mesh_instance: MeshInstance3D


func _ready() -> void:
	_valid_material = _make_material(Color(0.1, 0.9, 0.25, 0.38))
	_invalid_material = _make_material(Color(0.95, 0.12, 0.1, 0.38))

	var mesh := BoxMesh.new()
	mesh.size = footprint_size

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "PreviewMesh"
	_mesh_instance.mesh = mesh
	_mesh_instance.position.y = footprint_size.y * 0.5
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh_instance)
	set_valid(false)


func set_valid(is_valid: bool) -> void:
	if _mesh_instance == null:
		return

	_mesh_instance.set_surface_override_material(0, _valid_material if is_valid else _invalid_material)


func set_target_transform(target_transform: Transform3D) -> void:
	global_transform = target_transform


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = false
	return material
