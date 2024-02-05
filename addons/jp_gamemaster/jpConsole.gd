class_name jpConsole
extends RefCounted


static func print_method(object: Object, message: String = "", method_name: String = "", args: Array = []) -> void:
	var header : String = _get_print_header_method(object, method_name)
	var footer : String = _get_print_footer_args(args)
	print(header + message + footer)


static func push_warning_method(object: Object, message: String = "", method_name: String = "", args: Array = []) -> void:
	var header : String = _get_print_header_method(object, method_name)
	var footer : String = _get_print_footer_args(args)
	push_warning(header + message + footer)

static func push_error_method(object: Object, message: String = "", method_name: String = "", args: Array = []) -> void:
	var header : String = _get_print_header_method(object, method_name)
	var footer : String = _get_print_footer_args(args)
	push_error(header + message + footer)

static func _get_print_header_method(object: Object, method_name: String = "") -> String:
	var header := _pretty_typeof_object(object)
	if not method_name.is_empty(): header += ":%s | " % [method_name]
	return header

static func _get_print_footer_args(args: Array = []) -> String:
	return "" if args.is_empty() else " | Args: %s" % [args]


static func pretty_typeof(value: Variant) -> String:
	var type : int = typeof(value)
	var pretty_type : String
	if type == TYPE_OBJECT and is_instance_valid(value):
		pretty_type = _pretty_typeof_object(value)
	elif type == TYPE_ARRAY:
		pretty_type = _pretty_typeof_array(value)
	else:
		pretty_type = type_string(typeof(value))
	return pretty_type

static func _pretty_typeof_object(object: Object) -> String:
	var pretty_type : String = object.get_class()
	var object_script: Script = object.get_script()
	if object is Script:
		object_script = object
	if is_instance_valid(object_script):
		pretty_type = object_script.get_instance_base_type()
		var object_name: String = object_script.resource_path.get_file()
		pretty_type += "<%s>" % [object_name]
	return pretty_type

static func _pretty_typeof_array(array: Array) -> String:
	var pretty_type : String = type_string(typeof(array))
	var element_type := array.get_typed_builtin()
	if element_type != TYPE_NIL:
		var element_pretty_type: String
		if element_type == TYPE_OBJECT:
			if array.is_empty():
				element_pretty_type = array.get_typed_class_name()
			else:
				element_pretty_type = _pretty_typeof_object(array.front())
		else:
			element_pretty_type = type_string(typeof(element_type))
		pretty_type += "[%s]" % element_pretty_type
	return pretty_type


static func print_dict_types(msg: String, data: Dictionary, print_values: bool = false) -> void:
	for key in data.keys():
		var value = data[key]
		msg += "\n\t%s : %s" % [key, jpConsole.pretty_typeof(value)]
		if print_values: msg += " = %s" % [value]
	print(msg)
