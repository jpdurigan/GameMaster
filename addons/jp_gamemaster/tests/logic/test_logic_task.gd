extends GutTest

const EXPECTED_METHODS = [
	"execute",
]

const EXPECTED_SIGNALS = [
	"task_started",
	"task_ended",
]


func test_logic_task_interface() -> void:
	var task := jpLogicTask.new()
	assert_not_null(task)
	assert_is(task, jpLogicTask)
	for method_name in EXPECTED_METHODS:
		assert_has_method(task, method_name)
	for signal_name in EXPECTED_SIGNALS:
		assert_has_signal(task, signal_name)


func test_logic_task_id() -> void:
	var task := jpLogicTask.new()
	assert_ne(task.id, &"")
	assert_ne(task.id, jpUID.INVALID_ID)


func test_execute_must_trigger_signals() -> void:
	var task := jpLogicTask.new()
	watch_signals(task)
	task.execute()
	assert_signal_emit_count(task, "task_started", 1)
	assert_signal_emit_count(task, "task_ended", 1)
	assert_signal_emitted_with_parameters(task, "task_ended", [jpUID.INVALID_ID])


func test_out_ports() -> void:
	var task := jpLogicTask.new()
	assert_eq(task.outs, [])
	
	task.set_out_ports_size(2)
	assert_eq(task.outs, [jpUID.INVALID_ID, jpUID.INVALID_ID])
	
	var new_task := jpLogicTask.new()
	task.set_out_port(0, new_task)
	assert_eq(task.outs, [new_task.id, jpUID.INVALID_ID])
