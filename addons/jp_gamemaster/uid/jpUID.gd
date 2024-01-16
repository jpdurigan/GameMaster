@tool
extends RefCounted
class_name jpUID
## Static class for resource identification.
##
## This is supposed to be like [ResourceUID] with subresources handling.
## The UID is saved as metadata to the resource. This class also handles
## jpResourceUID objects that hold temporary metadata such as editor instances.
## That is saved to the cache folder.

const META_UID = &"jpuid"
const INVALID_ID = &"OH-NO"

const CACHE_PATH = "res://.godot/game_master/uid_cache.json"

static var _database: jpDatabase
static var _rng: RandomNumberGenerator
static var _queued_resources: Dictionary = {}
static var _has_changes: bool = false


static func track_resource(resource: Resource) -> void:
	var uid: StringName = get_uid(resource)
	
	if uid == INVALID_ID:
		uid = get_new_uid()
		set_uid(resource, uid)
	
	var resource_uid: jpResourceUID = get_resource_uid_from_resource(resource, true)
	var has_changes := resource_uid.update_from(resource)
	if has_changes:
		_add_to_database(resource_uid)


static func update_from_resource_uid(resource_uid: jpResourceUID) -> void:
	_add_to_database(resource_uid)
	has_changes()


static func get_uid(resource: Resource) -> StringName:
	return StringName(resource.get_meta(META_UID, INVALID_ID))


static func set_uid(resource: Resource, uid: StringName) -> void:
	resource.set_meta(META_UID, uid)


static func remove_uid(resource: Resource) -> void:
	resource.set_meta(META_UID, null)


static func get_resource_uid_from_resource(
		resource: Resource,
		should_create_new: bool = false
) -> jpResourceUID:
	var uid := get_uid(resource)
	var resource_uid := get_resource_uid_from_uid(uid, should_create_new)
	
	return resource_uid


static func get_resource_uid_from_uid(
		uid: StringName,
		should_create_new: bool = false
) -> jpResourceUID:
	var resource_uid: jpResourceUID = null
	
	if _is_database_loaded() and _database.has(uid):
		resource_uid = _database.read(uid)
	elif _queued_resources.has(uid):
		resource_uid = _queued_resources[uid]
	elif should_create_new:
		resource_uid = jpResourceUID.new()
	else:
		jpConsole.push_error_method(
			jpUID,
			"Resource does not have UID. Make sure to track_resource() before.",
			"get_resource_uid_from_uid",
			[uid]
		)
	
	return resource_uid


static func get_resource_from_uid(uid: StringName) -> Resource:
	var resource: Resource = null
	var resource_uid := get_resource_uid_from_uid(uid)
	if resource_uid != null:
		resource = resource_uid.get_resource()
	return resource


static func get_new_uid() -> StringName:
	var uid: StringName = INVALID_ID
	while _is_invalid_new_uid(uid):
		if not is_instance_valid(_rng):
			_rng = RandomNumberGenerator.new()
			_rng.randomize()
		uid = StringName(
			_format_hexadecimal(_rng.randi())
			+ _format_hexadecimal(_rng.randi())
		)
	return uid


static func save_to_cache(path: String = CACHE_PATH) -> void:
	do_safe_checks()
	if not _has_changes:
		return
	
	_database.save_to_json(path)
	
	var debug_database := _database.duplicate()
	ResourceSaver.save(debug_database, "res://jpuid.tres")
	
	_has_changes = false


static func load_from_cache(path: String = CACHE_PATH) -> void:
	_database = jpDatabase.new()
	jpConsole.print_method(_database, "load from cache")
	
	if FileAccess.file_exists(path):
		_database.load_from_json_file(path)
		_invalidate_instance_ids()
	has_changes()
	
	_rng = RandomNumberGenerator.new()
	_rng.randomize()


static func has_changes() -> void:
	_has_changes = true


static func do_safe_checks(deep_check: bool = false) -> void:
	for resource_uid in _queued_resources.values():
		_add_to_database(resource_uid, deep_check)
	if deep_check:
		for uid in _database.keys():
			var value = _database.read(uid)
			if not value is jpResourceUID:
				_database.delete(uid)
				has_changes()
				continue
			var resource_uid: jpResourceUID = _database.read(uid)
			if not resource_uid.is_valid(deep_check):
				_database.delete(uid)
				_queued_resources[uid] = resource_uid
				has_changes()


