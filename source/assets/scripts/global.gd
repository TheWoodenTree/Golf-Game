extends Node

var mouse_locked: bool = false

var players: Array[Player]

@onready var main: Node = get_tree().root.get_node("Main")
@onready var ui: Control = main.get_node("UI")
@onready var ball_res: Resource = preload("res://source/actors/balls/ball.tscn")
@onready var player_res: Resource = preload("res://source/actors/general/player.tscn")

signal player_added


func lock_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_locked = true


func unlock_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_locked = false


func create_new_player(id: int, username: String) -> Player:
	var new_player: Player = player_res.instantiate()
	new_player.id = id
	new_player.username = username
	return new_player


func add_player(player: Player):
	players.append(player)
	emit_player_added_signal.rpc(player.id)


func get_player_from_id(id: int) -> Player:
	for player in players:
		if player.id == id:
			return player
	return null


@rpc("any_peer", "call_local")
func emit_player_added_signal(player_id: int):
	emit_signal("player_added", player_id)
