extends CanvasLayer

@onready var fps_label = $FPS_label
@onready var vram_label = $VRAM_label

@onready var pasek_serc = $baseInterface/Serduszka
@onready var heart_prefab = preload("res://interfaces/serce.tscn")

@onready var pauzy_menu = $PauseMenuPanel
@onready var label1 = $PauseMenuPanel/VBoxContainer/Label1
@onready var label2 = $PauseMenuPanel/VBoxContainer/Label2
@onready var label3 = $PauseMenuPanel/VBoxContainer/Label3
var pauza_aktywna
var opcja_pauzy_wybrana

@onready var map_texture = $mapTexture
@onready var map_cursor = $mapTexture/cursorTexture
@onready var map_label = $mapTexture/Label
@onready var markers_container = $mapTexture/markersContainer
@onready var marker_prefab = preload("res://interfaces/marker.tscn")
var mapa_aktywna
var map_bounds = Rect2(200, 200, 3840 - 100 - 2*200, 2160 - 100 - 2*200) # -rozmiar kursora -2x margines ze zwyklej storny. bo jeden zeruje do krawedzi a drugi dopiero dodaje margines
var current_quests = ["KILL", "TALK"]


@onready var action_prompt_container = $baseInterface/actionPromptContainer
var action_prompt_active = false
var selected_action = 0
var action_labels: Array = []
var current_action_object = null


const kolor_wybrania = Color8(220, 20, 60)
const kolor_niewybrania = Color8(255, 255, 255)
const kolor_nieaktywny = Color8(112, 112, 112)



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #ukrycie myszki
	
	#TranslationServer.set_locale(OS.get_locale()) #auto jezyk z systemu. nie testowane.
	TranslationServer.set_locale("pl")
	

	pauza_aktywna = false
	pauzy_menu.hide()
	pasek_serc.show()
	get_tree().paused = false
	opcja_pauzy_wybrana = 1
	
	mapa_aktywna = false
	map_texture.hide()
	
	
	
	






func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	vram_label.text = "VRAM: " + str(int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024**2))) + " MB"
	update_hearts($"../World/Gracz".current_health) #kurwa dodane tu co klatke, bo sie jebalo gdy podnoszenie serduszka itp

	
	
	
	if Input.is_action_just_pressed("pauza"):
		if mapa_aktywna: # sprawia ze da sie wylaczyc mape escapem. przetestowac to na padzie itp
			toggle_map()
		else:
			toggle_pause()

	if pauza_aktywna:
		if Input.is_action_just_pressed("UIdol"):
			navigate_option(1, "pause")
		elif Input.is_action_just_pressed("UIgora"):
			navigate_option(-1, "pause")
		if Input.is_action_just_pressed("potwierdz"):
			match opcja_pauzy_wybrana:
				1:
					toggle_pause()
				2:
					pass
				3:
					get_tree().quit()


	if Input.is_action_just_pressed("mapa") and not pauza_aktywna:
		toggle_map()
		
	if mapa_aktywna: #sterowanie kursorem na mapie itp
		var cursor_move_vector = Vector2.ZERO
		cursor_move_vector.x = (Input.get_action_strength("prawo") - Input.get_action_strength("lewo"))
		cursor_move_vector.y = (Input.get_action_strength("dol") - Input.get_action_strength("gora"))
		
		map_cursor.position += cursor_move_vector.normalized() * 200 * delta * clamp(cursor_move_vector.length(),0,1)
		map_cursor.position = map_cursor.position.clamp(map_bounds.position, map_bounds.end)
		
		
		#sprawdzanie czy kursor jest na znacnziku i wyswietlanie tekstu
		for marker in markers_container.get_children():

			
			if marker.global_position.distance_to(map_cursor.global_position + map_cursor.texture.get_size()/2 - marker.texture.get_size()/2) < 35:  # jesli na znaczniku
				map_label.text = marker.name # tekst dolny przypiusanie
				marker.scale = Vector2(1, 1)
				
				if cursor_move_vector == Vector2.ZERO: # przyklejanie kursora do znacznika
					map_cursor.position = marker.position - map_cursor.texture.get_size()/2 + marker.texture.get_size()/2
				break 
			else:
				map_label.text = "" 
				marker.scale = Vector2(0.7, 0.7)




	if action_prompt_active and not pauza_aktywna:
		if current_action_object.is_talking:
			return  # Zignoruj wszystkie interakcje, jeśli obiekt mówi

		if Input.is_action_just_pressed("actionPromptDown"):
			navigate_option(1, "action")
		elif Input.is_action_just_pressed("actionPromptUp"):
			navigate_option(-1, "action")
		elif Input.is_action_just_pressed("potwierdz"):   #to gdy wyjscie z pauzy za pomoco wznow to tez sie klika gowno
			current_action_object.handle_action(action_labels[selected_action].text)






