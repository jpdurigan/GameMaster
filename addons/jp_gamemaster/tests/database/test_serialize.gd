extends GutTest

const SAVE_DESERIALIZED_TO = "res://.godot/game_master/debug_serialized.json"
const SAVE_TO_JSON_PATH = "res://.godot/game_master/debug_serialized.json"

const CustomResource = preload("res://addons/jp_gamemaster/tests/database/custom_resource.gd")
const CustomObject = preload("res://addons/jp_gamemaster/tests/database/custom_object.gd")

const VALUE_BOOL = true
const VALUE_INT = 1234567890
const VALUE_FLOAT = PI
const VALUE_STRING = "String"
const VALUE_VECTOR2 = Vector2.ONE
const VALUE_VECTOR2I = Vector2i.ONE
const VALUE_RECT2 = Rect2(Vector2.ZERO, Vector2(100, 100))
const VALUE_RECT2I = Rect2i(Vector2i.ZERO, Vector2i(100, 100))
const VALUE_COLOR = Color.AQUAMARINE
const VALUE_STRING_NAME = &"StringName"
const VALUE_DICTIONARY = { "dictionary": true }
const VALUE_ARRAY = [ 0, true, "a", Vector2.DOWN, { "key": "value" } ]

# Objects
var VALUE_PACKED_INT64_ARRAY = PackedInt64Array([ 1, 2, 3, 5, 8, 13 ])
var VALUE_PACKED_STRING_ARRAY = PackedStringArray([ "a", "b", "c" ])
var VALUE_PACKED_COLOR_ARRAY = PackedColorArray([ Color.RED, Color.GREEN, Color.BLUE ])
var VALUE_RESOURCE = CircleShape2D.new()
var VALUE_CUSTOM_OBJECT = CustomObject.new(VALUE_STRING, VALUE_INT, VALUE_COLOR)
var VALUE_CUSTOM_RESOURCE = CustomResource.new(VALUE_STRING, VALUE_INT, VALUE_COLOR)
var VALUE_CUSTOM_SUBCLASS = CustomObject.SubClass.new(VALUE_STRING, VALUE_INT, VALUE_COLOR)
var VALUE_EXTERNAL_RESOURCE = load("res://addons/jp_gamemaster/tests/database/test.svg")
var VALUE_CUSTOM_EXTERNAL_RESOURCE = load("res://addons/jp_gamemaster/tests/database/test_resource.tres")
var VALUE_ARRAY_OBJECT = [
	CustomObject.new("Leonardo", 13, Color.BLUE),
	CustomObject.new("Michelangelo", 13, Color.ORANGE),
	CustomObject.new("Donatello", 13, Color.PURPLE),
	CustomObject.new("Rafael", 13, Color.RED),
]
var VALUE_ARRAY_RESOURCE = [
	CustomResource.new("Leonardo", 13, Color.BLUE),
	CustomResource.new("Michelangelo", 13, Color.ORANGE),
	CustomResource.new("Donatello", 13, Color.PURPLE),
	CustomResource.new("Rafael", 13, Color.RED),
]
var VALUE_ARRAY_SUBCLASS = [
	CustomObject.SubClass.new("Leonardo", 13, Color.BLUE),
	CustomObject.SubClass.new("Michelangelo", 13, Color.ORANGE),
	CustomObject.SubClass.new("Donatello", 13, Color.PURPLE),
	CustomObject.SubClass.new("Rafael", 13, Color.RED),
]

