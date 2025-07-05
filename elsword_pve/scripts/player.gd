extends CharacterBody2D

signal health_changed(current: int, max: int)

@export var speed: float = 200.0

@export var max_hp: int = 100
@export var max_mp: int = 100
var hp: int
var mp: int

@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.4
var attack_timer: float = 0.0

@onready var attack_hitbox: Area2D = $"AttackHitbox"

func _ready() -> void:
    hp = max_hp
    mp = max_mp
    add_to_group("player")
    attack_hitbox.monitoring = false
    attack_hitbox.connect("body_entered", self, "_on_attack_body_entered")
    emit_signal("health_changed", hp, max_hp)

func _physics_process(delta: float) -> void:
    handle_movement()
    handle_attack(delta)

func handle_movement() -> void:
    var input_vector := Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    if input_vector.length_squared() > 0:
        input_vector = input_vector.normalized()
    velocity = input_vector * speed
    move_and_slide()

func handle_attack(delta: float) -> void:
    if attack_timer > 0.0:
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_hitbox.monitoring = false
    if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
        start_attack()

func start_attack() -> void:
    attack_timer = attack_cooldown
    attack_hitbox.monitoring = true
    # TODO: Play attack animation

func _on_attack_body_entered(body: Node) -> void:
    if body.has_method("apply_damage"):
        body.apply_damage(attack_damage)

func apply_damage(amount: int) -> void:
    hp -= amount
    emit_signal("health_changed", hp, max_hp)
    if hp <= 0:
        queue_free()