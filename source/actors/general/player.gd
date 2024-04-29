@tool
class_name Player
extends Node3D

const CAMERA_POS_LERP_WEIGHT: float = 0.2

var id: int

var username: String

var is_turn: bool = false
var is_local: bool # Whether or not this player owns this instance of the game

@onready var ball = $Ball
@onready var camera_controller = $CameraController
@onready var camera_spring = $CameraController/CameraSpring
@onready var camera = $CameraController/CameraSpring/Camera
@onready var putter_origin = $PutterOrigin
@onready var putter = $PutterOrigin/Putter
@onready var animation_player = $AnimationPlayer


func _ready():
	if MultiplayerManager.is_authority():
		is_turn = true
	if id == multiplayer.get_unique_id():
		is_local = true
		camera.make_current()
	else:
		is_local = false
		camera.clear_current()
	
	if ball:
		ball.camera_controller = camera_controller
		ball.camera_spring = camera_spring
		ball.camera = camera
		ball.player = self
	
	camera_controller.global_position = ball.global_position
	animation_player.play("swing")


func _process(_delta):
	if not Engine.is_editor_hint():
		putter_origin.global_position = ball.global_position
		putter_origin.rotation.y = camera_controller.rotation.y


func _physics_process(_delta):
	if not Engine.is_editor_hint():
		camera_controller.global_position = lerp(camera_controller.global_position, ball.global_position, CAMERA_POS_LERP_WEIGHT)


@rpc("any_peer", "call_local", "reliable")
func set_player_turn(player_id: int):
	is_turn = id == player_id
	#ball.physics_synchronizer.set_multiplayer_authority(player_id)
