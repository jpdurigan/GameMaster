extends GutTest
## This test will clear jpUID static references!

const RESOURCE = preload("res://addons/jp_gamemaster/tests/assets/test_resource.tres")
const RESOURCE_RECURSIVE = preload("res://addons/jp_gamemaster/tests/assets/test_resource_recursive.tres")


func before_each():
	jpUID.clear()
	for resource in [RESOURCE, RESOURCE_RECURSIVE]:
		for meta_name in resource.get_meta_list():
			resource.remove_meta(meta_name)


# new resource must begin with invalid id
func test_new_resource_must_have_invalid_uid() -> void:
	var resource: Resource = Resource.new()
	var uid: StringName = jpUID.get_uid(resource)
	assert_eq(uid, jpUID.INVALID_ID)


# after tracking, resource must have valid id
func test_track_resource_no_database() -> void:
	var resource: Resource = Resource.new()
	_test_track_resource(resource, "", false)
	_test_track_resource(RESOURCE, RESOURCE.resource_path, true)
	_test_track_resource(RESOURCE_RECURSIVE, RESOURCE_RECURSIVE.resource_path, true)


func _test_track_resource(
		resource: Resource,
		resource_path: String,
		is_valid: bool
) -> void:
	jpUID.track_resource(resource)
	
	var uid: StringName = jpUID.get_uid(resource)
	assert_ne(uid, jpUID.INVALID_ID)
	
	var resource_uid: jpUID.jpResourceUID = jpUID.get_resource_uid(resource)
	assert_not_null(resource_uid)
	assert_is(resource_uid, jpUID.jpResourceUID)
	assert_eq(resource_uid.uid, uid)
	assert_eq(resource_uid.path, resource_path)
	assert_eq(resource_uid.instance_id, resource.get_instance_id())
	assert_eq(resource_uid.is_valid(), is_valid, "expects jpResourceUID to not be valid")
	if is_valid and jpUID._is_database_loaded():
		assert_true(jpUID._database.has(uid), "expects jpResourceUID to be in database")
	else:
		assert_true(jpUID._queued_resources.has(uid), "expects jpResourceUID to be queued")
