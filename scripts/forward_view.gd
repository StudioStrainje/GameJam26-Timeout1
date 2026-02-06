extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var cheat: Node2D = $Cheat
@onready var progress_bar: TextureProgressBar = $ProgressBar

var pps: float = 17.5 * 3
var dementia_pps: float = 4.67
var completed = false

var this_view

func _ready() -> void:
	this_view = game.VIEW.FORWARD
	progress_bar.value = 0.0


func _process(delta: float) -> void:
	if game.get_current_view() == this_view:
		if this_view in game.get_cheating_views():
			cheat.visible = true
			clean.visible = false
			
			if Input.is_action_pressed("copy"):
				game.copying = this_view
				progress_bar.value += pps * delta
			else:
				game.copying = -1
				if progress_bar.value < 100:
					progress_bar.value -= dementia_pps * delta
				if progress_bar.value <= 0:
					completed = false
			if progress_bar.value >= 100 and not completed:
				game.copied_count += 1
				completed = true

		else:
			cheat.visible = false
			clean.visible = true
	else:
		if progress_bar.value < 100:
			progress_bar.value -= dementia_pps * delta


func _on_game_level_changed() -> void:
	progress_bar.value = 0
	completed = false
