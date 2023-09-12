class_name Recallable
extends Node3D

signal start_recalling(object: Recallable, length: int, timestep: float)
signal finished_recalling(object: Recallable)

@export var recall_length: float = 5.0 # seconds of recall
@export var parent_mesh: MeshInstance3D

@onready var sampler: Timer = $PositionSampler
@onready var visualizer: Node3D = $Visualizer
@onready var path: Path3D = $Visualizer/Path3D

var recalling: bool = false
var max_stack_size: int = 0
var transform_stack: Array[Transform3D]
var timestep: float = 0.0

var tween: Tween


func _ready():
	get_parent().process_mode = Node.PROCESS_MODE_ALWAYS
	get_parent().input_event.connect(_on_parent_input_event)
	get_parent().mouse_entered.connect(_on_parent_mouse_entered)
	get_parent().mouse_exited.connect(_on_parent_mouse_exited)
	timestep = sampler.wait_time
	max_stack_size = int(recall_length / timestep)


func _process(_delta):
	if recalling:
		recall()


func recall():
	if (not tween or not tween.is_valid()) and transform_stack.size() > 0:
		tween = create_tween()
		tween.tween_property(get_parent(), "global_transform", transform_stack[0], timestep).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): 
			transform_stack.pop_front()
			tween.kill()
			set_path(transform_stack)
		)

	if transform_stack.size() == 0:
		finish_recall()


func set_parent_lock(lock):
	var parent = get_parent()
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_X, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Z, lock)


func start_recall():
	recalling = true
	set_parent_lock(true)
	sampler.stop()
	start_recalling.emit(self, transform_stack.size(), timestep)
	show_visualizer(parent_mesh.mesh)


func finish_recall():
	recalling = false
	set_parent_lock(false)
	sampler.start()
	finished_recalling.emit(self)
	hide_visualizer()


func _on_position_sampler_timeout():
	transform_stack.push_front(get_parent().global_transform)

	# Removes last position if too much time
	if transform_stack.size() > max_stack_size:
		transform_stack.pop_back()


func _on_parent_input_event(_camera, event, _position, _normal, _shape_idx):
	if get_tree().paused and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_recall()


func _on_parent_mouse_entered():
	show_visualizer(parent_mesh.mesh)


func _on_parent_mouse_exited():
	hide_visualizer()


func _on_recall_manager_cancel_recall():
	finish_recall()


func _get_configuration_warnings():
	var warnings = []

	if not get_parent() is CollisionObject3D:
		warnings.append("Recallable node makes the parent CollisionObject3d recallable. The parent must be of that type.")

	return warnings


func show_visualizer(mesh: Mesh) -> void:
	visualizer.show()
	visualizer.transform = Transform3D.IDENTITY
	visualizer.get_node("FinalPositionMesh").mesh = mesh
	visualizer.get_node("FinalPositionMesh").global_transform = transform_stack.back()
	set_path(transform_stack)


func hide_visualizer() -> void:
	visualizer.hide()


func set_path(stack: Array[Transform3D]) -> void:
	var curve: Curve3D = Curve3D.new()
	for recall_position in stack:
		curve.add_point(recall_position.origin)
	
	path.curve = curve
