extends Control

var main_menu: Control = preload("res://source/actors/ui/menus/main_menu.tscn").instantiate()
var ip_and_port_menu: Menu = preload("res://source/actors/ui/menus/ip_and_port_menu.tscn").instantiate()
var start_host_menu: Menu = preload("res://source/actors/ui/menus/start_host_menu.tscn").instantiate()
var waiting_for_players_menu: Menu = preload("res://source/actors/ui/menus/waiting_for_players_menu.tscn").instantiate()

var player_profile_res: Resource = preload("res://source/actors/ui/misc/player_profile.tscn")

@onready var swing_power_bar = $swing_power_bar
@onready var menu_manager = $MenuManager


func get_swing_power():
	return lerp(0.0, 1.0, swing_power_bar.value / 100.0)


func _ready():
	display_menu(main_menu)


func display_menu(menu: Control):
	var success: bool = menu_manager.add_menu(menu)
	if menu_manager.num_menus == 1 and success:
		Global.unlock_mouse()


func remove_menu():
	var menu_removed: bool = false
	if menu_manager.num_menus > 0:
		menu_manager.pop_menu()
		menu_removed = true
		
	if menu_manager.num_menus == 0 and menu_removed:
		Global.lock_mouse()


@rpc("any_peer", "call_local")
func remove_all_menus():
	menu_manager.pop_all()
	Global.lock_mouse()
