extends Node

var mouse_locked: bool = false

var players: Array[Player]

@onready var main: Node = get_tree().root.get_node("Main")
@onready var ui: Control = main.get_node("UI")
@onready var ball_res: Resource = preload("res://source/actors/balls/ball.tscn")

signal player_added


func lock_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_locked = true


func unlock_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_locked = false


func add_player(player: Player):
	players.append(player)
	rpc_emit_player_added_signal.rpc(player)


@rpc("any_peer", "call_local")
func rpc_emit_player_added_signal(player: Player):
	emit_signal("player_added", player)


class Player:
	var id: int
	var username: String
	var ball: Ball
	
	
	func _init(id_: int, username_: String, ball_: Ball):
		id = id_
		username = username_
		ball = ball_
