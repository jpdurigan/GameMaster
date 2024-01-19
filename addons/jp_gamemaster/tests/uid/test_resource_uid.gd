extends GutTest
## This test will clear jpUID static references!

const RESOURCE = preload("res://addons/jp_gamemaster/tests/assets/test_resource.tres")
const RESOURCE_RECURSIVE = preload("res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres")


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
