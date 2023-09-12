extends Node3D

@export var fire_node_path: NodePath
@export var cannon_ball: PackedScene
@onready var fire_node: Node3D = get_node(fire_node_path)


func fire():
	var new_cannon_ball: Node3D = cannon_ball.instantiate()
	add_child(new_cannon_ball)
	new_cannon_ball.global_position = fire_node.global_position
	new_cannon_ball.global_rotation = fire_node.global_rotation
