extends Node

@export var local_play: bool = false
@export var enter_ip_and_port: bool = true

@onready var level_1: Node3D = preload("res://source/actors/levels/level_1.tscn").instantiate()


func _process(_delta):
	if local_play:
		AudioServer.set_bus_mute(0, not MultiplayerManager.is_authority())
	_handle_input()


func _handle_input():
	if Input.is_action_just_pressed("debug_toggle_mouse_lock"):
		if Global.mouse_locked:
			Global.unlock_mouse()
		else:
			Global.lock_mouse()


func _input(_event):
	pass


@rpc("any_peer", "call_local")
func load_level(_level_id: int):
	Global.ui.swing_power_bar.visible = true
	add_child(level_1)
	Global.ui.remove_menu()
	if not local_play or (local_play and MultiplayerManager.is_authority()):
		Global.lock_mouse()
