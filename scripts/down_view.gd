extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var status: Label = $Status

var pps: float = 17.5 * 3
var is_pasting: bool = false

var this_view

func _ready() -> void:
	this_view = game.VIEW.DOWN
	clean.visible = true
	progress_bar.value = 0
	status.text = "0"

func _process(delta: float) -> void:
	if is_pasting:
		return

	if game.get_current_view() != this_view or game.copied_count == 0:
		return

	if Input.is_action_pressed("paste"):
		progress_bar.value += pps * delta

	if progress_bar.value >= 100:
		_complete_paste()

func _complete_paste() -> void:
	is_pasting = true
	game.copied_count -= 1
	game.pasted_count += 1
	status.text = str(game.pasted_count)
	await get_tree().create_timer(0.25).timeout

	if game.pasted_count == len(game.cheating_views):
		status.text = "0"
		game.level_finished()

	progress_bar.value = 0
	is_pasting = false

func _on_game_level_changed() -> void:
	progress_bar.value = 0
	is_pasting = false
	status.text = str(game.pasted_count)
