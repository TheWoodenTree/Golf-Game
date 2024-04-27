extends Menu

@onready var port_field = $PanelContainer/VBoxContainer/HBoxContainer2/PortField


func _enter_tree():
	if port_field:
		port_field.text = ""


func _on_create_button_pressed():
	if MultiplayerManager.create_host(int(port_field.text), 4):
		Global.ui.display_menu(Global.ui.waiting_for_players_menu)
