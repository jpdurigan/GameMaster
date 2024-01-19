@tool
extends Button

@export var label_text: String = "":
	set(value):
		label_text = value
		if not is_node_ready():
			await ready
		label.text = label_text
@export var label: Label

@export_group("Modulate (Self)")
@export var modulate_normal: Color = Color.WHITE:
	set(value):
		modulate_normal = value
		queue_redraw()
@export var modulate_pressed: Color = Color.WHITE:
	set(value):
		modulate_pressed = value
		queue_redraw()
@export var modulate_hover: Color = Color.WHITE:
	set(value):
		modulate_hover = value
		queue_redraw()
@export var modulate_disabled: Color = Color.WHITE:
	set(value):
		modulate_disabled = value
		queue_redraw()
@export var modulate_hover_pressed: Color = Color.WHITE:
	set(value):
		modulate_hover_pressed = value
		queue_redraw()

@export_group("Modulate (Label)")
@export var label_modulate_normal: Color = Color.WHITE:
	set(value):
		label_modulate_normal = value
		queue_redraw()
@export var label_modulate_pressed: Color = Color.WHITE:
	set(value):
		label_modulate_pressed = value
		queue_redraw()
@export var label_modulate_hover: Color = Color.WHITE:
	set(value):
		label_modulate_hover = value
		queue_redraw()
@export var label_modulate_disabled: Color = Color.WHITE:
	set(value):
		label_modulate_disabled = value
		queue_redraw()
@export var label_modulate_hover_pressed: Color = Color.WHITE:
	set(value):
		label_modulate_hover_pressed = value
		queue_redraw()


func _draw() -> void:
	var color: Color = Color.WHITE
	var label_color: Color = Color.WHITE
	
	match get_draw_mode():
		BaseButton.DRAW_NORMAL:
			color = modulate_normal
			label_color = label_modulate_normal
		BaseButton.DRAW_PRESSED:
			color = modulate_pressed
			label_color = label_modulate_pressed
		BaseButton.DRAW_HOVER:
			color = modulate_hover
			label_color = label_modulate_hover
		BaseButton.DRAW_DISABLED:
			color = modulate_disabled
			label_color = label_modulate_disabled
		BaseButton.DRAW_HOVER_PRESSED:
			color = modulate_hover_pressed
			label_color = label_modulate_hover_pressed
	
	if color != self_modulate:
		self_modulate = color
	if label_color != label.self_modulate:
		label.self_modulate = label_color
