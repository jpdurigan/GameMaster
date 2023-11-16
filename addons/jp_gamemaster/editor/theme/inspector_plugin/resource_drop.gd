@tool
extends HBoxContainer

@export var allowed_classes: Array[StringName]
@export var allowed_scripts: Array[String]

var resource_path: String = "":
	set(value):
		resource_path = value
		if not is_node_ready():
			await ready
		_path.text = resource_path
		_close.visible = not resource_path.is_empty()

@onready var _path: LineEdit = %path
@onready var _close: Button = %close


func _ready() -> void:
	_close.pressed.connect(_on_close_pressed)
	mouse_exited.connect(_highlight_off)
	_highlight_off()


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var is_valid: bool = _is_valid_drop_data(at_position, data)
	if is_valid:
		_highlight_on()
	else:
		_highlight_off()
	return is_valid


func _is_valid_drop_data(at_position: Vector2, data: Variant) -> bool:
	var valid_rect := Rect2(Vector2.ZERO, size)
	var is_valid_position: bool = valid_rect.has_point(at_position)
	if not is_valid_position:
		return false
	
	var is_dictionary: bool = typeof(data) == TYPE_DICTIONARY
	if not is_dictionary:
		return false
	
	var is_type_files: bool = data.get("type", "") == "files"
	if not is_type_files:
		return false
	
	var files: PackedStringArray = data.get("files", PackedStringArray())
	var is_single_file: bool = files.size() == 1
	if not is_single_file:
		return false
	
	var file_path: String = files[0]
	if not allowed_scripts.is_empty():
		var dependencies := ResourceLoader.get_dependencies(file_path)
		var has_allowed_script := _has_any_match(allowed_scripts, dependencies)
		if has_allowed_script:
			return true
	
	var file: Object = load(file_path)
	var file_classes: Array[StringName] = _get_class_heritance(file)
	var has_allowed_class: bool = _has_any_match(allowed_classes, file_classes)
	return has_allowed_class


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	resource_path = data["files"][0]


func _highlight_on() -> void:
	if not _path.has_focus():
		_path.grab_focus.call_deferred()

func _highlight_off() -> void:
	if _path.has_focus():
		_path.release_focus()


# Expected this to work :(
#func _has_any_match(array1: Array, array2: Array) -> bool:
#	return array1.any(func(value): array2.has(value))

func _has_any_match(array1: Array, array2: Array) -> bool:
	for value in array1:
		if array2.has(value):
			return true
	return false

 
func _get_class_heritance(object: Object) -> Array[StringName]:
	var classes: Array[StringName] = []
	var class_to_compare: StringName = object.get_class()
	while class_to_compare != &"" and not classes.has(class_to_compare): 
		classes.append(class_to_compare)
		class_to_compare = ClassDB.get_parent_class(class_to_compare)
	return classes


func _on_close_pressed() -> void:
	resource_path = ""