# "Stress" tests
var VALUE_ARRAY_VARIANT = [
	VALUE_BOOL,
	VALUE_INT,
	VALUE_STRING,
	VALUE_STRING_NAME,
	VALUE_RECT2,
	[ VALUE_BOOL, VALUE_INT, VALUE_STRING, VALUE_STRING_NAME, VALUE_VECTOR2 ],
	{ "dict": true, "value": VALUE_INT, "tags": [ VALUE_COLOR, VALUE_STRING, VALUE_ARRAY ] },
	VALUE_RESOURCE,
	VALUE_CUSTOM_RESOURCE,
	VALUE_EXTERNAL_RESOURCE,
	VALUE_CUSTOM_EXTERNAL_RESOURCE
]
var VALUE_DICTIONARY_VARIANT = {
	VALUE_BOOL: VALUE_BOOL,
	VALUE_INT: VALUE_INT,
	VALUE_STRING: VALUE_STRING,
	VALUE_STRING_NAME: VALUE_STRING_NAME,
	"dict": {
		"dict": {
			"dict": {
				"array": VALUE_ARRAY,
			},
			"color": VALUE_COLOR,
		},
		"Rect2": VALUE_RECT2,
		"Vector2i": VALUE_VECTOR2I,
	},
	"resource": VALUE_RESOURCE,
	"custom resource": VALUE_CUSTOM_RESOURCE,
	"resource external": VALUE_EXTERNAL_RESOURCE,
	"custom resource external": VALUE_CUSTOM_EXTERNAL_RESOURCE,
}
var VALUE_RECURSIVE_OBJECT = CustomObject.new(
	"recursive object",
	42,
	Color.GREEN_YELLOW,
	[ 
		CustomObject.new("object1"),
		CustomObject.new("object2"),
		CustomObject.new("object3"),
	]
)
var VALUE_RECURSIVE_SUBCLASS = CustomObject.SubClass.new(
	"recursive subclass",
	42,
	Color.GREEN_YELLOW,
	[
		CustomObject.SubClass.new("subclass1"),
		CustomObject.SubClass.new("subclass2"),
		CustomObject.SubClass.new("subclass3"),
	]
)
var VALUE_RECURSIVE_RESOURCE = CustomResource.new(
	"recursive resource",
	42,
	Color.GREEN_YELLOW,
	[
		CustomResource.new("resource1"),
		CustomResource.new("resource2"),
		CustomResource.new("resource3"),
	]
)
var VALUE_RECURSIVE_EXTERNAL_RESOURCE = load("res://addons/jp_gamemaster/tests/database/test_resource_recursive.tres")


var VALUE_SAVE_TO_JSON: Dictionary = {
	&"VALUE_BOOL": VALUE_BOOL,
	&"VALUE_INT": VALUE_INT,
	&"VALUE_FLOAT": VALUE_FLOAT,
	&"VALUE_VECTOR2": VALUE_VECTOR2,
	&"VALUE_COLOR": VALUE_COLOR,
	&"VALUE_STRING_NAME": VALUE_STRING_NAME,
	&"VALUE_ARRAY": VALUE_ARRAY,
	&"VALUE_DICTIONARY": VALUE_DICTIONARY,
	&"VALUE_PACKED_INT64_ARRAY": VALUE_PACKED_INT64_ARRAY,
	&"VALUE_PACKED_STRING_ARRAY": VALUE_PACKED_STRING_ARRAY,
	&"VALUE_PACKED_COLOR_ARRAY": VALUE_PACKED_COLOR_ARRAY,
	&"VALUE_CUSTOM_OBJECT": VALUE_CUSTOM_OBJECT,
	&"VALUE_CUSTOM_RESOURCE": VALUE_CUSTOM_RESOURCE,
	&"VALUE_CUSTOM_SUBCLASS": VALUE_CUSTOM_SUBCLASS,
	&"VALUE_EXTERNAL_RESOURCE": VALUE_EXTERNAL_RESOURCE,
	&"VALUE_CUSTOM_EXTERNAL_RESOURCE": VALUE_CUSTOM_EXTERNAL_RESOURCE,
	&"VALUE_ARRAY_OBJECT": VALUE_ARRAY_OBJECT,
	&"VALUE_ARRAY_RESOURCE": VALUE_ARRAY_RESOURCE,
	&"VALUE_ARRAY_SUBCLASS": VALUE_ARRAY_SUBCLASS,
	&"VALUE_RECURSIVE_OBJECT": VALUE_RECURSIVE_OBJECT,
	&"VALUE_RECURSIVE_SUBCLASS": VALUE_RECURSIVE_SUBCLASS,
	&"VALUE_RECURSIVE_RESOURCE": VALUE_RECURSIVE_RESOURCE,
	&"VALUE_RECURSIVE_EXTERNAL_RESOURCE": VALUE_RECURSIVE_EXTERNAL_RESOURCE,
}


var _debug_data: Dictionary = {}


func test_serialize_bool() -> void:
	_test_serialize_value(VALUE_BOOL)

func test_serialize_int() -> void:
	_test_serialize_value(VALUE_INT)

func test_serialize_float() -> void:
	_test_serialize_value(VALUE_FLOAT)

func test_serialize_string() -> void:
	_test_serialize_value(VALUE_STRING)

func test_serialize_vector2() -> void:
	_test_serialize_value(VALUE_VECTOR2)

func test_serialize_vector2i() -> void:
	_test_serialize_value(VALUE_VECTOR2I)

func test_serialize_rect2() -> void:
	_test_serialize_value(VALUE_RECT2)

func test_serialize_rect2i() -> void:
	_test_serialize_value(VALUE_RECT2I)

func test_serialize_color() -> void:
	_test_serialize_value(VALUE_COLOR)

func test_serialize_string_name() -> void:
	_test_serialize_value(VALUE_STRING_NAME)

func test_serialize_dictionary() -> void:
	_test_serialize_value(VALUE_DICTIONARY)

