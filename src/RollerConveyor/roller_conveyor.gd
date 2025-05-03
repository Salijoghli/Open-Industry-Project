@tool
class_name RollerConveyor
extends ResizableNode3D

@export var enable_comms: bool = false:
	set(value):
		enable_comms = value
		notify_property_list_changed()
@export var tag: String = ""
@export var update_rate: int = 100
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s")
var speed: float = 2.0:
	set(value):
		speed = value
		if _instance_ready:
			$RollerConveyorLegacy.speed = value
@export_range(-60, 60 , 1, "degrees") var skew_angle: float = 0.0:
	set(value):
		skew_angle = value
		if _instance_ready:
			$RollerConveyorLegacy.skew_angle = value

var original_size := Vector3.ZERO
var transform_in_progress := false

static func _get_constrained_size(new_size: Vector3) -> Vector3:
	return Vector3(max(1.5, new_size.x), 0.24, max(0.10, new_size.z))


func _enter_tree() -> void:
	EditorInterface.transform_requested.connect(_transform_requested)
	EditorInterface.transform_commited.connect(_transform_commited)
	
func _exit_tree() -> void:	
	EditorInterface.transform_requested.disconnect(_transform_requested)
	EditorInterface.transform_commited.disconnect(_transform_commited)

func _transform_requested(data) -> void:
	if not EditorInterface.get_selection().get_selected_nodes().has(self): return
	
	if data.has("motion"):
		var motion = Vector3(data["motion"][0], data["motion"][1], data["motion"][2])
		
		if not transform_in_progress:
			original_size = size
			transform_in_progress = true
		
		var new_size = original_size + motion
		new_size = _get_constrained_size(new_size)	
		size = new_size
	
func _transform_commited() -> void:
	transform_in_progress = false

func _on_instantiated() -> void:
	$RollerConveyorLegacy.on_scene_instantiated()
	super._on_instantiated()
	$RollerConveyorLegacy.speed = speed
	$RollerConveyorLegacy.skew_angle = skew_angle


func _get_initial_size() -> Vector3:
	return Vector3(abs($RollerConveyorLegacy.scale.x) + 0.5, 0.24, abs($RollerConveyorLegacy.scale.z))


func _get_default_size() -> Vector3:
	return Vector3(1.525, 0.24, 1.524)


func _on_size_changed() -> void:
	$RollerConveyorLegacy.set_size(size)
