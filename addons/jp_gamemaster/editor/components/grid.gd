@tool
extends Control

@export var grid_size: float = 128.0
@export var grid_width: float = 0.8
@export var grid_subunits: int = 4
@export var grid_subunit_width: float = 0.4
@export var grid_background_color: Color = Color.WHITE
@export var grid_color: Color = Color.BLACK

@export var camera: Camera2D


func _ready() -> void:
	if camera:
		camera.draw.connect(queue_redraw)


func _draw() -> void:
	# draw background
	var bg_rect: Rect2 = get_viewport_rect()
	if camera:
		bg_rect.position = camera.position
	draw_rect(bg_rect, grid_background_color)
	
	# draw grid
	var grid_offset: Vector2 = bg_rect.position.posmod(grid_size)
	var grid_start_pos: Vector2 = bg_rect.position - grid_offset
	var grid_rect_size: Vector2 = bg_rect.size + Vector2.ONE * grid_size
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
