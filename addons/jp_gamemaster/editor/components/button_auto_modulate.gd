@tool
extends CanvasItem

@export var button: BaseButton

@export_group("Modulate")
@export var modulate_normal: Color = Color.WHITE:
	set(value):
		modulate_normal = value
		_update_modulate()
@export var modulate_pressed: Color = Color.WHITE:
	set(value):
		modulate_pressed = value
		_update_modulate()
@export var modulate_hover: Color = Color.WHITE:
	set(value):
		modulate_hover = value
		_update_modulate()
@export var modulate_disabled: Color = Color.WHITE:
	set(value):
		modulate_disabled = value
		_update_modulate()
@export var modulate_hover_pressed: Color = Color.WHITE:
	set(value):
		modulate_hover_pressed = value
		_update_modulate()


func _ready() -> void:
	if not is_instance_valid(button):
		return
	button.draw.connect(_update_modulate)


func _update_modulate() -> void:
	if not is_instance_valid(button):
		return
	var color: Color = Color.WHITE
	match button.get_draw_mode():
		BaseButton.DRAW_NORMAL:
			color = modulate_normal
		BaseButton.DRAW_PRESSED:
			color = modulate_pressed
		BaseButton.DRAW_HOVER:
			color = modulate_hover
		BaseButton.DRAW_DISABLED:
			color = modulate_disabled
		BaseButton.DRAW_HOVER_PRESSED:
			color = modulate_hover_pressed
	
	if color != modulate:
		modulate = color