func set_max_heart(max_health: int):
	for heart in pasek_serc.get_children():
		heart.queue_free()
		
	for i in range(max_health):
		var heart = heart_prefab.instantiate()
		pasek_serc.add_child(heart)
		

func update_hearts(current_health):
	var hearts = pasek_serc.get_children()

	for i in range(current_health):
		hearts[i].update(true)

	for i in range(current_health, hearts.size()):
		hearts[i].update(false)




func toggle_pause():
	pauza_aktywna = !pauza_aktywna
	get_tree().paused = pauza_aktywna
	pauzy_menu.visible = pauza_aktywna
	opcja_pauzy_wybrana = 1
	highlight_option(opcja_pauzy_wybrana, "pause")

func toggle_map():
	mapa_aktywna = !mapa_aktywna
	map_texture.visible = mapa_aktywna
	get_tree().paused = mapa_aktywna
	
	if mapa_aktywna: #tworzenie znacznikow
		map_cursor.position =  Vector2(1920, 1080) - map_cursor.texture.get_size()/2
		
		for quest in current_quests:
			var marker = marker_prefab.instantiate()
			
			match quest:
				"KILL":
					marker.position = Vector2(1000, 640) - marker.texture.get_size()/2
				"TALK":
					marker.position = Vector2(1920, 880) - marker.texture.get_size()/2
					
			marker.name = quest
			markers_container.add_child(marker)
			
	else:
		for child in markers_container.get_children():
			child.queue_free()








func show_action_prompt(actions: Array, action_object: Node2D):
	current_action_object = action_object
	
	if action_object.is_talking:  # Jeśli ten obiekt mówi, nie pokazuj opcji
		return
	
	for action in actions:
		var label = Label.new()
		label.text = action
		label.set("theme_override_font_sizes/font_size", 48)
		action_prompt_container.add_child(label)
		action_labels.append(label)
	selected_action = 0
	highlight_option(selected_action, "action")
	action_prompt_active = true
	action_prompt_container.show()

func update_action_prompt(actions: Array):
	if current_action_object.is_talking:  # Jeśli mówi, nie aktualizuj
		return
	
	for child in action_prompt_container.get_children():
		child.queue_free()
	action_labels.clear()
	for action in actions:
		var label = Label.new()
		label.text = action
		label.set("theme_override_font_sizes/font_size", 48)
		action_prompt_container.add_child(label)
		action_labels.append(label)
	selected_action = 0
	highlight_option(selected_action, "action")

func hide_action_prompt():
	action_prompt_active = false
	action_prompt_container.hide()
	for child in action_prompt_container.get_children():
		child.queue_free()
	action_labels.clear()






func navigate_option(direction: int, context: String):
	if context == "action":
		if action_labels.size() == 0: return
		selected_action = (selected_action + direction) % action_labels.size()
		if selected_action < 0:
			selected_action = action_labels.size() - 1
		highlight_option(selected_action, context)
	
	if context == "pause":
		var max_opcji = 3  # Ilość opcji w menu pauzy
		opcja_pauzy_wybrana = (opcja_pauzy_wybrana + direction) % max_opcji
		if opcja_pauzy_wybrana < 1:  # Ponieważ opcje są od 1 do 3
			opcja_pauzy_wybrana = max_opcji
		highlight_option(opcja_pauzy_wybrana, context)

