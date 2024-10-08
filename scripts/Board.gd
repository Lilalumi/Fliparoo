extends Node2D

var DeckPlayingScene = preload("res://Scenes/DeckPlaying.tscn")
var CardSpawningScene = preload("res://Scenes/CardSpawning.tscn")

var click_timer = 0  # Variable para almacenar el tiempo del último clic
var click_cooldown = 0.5  # Tiempo mínimo entre clics en segundos

var rows = 4
var cols = 6
var spacing = Vector2(120, 160)

# Timer to keep track of the game session
var game_timer: Timer = null
var remaining_time = 300  # 5 minutes in seconds

@onready var deck_label = $UI/Deck
@onready var unflip_label = $UI/Unflip
@onready var points_label = $UI/Points
@onready var goal_label = $UI/Goal
@onready var fever_label = $UI/FEVER
@onready var timer_label = $UI/Timer
@onready var time_bar = $UI/Timebar
@onready var deck_playing_instance = null

# Diccionario para llevar un registro de las cartas en el tablero
var card_registry = {}  # Clave: ID del nodo, Valor: Estado (up_front o up_down)
var cards_up_front = 0  # Contador de cartas con up_front = true
var hand_size_board = 0
var unflip_count_board = 0
var hand_size_updated = 0
var unflip_count_updated = 0
var point_goal = 9000
var point_count = 0
var fever_count = 0

func _ready():
	_instantiate_deck_playing()
	_create_board()
	await get_tree().create_timer(0.5).timeout
	_copy_values_from_playing()
	unflip_label.text = "Unflip: " + str(unflip_count_updated)
	goal_label.text = "Goal: " + str(point_goal)
	points_label.text = "Points: " + str(point_count)
	fever_label.text = "FEVER: " + str(fever_count)
	_start_game_timer()
	if fever_count == 0:
		fever_label.visible = false

# Función que verifica si se puede hacer clic
func _can_click() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0  # Tiempo actual en segundos
	if current_time - click_timer >= click_cooldown:
		click_timer = current_time  # Actualiza el tiempo del último clic
		return true
	return false

# Ejemplo de cómo usar esta verificación en un evento de clic
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _can_click():
			print("Clic permitido")
			# Aquí puedes manejar lo que sucede cuando se permite el clic
		else:
			print("Clic bloqueado. Espera un momento.")

# Function to start the game timer (5 minutes)
func _start_game_timer():
	game_timer = Timer.new()  # Create a new Timer node
	add_child(game_timer)
	game_timer.wait_time = 300  # 5 minutes = 300 seconds
	game_timer.one_shot = true  # One-shot timer
	game_timer.connect("timeout", Callable(self, "_on_game_timer_timeout"))  # Connect the timeout signal
	game_timer.start()  # Start the timer
	time_bar.max_value = 300  # Máximo valor de la barra de tiempo (5 minutos)
	time_bar.value = 300  # Establece la barra en el valor máximo al inicio


func _format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)

func _process(delta):
	if game_timer == null or game_timer.is_stopped():
		return  # No hacer nada si el temporizador no está iniciado o ya terminó
	
	remaining_time = game_timer.get_time_left()  # Obtener el tiempo restante del temporizador
	timer_label.text = _format_time(remaining_time)  # Actualizar el texto del Label
	
	# Actualizar la barra de progreso
	time_bar.value = remaining_time
	
func _instantiate_deck_playing():
	deck_playing_instance = DeckPlayingScene.instantiate()
	add_child(deck_playing_instance)  # Añadir DeckPlaying al árbol de nodos

func _copy_values_from_playing():
	await get_tree().create_timer(0.5).timeout
	# Asegúrate de que DeckPlaying se haya instanciado correctamente antes de acceder a sus propiedades
	if deck_playing_instance:
		hand_size_board = deck_playing_instance.hand_size_playing
		unflip_count_board = deck_playing_instance.unflip_count_playing
		await get_tree().create_timer(0.5).timeout
		hand_size_updated = hand_size_board
		unflip_count_updated = unflip_count_board

		print("Hand size board:", hand_size_board, " Unflip count board:", unflip_count_board)
		print("Hand size updated:", hand_size_updated, "Unflip count updated", unflip_count_updated)
	else:
		print("Error: DeckPlaying instance not found.")

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
	_update_deck_label()
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
	_update_deck_label()

	# Agregar la carta al registro
	card_registry[card_in_play.get_instance_id()] = card_info
