extends Node

var deck_playing = []

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
		
func _shuffle_deck():
	deck_playing.shuffle()



	
