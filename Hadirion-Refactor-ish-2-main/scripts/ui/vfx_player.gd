extends RefCounted
class_name VfxPlayer
## Plays an effect scene somewhere and removes it when it is finished.
## An effect can be:
##   * CPUParticles2D / GPUParticles2D - played once (it is set to one-shot)
##   * AnimatedSprite2D                - its animation played once (turn Loop off)
##   * anything with an AnimationPlayer child - the first animation is played once
##   * anything else                   - shown for a second
## Never more than MAX_AT_ONCE effects at a time, so a busy turn can't slow the game down.

const MAX_AT_ONCE := 12
## Safety net: an effect is removed after this many seconds even if it never says it is done.
const MAX_SECONDS := 3.0

static var _playing: int = 0

static func play(effect: PackedScene, parent: Node, position: Vector2) -> void:
	if effect == null or parent == null:
		return
	if _playing >= MAX_AT_ONCE:
		return
	var fx: Node = effect.instantiate()
	parent.add_child(fx)
	if fx is Node2D:
		fx.global_position = position
		fx.z_index = 3
	_playing += 1
	fx.tree_exited.connect(_on_effect_gone)
	_start(fx)
	parent.get_tree().create_timer(MAX_SECONDS).timeout.connect(_free_if_still_there.bind(fx))

## How many effects are playing right now (the tests use this).
static func playing_count() -> int:
	return _playing

static func _start(fx: Node) -> void:
	if fx is CPUParticles2D or fx is GPUParticles2D:
		fx.one_shot = true
		fx.emitting = true
		fx.finished.connect(fx.queue_free)
		return
	if fx is AnimatedSprite2D:
		fx.sprite_frames.set_animation_loop(fx.animation, false)
		fx.play()
		fx.animation_finished.connect(fx.queue_free)
		return
	var anim: AnimationPlayer = fx.get_node_or_null("AnimationPlayer")
	if anim != null and not anim.get_animation_list().is_empty():
		var first: String = ""
		for anim_name in anim.get_animation_list():
			if anim_name != "RESET":
				first = anim_name
				break
		if first != "":
			anim.play(first)
			anim.animation_finished.connect(_free_after_animation.bind(fx))
			return
	fx.get_tree().create_timer(1.0).timeout.connect(_free_if_still_there.bind(fx))

static func _free_after_animation(_anim_name: StringName, fx) -> void:
	_free_if_still_there(fx)

# `fx` has no type on purpose: by the time a timer calls this, the effect may already be gone,
# and Godot won't pass a deleted object to a typed parameter.
static func _free_if_still_there(fx) -> void:
	if is_instance_valid(fx):
		fx.queue_free()

static func _on_effect_gone() -> void:
	_playing = maxi(0, _playing - 1)
