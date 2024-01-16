extends GutTest
## This test will clear jpUID static references!

const RESOURCE = preload("res://addons/jp_gamemaster/tests/assets/test_resource.tres")
const RESOURCE_RECURSIVE = preload("res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres")

const RESOURCE_WITH_UID = preload("res://addons/jp_gamemaster/tests/assets/test_resource_with_uid.tres")

const VALID_CACHE_JSON_PATH = "res://.godot/game_master/tests/valid_uid_cache.json"
const INVALID_CACHE_JSON_PATH = "res://.godot/game_master/tests/invalid_uid_cache.json"


func before_each():
	_clear_all_references()


func after_all():
	_clear_all_references()


# new resource must begin with invalid id
func test_new_resource_must_have_invalid_uid() -> void:
	var resource: Resource = Resource.new()
	var uid: StringName = jpUID.get_uid(resource)
	assert_eq(uid, jpUID.INVALID_ID)


# after tracking, resource must have valid id
func test_track_resource_no_database() -> void:
	var resource: Resource = Resource.new()
	_test_track_resource(resource, "", false, false)
	_test_track_resource(RESOURCE, RESOURCE.resource_path, true, false)
	_test_track_resource(RESOURCE_RECURSIVE, RESOURCE_RECURSIVE.resource_path, true, false)
	for subresource in RESOURCE_RECURSIVE._data:
		if not subresource is Resource:
			continue
		_test_track_resource(subresource, subresource.resource_path, true, false)


func test_track_resource_with_database() -> void:
	jpUID.load_from_cache()
	var resource: Resource = Resource.new()
	_test_track_resource(resource, "", false, true)
	_test_track_resource(RESOURCE, RESOURCE.resource_path, true, true)
	_test_track_resource(RESOURCE_RECURSIVE, RESOURCE_RECURSIVE.resource_path, true, true)
	for subresource in RESOURCE_RECURSIVE._data:
		if not subresource is Resource:
			continue
		_test_track_resource(subresource, subresource.resource_path, true, true)


func test_get_resource_from_uid() -> void:
	var resource: Resource = Resource.new()
	_test_get_resource_from_uid(resource)
	_test_get_resource_from_uid(RESOURCE)
	_test_get_resource_from_uid(RESOURCE_RECURSIVE)
	for subresource in RESOURCE_RECURSIVE._data:
		if not subresource is Resource:
			continue
		_test_get_resource_from_uid(subresource)


func test_load_valid_cache() -> void:
	# assert valid cache is still valid
	var expected_uid: StringName = &"3F1AA471F7F6035A"
	var uid: StringName = jpUID.get_uid(RESOURCE_WITH_UID)
	assert_eq(uid, expected_uid)
	
	# write invalid cache
	var file := FileAccess.open(VALID_CACHE_JSON_PATH, FileAccess.WRITE_READ)
	file.store_string(JSON.stringify(VALID_CACHE_JSON_DATA))
	file.close()
	
	# must load valid cache
	jpUID.load_from_cache(VALID_CACHE_JSON_PATH)
	assert_eq(jpUID._database.size(), 1)
	assert_eq(jpUID._queued_resources.size(), 0)
	
	# assert resource is in database
	assert_true(jpUID._database.has(expected_uid), "expects uid to be in database")
	var resource_uid: jpUID.jpResourceUID = jpUID.get_resource_uid_from_uid(expected_uid)
	assert_eq(resource_uid.uid, expected_uid)
	assert_eq(resource_uid.path, RESOURCE_WITH_UID.resource_path)
	assert_eq(resource_uid.instance_id, jpUID.jpResourceUID.INVALID_INSTANCE_ID)
	
	# safe checks shouldn't change database
	jpUID.do_safe_checks(true)
	assert_eq(jpUID._database.size(), 1)
	assert_eq(jpUID._queued_resources.size(), 0)
	
	# tracking the resource should update instance id
	jpUID.track_resource(RESOURCE_WITH_UID)
	resource_uid = jpUID.get_resource_uid_from_uid(expected_uid)
	assert_eq(resource_uid.instance_id, RESOURCE_WITH_UID.get_instance_id())


func test_load_invalid_cache() -> void:
	# write invalid cache
	var file := FileAccess.open(INVALID_CACHE_JSON_PATH, FileAccess.WRITE_READ)
	file.store_string(JSON.stringify(INVALID_CACHE_JSON_DATA))
	file.close()
	
	# must load invalid cache
	jpUID.load_from_cache(INVALID_CACHE_JSON_PATH)
	assert_eq(jpUID._database.size(), 5)
	assert_eq(jpUID._queued_resources.size(), 0)
	
	# must invalidate database
	jpUID.do_safe_checks(true)
	assert_eq(jpUID._database.size(), 0)
	assert_eq(jpUID._queued_resources.size(), 5)


