@tool
class_name Ball
extends RigidBody3D

@export var color: Color = Color.WHITE : set = _set_color

# Set by parent #
var player: Player : set = _set_player # Player controlling this ball
var camera_controller: Node3D
var camera_spring: SpringArm3D
var camera: Camera3D

@onready var mesh = $Mesh
@onready var hit_sound_player = $HitSoundPlayer
@onready var explosion_light = $ExplosionLight
@onready var power_arrow = $PowerArrow
@onready var username_label = $UsernameLabel
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var physics_synchronizer = $PhysicsSynchronizer
@onready var impact_sound_player = $ImpactSoundPlayer
@onready var shadow_decal = $ShadowDecal


func _ready():
	pass


func _process(delta):
	if username_label:
		username_label.global_position = global_position + Vector3.UP * 0.2
	if shadow_decal:
		shadow_decal.global_position = mesh.global_position - Vector3.UP * 0.02
	
	if not Engine.is_editor_hint():
		#if physics_synchronizer.get_multiplayer_authority() != player.id:
		#	position = lerp(position, position + linear_velocity * delta, 0.1)
		#	rotation = lerp(rotation, rotation + angular_velocity * delta, 0.1)
			
		if player.is_local:
			var force_direction: Vector3 = -camera.position.rotated(Vector3.UP, camera_controller.rotation.y).normalized()
			power_arrow.global_position = global_position
			power_arrow.rotation.y = camera_controller.rotation.y
			power_arrow.scale.z = 1 + Global.ui.get_swing_power()
			if player.is_local and Input.is_action_just_released("left_click") and Global.ui.swing_power_bar.value > 0.0:
				for player_: Player in Global.players:
					player_.set_player_turn.rpc(player.id)
				apply_central_impulse(force_direction * Global.ui.get_swing_power())
				hit_sound_player.play()
				Global.ui.swing_power_bar.value = 0.0


func _physics_process(_delta):
	pass


func _integrate_forces(_state):
	pass


func _input(event):
	if player.is_local and Input.is_action_pressed("left_click") and event is InputEventMouseMotion:
		Global.ui.swing_power_bar.value += -event.relative.y * camera_controller.sens


@rpc("any_peer", "call_local")
func do_explosion_start():
	impact_sound_player.play()
	explosion_light.visible = true


@rpc("any_peer", "call_local")
func do_explosion_end():
	explosion_light.visible = false


@rpc("any_peer", "call_local")
func do_explosion(player_id: int):
	get_tree().paused = true
	
	var other_ball: Ball = Global.get_player_from_id(player_id).ball
	
	other_ball.impact_sound_player.play()
	other_ball.explosion_light.visible = true
	
	await get_tree().create_timer(0.25).timeout
	
	other_ball.explosion_light.visible = false
	
	add_collision_exception_with(other_ball)
	camera_controller.add_trauma(100.0)
	
	get_tree().paused = false
	
	await get_tree().create_timer(0.25).timeout
	
	remove_collision_exception_with(other_ball)


func _on_body_entered(body):
	if body is Ball and player.is_local and player.is_turn:
		do_explosion.rpc(body.player.id)


func _set_color(color_: Color):
	color = color_
	if mesh:
		mesh.mesh.surface_get_material(0).albedo_color = color


func _set_player(player_: Player):
	player = player_
	username_label.text = player.username
	if player.id == multiplayer.get_unique_id():
		username_label.visible = false
		power_arrow.visible = true
	else:
		power_arrow.visible = false
	multiplayer_synchronizer.set_multiplayer_authority(player.id)
	physics_synchronizer.set_multiplayer_authority(player.id)


func _on_sleeping_state_changed():
	if sleeping:
		pass


func _on_physics_synchronizer_synchronized():
	pass
