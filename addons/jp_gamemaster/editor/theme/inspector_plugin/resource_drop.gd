@tool
extends HBoxContainer

signal resource_changed(resource_path: String)

@export var allowed_classes: Array[StringName]:
	set(value):
		allowed_classes = value
		_allowed_global_classes.assign(
			ProjectSettings.get_global_class_list().filter(
				func (class_dict): return allowed_classes.has(class_dict.class)
			)
		)
		_allowed_classes_paths.assign(
			_allowed_global_classes.map(
				func (class_dict): return class_dict.path
			)
		)

var resource_path: String = "":
	set(value):
		resource_path = value
		if not is_node_ready():
			await ready
		_path.text = (
			".../%s" % resource_path.get_file()
			if resource_path.is_absolute_path()
			else resource_path
		)
		_path.tooltip_text = resource_path
		_close.visible = not resource_path.is_empty()
		resource_changed.emit(resource_path)

var property_name: String = "":
	set(value):
		property_name = value.get_slice("/", value.get_slice_count("/") - 1)
		if not is_node_ready():
			await ready
		_property.text = property_name

var _allowed_global_classes: Array[Dictionary]
var _allowed_classes_paths: Array[String]

@onready var _property: Label = %property
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
	
	var resource: Resource
	var data_type: String = data.get("type", "")
	match data_type:
		"files":
			var files: PackedStringArray = data.get("files", PackedStringArray())
			var is_single_file: bool = files.size() == 1
			
			if not is_single_file:
				return false
			
			var file_path: String = files[0]
			resource = load(file_path)
		"resource":
			resource = data.get("resource")
		"", _:
			jpConsole.push_error_method(
				self,
				"Unknown type: %s" % [data_type],
				"_is_valid_drop_data",
				[data]
			)
			return false
	
	if not _allowed_classes_paths.is_empty():
		var resource_dependencies: Array[String]
		resource_dependencies.assign(
			ResourceLoader.get_dependencies(resource.resource_path)
		)
		var has_allowed_class: bool = _has_any_match(
			_allowed_classes_paths,
			resource_dependencies
		)
		if has_allowed_class:
			return true
	
	var file_classes: Array[StringName] = _get_class_heritance(resource)
	var has_allowed_class: bool = _has_any_match(allowed_classes, file_classes)
	return has_allowed_class


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var data_type: String = data.get("type", "")
	match data_type:
		"files":
			resource_path = data["files"][0]
		"resource":
			resource_path = data["resource"].resource_path


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
