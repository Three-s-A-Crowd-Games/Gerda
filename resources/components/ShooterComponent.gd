extends Node2D

class_name ShooterComponent

@export var projectile_scene :PackedScene


func _ready():
	position = Vector2(position.x-0.5,position.y-0.5)


func shoot(damage :int) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.init(damage)
	projectile.transform = global_transform
	get_tree().get_first_node_in_group("projectiles").add_child(projectile)
