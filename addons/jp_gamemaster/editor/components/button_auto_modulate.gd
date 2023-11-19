@tool
extends CanvasItem

@export var button: BaseButton

@export_group("Modulate")
@export var modulate_normal: Color = Color.WHITE
@export var modulate_pressed: Color = Color.WHITE
@export var modulate_hover: Color = Color.WHITE
@export var modulate_disabled: Color = Color.WHITE
@export var modulate_hover_pressed: Color = Color.WHITE


func _ready() -> void:
	button.draw.connect(_update_label)


func _update_label() -> void:
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
