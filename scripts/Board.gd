extends Node2D

var DeckPlayingScene = preload("res://Scenes/DeckPlaying.tscn")
var CardSpawningScene = preload("res://Scenes/CardSpawning.tscn")

var rows = 4
var cols = 6
var spacing = Vector2(120, 160)

@onready var deck_label = $UI/Deck
@onready var deck_playing_instance = null

# Diccionario para llevar un registro de las cartas en el tablero
var card_registry = {}  # Clave: ID del nodo, Valor: Estado (up_front o up_down)
var cards_up_front = 0  # Contador de cartas con up_front = true

func _ready():
	_instantiate_deck_playing()
	_create_board()
	await get_tree().create_timer(0.5).timeout

func _process(delta):
	_update_deck_label()
	#_update_card_registry()
	
func _instantiate_deck_playing():
	deck_playing_instance = DeckPlayingScene.instantiate()
	add_child(deck_playing_instance)  # Añadir DeckPlaying al árbol de nodos

func _create_board():
	var card_spawning_id_counter = 0
	
	for row in range(rows):
		for col in range(cols):
			var card_spawning_instance = CardSpawningScene.instantiate()  # Crear una instancia de CardSpawning
			add_child(card_spawning_instance)  # Añadir al árbol de nodos
			
			# Asignar un ID único a cada CardSpawning
			card_spawning_instance.name = "CardSpawning_" + str(card_spawning_instance)
			card_spawning_id_counter += 1
			
			var position = Vector2(col * spacing.x, row * spacing.y) + Vector2(50, 50)  # Ajusta el offset según necesites
			card_spawning_instance.set_global_position(position)
			
# Función que se llama cuando una carta se instancia
func _on_card_instantiated(card_in_play):
	await get_tree().create_timer(0.01).timeout
	var card_info = {
		"id": card_in_play.get_instance_id(),  # ID de la carta
		"suit": card_in_play.suit,  # Palo de la carta
		"number": card_in_play.number,  # Número de la carta
		"modifier": card_in_play.modifier,  # Modificador de la carta
		"up_front": card_in_play.up_front,  # Estado inicial de la carta
		"up_down": card_in_play.up_down,
		"node": card_in_play
	}

	# Agregar la carta al registro
	card_registry[card_in_play.get_instance_id()] = card_info
	print("Card instantiated and added to registry:", card_info)
	
# Funciones que manejan las señales de CardInPlay
func _on_card_flipped_to_front(card_in_play):
	# Actualizar el estado en el diccionario
	if card_in_play.get_instance_id() in card_registry:
		# Solo incrementar si no estaba ya "up_front"
		if not card_registry[card_in_play.get_instance_id()]["up_front"]:
			card_registry[card_in_play.get_instance_id()]["up_front"] = true
			cards_up_front += 1  # Incrementar el contador
	print("Card flipped to front:", card_in_play.get_instance_id())
	print("Cards up front:", cards_up_front)
	
	#Si hay dos cartas con el frente visible, realiza la comprobación
	if cards_up_front == 2:
		check_value()

func _on_card_flipped_to_back(card_in_play):
	# Actualizar el estado en el diccionario
	if card_in_play.get_instance_id() in card_registry:
	# Solo decrementar si estaba "up_front"
		if card_registry[card_in_play.get_instance_id()]["up_front"]:
			card_registry[card_in_play.get_instance_id()]["up_front"] = false
			cards_up_front -= 1  # Decrementar el contador
			if cards_up_front < 0:
				cards_up_front = 0  # Asegurarse de que no sea menor a 0
	print("Card flipped to back:", card_in_play.get_instance_id())
	print("Cards up front:", cards_up_front)

func _on_card_destroyed(card_in_play):
	# Eliminar la carta del diccionario
	if card_in_play.get_instance_id() in card_registry:
		card_registry.erase(card_in_play.get_instance_id())
	print("Card destroyed and removed from registry:", card_in_play.get_instance_id())

# Nueva función para comparar las cartas up_front
func check_value():
	var up_front_cards = []

	# Buscar las dos cartas que tienen up_front = true
	for card_id in card_registry:
		if card_registry[card_id]["up_front"]:
			up_front_cards.append(card_id)

	if up_front_cards.size() == 2:
		var card1 = card_registry[up_front_cards[0]]
		var card2 = card_registry[up_front_cards[1]]

		# 1. True Par: Mismo suit y mismo número
		if card1["suit"] == card2["suit"] and card1["number"] == card2["number"]:
			print("True Par: Both cards are the same suit and number!")
			_trigger_card_destruction(up_front_cards)

		# 2. Par Suit: Mismo suit
		elif card1["suit"] == card2["suit"]:
			print("Par Suit: Both cards have the same suit!")
			_trigger_card_destruction(up_front_cards)

		# 3. Par Number: Mismo número
		elif card1["number"] == card2["number"]:
			print("Par Number: Both cards have the same number!")
			_trigger_card_destruction(up_front_cards)

		# 4. Ninguna coincidencia, flip to back
		else:
			print("No match, flipping both cards back.")
			_flip_cards_back(up_front_cards)

#Función que destruye ambas cartas que cumplen alguna de las condiciones
func _trigger_card_destruction(cards_to_destroy):
	for card_id in cards_to_destroy:
		if card_registry.has(card_id):
			var card_node = card_registry[card_id]["node"]  # Recuperar el nodo desde el registro
			if card_node:
				card_node._destroy_with_effect()
	cards_up_front = 0  # Reiniciar el contador de cartas con frente visible

func _flip_cards_back(cards_to_flip):
	for card_id in cards_to_flip:
		if card_registry.has(card_id):
			var card_node = card_registry[card_id]["node"]  # Recuperar el nodo desde el registro
			if card_node:
				card_node._flip_to_back_failed_check()
	cards_up_front = 0  # Reiniciar el contador de cartas con frente visible

func connect_card_signals(card_in_play):
	# Conectar la señal "card_instantiated" si no está conectada
	if not card_in_play.is_connected("card_instantiated", Callable(self, "_on_card_instantiated")):
		card_in_play.connect("card_instantiated", Callable(self, "_on_card_instantiated"))

	# Conectar la señal "card_flipped_to_front" si no está conectada
	if not card_in_play.is_connected("card_flipped_to_front", Callable(self, "_on_card_flipped_to_front")):
		card_in_play.connect("card_flipped_to_front", Callable(self, "_on_card_flipped_to_front"))

	# Conectar la señal "card_flipped_to_back" si no está conectada
	if not card_in_play.is_connected("card_flipped_to_back", Callable(self, "_on_card_flipped_to_back")):
		card_in_play.connect("card_flipped_to_back", Callable(self, "_on_card_flipped_to_back"))

	# Conectar la señal "card_destroyed" si no está conectada
	if not card_in_play.is_connected("card_destroyed", Callable(self, "_on_card_destroyed")):
		card_in_play.connect("card_destroyed", Callable(self, "_on_card_destroyed"))

	print("Connected signals for card:", card_in_play.name)


func _update_deck_label():
	if deck_playing_instance != null:
		var remaining_cards = deck_playing_instance.deck_playing.size()
		deck_label.text = "Deck: " + str(remaining_cards)
