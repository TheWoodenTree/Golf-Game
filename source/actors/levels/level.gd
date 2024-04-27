class_name Level
extends Node3D

var balls: Array[Ball]


func _ready():
	var player_idx: int = 0
	for player in Global.players:
		var new_ball: Ball = Global.ball_res.instantiate()
		balls.append(new_ball)
		
		player.ball = new_ball
		new_ball.player = player
		
		new_ball.position = get_node("Spawn%d" % player_idx).position
		add_child(new_ball)
		player_idx += 1

