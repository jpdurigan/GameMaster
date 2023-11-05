extends GutTest

const SAVE_DESERIALIZED_TO = "res://.godot/game_master/debug_serialized.json"

const CustomResource = preload("res://addons/jp_gamemaster/tests/database/custom_resource.gd")
const CustomObject = preload("res://addons/jp_gamemaster/tests/database/custom_object.gd")

const VALUE_BOOL = true
const VALUE_INT = 1234567890
const VALUE_FLOAT = PI
const VALUE_STRING = "string"
const VALUE_VECTOR2 = Vector2.ONE
const VALUE_VECTOR2I = Vector2i.ONE
const VALUE_RECT2 = Rect2(Vector2.ZERO, Vector2(100, 100))
const VALUE_RECT2I = Rect2i(Vector2i.ZERO, Vector2i(100, 100))
const VALUE_COLOR = Color.AQUA
const VALUE_STRING_NAME = &"StringName"
const VALUE_DICTIONARY = { "dictionary": true }
const VALUE_ARRAY = [ 0, true, "a", Vector2.DOWN, { "key": "value" } ]

# Objects
var VALUE_PACKED_INT64_ARRAY = PackedInt64Array([ 1, 2, 3, 5, 8, 13 ])
var VALUE_PACKED_STRING_ARRAY = PackedStringArray([ "a", "b", "c" ])
var VALUE_PACKED_COLOR_ARRAY = PackedColorArray([ Color.RED, Color.GREEN, Color.BLUE ])
var VALUE_RESOURCE = Gradient.new()
var VALUE_CUSTOM_OBJECT = CustomObject.new("João", 35, Color.YELLOW_GREEN)
var VALUE_CUSTOM_RESOURCE = CustomResource.new("Pedro", 18, Color.NAVY_BLUE)
var VALUE_CUSTOM_SUBCLASS = CustomObject.SubClass.new("Maria", 28, Color.HOT_PINK)
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
	_test_serialize_value(VALUE_RESOURCE)

func test_serialize_custom_object() -> void:
	_test_serialize_value(VALUE_CUSTOM_OBJECT)

func test_serialize_custom_resource() -> void:
	_test_serialize_value(VALUE_CUSTOM_RESOURCE)

func test_serialize_custom_subclass() -> void:
	_test_serialize_value(VALUE_CUSTOM_SUBCLASS)


func _test_serialize_value(value: Variant) -> void:
	var type: String = jpConsole.pretty_typeof(value)
	var database := jpDatabase.new()
	var serialized = database._serialize_value(value)
	_handle_debug_data(type, serialized)
	assert_not_null(serialized, "%s serialized should be not null" % [type])
	assert_typeof(serialized, TYPE_STRING, "%s serialized should be string" % [type])
	
	var deserialized = database._deserialize_value(serialized)
	assert_not_null(deserialized, "%s deserialized should be not null" % [type])
	assert_typeof(deserialized, typeof(value), "%s deserialized should be type %s" % [type])
	assert_eq_deep(value, deserialized)


func _handle_debug_data(type: String, serialized: String) -> void:
	_debug_data[type] = serialized
	if SAVE_DESERIALIZED_TO:
		var file := FileAccess.open(SAVE_DESERIALIZED_TO, FileAccess.WRITE_READ)
		if file:
			file.store_string(JSON.stringify(_debug_data, "\t"))
			file.close()
		else:
			push_error(FileAccess.get_open_error())
