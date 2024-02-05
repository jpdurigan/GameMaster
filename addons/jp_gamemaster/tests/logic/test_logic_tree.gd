extends GutTest

const EXPECTED_METHODS = [
	"add_task",
	"remove_task",
	"has_task",
	"get_task",
	"execute",
]

const EXPECTED_SIGNALS = [
	"tree_started",
	"tree_ended",
]


func test_logic_tree_interface() -> void:
	var tree := jpLogicTree.new()
	assert_not_null(tree)
	assert_is(tree, jpLogicTree)
	for method_name in EXPECTED_METHODS:
		assert_has_method(tree, method_name)
	for signal_name in EXPECTED_SIGNALS:
		assert_has_signal(tree, signal_name)


func test_initial_task() -> void:
	var tree := jpLogicTree.new()
	var initial_task: Variant = tree.initial_task
	assert_not_null(initial_task)
	assert_is(initial_task, jpLogicTask)
	assert_eq(tree.has_task(initial_task), true)
	assert_eq(tree.get_task(initial_task.id), initial_task)


func test_add_and_remove_task() -> void:
	var tree := jpLogicTree.new()
	var task := jpLogicTask.new()
	
	assert_eq(tree.has_task(task), false)
	assert_eq(tree.tasks.size(), 1)
	
	tree.add_task(task)
	assert_eq(tree.has_task(task), true)
	assert_eq(tree.tasks.size(), 2)
	
	tree.remove_task(task)
	assert_eq(tree.has_task(task), false)
	assert_eq(tree.tasks.size(), 1)


func test_execute_must_trigger_signals() -> void:
	var tree := jpLogicTree.new()
	watch_signals(tree)
	tree.execute()
	assert_signal_emit_count(tree, "tree_started", 1)
	assert_signal_emit_count(tree, "tree_ended", 1)