func highlight_option(index: int, context: String):
	if context == "action":
		for i in range(action_labels.size()):
			var label = action_labels[i]
			if i == index:
				#label.set("theme_override_colors/font_color", kolor_wybrania)
				label.set("theme_override_font_sizes/font_size", 64)
			else:
				#label.set("theme_override_colors/font_color", kolor_niewybrania)
				label.set("theme_override_font_sizes/font_size", 48)
				
	if context == "pause":
		label1.set("theme_override_colors/font_color", kolor_wybrania if index == 1 else kolor_niewybrania)
		label2.set("theme_override_colors/font_color", kolor_wybrania if index == 2 else kolor_niewybrania)
		label3.set("theme_override_colors/font_color", kolor_wybrania if index == 3 else kolor_niewybrania)








func dialogue_bubble(dialogue_key: String):
	
	var this_bubble_action_object = current_action_object #obiekt posiadajacy bobleka tego konkretnego
	var localized_text = tr(dialogue_key)
	var dialogue_panel = Panel.new()
	var dialogue_text = RichTextLabel.new()
	var dialogue_image = TextureRect.new()
	
	this_bubble_action_object.is_talking = true
	
	#sprawdzanie czy juz istneije i ewnetualne usuwannie
	for child in current_action_object.get_children():
		if child is Panel:
			child.queue_free()
	




	
	dialogue_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM) 
	dialogue_panel.size = Vector2(400, 300)  # Ustawienie rozmiaru panelu
	#dialogue_panel.add_theme_stylebox_override("panel", StyleBoxFlat.new()) # Ustawienie stylu
	
	dialogue_image.texture = load("res://interfaces/dialogueimage.png")
	dialogue_image.anchor_left = 0.5
	dialogue_image.anchor_right = 0.5
	dialogue_image.anchor_top = 1.0
	dialogue_image.anchor_bottom = 1.0
	dialogue_image.offset_left = -dialogue_image.texture.get_width() / 2
	dialogue_image.offset_top = -dialogue_image.texture.get_height() / 2
	
	dialogue_text.custom_minimum_size = Vector2(400, 300)  # Ustawienie minimalnego rozmiaru dla label
	dialogue_text.set("theme_override_font_sizes/normal_font_size", 28)
	dialogue_text.set("theme_override_colors/default_color", Color.WHITE)



	#przypisywanie dzieciaków
	current_action_object.add_child(dialogue_panel)
	dialogue_panel.add_child(dialogue_image)
	dialogue_panel.add_child(dialogue_text)
	dialogue_panel.position = current_action_object.dialogue_bubble_offset
	
	
	
	
	#pokazywanie tylko wybranego dialogu na czas animacji mowienia
	for i in range(action_labels.size()):
		if i == selected_action:
			action_labels[i].set("theme_override_colors/font_color", kolor_nieaktywny)
		else:
			action_labels[i].hide()


	#dialogue_text.text = localized_text
	for i in range(len(localized_text)): # ta petla tobi wypisywanie sie tekstu po literce
		dialogue_text.text = localized_text.substr(0, i + 1)
		await get_tree().create_timer(0.015).timeout

	this_bubble_action_object.is_talking = false

	if this_bubble_action_object.player_in_area:
			update_action_prompt(this_bubble_action_object.to_action_prompt)

	#czekanie az gracza nie bedzie w area ponad 5 sekund
	var remaining_time = 5.0 # ile sekund czeka bez gracza w area
	var current_remaining_time = remaining_time
	
	while current_remaining_time > 0.0: 
		await get_tree().process_frame
		if this_bubble_action_object.player_in_area: # gdy gracz w area
			if is_instance_valid(dialogue_image):
				dialogue_image.modulate = Color(1, 1, 1) 
			current_remaining_time = remaining_time  #resetowanie licznika jesli gracz w area
		else:
			if is_instance_valid(dialogue_image):
				dialogue_image.modulate = Color(0, 0, 0)

			current_remaining_time -= get_process_delta_time()  #zmniejszanie licnzika jesli gracz poza area

	#usuwanie jesli dalej istnieje bo moze byc usuniety wczesniej przez zastapienie
	if is_instance_valid(dialogue_panel):
		dialogue_panel.queue_free()
