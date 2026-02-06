extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var menu_scenes = [
	"mainmenu.tscn",
	"controls.tscn",
	"credits.tscn"
]

const FADE_DURATION = 1.0
const TARGET_VOLUME = -10.0
const MUTE_VOLUME = -80.0

var fade_tween: Tween

func _ready():
	audio_player.volume_db = MUTE_VOLUME
	get_tree().tree_changed.connect(_on_tree_changed)
	_check_scene()

func _on_tree_changed():
	_check_scene()

func _check_scene():
	var tree = get_tree()
	if not tree:
		return

	var current_scene = tree.current_scene
	if current_scene == null:
		return
	
	var scene_name = current_scene.scene_file_path.get_file()
	
	if scene_name in menu_scenes:
		_fade_in()
	else:
		_fade_out()

func _fade_in():
	if fade_tween:
		fade_tween.kill()
	
	if not audio_player.playing:
		audio_player.play()
	
	fade_tween = create_tween()
	fade_tween.tween_property(audio_player, "volume_db", TARGET_VOLUME, FADE_DURATION)

func _fade_out():
	if not audio_player.playing:
		return
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(audio_player, "volume_db", MUTE_VOLUME, FADE_DURATION)
	fade_tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	audio_player.stop()

func set_volume(volume_db: float):
	audio_player.volume_db = volume_db