func test_serialize_array() -> void:
	_test_serialize_value(VALUE_ARRAY)

func test_serialize_packed_int64_array() -> void:
	_test_serialize_value(VALUE_PACKED_INT64_ARRAY)

func test_serialize_packed_string_array() -> void:
	_test_serialize_value(VALUE_PACKED_STRING_ARRAY)

func test_serialize_packed_color_array() -> void:
	_test_serialize_value(VALUE_PACKED_COLOR_ARRAY)

func test_serialize_resource() -> void:
	_test_serialize_value(VALUE_RESOURCE, "Resource (Native)")

func test_serialize_custom_object() -> void:
	_test_serialize_value(VALUE_CUSTOM_OBJECT, "Object (GDScript)")

func test_serialize_custom_resource() -> void:
	_test_serialize_value(VALUE_CUSTOM_RESOURCE, "Resource (GDScript)")

func test_serialize_custom_subclass() -> void:
	_test_serialize_value(VALUE_CUSTOM_SUBCLASS, "Object (GDScript subclass)")

func test_serialize_resource_external() -> void:
	_test_serialize_value(VALUE_EXTERNAL_RESOURCE, "Resource external")

func test_serialize_custom_external_resource() -> void:
	_test_serialize_value(VALUE_CUSTOM_EXTERNAL_RESOURCE, "Resource (GDScript) external")

func test_serialize_array_object() -> void:
	_test_serialize_value(VALUE_ARRAY_OBJECT, "Array[Object]")

func test_serialize_array_resource() -> void:
	_test_serialize_value(VALUE_ARRAY_RESOURCE, "Array[Resource]")

func test_serialize_array_subclasses() -> void:
	_test_serialize_value(VALUE_ARRAY_SUBCLASS, "Array[Subclass]")

func test_serialize_array_variant() -> void:
	_test_serialize_value(VALUE_ARRAY_VARIANT, "Array[Variant]")

func test_serialize_dictionary_variant() -> void:
	_test_serialize_value(VALUE_DICTIONARY_VARIANT, "Dictionary<Variant, Variant>")

func test_serialize_recursive_object() -> void:
	_test_serialize_value(VALUE_RECURSIVE_OBJECT, "Object recursive")

func test_serialize_recursive_subclass() -> void:
	_test_serialize_value(VALUE_RECURSIVE_SUBCLASS, "Subclass recursive")

func test_serialize_recursive_resource() -> void:
	_test_serialize_value(VALUE_RECURSIVE_RESOURCE, "Resource recursive")

func test_serialize_recursive_external_resource() -> void:
	_test_serialize_value(VALUE_RECURSIVE_EXTERNAL_RESOURCE, "Resource recursive external")


func test_save_to_json_serialized() -> void:
	pending()


func _test_serialize_value(value: Variant, type: String = "") -> void:
	if type.is_empty():
		type = jpConsole.pretty_typeof(value)
	var serialized = jpSerialize.to_str(value)
	_handle_debug_data(type, value, serialized)
	assert_not_null(serialized, "%s serialized should be not null" % [type])
	assert_typeof(serialized, TYPE_STRING, "%s serialized should be string" % [type])
	
	var deserialized = jpSerialize.to_var(serialized)
	assert_not_null(deserialized, "%s deserialized should be not null" % [type])
	assert_typeof(deserialized, typeof(value), "%s deserialized should be type %s" % [type])
	_assert_equal_by_value(value, deserialized)


## Assert that two variables are equal for their value.[br]
## That means comparings Objects through their methods and properties, not by
## reference. When loading serialized data, jpSerialize will always creates new
## instances of Objects.[br]
## There is one exception, though: Resources with a valid resource path.
## If something is saved as an external file, jpSerialize should load that
## from disk.
func _assert_equal_by_value(value: Variant, compare: Variant) -> void:
	var msg: String = "Expected %s and %s to be equal by value" % [value, compare]
	if _is_equal_by_value(value, compare):
		pass_test(msg)
	else:
		fail_test(msg)

func _is_equal_by_value(value: Variant, compare: Variant) -> bool:
	var is_equal: bool = typeof(value) == typeof(compare)
	if not is_equal:
		fail_test(
			"Expected %s<%s> and %s<%s> to be same type."
			% [
				value, jpConsole.pretty_typeof(value),
				compare, jpConsole.pretty_typeof(compare)
			]
		)
		return is_equal
	
	match typeof(value):
		TYPE_ARRAY:
			is_equal = _is_equal_by_value_array(value, compare)
		TYPE_DICTIONARY:
			is_equal = _is_equal_by_value_dict(value, compare)
		TYPE_OBJECT:
			is_equal = _is_equal_by_value_object(value, compare)
		_:
			is_equal = value == compare
	
	return is_equal

