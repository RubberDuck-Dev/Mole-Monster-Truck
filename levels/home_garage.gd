extends Node2D

@onready var mole_spawn_l: Node2D = $SpawnPoints/MoleSpawnL
@onready var mole_spawn_r: Node2D = $SpawnPoints/MoleSpawnR

@onready var human_path_2d: Path2D = $SpawnPoints/HumanPath2D
@onready var path_follow_2d: PathFollow2D = $SpawnPoints/HumanPath2D/PathFollow2D

@onready var wheel_spawn: Node2D = $SpawnPoints/WheelSpawn

@export var is_hidden:bool=false
var human_state:int
@export var enter_direction_left:bool=false

enum State { DELAY, RED_LIGHT, WARNING, GREEN_LIGHT  }

var human_instance
const HUMAN = preload("uid://cbhvom5qh7cym")

var mole_instance
const MOLE = preload("uid://dno32qrxb21l5")

var wheel_instance
const WHEEL = preload("uid://dtsm6pmndsces")

@onready var reset_timer: Timer = $ResetTimer
var _is_caught:bool = false
var _can_exit:bool = false

func _ready() -> void:
	#var from_left: bool = GameManager.spawn_on_left
	#mole_instance.global_position = (mole_spawn_l if from_left else mole_spawn_r).global_position

	spawn_human()
	spawn_mole()
	spawn_wheel()
	update_human()
	connect_obstructions()
	#$ResetLayer.visible=false
	#GameManager.current_level_idx=0
	await get_tree().create_timer(0.4).timeout
	_can_exit = true
#	AudioManager.play_music("level_0")
	
func _process(delta: float) -> void:
	#check if human found you
	if human_state == 1:
		if is_hidden:
			HUD.show_caught(false)
		else:
			#human found you!
			look_at_mole(delta)
			if not _is_caught:
#				AudioManager.play_sfx("caught")
				_is_caught=true
				HUD.show_caught(true)
				#$ResetLayer.visible=true
				reset_timer.start()

func connect_obstructions()->void:
	#for the current level, loop and connect signals
	for o in $Obstructions.get_children():
		o.body_entered.connect(_on_obstruction_body_entered)
		o.body_exited.connect(_on_obstruction_body_exited)

func human_acting(action_type)->void:
	human_state=action_type
	#match human_state:
		#State.DELAY:
			#print("delay")
		#State.RED_LIGHT:
			#is_searching_sprite.self_modulate=Color.GREEN
		#State.WARNING:
			#is_searching_sprite.self_modulate=Color.YELLOW
		#State.GREEN_LIGHT:
			#is_searching_sprite.self_modulate=Color.RED
		
	#print("[main-human acting] current state: " + str(human_state))
	update_human()

func spawn_human()->void:
	human_instance = HUMAN.instantiate()

	if enter_direction_left:
		human_instance.global_position = human_path_2d.global_position
	else:
		human_instance.global_position = human_path_2d.global_position
	path_follow_2d.add_child(human_instance)

	#connect signal
	human_instance.human_action.connect(human_acting)

func spawn_mole()->void:
	mole_instance = MOLE.instantiate()

	if enter_direction_left:
		mole_instance.global_position = mole_spawn_l.global_position
	else:
		mole_instance.global_position = mole_spawn_r.global_position
	self.add_child(mole_instance)

func spawn_wheel()->void:
	wheel_instance = WHEEL.instantiate()

	if enter_direction_left:
		wheel_instance.global_position = wheel_spawn.global_position
	else:
		wheel_instance.global_position = wheel_spawn.global_position
	self.add_child(wheel_instance)
	
func update_human()->void:
	if is_hidden:
		HUD.set_hidden(true)
	else:
		HUD.set_hidden(false)

func look_at_mole(delta) -> void:
	if mole_instance == null: return
	var to_mole = human_instance.global_position.direction_to(mole_instance.global_position)
	var target = to_mole.angle() - PI/2
	human_instance.global_rotation = lerp_angle(human_instance.global_rotation, target, 8.0*delta)

func reset_level()->void:
	HUD.show_caught(false)
	human_instance.queue_free()
	spawn_human()
	mole_instance.queue_free()
	spawn_mole()
	if wheel_instance:
		wheel_instance.queue_free()
		spawn_wheel()

	#$ResetLayer.visible=false
	
func _on_obstruction_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D or body is RigidBody2D:
		is_hidden=true
		update_human()

func _on_obstruction_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D or body is RigidBody2D:
		is_hidden=false
		update_human()

func _on_reset_timer_timeout() -> void:
	_is_caught=false
	reset_level()

func _on_level_exit_r_body_entered(body)->void:
	if _can_exit and body == mole_instance:
		print("calling load_level: 1")
		GameManager.load_level.call_deferred(1)
	if body == wheel_instance:
#		AudioManager.play_sfx("collected")
		HUD.show_success(true)
		GameManager.part_collected = true
		wheel_instance.queue_free()

func _on_level_exit_l_body_entered(body)->void:
	if _can_exit and body == mole_instance:
		print("calling load_level: -1")
		GameManager.load_level.call_deferred(-1)
	if body == wheel_instance:
#		AudioManager.play_sfx("collected")
		HUD.show_success(true)
		GameManager.part_collected = true
		wheel_instance.queue_free()
