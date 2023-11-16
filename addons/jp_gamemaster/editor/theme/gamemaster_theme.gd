extends Resource

enum ResourceType {
	STYLE_BOX
}

enum ControlType {
	MAIN_PANEL,
	MAIN_TAB_BUTTON,
}


const CONTROL_DATA: Dictionary = {
	ControlType.MAIN_PANEL: {
		&"theme_override_styles/panel": ResourceType.STYLE_BOX,
	},
}


@export var PRESETS: Array[String] = [ "DEFAULT", "DARK" ]
