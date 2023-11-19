@tool
class_name jpValue
extends Resource
## Common interface for Flags, States and Metrics.
##
## These resources stores values that can be set or evaluated inside a Task.
## They should be interacted with the [u]get_value[/u] and [u]update_value[/u]
## methods, that are implemented in the children classes for correct typing.
## You should listen to [signal Resource.changed] for updates.[br]
## [br]
## [jpFlag] stores boolean values, true or false.[br]
## [jpState] stores a state value, as an enum.[br]
## [jpMetric] stores a numeric value, either an int or a float.[br]
## [br]
## All classes support boolean evaluation, so that all resources can be treated
## as a jpFlag. This is manly done to avoid creating Flags for one-off Items.


## Unique resource id, set by user via plugin.
@export var id: String


## Returns value.
func get_value() -> Variant:
	return null

## Returns value as a boolean.
func get_bool_value() -> bool:
	return false
