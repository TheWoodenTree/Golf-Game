@tool
extends Button

@export_enum("Cancel", "Close") var variant: String = "Close" : set = _set_variant


func _ready():
	text = variant


func _set_variant(variant_: String):
	variant = variant_
	text = variant


func _on_pressed():
	Global.ui.remove_menu()
