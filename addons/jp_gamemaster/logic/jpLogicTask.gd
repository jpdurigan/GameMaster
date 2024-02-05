@tool
class_name jpLogicTask
extends Resource
## Base resource for executing a task inside a Logic Tree.
##
## Works as a leaf in a [jpLogicTree]. Every jpLogicTask should have a single
## responsability and evaluate the next Task to be executed.


const META_EDITOR_NODE = "editor_node"
const META_EDITOR_POSITION = "editor_position"

## Emitted when a jpLogicTask has just started execution.
signal task_started
## Emmitted when a jpLogicTask has executed and evaluated the next task.
signal task_ended(out_id: StringName)

## Unique id from [jpUID].
@export var id : StringName = jpUID.INVALID_ID:
	get:
		return jpUID.get_uid(self)

## List of possible next task's ids.
@export var outs : Array[StringName]


func _init() -> void:
	jpUID.track_resource(self)


## Called by jpLogicTree when executing the tasks.
func execute() -> void:
	task_started.emit()
	await _execute()
	var out_id := _evaluate_out()
	task_ended.emit(out_id)


## Used inside the plugin to link tasks.
func set_out_port(out_index: int, task: jpLogicTask) -> void:
	if out_index >= outs.size():
		push_error(
			"Invalid out index %s at task id %s | outs size: %s"
			% [out_index, id, outs.size()]
		)
		return
	
	var task_id : StringName = task.id if task != null else jpUID.INVALID_ID
	outs[out_index] = task_id


## Used inside the plugin to resize [member outs].
func set_out_ports_size(ports_count: int) -> void:
	if outs.size() == ports_count:
		return
	
	if outs.size() > ports_count:
		outs.resize(ports_count)
	else:
		while outs.size() < ports_count:
			outs.append(jpUID.INVALID_ID)


## Virtual function to be extended.[br]
## This can be a couroutine. If a task need to await anything, do it here.
func _execute() -> void:
	pass


## Virtual function to be extended.[br]
## Must return a valid [member jpLogicTask.id].
func _evaluate_out() -> StringName:
	var out : StringName = outs.front() if not outs.is_empty() else jpUID.INVALID_ID
	return out
