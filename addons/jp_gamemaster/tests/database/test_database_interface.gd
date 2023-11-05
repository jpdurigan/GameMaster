extends GutTest

const EXPECTED_METHODS = [
	# CRUD
	"create",
	"create_bulk",
	"read",
	"read_bulk",
	"update",
	"update_bulk",
	"delete",
	"delete_bulk",
	"add",
	"add_bulk",
	
	# DICTIONARY
	"has",
	"keys",
	"values",
	"size",
	
	# SAVING
	"save",
	"save_to_json",
	"load_from_json_file",
	"get_json_string",
	"load_from_json_string",
	
	# CONFIGURATION
	"serialize_data_on_json",
	"ignore_warnings",
	"ignore_errors",
	"treat_warnings_as_errors",
]

const KEY_VALUE_A = &"a"
const KEY_VALUE_B = &"b"
const KEY_VALUE_C = &"c"

const VALUE_1 = 12345
const VALUE_2 = Color.BLACK
const VALUE_3 = ["hi", Color.MAGENTA]
const VALUE_4 = &"StringName"
const VALUE_5 = { "object": true }
const VALUE_6 = Vector2.ONE

const BULK_PAYLOAD = {
	KEY_VALUE_A: VALUE_1,
	KEY_VALUE_B: VALUE_2,
	KEY_VALUE_C: VALUE_3,
}

const BULK_PAYLOAD_ALT = {
	KEY_VALUE_A: VALUE_4,
	KEY_VALUE_B: VALUE_5,
	KEY_VALUE_C: VALUE_6,
}


func test_database_has_crud_interface() -> void:
	var database := jpDatabase.new()
	assert_not_null(database, "database can be created")
	for method in EXPECTED_METHODS:
		assert_has_method(database, method)


