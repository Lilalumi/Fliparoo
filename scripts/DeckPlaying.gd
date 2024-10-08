extends Node

var deck_playing = []
var hand_size_playing = 0
var unflip_count_playing = 0

@onready var deck_session = get_node("/root/Main/DeckSession")

func _ready():
	_generate_deck()
	_shuffle_deck()
	
	
func _generate_deck():
	var original_deck = deck_session.deck_session
	deck_playing.clear()
	for card in original_deck:
		deck_playing.append(card.duplicate())
		deck_playing.append(card.duplicate())
	_copy_values_from_session()
		
func _shuffle_deck():
	deck_playing.shuffle()

func _copy_values_from_session():
	# Copiar hand_size y unflip_count desde DeckSession
	hand_size_playing = deck_session.hand_size_session
	unflip_count_playing = deck_session.unflip_count_session


	
