extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var cheat: Node2D = $Cheat

var this_view

func _ready() -> void:
	this_view = game.VIEW.FORWARD


func _process(_delta: float) -> void:
	if game.get_current_view() == this_view:
		if this_view in game.get_cheating_views():
			cheat.visible = true
			clean.visible = false
		else:
			cheat.visible = false
			clean.visible = true
