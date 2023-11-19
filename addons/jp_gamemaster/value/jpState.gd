@tool
#@icon("res://addons/jp.gamemaster/editor/icons/flaticon/state.png")
class_name jpState
extends jpValue
## A jpValue that stores an enum value.


## Valid conditions for boolean evaluation.
enum Condition {
	EQUAL_TO,
	NOT_EQUAL_TO,
}

## List of valid enum values. 
@export var valid_values: Array[String]
@export var _value: int

@export var _condition: Condition = Condition.NOT_EQUAL_TO
@export var _comparison: int = 0


## Returns value.
func get_value() -> Variant:
	return _value

## Returns value as a boolean. Uses [enum jpState.Condition].
func get_bool_value() -> bool:
	var value: bool = false
	match _condition:
		Condition.EQUAL_TO:
			value = get_value() == _comparison
		Condition.NOT_EQUAL_TO:
			value = get_value() != _comparison
	return value

## Returns a value name.
func get_value_name(value: int = _value) -> String:
	if value >= valid_values.size():
		return "Invalid"
	return valid_values[value]

## Updates value.
func update_value(value: int) -> void:
	value = clampi(value, 0, valid_values.size())
	if _value == value:
		return
	
	_value = value
	changed.emit()
