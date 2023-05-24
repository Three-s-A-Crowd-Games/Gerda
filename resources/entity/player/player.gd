extends MovingEnity

class_name Player

@export var weapon_scene :PackedScene
@export var mining_equipment_scene :PackedScene

@onready var equipment_angle_point :Marker2D = $EquipmentAnglePoint
@onready var weapon := weapon_scene.instantiate()
@onready var mining_equipment := mining_equipment_scene.instantiate()
@onready var dash = $Dash

const dash_speed = 300
const dash_duration = 0.1
const dash_max_amount = 5
var dashes_left = dash_max_amount
var dash_refill_speed = 0.8

var input_component = PlayerInputComponent.new()

var current_equipment :Equipment
var ore_pouch := 0:
	set(value):
		if ore_pouch != value:
			print("+"+str(value-ore_pouch)+" Ore! We now have: "+str(value))
			ore_received.emit(value-ore_pouch, Vector2(global_position.x,global_position.y-20))
			ore_pouch = value

signal ore_received(amount, pos)


func _ready() -> void:
	weapon.position = equipment_angle_point.position
	add_child(weapon)
	weapon.owner = self
	mining_equipment.position = equipment_angle_point.position
	add_child(mining_equipment)
	mining_equipment.owner = self
	mining_equipment.visible = false
	
	current_equipment = weapon
	
	dash.get_node("RefillTimer").timeout.connect(_on_dash_refill)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Movement-Code
	input_component.update(self, delta)
	speed = dash_speed if dash.is_dashing() else base_speed
	
	# Animate
	if self.direction.length() > 0:
		$AnimationPlayer.play("walk")
	elif $AnimationPlayer.is_playing():
		$AnimationPlayer.stop(false)
	if !dash.is_dashing() and $DashEffect.emitting:
		$DashEffect.emitting = false
	
	current_equipment.update(self)


func change_equipment(equipment) -> void:
	current_equipment.visible = false
	current_equipment = equipment
	current_equipment.visible = true


func use_equipment(delta: float) -> void:
	current_equipment.act(self, delta)


func try_dash() -> void:
	if dashes_left > 0 && !dash.is_dashing() && direction.length() > 0:
		dash.start_dash(dash_duration, dash_refill_speed)
		$DashEffect.emitting = true
		dashes_left -= 1
		print("Dashed - Dashes left: "+str(dashes_left)+"/"+str(dash_max_amount))
	
	
func _on_dash_refill() -> void:
	if dashes_left < dash_max_amount:
		print("Refilled Dash - Dashes left: "+str(dashes_left)+"/"+str(dash_max_amount))
		dashes_left+=1
		if dashes_left == dash_max_amount:
			dash.stop_refill()
