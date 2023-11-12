class_name jpSerialize
extends RefCounted
## Static class for serializing values.

const ID_INST_TO_DICT = "@path"
const ID_SERIALIZE = "@jpSerialize"

const ID_VECTOR2 = jpConsole.PRETTY_TYPES[TYPE_VECTOR2]
const ID_VECTOR3 = jpConsole.PRETTY_TYPES[TYPE_VECTOR3]
const ID_VECTOR4 = jpConsole.PRETTY_TYPES[TYPE_VECTOR4]
const ID_COLOR = jpConsole.PRETTY_TYPES[TYPE_COLOR]


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
			string = float_to_str(value)
		TYPE_STRING:
			string = var_to_str(value)
		TYPE_VECTOR2:
			var dict: Dictionary = vec2_to_dict(value)
			string = to_str(dict)
		TYPE_VECTOR2I:
			string = var_to_str(value)
		TYPE_RECT2:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_RECT2I:
			string = var_to_str(value)
		TYPE_VECTOR3:
			var dict: Dictionary = vec3_to_dict(value)
			string = to_str(dict)
		TYPE_VECTOR3I:
			string = var_to_str(value)
		TYPE_TRANSFORM2D:
			_push_warning_unsupported_type(value)
			string = var_to_str(value)
		TYPE_VECTOR4:
			var dict: Dictionary = vec4_to_dict(value)
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
			var dict: Dictionary = color_to_dict(value)
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
				var dict_str: Dictionary = serialize_dict(dict)
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
			var dict_str: Dictionary = serialize_dict(value)
			string = var_to_str(dict_str)
		TYPE_ARRAY:
			var array_str: Array[String] = serialize_array(value)
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


static func to_var(string: String) -> Variant:
	var value: Variant = str_to_var(string)
	if typeof(value) == TYPE_DICTIONARY:
		var dict: Dictionary = {}
		for key_str in value.keys():
			var key: Variant = to_var(key_str)
			dict[key] = to_var(value[key_str])
		
		if dict.has(ID_INST_TO_DICT):
			value = dict_to_inst(dict)
		elif dict.has(ID_SERIALIZE):
			match dict[ID_SERIALIZE]:
				ID_VECTOR2:
					value = dict_to_vec2(dict)
				ID_VECTOR3:
					value = dict_to_vec3(dict)
				ID_VECTOR4:
					value = dict_to_vec4(dict)
				ID_COLOR:
					value = dict_to_color(dict)
		else:
			value = dict
	return value


static func float_to_str(value: float) -> String:
	return JSON.stringify(value, "", true, true)


static func vec2_to_dict(value: Vector2) -> Dictionary:
	return {
		ID_SERIALIZE: ID_VECTOR2,
		"x": value.x,
		"y": value.y,
	}

static func dict_to_vec2(dict: Dictionary) -> Vector2:
	return Vector2(
		dict.get("x", 0.0),
		dict.get("y", 0.0)
	)


static func vec3_to_dict(value: Vector3) -> Dictionary:
	return {
			ID_SERIALIZE: ID_VECTOR3,
			"x": value.x,
			"y": value.y,
			"z": value.z,
	}

static func dict_to_vec3(dict: Dictionary) -> Vector3:
	return Vector3(
		dict.get("x", 0.0),
		dict.get("y", 0.0),
		dict.get("z", 0.0),
	)


static func vec4_to_dict(value: Vector4) -> Dictionary:
	return {
		ID_SERIALIZE: ID_VECTOR4,
		"x": value.x,
		"y": value.y,
		"z": value.z,
		"w": value.w,
	}

static func dict_to_vec4(dict: Dictionary) -> Vector4:
	return Vector4(
		dict.get("x", 0.0),
		dict.get("y", 0.0),
		dict.get("z", 0.0),
		dict.get("w", 0.0),
	)


static func color_to_dict(value: Color) -> Dictionary:
	return {
		ID_SERIALIZE: ID_COLOR,
		"r": value.r,
		"g": value.g,
		"b": value.b,
		"a": value.a,
	}

static func dict_to_color(dict: Dictionary) -> Color:
	return Color(
		dict.get("r", 0.0),
		dict.get("g", 0.0),
		dict.get("b", 0.0),
		dict.get("a", 1.0),
	)


static func serialize_array(array: Array) -> Array[String]:
	var array_str: Array[String] = []
	array_str.resize(array.size())
	for idx in range(array.size()):
		array_str[idx] = to_str(array[idx])
	return array_str

static func deserialize_array(array_str: Array[String]) -> Array:
	var array: Array = []
	array.resize(array_str.size())
	for idx in range(array_str.size()):
		array[idx] = to_var(array_str[idx])
	return array


static func serialize_dict(dict: Dictionary) -> Dictionary:
	var dict_str: Dictionary = {}
	for key in dict.keys():
		var key_str: String = to_str(key)
		dict_str[key_str] = to_str(dict[key])
	return dict_str

static func deserialize_dict(dict_str: Dictionary) -> Dictionary:
	var dict: Dictionary = {}
	for key_str in dict_str.keys():
		var key: Variant = to_var(key_str)
		dict[key] = to_var(dict_str[key_str])
	return dict



static func _push_warning_unsupported_type(value: Variant) -> void:
	push_warning("Unsupported type: %s | May yield unexpected results.")
