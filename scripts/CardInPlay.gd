extends Node2D

@onready var sprite = $Sprite2D
@onready var deck_playing = get_node("/root/Board/DeckPlaying")
var remaining_cards = 0
var wave_amplitude = 0  # Ajusta la amplitud del efecto wave
var wave_speed = 2  # Ajusta la velocidad de oscilación
var time = 0  # Variable para el tiempo


func _ready():
	wave_amplitude = randf_range(5, 10)
	_choose_card()
	set_process(true)
	
func _process(delta):
	time += delta
	var wave_offset = sin(time * wave_speed) + wave_amplitude
	sprite.position.y = 22 + wave_offset
	#sprite.position.x = 0 + sin(time * wave_speed) * wave_amplitude
	
	

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
			
	print(deck_playing.deck_playing.size())
	
