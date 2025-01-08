extends Node

#to zapisywać
var currentCandle: Node2D = null # Przechowuje obecnie zapaloną świeczkę



func _ready():
	call_deferred("loadGame") #opóżniione wywołąnie bo sie bugowało że było null instance
	pass




# świeczkaaaa
func setCandle(candleName: String) -> void:
	
	if currentCandle: # sprawdza czy jest jakas przypisana zapalona
		currentCandle.turnOffCandle() #gasi tą przypisana poprzednia

	currentCandle = get_node("../World YSort/" + candleName) # przypisuje nowa
	currentCandle.turnOnCandle()  # zapala nowa



func saveGame():
	var config = ConfigFile.new()

	config.set_value("candle", "current_candle", currentCandle.name)


	var error = config.save("user://save_game.txt")  # Zapisz do pliku tekstowego
	if error == OK:
		print("Zapisano stan gry!")
	else:
		print("Błąd zapisu pliku!")


func loadGame():
	var config = ConfigFile.new()
	var error = config.load("user://save_game.txt")  # Odczyt z pliku

	if error == OK:
		# Odczytujemy nazwę świeczki
		if config.get_value("candle", "current_candle", "") != "":
			setCandle(config.get_value("candle", "current_candle", ""))
	else:
		print("Błąd wczytywania pliku!")
