extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var cheat: Node2D = $Cheat

var this_view

func _ready() -> void:
	this_view = game.VIEW.DOWN
	cheat.visible = false
	clean.visible = true
