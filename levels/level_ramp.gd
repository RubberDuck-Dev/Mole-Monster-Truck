extends Node2D

func _ready() -> void:
	GameManager.current_idx=4
	print(str(GameManager.current_idx))
	print(str(GameManager.current_zoom()))
	set_camera_per_level()
	$AnimationPlayer.play("drive_ramp")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="drive_ramp":
		$AnimationPlayer.play("in_air")
	else:
		GameManager.go_to_level(5)

func set_camera_per_level()->void:
	HUD.set_camera(Vector2.ONE * GameManager.current_zoom())
