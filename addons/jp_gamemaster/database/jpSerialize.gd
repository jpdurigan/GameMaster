class_name jpSerialize
extends RefCounted
## Static class for serializing values.
##
## Uses [method @GlobalScope.var_to_str] and [method @GDScript.inst_to_dict]
## to serialize variables.[br][br]
## Currently working around an issue when serializing floats.
## @tutorial(Float losing precision when using var_to_str): https://github.com/godotengine/godot/issues/78204

const _ID_INST_TO_DICT = "@path"
const _ID_SERIALIZE = "@jpSerialize"

const _ID_VECTOR2 = "Vector2"
const _ID_VECTOR3 = "Vector3"
const _ID_VECTOR4 = "Vector4"
const _ID_RECT2 = "Rect2"
const _ID_COLOR = "Color"


## Returns value as a String.
static func to_str(value: Variant) -> String:
	var string: String = ""
	match typeof(value):
		TYPE_NIL:
			string = var_to_str(value)
		TYPE_BOOL:
			string = var_to_str(value)
		TYPE_INT:
			string = var_to_str(value)
		TYPE_FLOAT:
			string = _float_to_str(value)
		TYPE_STRING:
			string = var_to_str(value)
		TYPE_VECTOR2:
			var dict: Dictionary = _vec2_to_dict(value)
			string = to_str(dict)
		TYPE_VECTOR2I:
			string = var_to_str(value)
		TYPE_RECT2:
			var dict: Dictionary = _rect2_to_dict(value)
			string = to_str(dict)
		TYPE_RECT2I:
			string = var_to_str(value)
		TYPE_VECTOR3:
			var dict: Dictionary = _vec3_to_dict(value)
			string = to_str(dict)
		TYPE_VECTOR3I:
			string = var_to_str(value)
		TYPE_TRANSFORM2D:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_VECTOR4:
			var dict: Dictionary = _vec4_to_dict(value)
			string = to_str(dict)
		TYPE_VECTOR4I:
			string = var_to_str(value)
		TYPE_PLANE:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_QUATERNION:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_AABB:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_BASIS:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_TRANSFORM3D:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_PROJECTION:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_COLOR:
			var dict: Dictionary = _color_to_dict(value)
			string = to_str(dict)
		TYPE_STRING_NAME:
			string = var_to_str(value)
		TYPE_NODE_PATH:
			string = var_to_str(value)
		TYPE_RID:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_OBJECT:
			var should_use_inst_to_dict: bool = (
				is_instance_valid(value)
				and value.get_script() != null
				and (value.resource_path.is_empty() if value is Resource else true)
			)
			if should_use_inst_to_dict:
				var dict: Dictionary = inst_to_dict(value)
				var dict_str: Dictionary = _serialize_dict(dict)
				string = var_to_str(dict_str)
			else:
				string = var_to_str(value)
		TYPE_CALLABLE:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_SIGNAL:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_DICTIONARY:
			var dict_str: Dictionary = _serialize_dict(value)
			string = var_to_str(dict_str)
		TYPE_ARRAY:
			var array_str: Array[String] = _serialize_array(value)
			string = var_to_str(array_str)
		TYPE_PACKED_BYTE_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_INT32_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_INT64_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_FLOAT32_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_FLOAT64_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_STRING_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_VECTOR2_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_VECTOR3_ARRAY:
			string = var_to_str(value)
		TYPE_PACKED_COLOR_ARRAY:
			string = var_to_str(value)
	
	return string


## Returns String as a value.
static func to_var(string: String) -> Variant:
	var value: Variant = str_to_var(string)
	match typeof(value):
		TYPE_DICTIONARY:
			var dict: Dictionary = {}
			for key_str in value.keys():
				var key: Variant = to_var(key_str)
				dict[key] = to_var(value[key_str])
			
			if dict.has(_ID_INST_TO_DICT):
				value = dict_to_inst(dict)
			elif dict.has(_ID_SERIALIZE):
				match dict[_ID_SERIALIZE]:
					_ID_VECTOR2:
						value = _dict_to_vec2(dict)
					_ID_VECTOR3:
						value = _dict_to_vec3(dict)
					_ID_VECTOR4:
						value = _dict_to_vec4(dict)
					_ID_RECT2:
						value = _dict_to_rect2(dict)
					_ID_COLOR:
						value = _dict_to_color(dict)
			else:
				value = dict
		TYPE_ARRAY:
			var array: Array = []
			array.resize(value.size())
			for idx in range(value.size()):
				array[idx] = to_var(value[idx])
			value = array
	
	return value


