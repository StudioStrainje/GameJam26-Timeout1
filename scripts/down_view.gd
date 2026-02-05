extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var status: Label = $Status

var pps: float = 17.5

var this_view

func _ready() -> void:
	this_view = game.VIEW.DOWN
	clean.visible = true
	progress_bar.value = 0
	status.text = "0"

func _process(delta: float) -> void:
	if game.get_current_view() != this_view or game.copied_count == 0:
		return

	if Input.is_action_pressed("paste"):
		progress_bar.value += pps * delta
	if progress_bar.value == 100:
		game.copied_count -= 1
		game.pasted_count += 1
		status.text = str(game.pasted_count)
		progress_bar.value = 0
