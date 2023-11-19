@tool
extends Label

@export var button: BaseButton

@export_group("Label Settings")
@export var label_normal: LabelSettings
@export var label_pressed: LabelSettings
@export var label_hover: LabelSettings
@export var label_disabled: LabelSettings
@export var label_hover_pressed: LabelSettings


func _ready() -> void:
	button.draw.connect(_update_label)


func _update_label() -> void:
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
