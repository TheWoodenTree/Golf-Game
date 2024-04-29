class_name Level
extends Node3D

@onready var ball_manager = $BallManager


func _ready():
	var player_idx: int = 0
	for player in Global.players:
		player.position = get_node("Spawn%d" % player_idx).position
		add_child(player)
		ball_manager.add_ball(player.ball)
		player_idx += 1


