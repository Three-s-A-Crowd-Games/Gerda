extends Path2D

class_name ParabolicProjectile

## General speed of the projectile. Influences velocity
@export var speed_factor: float = 5
## How much the projectile slows down at its peak point. Greater value -> more slowdown
@export var peak_slowdown: float = 150

## The PathFollow2D node which follows the curve
@onready var follow: PathFollow2D = $PathFollow2D

## Shooting angle relative to Vector2.RIGHT
var alpha: float
## Length of the Path2D.curve
var length: float
## float from 0 to 1. Reprecents the relative x distance of the curves peak point.
## If the peak point is in the middle peak_ratio will be 0.5 
var peak_ratio: float
var alpha_factor: float
var parabolic_factor: float
## Minimum velocity of the projectile. Influenced by speed_factor
var velocity: float


func _ready():
	length = curve.get_baked_length()
	peak_ratio = get_peak_ratio()
	alpha_factor = get_alpha_factor()
	parabolic_factor = get_parabolic_factor()
	velocity = (curve.point_count/100.0) * speed_factor
	

func _physics_process(delta) -> void:
	follow.progress += delta_progress_of(follow.progress)
	
	if follow.progress_ratio == 1:
		release()
	

func delta_progress_of(x: float) -> float:
	return pow((x - peak_ratio * length), 2) * parabolic_factor * alpha_factor + velocity
	

func get_alpha_factor() -> float:
	return (abs(alpha-PI/2)-PI/4) / (-PI/4)
	

func get_parabolic_factor() -> float:
	return 1 / (alpha_factor * pow(length,2) * ((1.0/3.0) - peak_ratio + pow(peak_ratio,2)))
	

func get_peak_ratio() -> float:
	var peak: float = 0
	var points := curve.get_baked_points()
	var prev_y: float = points[0].y
	for point in points:
		if point.y > prev_y:
			break
		peak += 1
		prev_y = point.y
	
	return peak/points.size()


func release() -> void:
	queue_free()
