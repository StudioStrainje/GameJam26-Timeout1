extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var menu_scenes = [
	"mainmenu.tscn",
	"controls.tscn",
	"credits.tscn"
]

func _ready():
	get_tree().tree_changed.connect(_on_tree_changed)
	_check_scene()

func _on_tree_changed():
	_check_scene()

func _check_scene():
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	
	var scene_name = current_scene.scene_file_path.get_file()
	
	if scene_name in menu_scenes:
		_play_music()
	else:
		_stop_music()

func _play_music():
	if not audio_player.playing:
		audio_player.play()

func _stop_music():
	if audio_player.playing:
		audio_player.stop()

func set_volume(volume_db: float):
	audio_player.volume_db = volume_db