func test_database_interface_is_working() -> void:
	var database := jpDatabase.new()
	assert_eq(database.size(), 0, "database must begin empty")
	
	database.add(KEY_VALUE_A, VALUE_1)
	assert_eq(database.size(), 1, "database must have one value")
	assert_true(database.has(KEY_VALUE_A), "database must have KEY_VALUE_A")
	assert_true(KEY_VALUE_A in database.keys(), "database must have KEY_VALUE_A")
	assert_true(VALUE_1 in database.values(), "database must have VALUE_1")
	
	database.create(KEY_VALUE_B, VALUE_2)
	assert_eq(database.size(), 2, "database must have two values")
	assert_true(database.has(KEY_VALUE_B), "database must have KEY_VALUE_B")
	assert_true(KEY_VALUE_B in database.keys(), "database must have KEY_VALUE_B")
	assert_true(VALUE_2 in database.values(), "database must have VALUE_2")
	
	database.update(KEY_VALUE_C, VALUE_3)
	assert_eq(database.size(), 3, "database must have three values")
	assert_true(database.has(KEY_VALUE_C), "database must have KEY_VALUE_C")
	assert_true(KEY_VALUE_C in database.keys(), "database must have KEY_VALUE_C")
	assert_true(VALUE_3 in database.values(), "database must have VALUE_3")
	
	assert_eq(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must return VALUE_1")
	assert_eq(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must return VALUE_2")
	assert_eq(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must return VALUE_3")
	
	database.add(KEY_VALUE_A, VALUE_4)
	assert_not_same(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must not return VALUE_1")
	database.create(KEY_VALUE_B, VALUE_5)
	assert_not_same(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must not return VALUE_2")
	database.update(KEY_VALUE_C, VALUE_6)
	assert_not_same(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must not return VALUE_3")
	
	database.delete(KEY_VALUE_A)
	assert_eq(database.size(), 2, "database must have two values")
	assert_false(database.has(KEY_VALUE_A), "database must not have KEY_VALUE_A")
	assert_false(KEY_VALUE_A in database.keys(), "database must not have KEY_VALUE_A")
	assert_null(database.read(KEY_VALUE_A), "database must read null for KEY_VALUE_A")
	
	database.delete(KEY_VALUE_B)
	assert_eq(database.size(), 1, "database must have one values")
	assert_false(database.has(KEY_VALUE_B), "database must not have KEY_VALUE_B")
	assert_false(KEY_VALUE_B in database.keys(), "database must not have KEY_VALUE_B")
	assert_null(database.read(KEY_VALUE_B), "database must read null for KEY_VALUE_B")
	
	database.delete(KEY_VALUE_C)
	assert_eq(database.size(), 0, "database must be empty")
	assert_false(database.has(KEY_VALUE_C), "database must not have KEY_VALUE_C")
	assert_false(KEY_VALUE_C in database.keys(), "database must not have KEY_VALUE_C")
	assert_null(database.read(KEY_VALUE_C), "database must read null for KEY_VALUE_C")


func test_database_add_bulk_is_working() -> void:
	var database := jpDatabase.new()
	assert_eq(database.size(), 0, "database must begin empty")
	
	database.add_bulk(BULK_PAYLOAD)
	
	assert_eq(database.size(), BULK_PAYLOAD.size(), "database must have payload size")
	
	assert_true(database.has(KEY_VALUE_A), "database must have KEY_VALUE_A")
	assert_true(database.has(KEY_VALUE_B), "database must have KEY_VALUE_B")
	assert_true(database.has(KEY_VALUE_C), "database must have KEY_VALUE_C")
	
	assert_true(KEY_VALUE_A in database.keys(), "database must have KEY_VALUE_A")
	assert_true(KEY_VALUE_B in database.keys(), "database must have KEY_VALUE_B")
	assert_true(KEY_VALUE_C in database.keys(), "database must have KEY_VALUE_C")
	
	assert_true(VALUE_1 in database.values(), "database must have VALUE_1")
	assert_true(VALUE_2 in database.values(), "database must have VALUE_2")
	assert_true(VALUE_3 in database.values(), "database must have VALUE_3")
	
	assert_eq(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must return VALUE_1")
	assert_eq(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must return VALUE_2")
	assert_eq(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must return VALUE_3")
	
	database.add_bulk(BULK_PAYLOAD_ALT)
	
	assert_not_same(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must not return VALUE_1")
	assert_not_same(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must not return VALUE_2")
	assert_not_same(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must not return VALUE_3")


func test_database_create_bulk_is_working() -> void:
	var database := jpDatabase.new()
	assert_eq(database.size(), 0, "database must begin empty")
	
	database.create_bulk(BULK_PAYLOAD)
	
	assert_eq(database.size(), BULK_PAYLOAD.size(), "database must have payload size")
	
	assert_true(database.has(KEY_VALUE_A), "database must have KEY_VALUE_A")
	assert_true(database.has(KEY_VALUE_B), "database must have KEY_VALUE_B")
	assert_true(database.has(KEY_VALUE_C), "database must have KEY_VALUE_C")
	
	assert_true(KEY_VALUE_A in database.keys(), "database must have KEY_VALUE_A")
	assert_true(KEY_VALUE_B in database.keys(), "database must have KEY_VALUE_B")
	assert_true(KEY_VALUE_C in database.keys(), "database must have KEY_VALUE_C")
	
	assert_true(VALUE_1 in database.values(), "database must have VALUE_1")
	assert_true(VALUE_2 in database.values(), "database must have VALUE_2")
	assert_true(VALUE_3 in database.values(), "database must have VALUE_3")
	
	assert_eq(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must return VALUE_1")
	assert_eq(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must return VALUE_2")
	assert_eq(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must return VALUE_3")
	
	database.create_bulk(BULK_PAYLOAD_ALT)
	
	assert_not_same(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must not return VALUE_1")
	assert_not_same(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must not return VALUE_2")
	assert_not_same(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must not return VALUE_3")



func test_database_update_bulk_is_working() -> void:
	var database := jpDatabase.new()
	assert_eq(database.size(), 0, "database must begin empty")
	
	database.update_bulk(BULK_PAYLOAD)
	
	assert_eq(database.size(), BULK_PAYLOAD.size(), "database must have payload size")
	
	assert_true(database.has(KEY_VALUE_A), "database must have KEY_VALUE_A")
	assert_true(database.has(KEY_VALUE_B), "database must have KEY_VALUE_B")
	assert_true(database.has(KEY_VALUE_C), "database must have KEY_VALUE_C")
	
	assert_true(KEY_VALUE_A in database.keys(), "database must have KEY_VALUE_A")
	assert_true(KEY_VALUE_B in database.keys(), "database must have KEY_VALUE_B")
	assert_true(KEY_VALUE_C in database.keys(), "database must have KEY_VALUE_C")
	
	assert_true(VALUE_1 in database.values(), "database must have VALUE_1")
	assert_true(VALUE_2 in database.values(), "database must have VALUE_2")
	assert_true(VALUE_3 in database.values(), "database must have VALUE_3")
	
	assert_eq(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must return VALUE_1")
	assert_eq(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must return VALUE_2")
	assert_eq(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must return VALUE_3")
	
	database.update_bulk(BULK_PAYLOAD_ALT)
	
	assert_not_same(database.read(KEY_VALUE_A), VALUE_1, "database read(KEY_VALUE_A) must not return VALUE_1")
	assert_not_same(database.read(KEY_VALUE_B), VALUE_2, "database read(KEY_VALUE_B) must not return VALUE_2")
	assert_not_same(database.read(KEY_VALUE_C), VALUE_3, "database read(KEY_VALUE_C) must not return VALUE_3")


func test_database_delete_bulk_is_working() -> void:
	var database := jpDatabase.new()
	assert_eq(database.size(), 0, "database must begin empty")
	
	database.create_bulk(BULK_PAYLOAD)
	assert_eq(database.size(), BULK_PAYLOAD.size(), "database must have payload size")
	
	var DELETE_KEYS: Array[StringName]
	DELETE_KEYS.assign(BULK_PAYLOAD.keys())
	database.delete_bulk(DELETE_KEYS)
	assert_eq(database.size(), 0, "database must be empty")
	assert_null(database.read(KEY_VALUE_A), "database must read null for KEY_VALUE_A")
	assert_null(database.read(KEY_VALUE_B), "database must read null for KEY_VALUE_B")
	assert_null(database.read(KEY_VALUE_C), "database must read null for KEY_VALUE_C")
