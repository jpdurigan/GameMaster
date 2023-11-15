@tool
extends Control

enum ViewportScale {
	DEFAULT,
	EDITOR_SCALE,
}

const TIMER_DURATION = 2.0

@export var subviewport_container: SubViewportContainer

var scale_mode: ViewportScale = ViewportScale.DEFAULT

var editor_interface: EditorInterface


func _ready() -> void:
	_change_scale_mode()


func _change_scale_mode() -> void:
	scale_mode = wrapi(scale_mode + 1, 0, ViewportScale.size())
	if subviewport_container and editor_interface:
#		printt("")
		subviewport_container.stretch_shrink = (
			editor_interface.get_editor_scale()
			if scale_mode == ViewportScale.EDITOR_SCALE
			else 1
		)
#	print(scale_mode)
	get_tree().create_timer(TIMER_DURATION).timeout.connect(_change_scale_mode)
