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

@export var dialogue: Dictionary = {
	0:[[0,"Good morning, mon cher."], [1,"Erghhh.."], [0,"Too early?"], [1,"Too early."],[0,"Shall we get some air?"]],
	1:[[0,"What to do..."], [0,"Aha!"], [0,"Let's grab that wheel!"]],
	2:[[1,"What's that for?"], [0,"Darling, as I said..."],[0,"I wanted some air..."],
		[1,"A MoNsTeR TrUcK!?","show_truck"],[1,"Are you mad? We're moles!"],[0,"We are. And we like monster trucks."]],
	3:[[0,"Huh?!"], [0,"I'm being watched..."]],
	4:[[0,"I should return home."]],
	5:[[0,"I should fetch that."]],
	6:[[0,"One more, my dear."]],
	7:[[0,"Hop in!","ride_truck"]]
	}

var current_line:int = 0
var current_dialogue:int = 0
var dialogue_active:bool = false

signal dialogue_finished(id)  
signal dialogue_event(tag)

func _ready() -> void:
#	show_dialogue(true)
	#trigger_dialogue()
	pass

func _process(_delta: float) -> void:
	if dialogue_active and Input.is_action_just_pressed("interact"):
	#advance
		advance_dialogue()

func set_camera(_vector_amt)->void:
	var tween = create_tween()
	tween.tween_property($Camera2D, "zoom", _vector_amt, 0.3).set_trans(Tween.TRANS_LINEAR)

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

func start_dialogue(id) -> void:
	if not dialogue.has(id):
		return
	current_dialogue = id
	current_line = 0
	dialogue_active = true
	show_dialogue(true)
	_show_line()

func advance_dialogue() -> void:
	if not dialogue_active:
		return
	var convo = dialogue[current_dialogue]
	if current_line >= convo.size():
		_finish_dialogue()
	else:
		_show_line()

func _show_line() -> void:
	var convo = dialogue[current_dialogue]
	if current_line >= convo.size():
		_finish_dialogue()
		return

	var entry = convo[current_line]
	dialogue_text.text = entry[1]
	show_speaker(entry[0])

	# optional element = fire an event tag
	if entry.size() > 2:
		dialogue_event.emit(entry[2])

	current_line += 1
	dialogue_action_label.text = "[E]\nclose" if current_line >= convo.size() else "[E]\n>>"

func _finish_dialogue() -> void:
	dialogue_active = false
	show_dialogue(false)
	dialogue_finished.emit(current_dialogue)

func show_speaker(speaker:int) -> void:
	match speaker:
		0:
			speaker_left.visible=true
			speaker_right.visible=false
		1:
			speaker_left.visible=false
			speaker_right.visible=true
