# Main.gd (escena principal del juego)
extends Node2D

var deck_core
var card_scene = load("res://Card.tscn")  # Precarga la escena de la carta

func _ready():
	deck_core = DeckCore.new()
	deck_core._initialize_deck_core()

	# Instancia una carta del DeckCore
	var card_data = deck_core.deck_core[0]  # Obtén la primera carta como ejemplo
	var card_instance = card_scene.instance()
	
	# Inicializa la carta con su palo y número
	card_instance.initialize_card(card_data.suit, card_data.number)

	# Añade la carta a la escena
	add_child(card_instance)

	# Coloca la carta en una posición visible
	card_instance.position = Vector2(400, 300)

	# Revela la carta para mostrar su cara
	card_instance.reveal_card()
