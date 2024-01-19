@tool
extends Control

const ZOOM_MIN = 0.33
const ZOOM_MAX = 1.0
const ZOOM_STEP = 1.05

@export var focus_color: Color = Color.WHITE
@export var select_color: Color = Color.WHITE
@export var border: Control

@export var root: Control
@export var grid: Control
@export var nodes: Control

var _border_color_backup: Color

var _zoom_relative: float = 0.0

var _is_mouse_over: bool = false
var _is_mouse_pressed: bool = false
var _is_node_pressed: bool = false
var _is_pressing_space: bool = false

var _can_drag_root: bool = false
var _is_dragging_root: bool = false
var _is_dragging_nodes: bool = false
var _can_select_nodes: bool = false

var _selection_start: Vector2
var _selection_end: Vector2
var _selection_rect: Rect2
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
			if not get_rect().has_point(get_local_mouse_position()):
				_unselect_all()


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
				if event.is_pressed():
					_update_selection()
					_selection_start = get_global_mouse_position()
					_selection_end = get_global_mouse_position()
				elif _can_select_nodes:
					_selection_start = Vector2.INF
					_selection_end = Vector2.INF
					queue_redraw()
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_in()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out()
	
	if event is InputEventMouseMotion:
		if _can_select_nodes:
			_selection_end = get_global_mouse_position()
			_update_selection()
			queue_redraw()
		if _is_dragging_root:
			_process_dragging_root(event.relative)
	
	_update_conditions()
#	printt("_gui_input", event, _is_pressing_space)


func _draw() -> void:
	if _can_select_nodes:
		draw_set_transform(-global_position)
		draw_rect(_selection_rect, select_color.lerp(Color.TRANSPARENT, 0.5))
		draw_rect(_selection_rect, select_color, false, grid.grid_width)


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
					_select_node(node, false)
				else:
					_unselect_node(node, false)
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
		selected_node.move_by(relative, grid.get_grid_snap())


func _update_selection() -> void:
	_selection_start = _selection_start.clamp(global_position, global_position + size)
	_selection_end = _selection_end.clamp(global_position, global_position + size)
	_selection_rect = Rect2(
		min(_selection_start.x, _selection_end.x),
		min(_selection_start.y, _selection_end.y),
		abs(_selection_end.x - _selection_start.x),
		abs(_selection_end.y - _selection_start.y),
	)
	
#	var global_selection: Rect2 = _selection_rect * root.scale.x
	for child in nodes.get_children():
		if child is Control:
			var child_rect: Rect2 = child.get_global_rect()
			if _selection_rect.intersects(child_rect):
				_select_node(child, true)
			else:
				_unselect_node(child, true)

func _select_node(node: Control, is_multiple: bool) -> void:
	var node_id: int = node.get_instance_id()
	if _selected_nodes.has(node_id):
		return
	_selected_nodes[node_id] = SelectedNode.new(node, is_multiple)
	node.modulate = Color.WHITE.lerp(Color.TRANSPARENT, 0.2)
	printt("selected node", _selected_nodes)

func _unselect_node(node: Control, is_multiple: bool) -> void:
	var node_id: int = node.get_instance_id()
	if not _selected_nodes.has(node_id):
		return
	var selected_node: SelectedNode = _selected_nodes[node_id]
	if is_multiple != selected_node.is_multiple:
		return
	_selected_nodes.erase(node_id)
	node.modulate = Color.WHITE
	printt("unselected node", _selected_nodes)

func _unselect_all() -> void:
	for node_id in _selected_nodes.keys():
		var selected_node: SelectedNode = _selected_nodes[node_id]
		selected_node.node.modulate = Color.WHITE
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
	_can_select_nodes = not _can_drag_root and _is_mouse_pressed
#	printt(
#		"_update_conditions",
#		_can_select_nodes,
#		_selection_start,
#		_selection_end
#	)


func _handle_cursor() -> void:
	var cursor: DisplayServer.CursorShape = DisplayServer.CURSOR_ARROW
	if _is_pressing_space:
		cursor = DisplayServer.CURSOR_DRAG
	DisplayServer.cursor_set_shape(cursor)


class SelectedNode:
	var node: Control
	var target_position: Vector2
	var is_multiple: bool
	
	func _init(p_node: Control, p_is_multiple: bool = false) -> void:
		node = p_node
		target_position = node.position
		is_multiple = p_is_multiple
	
	func move_by(relative: Vector2, grid_snap: Vector2) -> void:
		target_position += relative
		node.position = target_position.snapped(grid_snap)
