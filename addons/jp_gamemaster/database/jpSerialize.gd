class_name jpSerialize
extends RefCounted


static func to_str(value: Variant) -> String:
	var serialized: String
	var should_use_inst_to_dict: bool = (
		is_instance_valid(value)
		and value.get_script() != null
		and (value.resource_path.is_empty() if value is Resource else true)
	)
	if should_use_inst_to_dict:
		var dict: Dictionary = inst_to_dict(value)
		for key in dict.keys():
			dict[key] = to_str(dict[key])
		serialized = var_to_str(dict)
	elif typeof(value) == TYPE_FLOAT:
		# check https://github.com/godotengine/godot/issues/78204
		serialized = JSON.stringify(value, "", true, true)
	else:
		serialized = var_to_str(value)
	return serialized


static func to_var(string: String) -> Variant:
	var value: Variant = str_to_var(string)
	if typeof(value) == TYPE_DICTIONARY:
		for key in value.keys():
			if typeof(value[key]) == TYPE_STRING:
				value[key] = to_var(value[key])
		if value.has("@path"):
			var object = dict_to_inst(value)
			if is_instance_valid(object):
				value = object
	return value

