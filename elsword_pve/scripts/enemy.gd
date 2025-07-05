extends CharacterBody2D

signal died

@export var speed: float = 100.0
@export var max_hp: int = 30
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

var hp: int
var attack_timer: float = 0.0
var target: Node2D

@onready var attack_area: Area2D = $"AttackArea"

func _ready() -> void:
    hp = max_hp
    attack_area.connect("body_entered", self, "_on_attack_area_body_entered")
    target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    if target and target.is_inside_tree():
        var direction := (target.global_position - global_position).normalized()
        velocity = direction * speed
    else:
        velocity = Vector2.ZERO
    move_and_slide()

    if attack_timer > 0.0:
        attack_timer -= delta

func _on_attack_area_body_entered(body: Node) -> void:
    if attack_timer > 0.0:
        return
    if body.is_in_group("player") and body.has_method("apply_damage"):
        body.apply_damage(attack_damage)
        attack_timer = attack_cooldown

func apply_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        die()

func die() -> void:
    emit_signal("died", self)
    queue_free()