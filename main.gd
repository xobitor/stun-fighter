extends Node2D

@onready var f1: Fighter = $Fighter1
@onready var f2: Fighter = $Fighter2

func _ready() -> void:
	f1.opponent = f2
	f2.opponent = f1
