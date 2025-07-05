extends Node2D

@export var life: float = 0.3

func _ready() -> void:
    await get_tree().create_timer(life).timeout
    queue_free()