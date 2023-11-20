@tool
extends Control

const ZOOM_MIN = 0.33
const ZOOM_MAX = 1.0
const ZOOM_STEP = 1.05

@export var focus_color: Color
@export var border: Control

@export var root: Control

var _border_color_backup: Color

var _zoom_relative: float = 0.0

var _is_mouse_over: bool = false
var _is_mouse_pressed: bool = false
var _is_node_pressed: bool = false
var _is_pressing_space: bool = false

var _can_drag_root: bool = false
var _is_dragging_root: bool = false
var _is_dragging_nodes: bool = false

var _selected_nodes: Dictionary


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
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_in()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out()
	
	if event is InputEventMouseMotion:
		if _is_dragging_root:
			_process_dragging_root(event.relative)
	
	_update_conditions()
	printt("_gui_input", event, _is_pressing_space)


func _process(_delta: float) -> void:
	if not has_focus():
		return
	_handle_cursor()


func on_node_gui_input(node: Control, event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_is_node_pressed = event.is_pressed()
				if event.is_pressed():
					_select_node(node)
				else:
					_unselect_node(node)
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_in()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out()
	
	if event is InputEventMouseMotion:
		if _is_dragging_nodes:
			_process_dragging_nodes(event.relative)
	
	_update_conditions()
#	printt("_gui_input", event, _is_pressing_space)


func _process_dragging_root(relative: Vector2) -> void:
	root.position += relative

func _process_dragging_nodes(relative: Vector2) -> void:
	for node_id in _selected_nodes.keys():
		var selected_node: SelectedNode = _selected_nodes[node_id]
		selected_node.move_by(relative, Vector2.ONE * 64.0)


func _select_node(node: Control) -> void:
	var node_id: int = node.get_instance_id()
	if _selected_nodes.has(node_id):
		return
	_selected_nodes[node_id] = SelectedNode.new(node)
	printt("selected node", _selected_nodes)

func _unselect_node(node: Control) -> void:
	var node_id: int = node.get_instance_id()
	if not _selected_nodes.has(node_id):
		return
	_selected_nodes.erase(node_id)


func _zoom_in() -> void:
	if root.scale.x >= ZOOM_MAX:
		return
	root.scale *= ZOOM_STEP

func _zoom_out() -> void:
	if root.scale.x <= ZOOM_MIN:
		return
	root.scale /= ZOOM_STEP

func _update_conditions() -> void:
	_can_drag_root = _is_pressing_space
	_is_dragging_root = _can_drag_root and _is_mouse_pressed
	_is_dragging_nodes = _is_node_pressed and not _selected_nodes.is_empty()


func _handle_cursor() -> void:
	var cursor: DisplayServer.CursorShape = DisplayServer.CURSOR_ARROW
	if _is_pressing_space:
		cursor = DisplayServer.CURSOR_DRAG
	DisplayServer.cursor_set_shape(cursor)


class SelectedNode:
	var node: Control
	var target_position: Vector2
	
	func _init(p_node: Control) -> void:
		node = p_node
		target_position = node.position
	
	func move_by(relative: Vector2, grid_snap: Vector2) -> void:
		target_position += relative
		node.position = target_position.snapped(grid_snap)
