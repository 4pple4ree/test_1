extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var ui_scene: PackedScene = preload("res://scenes/UI.tscn")

@export var total_waves: int = 3
@export var enemies_per_wave: int = 3

@onready var player_spawn: Node2D = $"PlayerSpawn"
@onready var enemy_container: Node2D = $"EnemyContainer"

var current_wave: int = 0
var alive_enemies: int = 0
var player_instance: Node2D

func _ready() -> void:
    player_instance = spawn_player()
    var ui_instance = ui_scene.instantiate()
    add_child(ui_instance)
    if player_instance.has_signal("health_changed"):
        player_instance.connect("health_changed", ui_instance, "update_hp")
    spawn_wave()

func spawn_player() -> Node2D:
    var p = player_scene.instantiate()
    p.position = player_spawn.position
    add_child(p)
    return p

func spawn_wave() -> void:
    if current_wave >= total_waves:
        print("Stage Clear!")
        return
    for i in range(enemies_per_wave):
        var enemy: Node2D = enemy_scene.instantiate()
        enemy.position = player_spawn.position + Vector2(200 + i * 50, 0)
        enemy_container.add_child(enemy)
        enemy.connect("died", self, "_on_enemy_died")
        alive_enemies += 1
    current_wave += 1
    print("Wave %d spawned" % current_wave)

func _on_enemy_died(enemy):
    alive_enemies -= 1
    if alive_enemies <= 0:
        spawn_wave()