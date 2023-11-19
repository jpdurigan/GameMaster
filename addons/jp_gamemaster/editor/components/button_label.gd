@tool
extends Label

@export var button: BaseButton

@export_group("Label Settings")
@export var label_normal: LabelSettings:
	set(value):
		label_normal = value
		_update_label()
@export var label_pressed: LabelSettings:
	set(value):
		label_pressed = value
		_update_label()
@export var label_hover: LabelSettings:
	set(value):
		label_hover = value
		_update_label()
@export var label_disabled: LabelSettings:
	set(value):
		label_disabled = value
		_update_label()
@export var label_hover_pressed: LabelSettings:
	set(value):
		label_hover_pressed = value
		_update_label()


func _ready() -> void:
	if not is_instance_valid(button):
		return
	button.draw.connect(_update_label)
	_update_label()


func _update_label() -> void:
	if not is_instance_valid(button):
		return
	var settings: LabelSettings = null
	match button.get_draw_mode():
		BaseButton.DRAW_NORMAL:
			settings = label_normal
		BaseButton.DRAW_PRESSED:
			settings = label_pressed
		BaseButton.DRAW_HOVER:
			settings = label_hover
		BaseButton.DRAW_DISABLED:
			settings = label_disabled
		BaseButton.DRAW_HOVER_PRESSED:
			settings = label_hover_pressed
	
	if settings != null and settings != label_settings:
		label_settings = settings
