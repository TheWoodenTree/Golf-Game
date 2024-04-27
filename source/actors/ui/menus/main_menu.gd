extends Menu

@export var address: String = "127.0.0.1"
@export var port: int = 1234

@onready var name_editor = $MarginContainer/VBoxContainer/VBoxContainer/NameEditor
@onready var buttons_container = $MarginContainer/VBoxContainer/VBoxContainer


#func _ready():
	#ip_and_port_menu.close_button_pressed.connect(show_buttons)


func hide_buttons():
	buttons_container.visible = false
	buttons_container.mouse_filter = MOUSE_FILTER_IGNORE


func show_buttons():
	buttons_container.visible = true
	buttons_container.mouse_filter = MOUSE_FILTER_STOP


func _on_host_button_pressed():
	MultiplayerManager.peer_username = name_editor.text if name_editor.text else "Player"
	if Global.main.enter_ip_and_port:
		Global.ui.display_menu(Global.ui.start_host_menu)
	else:
		MultiplayerManager.create_host(port, 4)



func _on_join_button_pressed():
	MultiplayerManager.peer_username = name_editor.text if name_editor.text else "Player"
	if Global.main.enter_ip_and_port:
		Global.ui.display_menu(Global.ui.ip_and_port_menu)
	else:
		MultiplayerManager.connect_to_host(address, port)


func _on_start_button_pressed():
	Global.main.load_level.rpc(1)
