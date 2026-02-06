extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var status: Label = $Status

var pps: float = 17.5

var this_view
var changed: bool = false
var was_paste_pressed: bool = false
func _ready() -> void:
	this_view = game.VIEW.DOWN
	clean.visible = true
	progress_bar.value = 0
	status.text = "0"

func _process(delta: float) -> void:
	if game.get_current_view() != this_view or game.copied_count == 0:
		was_paste_pressed = false
		changed = false
		return

	var is_paste_pressed = Input.is_action_pressed("paste")
	
	if not is_paste_pressed:
		was_paste_pressed = false
		changed = false
		if progress_bar.value < 100:
			progress_bar.value = 0
	
	if is_paste_pressed and not was_paste_pressed and not changed:
		was_paste_pressed = true
	
	if is_paste_pressed and was_paste_pressed and not changed:
		progress_bar.value += pps * delta
	
	if progress_bar.value >= 100 and not changed:
		game.copied_count -= 1
		game.pasted_count += 1
		changed = true
		status.text = str(game.pasted_count)
		await get_tree().create_timer(.25).timeout
		progress_bar.value = 0
		if game.copied_count > 0:
			changed = false
			was_paste_pressed = false
		if game.pasted_count == len(game.cheating_views):
			game.level_finished()


func _on_game_level_changed() -> void:
	status.text = "0"
