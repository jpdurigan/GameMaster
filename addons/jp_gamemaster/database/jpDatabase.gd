@tool
class_name jpDatabase
extends Resource
## Resource for storing Variant entries in a database with StringName keys.
##
## Essentially, a Dictionary that can be saved - as a resource, as a JSON file
## or string. It uses CRUD for data operations
## and Dictionary methods if you need to iterate throught it.[br]
## This resource raises warnings when [method create]-ing an entry with an
## existing key or [method update]-ing a non-exiting key.
## You can use [method add] if you don't care about overwriting keys.
## [method delete]-ing a non-existing key raises an error.[br]
## You may dismiss this with [method ignore_warnings] and
## [method ignore_errors]. You may [method treat_warnings_as_errors]
## if you wanna be strict about it (errors abort the operation).[br]
## If your dealing with non-Resource and/or saving to JSON, it's recommended to
## [method serialize_data].


## Raw database.
@export var _data: Dictionary
@export var _serialize_data_on_json: bool = false
@export var _ignore_warnings: bool = false
@export var _ignore_errors: bool = false
@export var _treat_warnings_as_errors: bool = false


## Creates a new entry. Asserts that key is a new key in the database.
func create(key: StringName, value) -> void:
	if has(key):
		_push_warning("Key already exists in database.", "create", [key, value])
		if _treat_warnings_as_errors:
			return
	_data[key] = value
	emit_changed()

## Creates new entries from a Dictionary.
func create_bulk(entries: Dictionary) -> void:
	for key in entries.keys():
		create(key, entries[key])

## Reads an entry.
func read(key: StringName) -> Variant:
	var value: Variant = null
	if has(key):
		value = _data[key]
	return value

## Read entries from an Array.
func read_bulk(keys: Array[StringName]) -> Array:
	var entries: Array = []
	for key in keys:
		entries.append(read(key))
	return entries

## Updates an entry. Asserts that key exists in the database.
func update(key: StringName, value) -> void:
	if not has(key):
		_push_warning("Key does not exist in database.", "update", [key, value])
		if _treat_warnings_as_errors:
			return
	_data[key] = value
	emit_changed()

# Updates entries from a Dictionary.
func update_bulk(entries: Dictionary) -> void:
	for key in entries.keys():
		update(key, entries[key])

## Deletes an entry. Raises an error if key does not exist.
func delete(key: StringName) -> void:
	if not has(key):
		_push_error("Key does not exist in database.", "delete", [key])
		return
	_data.erase(key)
	emit_changed()

## Deletes entries from an Array[StringName].
func delete_bulk(keys: Array[StringName]) -> void:
	for key in keys:
		delete(key)

## Adds an entry. If key already exists, it will override it without warnings.
func add(key: StringName, value) -> void:
	jpConsole.print_method(self)
	_data[key] = value
	emit_changed()

## Adds entries from a Dictionary.
func add_bulk(entries: Dictionary) -> void:
	for key in entries.keys():
		add(key, entries[key])

## Checks if key exists in the database.
func has(key: StringName) -> bool:
	return _data.has(key)

## Returns a typed list of keys in the database.
func keys() -> Array[StringName]:
	var keys: Array[StringName]
	keys.assign(_data.keys())
	return keys

## Returns all entries from the database.
func values() -> Array:
	return _data.values()

## Returns the number of entries in the database.
func size() -> int:
	return _data.size()


## Saves the database as Resource. [member Resource.resource_path] must not be
## empty (set it with [method Resource.take_over_path]).
func save() -> void:
	if resource_path.is_empty():
		_push_error("Database does not have resource_path.", "save")
		return
	ResourceSaver.save(self, resource_path)

## Saves the database to a JSON file.
## Check [method JSON.stringify] for options.
func save_to_json(
		json_path: String,
		indent: String = "",
		sort_keys: bool = true,
		full_precision: bool = false
) -> void:
	var json_data := get_json_string(indent, sort_keys, full_precision)
	var file := FileAccess.open(json_path, FileAccess.WRITE)
	file.store_string(json_data)

## Returns the database as JSON string.
## Check [method JSON.stringify] for options.
func get_json_string(
		indent: String = "",
		sort_keys: bool = true,
		full_precision: bool = false
) -> String:
	var json_data: Dictionary = _data
	return JSON.stringify(json_data, indent, sort_keys, full_precision)

## Populates the resource from a JSON file.
func load_from_json_file(json_path: String) -> void:
	# _print_debug_data_types("Before loading from json")
	var file := FileAccess.open(json_path, FileAccess.READ)
	var file_data := file.get_as_text()
	load_from_json_string(file_data)
	# _print_debug_data_types("After loading from json")

## Populates the resource from a JSON string.
func load_from_json_string(json_string: String) -> void:
	var json_data: Dictionary = JSON.parse_string(json_string)
#	jpConsole.print_method(self, "changing_data", "load_from_json_string", [json_string])
	_data = json_data
	emit_changed()

## Sets database configuration.
func ignore_warnings(should_ignore: bool = true) -> void:
	if _ignore_warnings == should_ignore: return
	_ignore_warnings = should_ignore
	emit_changed()

## Sets database configuration.
func ignore_errors(should_ignore: bool = true) -> void:
	if _ignore_errors == should_ignore: return
	_ignore_errors = should_ignore
	emit_changed()

## Sets database configuration.
func treat_warnings_as_errors(should_treat: bool = true) -> void:
	if _treat_warnings_as_errors == should_treat: return
	_treat_warnings_as_errors = should_treat
	emit_changed()

## Sets database configuration.
func serialize_data_on_json(should_serialize: bool = true) -> void:
	if _serialize_data_on_json == should_serialize: return
	_serialize_data_on_json = should_serialize
	emit_changed()


func _serialize_value(value: Variant) -> String:
	var serialized: String
	if is_instance_valid(value):
		var dict: Dictionary = inst_to_dict(value)
		for key in dict.keys():
			dict[key] = _serialize_value(dict[key])
		serialized = var_to_str(dict)
	else:
		serialized = var_to_str(value)
	return serialized

func _deserialize_value(serialized: String) -> Variant:
	var value: Variant = str_to_var(serialized)
	if typeof(value) == TYPE_DICTIONARY:
		for key in value.keys():
			if typeof(value[key]) == TYPE_STRING:
				value[key] = _deserialize_value(value[key])
		if value.has("@path"):
			var object = dict_to_inst(value)
			if is_instance_valid(object):
				value = object
	return value


func _push_warning(message: String, method_name: String, args: Array = []) -> void:
	if _ignore_warnings: return
	if _treat_warnings_as_errors:
		jpConsole.push_error_method(self, message, method_name, args)
	else:
		jpConsole.push_warning_method(self, message, method_name, args)

func _push_error(message: String, method_name: String, args: Array = []) -> void:
	if _ignore_errors: return
	jpConsole.push_error_method(self, message, method_name, args)

func _print_debug_data_types(msg: String = "", data: Dictionary = _data, print_values: bool = false) -> void:
	if msg.is_empty(): msg = "jpDatabase:print_debug_data_types"
	for key in data.keys():
		var value = data[key]
		msg += "\n\t%s : %s" % [key, jpConsole.pretty_typeof(value)]
		if print_values: msg += " = %s" % [value]
	print(msg)
