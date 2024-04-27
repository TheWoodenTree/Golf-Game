extends Node

var peer: ENetMultiplayerPeer
var peer_username: String


func _ready():
	multiplayer.allow_object_decoding = true
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


func peer_connected(id: int):
	print("Player connected with id " + str(id))


func peer_disconnected(id: int):
	print("Player with id " + str(id) + " disconnected")


func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, multiplayer.get_unique_id(), peer_username)


func connection_failed():
	print("Couldn't connect")


@rpc("any_peer")
func send_player_information(id: int, username: String):
	if Global.players.is_empty():
		Global.add_player(Global.Player.new(id, username, null))
	else:
		var has_player: bool = false
		for player in Global.players:
			if player.id == id:
				has_player = true
				break
				
		if not has_player:
			Global.add_player(Global.Player.new(id, username, null))
	
	if multiplayer.is_server():
		for player in Global.players:
			send_player_information.rpc(player.id, player.username)


func create_host(port: int, max_players: int) -> bool:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port, max_players)
	if error != OK:
		print("Host error: " + str(error))
		return false
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	send_player_information(multiplayer.get_unique_id(), peer_username)
	return true


func connect_to_host(address: String, port: int):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func stop_host():
	multiplayer.set_multiplayer_peer(null)
	peer = null


func is_authority() -> bool:
	return multiplayer.has_multiplayer_peer() and multiplayer.get_unique_id() == 1
