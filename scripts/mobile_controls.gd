extends CanvasLayer

@onready var control_container: Control = $ControlContainer
@onready var left_btn: Button = $ControlContainer/LeftBtn
@onready var right_btn: Button = $ControlContainer/RightBtn
@onready var up_btn: Button = $ControlContainer/UpBtn
@onready var down_btn: Button = $ControlContainer/DownBtn
@onready var copy_btn: Button = $ControlContainer/CopyBtn
@onready var paste_btn: Button = $ControlContainer/PasteBtn

var is_mobile: bool = false

func _ready() -> void:
	is_mobile = _check_is_mobile()
	visible = is_mobile
	if not is_mobile:
		set_process(false)
		return
	_connect_buttons()

func _check_is_mobile() -> bool:
	if OS.has_feature("android"):
		return true
	if OS.has_feature("web"):
		if DisplayServer.is_touchscreen_available():
			return true
		var nav = JavaScriptBridge.get_interface("navigator")
		if is_instance_valid(nav):
			var js_code = "(function() { return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent); })()"
			var result = JavaScriptBridge.eval(js_code)
			if result == true:
				return true
	return false

func _connect_buttons() -> void:
	left_btn.button_down.connect(_on_button_down.bind("left"))
	left_btn.button_up.connect(_on_button_up.bind("left"))
	right_btn.button_down.connect(_on_button_down.bind("right"))
	right_btn.button_up.connect(_on_button_up.bind("right"))
	up_btn.button_down.connect(_on_button_down.bind("up"))
	up_btn.button_up.connect(_on_button_up.bind("up"))
	down_btn.button_down.connect(_on_button_down.bind("down"))
	down_btn.button_up.connect(_on_button_up.bind("down"))
	copy_btn.button_down.connect(_on_button_down.bind("copy"))
	copy_btn.button_up.connect(_on_button_up.bind("copy"))
	paste_btn.button_down.connect(_on_button_down.bind("paste"))
	paste_btn.button_up.connect(_on_button_up.bind("paste"))

func _on_button_down(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)

func _on_button_up(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)