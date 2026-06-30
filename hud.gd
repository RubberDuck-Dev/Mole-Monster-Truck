extends CanvasLayer

@onready var is_hidden_sprite = $HidingStatusUI/HBoxContainer/IsHiddenContainer/IsHiddenSprite
@onready var is_searching_sprite = $HidingStatusUI/HBoxContainer/IsSearchingContainer/IsSearchingSprite
@onready var caught_overlay = $ResetOverlay
@onready var success_overlay: Control = $SuccessOverlay

@onready var dialogue_box: MarginContainer = $DialogueMargin
@onready var dialogue_text: Label = $DialogueMargin/Panel/MarginContainer/HBoxContainer/Label
@onready var dialogue_action_label: Label = $DialogueMargin/Panel/MarginContainer/HBoxContainer/Label2

@onready var speaker_left: TextureRect = $DialogueMargin/Panel/MarginContainer/HBoxContainer/SpeakerLeft
@onready var speaker_right: TextureRect = $DialogueMargin/Panel/MarginContainer/HBoxContainer/SpeakerRight

@export var dialogue: Dictionary = {0:[[0,"Good morning, mon cher."], [1,"Erghhh.."], [0,"Too early?"], [1,"Too early."]],
1:[[0,"What to do..."], [0,"Aha!"], [0,"Let's clear our heads..."], [0,"get some air."],[1,"Now we're talking!"]]}

var current_line = 0
var current_dialogue = 0

func _ready() -> void:
#	show_dialogue(true)
	#trigger_dialogue()
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
	#advance
		trigger_dialogue()

func set_camera(_vector_amt)->void:
	$Camera2D.zoom = _vector_amt

func set_hidden(hidden: bool) -> void:
	is_hidden_sprite.self_modulate = Color.GREEN if hidden else Color.RED

func show_caught(on: bool) -> void:
	caught_overlay.visible = on

func show_success(on: bool) -> void:
	success_overlay.visible = on
	await get_tree().create_timer(3.0).timeout
	success_overlay.visible = false

func show_dialogue(on:bool) -> void:
	dialogue_box.visible=on

func trigger_dialogue() -> void:
	update_dialogue_box()
	show_dialogue(true)

func update_dialogue_box()->void:

	var speaker
	var line

	#if dialogue_box.visible:
	if current_dialogue < dialogue.size():
		var dialogue_length = dialogue[current_dialogue].size()

		print(current_line)
		print(dialogue_length)

		if current_line == dialogue_length:
			print("last line, closing")
			current_dialogue+=1
			current_line=0
			show_dialogue(false)
		elif current_line < dialogue_length:
			speaker = dialogue[current_dialogue][current_line][0]
			line = dialogue[current_dialogue][current_line][1]
			dialogue_text.text=line
			current_line += 1
			
			#print(str(speaker) + " : " + line)
			show_speaker(speaker)
			
			if current_line == dialogue_length:
				dialogue_action_label.text = "[E]\nclose"
			else:
				dialogue_action_label.text = "[E]\n>>"
		else:
			#end of dialogue chain
			show_dialogue(false)
			current_dialogue+=1
			current_line=0

func show_speaker(speaker:int) -> void:
	match speaker:
		0:
			speaker_left.visible=true
			speaker_right.visible=false
		1:
			speaker_left.visible=false
			speaker_right.visible=true