# Funciones que manejan las señales de CardInPlay
func _on_card_flipped_to_front(card_in_play):
	#Actualizar el estado en el diccionario
	if card_in_play.get_instance_id() in card_registry:
		# Solo incrementar si no estaba ya "up_front"
		if not card_registry[card_in_play.get_instance_id()]["up_front"]:
			card_registry[card_in_play.get_instance_id()]["up_front"] = true
			print("Cards fliped up: ", cards_up_front)
	
	#Si hay dos cartas con el frente visible, realiza la comprobación
	if cards_up_front == hand_size_updated:
		check_value()

func _on_card_flipped_to_back(card_in_play):
	_update_unflip_label()
	# Actualizar el estado en el diccionario
	if card_in_play.get_instance_id() in card_registry:
	# Solo decrementar si estaba "up_front"
		if card_registry[card_in_play.get_instance_id()]["up_front"]:
			card_registry[card_in_play.get_instance_id()]["up_front"] = false
			cards_up_front -= 1  # Decrementar el contador
			if cards_up_front < 0:
				cards_up_front = 0  # Asegurarse de que no sea menor a 0

func _on_card_destroyed(card_in_play):
	# Eliminar la carta del diccionario
	if card_in_play.get_instance_id() in card_registry:
		card_registry.erase(card_in_play.get_instance_id())
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
			var points = (card1["number"] * card2["number"]) * (unflip_count_updated + 1)
			print("Calculation: (", card1["number"], "*", card2["number"], ") * (", unflip_count_updated, "+ 1 ) = ", points)
			point_count += points
			print("Points awarded (True Par):", points)
			fever_count += 1
			fever_label.text = "FEVER: " + str(fever_count)
			if fever_count > 0:
				fever_label.visible = true
			_trigger_card_destruction(up_front_cards)
			_point_check()

		# 2. Par Suit: Mismo suit
		elif card1["suit"] == card2["suit"]:
			print("Par Suit: Both cards have the same suit!")
			var points = (card1["number"] + card2["number"]) * (unflip_count_updated + 1)
			print("Calculation: (", card1["number"], "+", card2["number"], ") * (", unflip_count_updated, "+ 1 ) = ", points)
			point_count += points
			print("Points awarded (Par Suit):", points)
			fever_count += 1
			fever_label.text = "FEVER: " + str(fever_count)
			if fever_count > 0:
				fever_label.visible = true
			_trigger_card_destruction(up_front_cards)
			_point_check()

		# 3. Par Number: Mismo número
		elif card1["number"] == card2["number"]:
			print("Par Number: Both cards have the same number!")
			var points = (card1["number"] + card2["number"]) * (unflip_count_updated + 1)
			print("Calculation: (", card1["number"], "+", card2["number"], ") * (", unflip_count_updated, "+ 1 ) = ", points)
			point_count += points
			print("Points awarded (Par Number):", points)
			fever_count += 1
			fever_label.text = "FEVER: " + str(fever_count)
			if fever_count > 0:
				fever_label.visible = true
			_trigger_card_destruction(up_front_cards)
			_point_check()

		# 4. Ninguna coincidencia, flip to back
		else:
			fever_count = 0
			fever_label.text = "FEVER: " + str(fever_count)
			if fever_count == 0:
				fever_label.visible = false
			print("No match, flipping both cards back.")
			_flip_cards_back(up_front_cards)
			
	unflip_count_updated = unflip_count_board
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

func _point_check():
	print("Total points:", point_count)
	points_label.text = "Points: " + str(point_count)
	if point_count >= point_goal:
		print("You Win")

func _update_deck_label():
	_update_unflip_label()
	if deck_playing_instance != null:
		var remaining_cards = deck_playing_instance.deck_playing.size()
		deck_label.text = "Deck: " + str(remaining_cards)
		
func _update_unflip_label():
	unflip_label.text = "Unflip: " + str(unflip_count_updated)

# Function that gets called when the timer runs out (game over)
func _on_game_timer_timeout():
	print("Game Over - Time's Up!")
	_trigger_game_over()

# Handle the game over logic (this can be customized further)
func _trigger_game_over():
	# Show a game over screen, disable inputs, etc.
	# For now, let's just print game over and stop the game
	get_tree().paused = true  # Pause the game
	print("Game Over! Pausing the game.")
