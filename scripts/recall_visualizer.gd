@tool
extends Node3D

@onready var csgPolygon: CSGPolygon3D = $CSGPolygon3D

@export var line_radius: float = 0.1:
	set(value):
		line_radius = value
		is_circle = false
	get:
		return line_radius

@export var line_resolution: float = 180:
	set(value):
		line_resolution = value
		is_circle = false
	get:
		return line_resolution


var is_circle = false


func _ready():
	var circle: PackedVector2Array = PackedVector2Array()
	for degree in line_resolution:
		var x = line_radius * sin(PI * 2 * degree / line_resolution)
		var y = line_radius * cos(PI * 2 * degree / line_resolution)
		circle.append(Vector2(x, y))
	
	$CSGPolygon3D.polygon = circle


func _process(_delta):
	if Engine.is_editor_hint() and not is_circle:
		var circle: PackedVector2Array = PackedVector2Array()
		for degree in line_resolution:
			var x = line_radius * sin(PI * 2 * degree / line_resolution)
			var y = line_radius * cos(PI * 2 * degree / line_resolution)
			circle.append(Vector2(x, y))
		
		$CSGPolygon3D.polygon = circle
		is_circle = true
