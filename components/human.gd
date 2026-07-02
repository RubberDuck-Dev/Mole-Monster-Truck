extends Node2D

enum State { DELAY, RED_LIGHT, WARNING, GREEN_LIGHT  }

var current_state: State = State.DELAY

@export var delay_time: float = 1.0 #time before starting search cycle
@export var wait_light_time= range(4,6)
@export var search_light_time: float = 3.0
@export var warning_time: float = 2.0

@onready var timer: Timer = $StateTimer
@onready var point_light: PointLight2D = $Eyeball/PointLightNode/PointLight2D
@onready var point_light_2: PointLight2D = $Eyeball/PointLightNode/PointLight2D2

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
			var tween = create_tween()
			tween.tween_property($Eyeball/Retina/Pupil,"scale",Vector2(2,2),0.5).set_trans(Tween.TRANS_ELASTIC)
			AudioManager.play_sfx("human_search")
			timer.start(search_light_time)
		State.WARNING:
			#print("near countdown")
			var tween = create_tween()
			tween.tween_property($Eyeball/Retina/Pupil,"scale",Vector2(1.5,1.5),0.5).set_trans(Tween.TRANS_ELASTIC)
#			AudioManager.play_sfx("human_countdown")			
			timer.start(warning_time)
		State.GREEN_LIGHT:
			#print("waiting")
			var tween = create_tween()
			tween.tween_property($Eyeball/Retina/Pupil,"scale",Vector2(1,1),0.5).set_trans(Tween.TRANS_ELASTIC)
			AudioManager.play_sfx("human_idle")

			var wait_rand_time = wait_light_time.pick_random()
			timer.start(wait_rand_time)

func _on_state_timer_timeout() -> void:
	match current_state:
		State.DELAY:
			enter_state(State.GREEN_LIGHT)
			point_light.scale.x = 1.0
			point_light_2.scale.x = 1.0

		State.GREEN_LIGHT:
			enter_state(State.WARNING)
			point_light.color=Color.YELLOW
			point_light_2.color=Color.YELLOW
			point_light.scale.x = 0.5
			point_light_2.scale.x = 0.5


		State.WARNING:
			enter_state(State.RED_LIGHT)
			point_light.color=Color.RED
			point_light_2.color=Color.RED

			point_light.scale.x = 0.3
			point_light_2.scale.x = 0.3

		State.RED_LIGHT:
			# loop back
			enter_state(State.GREEN_LIGHT)
			point_light.color=Color.NAVAJO_WHITE
			point_light_2.color=Color.NAVAJO_WHITE

			point_light.scale.x = 1.0
			point_light_2.scale.x = 1.0
