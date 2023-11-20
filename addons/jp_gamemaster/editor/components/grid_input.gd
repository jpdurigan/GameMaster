@tool
extends Control

@export var focus_color: Color
@export var border: Control

@export var root: Control

var _border_color_backup: Color

var _is_mouse_over: bool = false
var _is_mouse_pressed: bool = false
var _is_pressing_space: bool = false

var _can_drag: bool = false
var _is_dragging: bool = false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_is_mouse_over = true
		NOTIFICATION_MOUSE_EXIT:
			_is_mouse_over = false
		NOTIFICATION_FOCUS_ENTER:
			_border_color_backup = border.self_modulate
			border.self_modulate = focus_color
		NOTIFICATION_FOCUS_EXIT:
			border.self_modulate = _border_color_backup


#func _input(event: InputEvent) -> void:
#	if not _is_mouse_over:
#		return
#	printt("_input", self, has_focus(), event.as_text())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				_is_pressing_space = event.is_pressed()
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_is_mouse_pressed = event.is_pressed()
	
	if event is InputEventMouseMotion:
		if _is_dragging:
			_process_dragging(event.relative)
	
	_update_conditions()
	printt("_gui_input", event, _is_pressing_space)


func _process(_delta: float) -> void:
	if not has_focus():
		return
	_handle_cursor()


func _process_dragging(relative: Vector2) -> void:
	root.position += relative


func _update_conditions() -> void:
	_can_drag = _is_pressing_space
	_is_dragging = _can_drag and _is_mouse_pressed


func _handle_cursor() -> void:
	var cursor: DisplayServer.CursorShape = DisplayServer.CURSOR_ARROW
	if _is_pressing_space:
		cursor = DisplayServer.CURSOR_DRAG
	DisplayServer.cursor_set_shape(cursor)
