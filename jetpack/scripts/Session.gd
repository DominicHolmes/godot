extends Node2D

var Player = preload("res://scenes/Player.tscn")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print("In session")
	print("Is on server ", multiplayer.is_server())
	print("Multiplayer_authority ", get_multiplayer_authority())

func _ready():
	if not is_multiplayer_authority(): return
	var player = Player.instantiate()
	add_child(player, true)

