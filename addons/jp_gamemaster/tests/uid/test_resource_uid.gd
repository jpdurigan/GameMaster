extends GutTest

# new resource must begin with invalid id
func test_new_resource_must_have_invalid_uid() -> void:
	var resource: Resource = Resource.new()
	var uid: StringName = jpUID.get_uid(resource)
	assert_eq(uid, jpUID.INVALID_ID)


# after tracking, resource must have valid id
func test_track_resource_no_database() -> void:
	var resource: Resource = Resource.new()
	jpUID.track_resource(resource)
	
	var uid: StringName = jpUID.get_uid(resource)
	assert_ne(uid, jpUID.INVALID_ID)
	
	var resource_uid: jpUID.jpResourceUID = jpUID.get_resource_uid(resource)
	assert_not_null(resource_uid)
	assert_is(resource_uid, jpUID.jpResourceUID)
	assert_eq(resource_uid.uid, uid)
	assert_eq(resource_uid.path, "")
	assert_eq(resource_uid.instance_id, resource.get_instance_id())
	assert_false(resource_uid.is_valid(), "expects jpResourceUID to not be valid")
	assert_false(resource_uid.is_valid(true), "expects jpResourceUID to not be valid")
	
	assert_true(jpUID._queued_resources.has(uid), "expects jpResourceUID to be queued")
