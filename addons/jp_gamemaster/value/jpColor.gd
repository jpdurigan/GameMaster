@tool
#@icon("res://addons/jp.gamemaster/editor/icons/flaticon/flag.png")
class_name jpColor
extends jpValue
## A jpValue that stores a [Color] value.


@export var _value: Color


## Returns value.
func get_value() -> Variant:
	return _value

## Returns value as a Color.
func get_color_value() -> Color:
	return get_value()

## Updates value.
func update_value(value: Color) -> void:
	if _value == value:
		return
	
	_value = value
	changed.emit()
