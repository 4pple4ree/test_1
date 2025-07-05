extends CharacterBody2D

signal health_changed(current: int, max: int)
signal mp_changed(current: int, max: int)

# Movement
@export var speed: float = 200.0

# Stats
@export var max_hp: int = 100
@export var max_mp: int = 100
var hp: int
var mp: int

# Combo Attacks
const COMBO_ATTACKS := [
    {"anim": "attack1", "damage": 10, "duration": 0.3},
    {"anim": "attack2", "damage": 12, "duration": 0.35},
    {"anim": "attack3", "damage": 15, "duration": 0.4},
]
var attack_index: int = 0
var attack_timer: float = 0.0
var combo_window: float = 0.2 # time before attack ends to accept next input

# Skill
@export var skill_cost: int = 20
@export var skill_damage: int = 40
@export var skill_cooldown: float = 2.0
var skill_timer: float = 0.0

@onready var attack_hitbox: Area2D = $"AttackHitbox"
@onready var skill_hitbox: Area2D = $"SkillHitbox"
@onready var anim_player: AnimationPlayer = $"AnimationPlayer"

func _ready() -> void:
    hp = max_hp
    mp = max_mp
    add_to_group("player")
    attack_hitbox.monitoring = false
    skill_hitbox.monitoring = false
    attack_hitbox.connect("body_entered", self, "_on_attack_body_entered")
    skill_hitbox.connect("body_entered", self, "_on_skill_body_entered")
    emit_signal("health_changed", hp, max_hp)
    emit_signal("mp_changed", mp, max_mp)

func _physics_process(delta: float) -> void:
    handle_movement()
    handle_attacks(delta)
    handle_skill(delta)

func handle_movement() -> void:
    var input_vector := Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    if input_vector.length_squared() > 0 and attack_timer <= 0: # allow slight movement while attacking ended
        input_vector = input_vector.normalized()
        velocity = input_vector * speed
    else:
        velocity = Vector2.ZERO if attack_timer > 0 else Vector2.ZERO
    move_and_slide()

func handle_attacks(delta: float) -> void:
    if attack_timer > 0:
        attack_timer -= delta
        if attack_timer <= combo_window:
            # allow chaining if input pressed
            if Input.is_action_just_pressed("attack"):
                chain_attack()
        if attack_timer <= 0:
            attack_end()
    elif Input.is_action_just_pressed("attack"):
        start_attack()

func start_attack() -> void:
    attack_index = 0
    play_attack(COMBO_ATTACKS[attack_index])

func chain_attack() -> void:
    if attack_index + 1 < COMBO_ATTACKS.size():
        attack_index += 1
        play_attack(COMBO_ATTACKS[attack_index])

func play_attack(data: Dictionary) -> void:
    attack_timer = data.duration
    attack_hitbox.monitoring = true
    anim_player.play(data.anim)

func attack_end() -> void:
    attack_hitbox.monitoring = false
    attack_index = 0

func handle_skill(delta: float) -> void:
    if skill_timer > 0:
        skill_timer -= delta
    if Input.is_action_just_pressed("skill1") and skill_timer <= 0 and mp >= skill_cost:
        cast_skill()

func cast_skill() -> void:
    mp -= skill_cost
    emit_signal("mp_changed", mp, max_mp)
    skill_timer = skill_cooldown
    skill_hitbox.monitoring = true
    anim_player.play("skill1")
    await get_tree().create_timer(0.2).timeout
    skill_hitbox.monitoring = false

func _on_attack_body_entered(body: Node) -> void:
    if body.has_method("apply_damage"):
        var damage := COMBO_ATTACKS[attack_index].damage
        body.apply_damage(damage)

func _on_skill_body_entered(body: Node) -> void:
    if body.has_method("apply_damage"):
        body.apply_damage(skill_damage)

func apply_damage(amount: int) -> void:
    hp -= amount
    emit_signal("health_changed", hp, max_hp)
    if hp <= 0:
        die()

func die() -> void:
    queue_free()