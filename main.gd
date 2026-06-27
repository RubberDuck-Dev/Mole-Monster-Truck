extends Node2D

@onready var human: Node2D = $Human
@onready var is_hidden_sprite: TextureRect = $Human/MarginContainer/HBoxContainer/IsHiddenContainer/IsHiddenSprite
#@onready var is_searching_sprite: TextureRect = $Human/MarginContainer/HBoxContainer/IsSearchingContainer/IsSearchingSprite

@onready var mole_spawn_l: Node2D = $HomeGarage/MoleSpawnL
@onready var mole_spawn_r: Node2D = $HomeGarage/MoleSpawnR

@export var is_hidden:bool=false
var human_state:int
@export var enter_direction_left:bool=false

var mole_instance
const MOLE = preload("uid://dno32qrxb21l5")
@onready var reset_timer: Timer = $ResetLayer/Timer

func _ready() -> void:
	human.human_action.connect(human_acting)
	update_human()
	spawn_mole()
	$ResetLayer.visible=false
	
func _process(_delta: float) -> void:
	#check if human found you
	#if human_state == 1:
		#if is_hidden:
			#$ResetLayer.visible=false
		#else:
			#$ResetLayer.visible=true
			#reset_timer.start()
	pass

func human_acting(action_type)->void:
	human_state=action_type
	#print("[main-human acting] current state: " + str(human_state))
	update_human()

func spawn_mole()->void:
	mole_instance = MOLE.instantiate()

	if enter_direction_left:
		mole_instance.global_position = mole_spawn_l.global_position
	else:
		mole_instance.global_position = mole_spawn_r.global_position
	self.add_child(mole_instance)

func update_human()->void:
	if is_hidden:
		is_hidden_sprite.self_modulate = Color.GREEN
	else:
		is_hidden_sprite.self_modulate = Color.RED
	
func reset_level()->void:
	mole_instance.queue_free()
	spawn_mole()
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
