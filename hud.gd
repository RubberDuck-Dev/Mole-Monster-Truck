extends CanvasLayer

@onready var is_hidden_sprite = $HidingStatusUI/HBoxContainer/IsHiddenContainer/IsHiddenSprite
@onready var is_searching_sprite = $HidingStatusUI/HBoxContainer/IsSearchingContainer/IsSearchingSprite
@onready var caught_overlay = $ResetOverlay
@onready var success_overlay: Control = $SuccessOverlay

#func _ready() -> void:
#	home_garage.is_found.connect(show_caught)

func set_hidden(hidden: bool) -> void:
	is_hidden_sprite.self_modulate = Color.GREEN if hidden else Color.RED

func show_caught(on: bool) -> void:
	caught_overlay.visible = on

func show_success(on: bool) -> void:
	success_overlay.visible = on
	await get_tree().create_timer(3.0).timeout
	success_overlay.visible = false
