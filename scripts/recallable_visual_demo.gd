extends Node3D

@export var recall_length: float = 5.0 # seconds of recall
@export var parent_mesh: MeshInstance3D

@onready var sampler: Timer = $PositionSampler
@onready var meshes: Node3D = $Meshes

var tween: Tween
var transform_stack: Array[Transform3D]
var timestep: float = 0.0
var max_stack_size: int = 0
var recalling: bool = false

var display_meshes: Array[MeshInstance3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	timestep = sampler.wait_time
	max_stack_size = int(recall_length / timestep)


func _process(_delta):
	if Input.is_action_just_pressed("recall_demo"):
		start_recall()

	if recalling:
		recall()


func recall():
	if (not tween or not tween.is_valid()) and transform_stack.size() > 0:
		tween = create_tween()
		tween.tween_property(get_parent(), "global_transform", transform_stack[0], timestep).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): 
			transform_stack.pop_front()
			display_meshes.front().queue_free()
			display_meshes.pop_front()
			tween.kill()
		)

	if transform_stack.size() == 0:
		finish_recall()


func start_recall():
	recalling = true
	set_parent_lock(true)
	sampler.stop()


func finish_recall():
	recalling = false
	set_parent_lock(false)


func _on_position_sampler_timeout():
	transform_stack.push_front(get_parent().global_transform)
	var new_mesh: MeshInstance3D = MeshInstance3D.new()
	new_mesh.mesh = parent_mesh.mesh
	new_mesh.global_transform = transform_stack[0]
	meshes.transform = Transform3D.IDENTITY
	meshes.add_child(new_mesh)
	display_meshes.push_front(new_mesh)

	# Removes last position if too much time
	if transform_stack.size() > max_stack_size:
		transform_stack.pop_back()
		display_meshes.back().queue_free()
		display_meshes.pop_back()


func set_parent_lock(lock):
	var parent = get_parent()
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_X, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, lock)
	parent.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Z, lock)
