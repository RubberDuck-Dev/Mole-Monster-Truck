extends Node2D

@onready var is_hidden_sprite: TextureRect = $Dialogue/HidingStatusUI/HBoxContainer/IsHiddenContainer/IsHiddenSprite
@onready var is_searching_sprite: TextureRect = $Dialogue/HidingStatusUI/HBoxContainer/IsSearchingContainer/IsSearchingSprite

@onready var mole_spawn_l: Node2D = $HomeGarage/SpawnPoints/MoleSpawnL
@onready var mole_spawn_r: Node2D = $HomeGarage/SpawnPoints/MoleSpawnR

@onready var human_path_2d: Path2D = $HomeGarage/SpawnPoints/HumanPath2D
@onready var path_follow_2d: PathFollow2D = $HomeGarage/SpawnPoints/HumanPath2D/PathFollow2D

@onready var wheel_spawn: Node2D = $HomeGarage/SpawnPoints/WheelSpawn


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

@onready var reset_timer: Timer = $ResetLayer/Timer

func _ready() -> void:
	spawn_human()
	spawn_mole()
	spawn_wheel()
	update_human()
	$ResetLayer.visible=false
	#GameManager.current_level_idx=0
	
func _process(_delta: float) -> void:
	#check if human found you
	if human_state == 1:
		if is_hidden:
			$ResetLayer.visible=false
		else:
			#human found you!
			look_at_mole()
			$ResetLayer.visible=true
			reset_timer.start()

func human_acting(action_type)->void:
	human_state=action_type
	match human_state:
		State.DELAY:
			print("delay")
		State.RED_LIGHT:
			is_searching_sprite.self_modulate=Color.GREEN
		State.WARNING:
			is_searching_sprite.self_modulate=Color.YELLOW
		State.GREEN_LIGHT:
			is_searching_sprite.self_modulate=Color.RED
		
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
		is_hidden_sprite.self_modulate = Color.GREEN
	else:
		is_hidden_sprite.self_modulate = Color.RED

func look_at_mole()->void:
	if mole_instance == null:
		return
	var target: Vector2 = mole_instance.global_position

	var target_angle = human_instance.global_position.direction_to(target).angle()
	human_instance.global_rotation = lerp_angle(global_rotation, target_angle, 1.0)
	
func reset_level()->void:
	human_instance.queue_free()
	spawn_human()
	mole_instance.queue_free()
	spawn_mole()
	wheel_instance.queue_free()
	spawn_wheel()
	$ResetLayer.visible=false
	
func _on_obstruction_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D or body is RigidBody2D:
		is_hidden=true
		update_human()

func _on_obstruction_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D or body is RigidBody2D:
		is_hidden=false
		update_human()

func _on_timer_timeout() -> void:
	reset_level()


func _on_level_exit_l_body_entered(body: Node2D) -> void:
	pass
	#if body is RigidBody2D:
		#GameManager.part_collected = true
	#if body is CharacterBody2D:
		#GameManager.level_transition(-1)

func _on_level_exit_r_body_entered(body: Node2D) -> void:
	pass
	#if body is RigidBody2D:
		#GameManager.part_collected = true
	#if body is CharacterBody2D:
		#GameManager.level_transition(-1)
