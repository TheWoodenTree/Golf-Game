extends Menu

@onready var ip_field = $PanelContainer/VBoxContainer/IPContainer/IpField
@onready var port_field = $PanelContainer/VBoxContainer/PortContainer/PortField


func _enter_tree():
	if ip_field and port_field:
		ip_field.text = ""
		port_field.text = ""


func _on_connect_button_pressed():
	MultiplayerManager.connect_to_host(ip_field.text, int(port_field.text))
	Global.ui.display_menu(Global.ui.waiting_for_players_menu)
