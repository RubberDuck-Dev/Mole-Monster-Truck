extends Node2D

func _ready() -> void:
	HUD.visible=false
	GameManager.current_idx=5
	set_camera_per_level()
	$AnimationPlayer.play("cake_splash")

func set_camera_per_level()->void:
	HUD.set_camera(Vector2.ONE * GameManager.current_zoom())
