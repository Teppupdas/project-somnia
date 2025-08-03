extends Node

@onready var player = $"../World YSort/Gracz"
@onready var UI = $"../CanvasLayer"


var currentPentagram: Node2D = null # Przechowuje ostatni pentagram













func _ready():
	randomize()
	call_deferred("loadGame") #opóżnione wywołanie bo sie bugowało że było null instance
	pass







func saveGame():
	var dataFile = ConfigFile.new()

	dataFile.set_value("player", "pentagram", currentPentagram.name)
	dataFile.set_value("player", "maxHealth", player.maxHealth)


	dataFile.set_value("actions", "kiedro10czaha", get_node("../World YSort/Kiedro10czaha").baseActions)


	var error = dataFile.save("user://save_game.txt")  # Zapis
	if error == OK:
		print("zapisano")
	else:
		print("zapis wypierdolony")


func loadGame():
	var dataFile = ConfigFile.new()
	var error = dataFile.load("user://saave_game.txt")  # Odczyt




	player.maxHealth = dataFile.get_value("player", "maxHealth", 5) # ustawianie maksymalnego zycia
	player.currentHealth = dataFile.get_value("player", "maxHealth", 5) # ustawianianie obencego zycia
	UI.setMaxHeart(player.maxHealth)
	UI.updateHearts(player.maxHealth)
	
	if dataFile.get_value("player", "pentagram", ""):
		setPentagram(get_node("../World YSort/" + dataFile.get_value("player", "pentagram", ""))) #zapalenie swieczki i jej wybor
		player.position = currentPentagram.position #pozycja gracza na pentagram
		
	get_node("../World YSort/Kiedro10czaha").baseActions = dataFile.get_value("actions", "kiedro10czaha", ["CZAHA1"])
	get_node("../World YSort/Kiedro10czaha").toActionPrompt = dataFile.get_value("actions", "kiedro10czaha", ["CZAHA1"])




# pentagramm
func setPentagram(pentagram: Node2D) -> void:
	player.currentHealth = player.maxHealth #leczenie gracza gdy swieczki dotknie
	UI.updateHearts(player.currentHealth)
	
	currentPentagram = pentagram # przypisuje nowa
