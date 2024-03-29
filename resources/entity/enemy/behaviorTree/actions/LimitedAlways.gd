extends BTAction

## Node which returns for the given amount of iterations the result and deletes itself afterwards.

enum BlockResult {SUCCESS, RUNNING, FAILURE}
@export var result: BlockResult
var tick_result

## Number of iterations this node will return the given result. Afterwards this node will be ignored.
@export var iterations: int = 1

func _ready() -> void:
	match result:
		BlockResult.SUCCESS:
			tick_result = BTTickResult.SUCCESS
		BlockResult.RUNNING:
			tick_result = BTTickResult.RUNNING
		BlockResult.FAILURE:
			tick_result = BTTickResult.FAILURE

func tick(_actor:Node, _blackboard:BTBlackboard):
	iterations -= 1
	if iterations <= 0:
		queue_free()
	
	return result
	
