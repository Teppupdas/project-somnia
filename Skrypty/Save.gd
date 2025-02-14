extends Node

@onready var player = $"../World YSort/Gracz"
@onready var UI = $"../CanvasLayer"


var currentCandle: Node2D = null # Przechowuje obecnie zapaloną świeczkę

signal candleActimel 












func _ready():
	call_deferred("loadGame") #opóżnione wywołąnie bo sie bugowało że było null instance
	pass







func saveGame():
	var dataFile = ConfigFile.new()

	dataFile.set_value("player", "candle", currentCandle.name)
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




	player.maxHealth = dataFile.get_value("player", "maxHealth", 1) # ustawianie maksymalnego zycia
	player.currentHealth = dataFile.get_value("player", "maxHealth", 1) # ustawianianie obencego zycia
	UI.setMaxHeart(player.maxHealth)
	UI.updateHearts(player.maxHealth)
	
	if dataFile.get_value("player", "candle", ""):
		candleActimelizing()
		setCandle(get_node("../World YSort/" + dataFile.get_value("player", "candle", ""))) #zapalenie swieczki i jej wybor
		player.position = currentCandle.position #pozycja gracza na swieczke
		
	get_node("../World YSort/Kiedro10czaha").baseActions = dataFile.get_value("actions", "kiedro10czaha", ["CZAHA1"])
	get_node("../World YSort/Kiedro10czaha").toActionPrompt = dataFile.get_value("actions", "kiedro10czaha", ["CZAHA1"])





func candleActimelizing(): # to robi ze swieczek mnozna uzwyac. wywolane po gadaniu z czaszku lub przy wczytywaniu
	emit_signal("candleActimel")


# świeczkaaaa
func setCandle(candle: Node2D) -> void:
	player.currentHealth = player.maxHealth #leczenie gracza gdy swieczki dotknie
	UI.updateHearts(player.currentHealth)
	
	if currentCandle: # sprawdza czy jest jakas przypisana zapalona
		currentCandle.turnOffCandle() #gasi tą przypisana poprzednia
		
	currentCandle = candle # przypisuje nowa
	currentCandle.turnOnCandle()  # zapala nowa
	
