extends CharacterBody2D

class_name MovingEnity

@export var base_speed: int
@onready var speed: int = base_speed


var direction := Vector2.ZERO:
	set(value):
		if value != direction:
			direction = value.normalized()

func _ready():
	pass


func _physics_process(delta):
	move()
	

func move():
	velocity = speed * direction
	move_and_slide()


func flash():
	var shader_mat = get_node("SubViewportContainer/SubViewport/AnimatedSprite2D").material
	shader_mat.set_shader_parameter("flash_modifier",0.4)
	await get_tree().create_timer(0.05).timeout
	shader_mat.set_shader_parameter("flash_modifier",0)


# base_dir of sprite: -1 for left, +1 for right
func flip_for_movement(base_dir: int, scale_x: int) -> void:
	if base_dir  == 0: return
	# Looking to the right by default
	if base_dir > 0:
		if direction.x < 0 and scale_x > 0 or direction.x > 0 and scale_x < 0:
			flip()
	else:
		if direction.x < 0 and scale_x < 0 or direction.x > 0 and scale_x > 0:
			flip()


func flip() -> void:
	pass
