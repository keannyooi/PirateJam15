extends Node

# these signals are necessary for certain parts of the game to function
signal enemy_defeated(enemy: Enemy)

signal select_card(card: Card)
signal select_enemy(enemy: Enemy)

# these signals are for a future implementation of achievements
signal play_card(card: Card)
