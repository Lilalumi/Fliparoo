extends Node

var deck_core = []
var hand_size_core = 2
var unflip_count_core = 2

@onready var texture_manager = $CardTextureManager

func _ready():
	_initialize_deck_core()

func _initialize_deck_core():
	var suits = ["hearts", "diamonds", "clubs", "spades"]
	for suit in suits:
		for number in range(1, 14):
			var card = {
				"suit": suit,
				"number": number,
				"image": texture_manager.get_texture_for_card(suit,number),
				"modifier": "null"
			}
			
			deck_core.append(card)
			
	
