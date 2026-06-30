extends Node

@export var audio_muted = false

#level transition/tracking
@export var levels: Array[PackedScene] = []
var current_idx:int=0
var spawn_on_left := false        # which side to spawn mole

var level_config = {
	0:{"zoom":0.5,"intro":0,"requires_part":false},
	1:{"zoom":0.3,"intro":1,"requires_part":true},
	2:{"zoom":0.3,"intro":2,"requires_part":true},
	3:{"zoom":0.25,"intro":"","requires_part":true},
	4:{"zoom":0.2,"intro":"","requires_part":false}
}

#control the dialogue shown per level + stage completed
# { level_idx: { part_collected_amount: dialogue_id } }
var intro_dialogue := {
	0: { 0: 0, 1: 2, 2:6, 3: 7},
	1: { 0: 1 },
	2: { 1: 3 },
}

#progress tracking
@export var parts_collected = {}
@export var stage_completed:int=0

var show_truck:bool=false

func _ready()->void:
	AudioManager.set_muted(audio_muted)

func load_level(exit_direction)->void:
	current_idx = clampi(current_idx + exit_direction, 0, levels.size() - 1)
	spawn_on_left = exit_direction > 0  # exit right -> appear on the next level's LEFT

#	print("Loading level: " + str(current_idx))

	get_tree().change_scene_to_packed(levels[current_idx])

	#update stage completion
	#if current_idx>0 and parts_collected==current_idx:
		#stage_completed +=1

func collect_part()->void:
	parts_collected[current_idx]=true

func has_part(idx:=current_idx)->bool:
	return parts_collected.get(idx,false)
	
func requires_part(idx:=current_idx)->bool:
	return level_config.get(idx,{}).get("requires_part", false)

func parts_count() -> int:      
	# total parts collected - used in dialogue table
	return parts_collected.size()

func can_progress() -> bool:
	return not requires_part() or has_part()

func current_zoom() -> float:
	return level_config.get(current_idx, {}).get("zoom", 0.3)

func current_intro():
	return level_config.get(current_idx, {}).get("intro", "")

func stages_done() -> int:
	return parts_collected.size()

func dialogue_for_state() -> int:
	var count := parts_collected.size()
	return intro_dialogue.get(current_idx, {}).get(count, -1)
