extends Node2D

enum State { DELAY, RED_LIGHT, WARNING, GREEN_LIGHT  }

var current_state: State = State.DELAY

@export var delay_time: float = 2.0
@export var wait_light_time= range(4,8)
@export var search_light_time: float = 3.0
@export var warning_time: float = 2.0

@onready var timer: Timer = $StateTimer

@onready var is_searching_sprite: TextureRect = $MarginContainer/HBoxContainer/IsSearchingContainer/IsSearchingSprite
@onready var is_hidden_sprite: TextureRect = $MarginContainer/HBoxContainer/IsHiddenContainer/IsHiddenSprite

signal human_action

func _ready() -> void:
	#minor delay for acclimate to level layout
	enter_state(State.DELAY)

func enter_state(new_state: State) -> void:
	current_state = new_state
	human_action.emit(current_state)
	#print(current_state)
	
	match current_state:
		State.DELAY:
			#print("delay")
			timer.start(delay_time)
		State.RED_LIGHT:
			#print("searching")
			timer.start(search_light_time)
		State.WARNING:
			#print("near countdown")
			timer.start(warning_time)
		State.GREEN_LIGHT:
			#print("waiting")
			var wait_rand_time = wait_light_time.pick_random()
			timer.start(wait_rand_time)

func _on_state_timer_timeout() -> void:
	match current_state:
		State.DELAY:
			enter_state(State.GREEN_LIGHT)
		State.GREEN_LIGHT:
			enter_state(State.WARNING)
			is_searching_sprite.self_modulate=Color.YELLOW
		State.WARNING:
			enter_state(State.RED_LIGHT)
			is_searching_sprite.self_modulate=Color.GREEN
		State.RED_LIGHT:
			# loop back
			enter_state(State.GREEN_LIGHT)
			is_searching_sprite.self_modulate=Color.RED
