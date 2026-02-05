extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var cheat: Node2D = $Cheat
@onready var progress_bar: TextureProgressBar = $ProgressBar

var points_per_second: float = 10.0

var this_view

func _ready() -> void:
	this_view = game.VIEW.FORWARD
	progress_bar.value = 0.0


func _process(delta: float) -> void:
	if game.get_current_view() == this_view:
		if this_view in game.get_cheating_views():
			cheat.visible = true
			clean.visible = false
			
			if Input.is_action_pressed("interact"):
				progress_bar.value = min(progress_bar.value + points_per_second * delta, 100.0)
				print(progress_bar.value)
			else:
				progress_bar.value = 0.0
		else:
			cheat.visible = false
			clean.visible = true
			progress_bar.value = 0.0
