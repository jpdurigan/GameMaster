extends Resource

@export var name: String
@export var number: int
@export var color: Color

func _init(
		p_name: String = "",
		p_number: int = -1,
		p_color: Color = Color.TRANSPARENT
) -> void:
	name = p_name
	number = p_number
	color = p_color