## Clear all static references.
static func clear() -> void:
	_database = null
	_rng = null
	_queued_resources = {}
	_has_changes = false


static func _add_to_database(resource_uid: jpResourceUID, deep_check: bool = false) -> void:
	var uid := resource_uid.uid
	if _is_database_loaded() and resource_uid.is_valid(deep_check):
		_database.add(uid, resource_uid)
		has_changes()
	else:
		if _queued_resources == null:
			_queued_resources = {}
		if _is_database_loaded() and _database.has(uid):
			_database.delete(uid)
			has_changes()
		_queued_resources[uid] = resource_uid


static func _invalidate_instance_ids() -> void:
	for uid in _database.keys():
		var resource_uid: jpResourceUID = _database.read(uid)
		if not is_instance_valid(resource_uid):
			continue
		resource_uid.invalidate_instance_id()
		_database.add(uid, resource_uid)


static func _is_invalid_new_uid(uid: StringName) -> bool:
	return (
		uid == INVALID_ID
		or uid.is_empty()
		or (_queued_resources and _queued_resources.has(uid))
		or (_database and _database.has(uid))
	)


static func _is_database_loaded() -> bool:
	return is_instance_valid(_database)


static func _format_hexadecimal(number: int, length: int = 8) -> String:
	var formatted := String.num_int64(number, 16, true)
	var padding := "0".repeat(length - formatted.length())
	return padding + formatted


class jpResourceUID:
	const INVALID_INSTANCE_ID: int = 0

	var uid: StringName = jpUID.INVALID_ID
	var path: String = ""
	var instance_id: int = INVALID_INSTANCE_ID

	func is_valid(deep_check: bool = false) -> bool:
		var is_valid := (
			not uid.is_empty()
			and uid != jpUID.INVALID_ID
			and path.is_absolute_path()
			and ResourceLoader.exists(path)
		)
		if not is_valid or not deep_check:
			return is_valid
		
		var resource_uid := jpUID.get_uid(get_resource())
		is_valid = resource_uid == uid
		return is_valid

	func invalidate_instance_id() -> void:
		instance_id = INVALID_INSTANCE_ID

	func get_resource() -> Resource:
		var resource: Resource = null
		if instance_id != INVALID_INSTANCE_ID and is_instance_id_valid(instance_id):
			resource = instance_from_id(instance_id)
		elif ResourceLoader.exists(path):
			resource = ResourceLoader.load(path)
		else:
			push_error("Invalid jpResourceUID: %s" % self)
		return resource
	
	func update_from(resource: Resource) -> bool:
		var has_changes: bool = false
		has_changes = _update_uid(resource) or has_changes
		has_changes = _update_path(resource) or has_changes
		has_changes = _update_instance_id(resource) or has_changes
		return has_changes
	
	func _update_uid(resource: Resource) -> bool:
		var has_changed: bool = false
		var new_uid: StringName = jpUID.get_uid(resource)
		if uid != new_uid:
			uid = new_uid
			has_changed = true
		return has_changed
	
	func _update_path(resource: Resource) -> bool:
		var has_changed: bool = false
		var new_path: String = resource.resource_path
		if path != new_path:
			path = new_path
			has_changed = true
		return has_changed
	
	func _update_instance_id(resource: Resource) -> bool:
		var has_changed: bool = false
		var new_instance_id: int = resource.get_instance_id()
		if instance_id != new_instance_id:
			instance_id = new_instance_id
			has_changed = true
		return has_changed
	
#	func to_dict() -> Dictionary:
#		var dict: Dictionary = {
#			uid = uid,
#			path = path,
#			instance_id = instance_id
#		}
#		for meta_name in get_meta_list():
#			dict[meta_name] = get_meta(meta_name)
#		return dict
#
#	static func from_dict(dict: Dictionary) -> jpResourceUID:
#		var uid := jpResourceUID.new()
#		for key in dict.keys():
#			if key in uid:
#				uid.set(key, dict[key])
#			else:
#				uid.set_meta(key, dict[key])
#		return uid

#	func _to_string() -> String:
#		return JSON.stringify(to_dict())
