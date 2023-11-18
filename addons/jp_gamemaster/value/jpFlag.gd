@tool
#@icon("res://addons/jp.gamemaster/editor/icons/flaticon/flag.png")
class_name jpFlag
extends jpValue
## A jpValue that stores a boolean value.


@export var _value: bool


## Returns value.
func get_value() -> bool:
	return _value

## Returns value as a boolean.
func get_bool_value() -> bool:
	return get_value()

## Updates value.
func update_value(value: bool) -> void:
	if _value == value:
		return
	
	_value = value
	changed.emit()
