extends Node


func TestDomek1_entry(body: Node2D):
	#print("Gracz enter")
	switch("AAADwor", false)
	switch("TestDomek1", true)

func TestDomek1_exit(body: Node2D):
	#print("Gracz exit")
	switch("TestDomek1", false)
	switch("AAADwor", true)
	
func orto_entry(body: Node2D) -> void:
	switch("AAADwor", false)
	switch("Test3D_orto", true)


func orto_exit(body: Node2D) -> void:
	switch("Test3D_orto", false)
	switch("AAADwor", true)
	
	
	
	
	
	
	
	
	
	
	



func switch(group_name, active):
	for node in get_tree().get_nodes_in_group(group_name):
		abiduaka(node, active)
	
func abiduaka(node, active):
	#set_process_mode(0 if active else 4) # to wymaga cos tam set =defeared
	if "disabled" in node:
		#node.disabled = !active
		node.set_deferred("disabled", !active)
		
	#if node.has_method("set_visible"):
	#node.set_visible(active)
	if "modulate" in node:
		var tween = get_tree().create_tween()
		tween.tween_property(node, "modulate:a", 1.0 if active else 0.0, 0.1) #wartosc alfa, czas trawnia
		
	for child in node.get_children():
		abiduaka(child, active)
		
		
		
		
		
#auto import nazwy grup. Możliwy?
#wylaczanie monitoring w area2d zamiast disabled w koliderach
#pojedyncze wywolanie funkcji zamiast podowjengo i wgl zautomatyzowane
#nazwy zmienic sygnalow

#Najpierw wylaczanie widocznosci potem wlaczanie?!?!?

#Czy rysować 2d czy 3d
#rybie oko?
#Pietra itp sprawdzic
#okreslic pod jakim katem renderowac
#blokowanie kamery marginesy w budynkach
