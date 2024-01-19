@tool
extends Control

@export var grid_size: float = 128.0:
	set(value):
		grid_size = value
		queue_redraw()
@export var grid_width: float = 0.8:
	set(value):
		grid_width = value
		queue_redraw()
@export var grid_subunits: int = 4:
	set(value):
		grid_subunits = value
		queue_redraw()
@export var grid_subunit_width: float = 0.4:
	set(value):
		grid_subunit_width = value
		queue_redraw()
@export var grid_background_color: Color = Color.WHITE:
	set(value):
		grid_background_color = value
		queue_redraw()
@export var grid_color: Color = Color.BLACK:
	set(value):
		grid_color = value
		queue_redraw()

@export var root: Control


func _ready() -> void:
	root.draw.connect(queue_redraw)
	root.item_rect_changed.connect(queue_redraw)


func _draw() -> void:
	# draw background
	var bg_rect := Rect2(-root.position, root.size)
	draw_rect(bg_rect, grid_background_color)
	
	# draw grid
	var grid_offset: Vector2 = bg_rect.position.posmod(grid_size)
	var grid_start_pos: Vector2 = (bg_rect.position - grid_offset) / root.scale
	var grid_rect_size: Vector2 = (bg_rect.size + Vector2.ONE * grid_size) / root.scale
	var grid_rect := Rect2(grid_start_pos, grid_rect_size)
	
	# draw vertical lines
	var x: float = grid_rect.position.x
	while x <= grid_rect.end.x:
		draw_line(
			Vector2(x, grid_rect.position.y),
			Vector2(x, grid_rect.end.y),
			grid_color,
			grid_width,
			true
		)
		for idx in range(1, grid_subunits):
			var subunit_offset: float = grid_size * idx / grid_subunits
			draw_line(
				Vector2(x + subunit_offset, grid_rect.position.y),
				Vector2(x + subunit_offset, grid_rect.end.y),
				grid_color,
				grid_subunit_width,
				true
			)
		x += grid_size
	
	# draw horizontal lines
	var y: float = grid_rect.position.y
	while y <= grid_rect.end.y:
		draw_line(
			Vector2(grid_rect.position.x, y),
			Vector2(grid_rect.end.x, y),
			grid_color,
			grid_width,
			true
		)
		for idx in range(1, grid_subunits):
			var subunit_offset: float = grid_size * idx / grid_subunits
			draw_line(
				Vector2(grid_rect.position.x, y + subunit_offset),
				Vector2(grid_rect.end.x, y + subunit_offset),
				grid_color,
				grid_subunit_width,
				true
			)
		y += grid_size


func get_grid_snap() -> Vector2:
	return Vector2.ONE * grid_size / grid_subunits