func _test_track_resource(
		resource: Resource,
		resource_path: String,
		is_valid: bool,
		is_valid_database: bool
) -> void:
	jpUID.track_resource(resource)
	
	var uid: StringName = jpUID.get_uid(resource)
	assert_ne(uid, jpUID.INVALID_ID)
	
	var resource_uid: jpUID.jpResourceUID = jpUID.get_resource_uid_from_resource(resource)
	assert_not_null(resource_uid)
	assert_is(resource_uid, jpUID.jpResourceUID)
	assert_eq(resource_uid.uid, uid)
	assert_eq(resource_uid.path, resource_path)
	assert_eq(resource_uid.instance_id, resource.get_instance_id())
	assert_eq(resource_uid.is_valid(), is_valid, "expects jpResourceUID to not be valid")
	if is_valid and is_valid_database:
		assert_true(jpUID._database.has(uid), "expects jpResourceUID to be in database")
	else:
		assert_true(jpUID._queued_resources.has(uid), "expects jpResourceUID to be queued")


func _test_get_resource_from_uid(resource: Resource) -> void:
	var test_uid: StringName = &"MY-TEST-UID"
	
	jpUID.set_uid(resource, test_uid)
	var uid: StringName = jpUID.get_uid(resource)
	assert_eq(uid, test_uid)
	
	jpUID.track_resource(resource)
	var test_resource: Resource = jpUID.get_resource_from_uid(test_uid)
	assert_eq(resource, test_resource)


func _clear_all_references() -> void:
	jpUID.clear()
	if FileAccess.file_exists(jpUID.CACHE_PATH):
		var file := FileAccess.open(jpUID.CACHE_PATH, FileAccess.WRITE_READ)
		file.store_string("{}")
		file.close()
	for resource in [RESOURCE, RESOURCE_RECURSIVE]:
		for meta_name in resource.get_meta_list():
			resource.remove_meta(meta_name)


const VALID_CACHE_JSON_DATA = {
"\"3F1AA471F7F6035A\"": "{
\"\\\"@path\\\"\": \"\\\"res://addons/jp_gamemaster/uid/jpUID.gd\\\"\",
\"\\\"@subpath\\\"\": \"NodePath(\\\"jpResourceUID\\\")\",
\"\\\"instance_id\\\"\": \"-9223371992210602512\",
\"\\\"path\\\"\": \"\\\"res://addons/jp_gamemaster/tests/assets/test_resource_with_uid.tres\\\"\",
\"\\\"uid\\\"\": \"&\\\"3F1AA471F7F6035A\\\"\"
}"
}

const INVALID_CACHE_JSON_DATA = {
"\"190041887723F006\"": "{
\"\\\"@path\\\"\": \"\\\"res://addons/jp_gamemaster/uid/jpUID.gd\\\"\",
\"\\\"@subpath\\\"\": \"NodePath(\\\"jpResourceUID\\\")\",
\"\\\"instance_id\\\"\": \"-9223371992646810141\",
\"\\\"path\\\"\": \"\\\"res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres::Resource_vgeqt\\\"\",
\"\\\"uid\\\"\": \"&\\\"190041887723F006\\\"\"
}",
"\"1C57F6B172A54F77\"": "{
\"\\\"@path\\\"\": \"\\\"res://addons/jp_gamemaster/uid/jpUID.gd\\\"\",
\"\\\"@subpath\\\"\": \"NodePath(\\\"jpResourceUID\\\")\",
\"\\\"instance_id\\\"\": \"-9223371992630032924\",
\"\\\"path\\\"\": \"\\\"res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres\\\"\",
\"\\\"uid\\\"\": \"&\\\"1C57F6B172A54F77\\\"\"
}",
"\"739B76A0BDA417B3\"": "{
\"\\\"@path\\\"\": \"\\\"res://addons/jp_gamemaster/uid/jpUID.gd\\\"\",
\"\\\"@subpath\\\"\": \"NodePath(\\\"jpResourceUID\\\")\",
\"\\\"instance_id\\\"\": \"-9223371992948800034\",
\"\\\"path\\\"\": \"\\\"res://addons/jp_gamemaster/tests/assets/test_resource.tres\\\"\",
\"\\\"uid\\\"\": \"&\\\"739B76A0BDA417B3\\\"\"
}",
"\"B397F7A328F916A9\"": "{
\"\\\"@path\\\"\": \"\\\"res://addons/jp_gamemaster/uid/jpUID.gd\\\"\",
\"\\\"@subpath\\\"\": \"NodePath(\\\"jpResourceUID\\\")\",
\"\\\"instance_id\\\"\": \"-9223371992680364575\",
\"\\\"path\\\"\": \"\\\"res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres::Resource_oae7x\\\"\",
\"\\\"uid\\\"\": \"&\\\"B397F7A328F916A9\\\"\"
}",
"\"E513877802AF5708\"": "{
\"\\\"@path\\\"\": \"\\\"res://addons/jp_gamemaster/uid/jpUID.gd\\\"\",
\"\\\"@subpath\\\"\": \"NodePath(\\\"jpResourceUID\\\")\",
\"\\\"instance_id\\\"\": \"-9223371992697141792\",
\"\\\"path\\\"\": \"\\\"res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres::Resource_whgiw\\\"\",
\"\\\"uid\\\"\": \"&\\\"E513877802AF5708\\\"\"
}"
}
