extends Menu

@onready var players_container = $PanelContainer/VBoxContainer/PlayersContainer
@onready var start_button = $PanelContainer/VBoxContainer/HBoxContainer/StartButton


func _ready():
	for player in Global.players:
		add_player(player)
	Global.player_added.connect(add_player)
	
	if MultiplayerManager.is_authority():
		start_button.visible = true
		start_button.disabled = false
	else:
		start_button.visible = false
		start_button.disabled = true


func add_player(player: Global.Player):
	var profile: Control = Global.ui.player_profile_res.instantiate()
	players_container.add_child(profile)
	profile.text = player.username


func _on_start_button_pressed():
	Global.main.load_level.rpc(1)
	Global.ui.remove_all_menus.rpc()


func _on_close_button_pressed():
	MultiplayerManager.stop_host()


