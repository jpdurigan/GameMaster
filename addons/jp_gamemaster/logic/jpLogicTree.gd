@tool
class_name jpLogicTree
extends Resource
## Base resource to manage non-linear sequenced tasks.

const META_EDITOR_MAIN_POSITION = "editor_main_position"

signal tree_started
signal tree_ended

@export var id : String
@export var tasks : Dictionary # task_id: int : task: jpLogicTask
@export var initial_task : jpLogicTaskStart
@export var is_executing : bool = false

@export var _current_task : jpLogicTask = null


func _init() -> void:
	if initial_task == null:
		initial_task = jpLogicTaskStart.new()
		add_task(initial_task)


func add_task(task: jpLogicTask) -> void:
	tasks[task.id] = task

func remove_task(task: jpLogicTask) -> void:
	tasks.erase(task.id)
	for id in tasks.keys():
		var remaining_task: jpLogicTask = tasks[id]
		var task_index = remaining_task.outs.find(task.id)
		if task_index < 0: continue
		remaining_task.outs[task_index] = -1

func has_task(task: jpLogicTask) -> bool:
	return tasks.has(task.id)

func get_task(task_id: int) -> jpLogicTask:
	if not tasks.has(task_id): return null
	return tasks[task_id]


func execute() -> void:
	_tree_start()
	await tree_ended

func set_current_task(new_task: jpLogicTask) -> void:
	if new_task == _current_task: return
	
	if is_instance_valid(_current_task):
		_current_task.task_out.disconnect(_on_current_task_task_out)
	
	_current_task = new_task
	
	if not is_executing: return
	if is_instance_valid(_current_task):
		_current_task.task_out.connect(_on_current_task_task_out)
		_current_task.execute()
	else:
		_tree_end()


func _tree_start() -> void:
	is_executing = true
	tree_started.emit()
	set_current_task(initial_task)

func _tree_end() -> void:
	is_executing = false
	tree_ended.emit()


func _on_current_task_task_out(out: int) -> void:
	var new_task : jpLogicTask = get_task(out)
	set_current_task(new_task)
