@tool
#@icon("res://addons/jp.gamemaster/editor/icons/flaticon/metric.png")
class_name jpMetric
extends jpValue
## A jpValue that stores a numerical value.


## Valid conditions for boolean evaluation.
enum Condition {
	EQUAL_TO,
	NOT_EQUAL_TO,
	GREATER_THEN,
	GREATER_OR_EQUAL_TO,
	LESS_THEN,
	LESS_OR_EQUAL_TO,
}

## If true, Metric is treated as an integer.
@export var as_int: bool = true
## If true, Metric will only update to higher values.
@export var keep_max: bool = false

@export var _value_float: float
@export var _value_int: int

@export var _condition: Condition = Condition.NOT_EQUAL_TO
@export var _comparison: float = 0


## Returns value.
func get_value():
	var value = _value_int if as_int else _value_float
	return value

## Returns value as a boolean.
func get_bool_value() -> bool:
	var value: bool = false
	match _condition:
		Condition.EQUAL_TO:
			value = get_value() == _comparison
		Condition.NOT_EQUAL_TO:
			value = get_value() != _comparison
		Condition.GREATER_THEN:
			value = get_value() > _comparison
		Condition.GREATER_OR_EQUAL_TO:
			value = get_value() >= _comparison
		Condition.LESS_THEN:
			value = get_value() < _comparison
		Condition.LESS_OR_EQUAL_TO:
			value = get_value() <= _comparison
	return value

## Returns value as a float.
func get_float_value() -> float:
	return _value_float

## Returns value as an int.
func get_int_value() -> int:
	return _value_int

## Updates value.
func update_value(value: float) -> void:
	var should_update: bool = (
		value != _value_float
		and value > _value_float if keep_max else true
	)
	if not should_update:
		return
	
	_value_float = value
	_value_int = int(value)
	changed.emit()