func _is_equal_by_value_array(value: Array, compare: Array) -> bool:
	var is_equal: bool = value.size() == compare.size()
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same size."
			% [value, compare]
		)
		return is_equal
	
	for idx in value.size():
		if not _is_equal_by_value(value[idx], compare[idx]):
			is_equal = false
			fail_test(
				"Difference at index %s. Expected %s to be equal %s."
				% [idx, value[idx], compare[idx]]
			)
	
	return is_equal

func _is_equal_by_value_dict(value: Dictionary, compare: Dictionary) -> bool:
	var is_equal: bool = value.size() == compare.size()
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same size."
			% [value, compare]
		)
		return is_equal
	
	var value_keys: Array = value.keys()
	value_keys.sort()
	var compare_keys: Array = compare.keys()
	compare_keys.sort()
	
	is_equal = _is_equal_by_value_array(value_keys, compare_keys)
	if not is_equal:
		fail_test(
			"Expected keys { %s } and { %s } to match."
			% [value.keys(), compare.keys()]
		)
		return is_equal
	
	for key in value.keys():
		if not _is_equal_by_value(value[key], compare[key]):
			is_equal = false
			fail_test(
				"Difference at key %s. Expected %s to be equal %s."
				% [key, value[key], compare[key]]
			)
	
	return is_equal

func _is_equal_by_value_object(value: Object, compare: Object) -> bool:
	var is_equal: bool = value.get_class() == compare.get_class()
	if not is_equal:
		fail_test(
			"Expected %s<%s> and %s<%s> to match classes."
			% [value, value.get_class(), compare, compare.get_class()]
		)
		return is_equal
	
	if value is Resource and not value.resource_path.is_empty():
		is_equal = value.resource_path == compare.resource_path
		if not is_equal:
			fail_test(
				"Expected %s and %s to be same Resource."
				% [value, compare]
			)
		return is_equal
	
	# same class
	is_equal = _is_equal_by_value(value.get_class(), compare.get_class())
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same Class."
			% [value, compare]
		)
		return is_equal
	
	# same script
	is_equal = _is_equal_by_value(value.get_script(), compare.get_script())
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same Script."
			% [value, compare]
		)
		return is_equal
	
	# same method list
	is_equal = _is_equal_by_value(value.get_method_list(), compare.get_method_list())
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same method list."
			% [value, compare]
		)
		return is_equal
	
	# same signal list
	is_equal = _is_equal_by_value(value.get_signal_list(), compare.get_signal_list())
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same signal list."
			% [value, compare]
		)
		return is_equal
	
	# same property list
	is_equal = _is_equal_by_value(value.get_property_list(), compare.get_property_list())
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same property list."
			% [value, compare]
		)
		return is_equal
	
	# same properties values
	for property_dict in value.get_property_list():
		var property_name := StringName(property_dict.name)
		if not _is_equal_by_value(value.get(property_name), compare.get(property_name)):
			is_equal = false
			fail_test(
				"Expected property %s to be equal. Got %s and %s."
				% [property_name, value.get(property_name), compare.get(property_name)]
			)
	
	if not is_equal:
		return is_equal
	
	# same meta list
	is_equal = _is_equal_by_value(value.get_meta_list(), compare.get_meta_list())
	if not is_equal:
		fail_test(
			"Expected %s and %s to have same meta list."
			% [value, compare]
		)
		return is_equal
	
	# same meta values
	for meta_name in value.get_meta_list():
		if not _is_equal_by_value(value.get_meta(meta_name), compare.get_meta(meta_name)):
			is_equal = false
			fail_test(
				"Expected metadata entry %s to be equal. Got %s and %s."
				% [meta_name, value.get_meta(meta_name), compare.get_meta(meta_name)]
			)
	
	return is_equal


func _handle_debug_data(type: String, value: Variant, serialized: String) -> void:
	if SAVE_DESERIALIZED_TO:
		_debug_data[type] = DebugData.new(type, value, serialized).to_dict()
		var file := FileAccess.open(SAVE_DESERIALIZED_TO, FileAccess.WRITE_READ)
		if file:
			file.store_string(JSON.stringify(_debug_data, "\t"))
			file.close()
		else:
			push_error(FileAccess.get_open_error())


class DebugData:
	var type: String
	var value: Variant
	var serialized: String
	
	func _init(p_type: String, p_value: Variant, p_serialized: String) -> void:
		type = p_type
		value = p_value
		serialized = p_serialized
	
	func to_dict() -> Dictionary:
		return {
			type = type,
			serialized = serialized,
			var2str = var_to_str(value),
		}
