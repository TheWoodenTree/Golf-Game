@tool
class_name Ball
extends RigidBody3D

var is_local: bool # Whether or not this ball is controlled by this instance of the game
var player: Global.Player # Player controlling this ball

@onready var camera_controller = $CameraController
@onready var camera_spring = $CameraController/CameraSpring
@onready var camera = $CameraController/CameraSpring/Camera
@onready var hit_sound_player = $HitSoundPlayer
@onready var explosion_light = $ExplosionLight
@onready var power_arrow = $PowerArrow
@onready var username_label = $UsernameLabel
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer


func _ready():
	multiplayer_synchronizer.set_multiplayer_authority(player.id)
	username_label.text = player.username
	if player.id == multiplayer.get_unique_id():
		is_local = true
		username_label.visible = false
		camera.make_current()
		power_arrow.visible = true
	else:
		is_local = false
		camera.clear_current()
		power_arrow.visible = false
		
	camera_controller.global_position = global_position


func _process(_delta):
	if camera_controller:
		camera_controller.global_position = global_position
	if username_label:
		username_label.global_position = global_position + Vector3.UP * 0.2
	
	if not Engine.is_editor_hint() and is_local:
		var force_direction: Vector3 = -camera.position.rotated(Vector3.UP, camera_controller.rotation.y).normalized()
		power_arrow.global_position = global_position
		power_arrow.rotation.y = camera_controller.rotation.y
		power_arrow.scale.z = 1 + Global.ui.get_swing_power()
		if is_local and Input.is_action_just_released("left_click") and Global.ui.swing_power_bar.value > 0.0:
			for ball in get_parent().balls:
				ball.set_synchronizer_authority.rpc(player.id)
			apply_central_impulse(force_direction * Global.ui.get_swing_power())
			hit_sound_player.play()
			Global.ui.swing_power_bar.value = 0.0


func _integrate_forces(state):
	if state.get_contact_count() > 0 and is_local:
		for i in range(state.get_contact_count()):
			var object: PhysicsBody3D = state.get_contact_collider_object(i)
			if object is Ball:
				$ImpactSoundPlayer.play()
				get_tree().paused = true
				object.explosion_light.visible = true
				await get_tree().create_timer(0.25).timeout
				object.explosion_light.visible = false
				$Explosion.emitting = true
				get_tree().paused = false
				add_collision_exception_with(object)
				camera_controller.add_trauma(100.0)
				await get_tree().create_timer(0.1).timeout
				remove_collision_exception_with(object)


func _input(event):
	if is_local and Input.is_action_pressed("left_click") and event is InputEventMouseMotion:
		Global.ui.swing_power_bar.value += -event.relative.y * camera_controller.sens


@rpc("any_peer", "call_local")
func set_synchronizer_authority(id: int):
	multiplayer_synchronizer.set_multiplayer_authority(id)
