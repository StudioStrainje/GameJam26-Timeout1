extends Node

const CLICK_SOUND := preload("res://assets/button.ogg")

var click_player: AudioStreamPlayer

func _ready() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.stream = CLICK_SOUND
	add_child(click_player)
	_connect_buttons_in_tree(get_tree().root)
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	_connect_button(node)

func _connect_buttons_in_tree(node: Node) -> void:
	_connect_button(node)
	for child in node.get_children():
		_connect_buttons_in_tree(child)

func _connect_button(node: Node) -> void:
	if node is BaseButton:
		var button := node as BaseButton
		var handler := Callable(self, "_on_button_pressed")
		if not button.pressed.is_connected(handler):
			button.pressed.connect(handler)

func _on_button_pressed() -> void:
	if click_player and click_player.stream:
		click_player.play()
