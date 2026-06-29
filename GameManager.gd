extends Node

@export var audio_muted = false

#level transition/tracking
@export var levels: Array[PackedScene] = []
var current_idx:int=-1
var spawn_on_left := false        # which side to spawn mole

#progress tracking
@export var stage_completed:int=0
@export var part_collected:bool=false

func load_level(exit_direction)->void:
	current_idx = clampi(current_idx + exit_direction, 0, levels.size() - 1)
	spawn_on_left = exit_direction > 0  # exit right -> appear on the next level's LEFT

	print("Loading level: " + str(current_idx))

	get_tree().change_scene_to_packed(levels[current_idx])

	#update stage completion
	if current_idx>0 and part_collected:
		stage_completed +=1
