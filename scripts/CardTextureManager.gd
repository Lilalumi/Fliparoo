# CardTextureManager.gd
extends Node

# Diccionario con los paths base de las texturas
var card_images = {
	"hearts": "res://assets/art/sprites/cards/hearts/",
	"diamonds": "res://assets/art/sprites/cards/diamonds/",
	"clubs": "res://assets/art/sprites/cards/clubs/",
	"spades": "res://assets/art/sprites/cards/spades/"
}

# Función que devuelve la textura de una carta basada en el palo y el número
func get_texture_for_card(suit: String, number: int) -> Texture:
	var path = card_images[suit] + str(number) + ".png"
	return load(path)
