extends Node

@export var audio_muted = false
@export var levels: Array[PackedScene] = []

#current level tracking
@export var start_level:PackedScene
var current_level_idx:int=0
@onready var current_level:PackedScene = levels[current_level_idx]

#progress tracking
@export var stage_completed:int=0
@export var part_collected:bool=false

func  _ready()->void:
	if start_level:
		_load_level(start_level,false)
		
func _load_level(start_level,exit_direction)->void:
	var target_level
	
	if exit_direction:
		#exiting left -> return home
		target_level = levels[0]
	else:
		target_level = levels[current_level_idx+1]
	target_level.instantiate()
	get_tree().current_scene.add_child(target_level)

	#update stage completion
	if current_level_idx>0 and part_collected:
		stage_completed +=1

	#get rid of previous level
	#current_level.queue_free()
