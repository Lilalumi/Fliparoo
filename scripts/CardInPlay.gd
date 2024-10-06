extends Node2D

@onready var sprite = $Sprite2D
@onready var deck_playing = get_node("/root/Board/DeckPlaying")
var remaining_cards = 0

func _ready():
	_choose_card()
	
func _choose_card():
	print(deck_playing.deck_playing.size())
	
	remaining_cards = int(deck_playing.deck_playing.size())
	
	print("Remaining cards in deck are: ", remaining_cards)
	
	if remaining_cards == 0:
		print("Game Over")
	else:
		var card = deck_playing.deck_playing.pop_back()
	
		sprite.texture = card.image
	
		print("Carta en juego: ", card.suit, " ", card.number, " Modifier: ", card.modifier)
	
	#print("Quedan cartas ", remaining_cards, "en DeckPlaying")
	#else:
		#print("No quedan cartas en DeckPlaying")
		
	print(deck_playing.deck_playing.size())
