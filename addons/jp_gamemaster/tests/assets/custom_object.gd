extends Object

var name: String
var number: int
var color: Color

var _data: Array

func _init(
		p_name: String = "",
		p_number: int = -1,
		p_color: Color = Color.TRANSPARENT,
		p_data: Array = [],
) -> void:
	name = p_name
	number = p_number
	color = p_color
	_data = p_data


class SubClass:
	var name
	var number
	var color: Color
	
	var _data: Array
	
	func _init(
			p_name: String = "",
			p_number: int = -1,
			p_color: Color = Color.TRANSPARENT,
			p_data: Array = [],
	) -> void:
		name = p_name
		number = p_number
		color = p_color
		_data = p_data
