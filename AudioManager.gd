extends Node

@export var MUSIC := {}
	#"level_0": "res://audio/music/",
#}

@export var SFX :={
	"human_search": "res://audio/sfx/human_search.wav",
	"human_idle": "res://audio/sfx/human_idle.wav",
	#"wheel_roll":    "res://audio/sfx/",
	#"human_idle":    "res://audio/sfx/",
	#"mole_push":    "res://audio/sfx/",
	#"mole_chatter":    "res://audio/sfx/",
	#"human_countdown":    "res://audio/sfx/",
	#"caught":    "res://audio/sfx/",
	"collected":    "res://audio/sfx/collected.wav",
	#"truck_upgrade":    "res://audio/sfx/",
	#"truck_engine":    "res://audio/sfx/",
	#"truck_drive":    "res://audio/sfx/",
	#"truck_jump":    "res://audio/sfx/",
	#"cake_landing":    "res://audio/sfx/",
	#"cake_success":    "res://audio/sfx/",
}

const SFX_LIMIT := 8   # how many SFX can overlap at once

var muted := false
var _music := {}                       # name -> AudioStream or null
var _sfx := {}                         # name -> AudioStream or null
var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _current := ""

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = _safe_bus("Music")
	add_child(_music_player)
	for i in SFX_LIMIT:
		var p := AudioStreamPlayer.new()
		p.bus = _safe_bus("SFX")
		add_child(p)
		_sfx_players.append(p)
	for key in MUSIC: _music[key] = _try_load(MUSIC[key])
	for key in SFX:   _sfx[key]   = _try_load(SFX[key])

func _try_load(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("[AudioManager] missing audio, skipped: %s" % path)
	return null

func _safe_bus(bus_name: String) -> String:
	# fall back to Master if you haven't made the bus yet
	return bus_name if AudioServer.get_bus_index(bus_name) != -1 else "Master"

func play_music(name: String, restart_if_same := false) -> void:
	if muted: return
	if name == _current and _music_player.playing and not restart_if_same:
		return
	var stream = _music.get(name)
	if stream == null: return            # not delivered yet -> silence
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music_player.stream = stream
	_music_player.play()
	_current = name

func stop_music() -> void:
	_music_player.stop()
	_current = ""

func play_sfx(name: String) -> void:
	if muted: return
	var stream = _sfx.get(name)
	if stream == null: return
	var p := _free_player()
	p.stream = stream
	p.play()

func set_muted(value: bool) -> void:
	muted = value
	if muted: stop_music()

func _free_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing: return p
	return _sfx_players[0]   # all busy -> replace the oldest
