extends Node

@onready var player = $"../World YSort/Gracz"
@onready var ui = $"../CanvasLayer"


var current_pentagram: Node2D = null # Przechowuje ostatni pentagram













func _ready():
	randomize()
	call_deferred("load_game") #opóżnione wywołanie bo sie bugowało że było null instance
	pass







func save_game():
	var data_file = ConfigFile.new()

	data_file.set_value("player", "pentagram", current_pentagram.name)
	data_file.set_value("player", "max_health", player.max_health)


	data_file.set_value("actions", "kiedro10czaha", get_node("../World YSort/Kiedro10czaha").base_actions)


	var error = data_file.save("user://save_game.txt")  # Zapis
	if error == OK:
		print("zapisano")
	else:
		print("zapis wypierdolony")


func load_game():
	var data_file = ConfigFile.new()
	var error = data_file.load("user://saave_game.txt")  # Odczyt




	player.max_health = data_file.get_value("player", "max_health", 50) # ustawianie maksymalnego zycia
	player.current_health = data_file.get_value("player", "max_health", 50) # ustawianianie obencego zycia
	ui.set_max_heart(player.max_health)
	ui.update_hearts(player.max_health)
	
	if data_file.get_value("player", "pentagram", ""):
		set_pentagram(get_node("../World YSort/" + data_file.get_value("player", "pentagram", ""))) #zapalenie swieczki i jej wybor
		player.position = current_pentagram.position #pozycja gracza na pentagram
		
	get_node("../World YSort/Kiedro10czaha").base_actions = data_file.get_value("actions", "kiedro10czaha", ["CZAHA1"])
	get_node("../World YSort/Kiedro10czaha").to_action_prompt = data_file.get_value("actions", "kiedro10czaha", ["CZAHA1"])




# pentagramm
func set_pentagram(pentagram: Node2D) -> void:
	player.current_health = player.max_health #leczenie gracza gdy swieczki dotknie
	ui.update_hearts(player.current_health)
	
	current_pentagram = pentagram # przypisuje nowa
