extends Node2D

@export var player_scene: PackedScene

@onready var player_spawn: Node2D = $"PlayerSpawn"

func _ready() -> void:
    spawn_player()

func spawn_player() -> void:
    if player_scene:
        var player_instance: Node2D = player_scene.instantiate()
        player_instance.position = player_spawn.position
        add_child(player_instance)