static func _float_to_str(value: float) -> String:
	return JSON.stringify(value, "", true, true)


static func _vec2_to_dict(value: Vector2) -> Dictionary:
	return {
		_ID_SERIALIZE: _ID_VECTOR2,
		"x": value.x,
		"y": value.y,
	}

static func _dict_to_vec2(dict: Dictionary) -> Vector2:
	return Vector2(
		dict.get("x", 0.0),
		dict.get("y", 0.0)
	)


static func _vec3_to_dict(value: Vector3) -> Dictionary:
	return {
			_ID_SERIALIZE: _ID_VECTOR3,
			"x": value.x,
			"y": value.y,
			"z": value.z,
	}

static func _dict_to_vec3(dict: Dictionary) -> Vector3:
	return Vector3(
		dict.get("x", 0.0),
		dict.get("y", 0.0),
		dict.get("z", 0.0),
	)


static func _vec4_to_dict(value: Vector4) -> Dictionary:
	return {
		_ID_SERIALIZE: _ID_VECTOR4,
		"x": value.x,
		"y": value.y,
		"z": value.z,
		"w": value.w,
	}

static func _dict_to_vec4(dict: Dictionary) -> Vector4:
	return Vector4(
		dict.get("x", 0.0),
		dict.get("y", 0.0),
		dict.get("z", 0.0),
		dict.get("w", 0.0),
	)


static func _rect2_to_dict(value: Rect2) -> Dictionary:
	return {
		_ID_SERIALIZE: _ID_RECT2,
		"position": value.position,
		"size": value.size,
	}

static func _dict_to_rect2(dict: Dictionary) -> Rect2:
	return Rect2(
		dict.get("position", Vector2.ZERO),
		dict.get("size", Vector2.ZERO)
	)


static func _color_to_dict(value: Color) -> Dictionary:
	return {
		_ID_SERIALIZE: _ID_COLOR,
		"r": value.r,
		"g": value.g,
		"b": value.b,
		"a": value.a,
	}

static func _dict_to_color(dict: Dictionary) -> Color:
	return Color(
		dict.get("r", 0.0),
		dict.get("g", 0.0),
		dict.get("b", 0.0),
		dict.get("a", 1.0),
	)


static func _serialize_array(array: Array) -> Array[String]:
	var array_str: Array[String] = []
	array_str.resize(array.size())
	for idx in range(array.size()):
		array_str[idx] = to_str(array[idx])
	return array_str

static func _deserialize_array(array_str: Array[String]) -> Array:
	var array: Array = []
	array.resize(array_str.size())
	for idx in range(array_str.size()):
		array[idx] = to_var(array_str[idx])
	return array


static func _serialize_dict(dict: Dictionary) -> Dictionary:
	var dict_str: Dictionary = {}
	for key in dict.keys():
		var key_str: String = to_str(key)
		dict_str[key_str] = to_str(dict[key])
	return dict_str

static func _deserialize_dict(dict_str: Dictionary) -> Dictionary:
	var dict: Dictionary = {}
	for key_str in dict_str.keys():
		var key: Variant = to_var(key_str)
		dict[key] = to_var(dict_str[key_str])
	return dict



static func _push_warning_float_precision(value: Variant) -> void:
	push_warning(
		"Type %s will lose precision. " % type_string(typeof(value))
		+ "Check jpSerialize description for more information."
	)

static func _push_warning_unsupported_type(value: Variant) -> void:
	push_warning(
		"Unsupported type %s. " % type_string(typeof(value))
		+ "May yield unexpected results."
	)
