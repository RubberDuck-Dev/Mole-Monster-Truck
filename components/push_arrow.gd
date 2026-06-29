extends Node2D

@onready var wheel = get_parent()

func _process(_delta: float) -> void:
	# Match position to the wheel
	global_position = wheel.global_position
	global_rotation=0.0
