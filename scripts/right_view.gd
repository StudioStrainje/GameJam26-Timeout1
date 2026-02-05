extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var cheat: Node2D = $Cheat
@onready var progress_bar: TextureProgressBar = $ProgressBar

@export var pps: float = 17.5
@export var dementia_pps: float = 4.67

var this_view

func _ready() -> void:
	this_view = game.VIEW.RIGHT
	progress_bar.value = 0.0


func _process(delta: float) -> void:
	if game.get_current_view() == this_view:
		if this_view in game.get_cheating_views():
			cheat.visible = true
			clean.visible = false
			
			if Input.is_action_pressed("interact"):
				progress_bar.value += pps * delta
			else:
				if progress_bar.value < 100:
					progress_bar.value -= dementia_pps * delta
		else:
			cheat.visible = false
			clean.visible = true
	else:
		if progress_bar.value < 100:
			progress_bar.value -= dementia_pps * delta
