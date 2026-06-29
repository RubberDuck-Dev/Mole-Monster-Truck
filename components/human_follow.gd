extends PathFollow2D

@export var speed: float = 250.0
var direction: int = 1

func _ready() -> void:
	# stop progress from auto-wrapping at the ends
	loop = false

func _process(delta: float) -> void:
	progress += speed * direction * delta
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		direction = -1
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0
		direction = 1

	global_rotation = 0.0
