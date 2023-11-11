extends Object

var name: String
var number: int
var color: Color

func _init(
		p_name: String = "",
		p_number: int = -1,
		p_color: Color = Color.TRANSPARENT
) -> void:
	name = p_name
	number = p_number
	color = p_color


class SubClass:
	var name
	var number
	var color: Color
	
	func _init(
			p_name: String = "",
			p_number: int = -1,
			p_color: Color = Color.TRANSPARENT
	) -> void:
		name = p_name
		number = p_number
		color = p_color
