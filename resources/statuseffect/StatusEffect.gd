extends RefCounted
class_name StatusEffect

## Base class for a status effect. This class shouldn't be instantiated itself. 
## To crate your own effect create a derived class and override the trigger method.

## The actor that gets affectet by this status effect
var onwer
## The time intervall between successive triggers of this effect
var trigger_time: float = 0
## Counter for the passed time between successive triggers of this effect
var passed_time: float = 0
## The time this effect will last
var life_time: float = 0
## Counter for the time this effect is already alive
var passed_life_time: float = 0

## Flag to enable and disable triggers from this effect
var trigger_enabled = true
## Flag to declare this effect only triggers once
var one_time_trigger = false


## Constructor for this class. Initialize trigger_time and life_time with desired values.
## To let the effect only trigger once assign the desired trigger_time as negative value.
## For infinite life_time set it to -1.
## If instant_trigger is set to false, the effect will not trigger until trigger_time is over the first time.
func _init(wanted_trigger_time: float = -1, wanted_life_time: float = -1, instant_trigger: bool = true):
	self.trigger_time = wanted_trigger_time
	self.life_time = wanted_life_time
	if trigger_time < 0:
		one_time_trigger = true
		trigger_time *= -1
	if instant_trigger:
		#skip forward to trigger instantly
		passed_time = trigger_time


## Process this effect -> increase counters (passed_time, passed_life_time) by delta
## and react with a trigger if passed_time reaches trigger_time.
func process(delta: float, owner) -> void:
	passed_time += delta
	passed_life_time += delta
	if trigger_enabled and passed_time >= trigger_time:
		if one_time_trigger:
			trigger_enabled = false
		passed_time = delta
		trigger(owner)
	

## Refresh the life_time of this status effect.
func refresh() -> void:
	passed_life_time = 0
	

## Check if the life_time_is_over.
func is_life_time_over() -> bool:
	return passed_life_time > life_time and life_time > 0

## Execute the actual behaviour of this status effect. Method to override in deriving classes.
func trigger(_owner) -> void:
	pass 
	

func disable(_owner) -> void:
	pass
