extends Node3D

@export var trauma_noise: FastNoiseLite
@export var trauma_speed: float = 1000.0
@export var trauma_max_x: float = 10.0
@export var trauma_max_y: float = 10.0
@export var trauma_max_z: float = 5.0

var sens: float = 0.25

var trauma: float = 0.0
var trauma_time: float = 0.0
var trauma_reduction_rate: float = 3.0


var block_rotation: bool = false

var initial_camera_rotation := Vector3.ZERO

@onready var camera_spring: SpringArm3D = $CameraSpring
@onready var camera: Camera3D = $CameraSpring/Camera


func _process(delta):
	if get_parent().is_local:
		trauma_time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
		camera.rotation_degrees.x = initial_camera_rotation.x + trauma_max_x * get_shake_intensity() * get_trauma_noise_from_seed(0)
		camera.rotation_degrees.y = initial_camera_rotation.y + trauma_max_y * get_shake_intensity() * get_trauma_noise_from_seed(1)
		camera.rotation_degrees.z = initial_camera_rotation.z + trauma_max_z * get_shake_intensity() * get_trauma_noise_from_seed(2)


func _input(event):
	if event is InputEventMouseMotion and Global.mouse_locked and not Input.is_action_pressed("left_click"):
		rotation.x += deg_to_rad(-event.relative.y * sens)
		rotation.x = clamp(rotation.x, -PI/2, -PI/12)
		
		rotation.y += deg_to_rad(-event.relative.x * sens)
		camera_spring.rotation.y = wrapf(camera_spring.rotation.y, 0.0, TAU)


func add_trauma(trauma_amount: float):
	trauma = clamp(trauma + trauma_amount, 0.0, 2.5)


func get_trauma_noise_from_seed(seed_: int):
	trauma_noise.seed = seed_
	return trauma_noise.get_noise_1d(trauma_time * trauma_speed)


func get_shake_intensity():
	return trauma * trauma
