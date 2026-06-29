extends PathFollow2D

@export var speed: float = 250.0 # pixels per second

func _process(delta: float) -> void:
	progress += speed * delta
	
	#loop along path
	progress_ratio = fmod(progress_ratio, 1.0)

	global_rotation=0.0
