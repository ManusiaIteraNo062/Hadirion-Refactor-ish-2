extends CharacterPlaceholder
class_name UnitVisual
## One fighter on the battlefield (scenes/battle/unit_visual.tscn).
## With no art it draws the stick figure. There are two kinds of art:
##
## 1) Single pictures (set_art): one picture per pose.
##      "idle"   - standing around
##      "attack" - while attacking
##      "alter"  - while using an Alteration (characters only)
##      "hurt"   - when hit (characters only)
##    A pose that has no picture just shows idle.
##
## 2) An animated sprite sheet (set_animated_art): a SpriteFrames resource whose
##    ANIMATIONS carry the pose names, plus a few extras:
##      "idle"   - loops while standing around (required)
##      "attack" - the club swing (it plays after the jump, see play_lunge)
##      "alter"  - the spellcast
##      "hurt"   - a short flinch when hit
##      "defeat" - falls down and stays down (while being dragged off)
##      "jump"   - the hop to the target and back (play_lunge)
##      "guard"  - the Guard stance
##    An animation that is missing just shows idle.

# The stick figure is about 122 units tall (head top -72, feet +50) at figure_scale 1.
# The picture is scaled to the same height so names, numbers and markers still fit.
const FIGURE_HEIGHT := 122.0

## Make a single picture bigger or smaller than the stick figure (1.0 = same height).
@export var art_size: float = 1.0

@export_group("Animated art (sprite sheets)")
## Size of an animated character relative to the stick figure. One LPC frame is 64 px with empty
## space around a ~44 px tall character, so 1.6 makes the character about as tall as the stick figure.
@export var anim_size: float = 1.6
## Where the feet are inside one frame, in pixels from the top (LPC: 58 of 64).
@export var anim_feet_y: float = 58.0

@export_group("Lunge (jump to the enemy, swing, jump back)")
## How far in front of the target the fighter lands (screen pixels).
@export var lunge_distance: float = 90.0
## Seconds each jump takes (there, and back).
@export var lunge_jump_seconds: float = 0.3
## How high the jump arc goes (screen pixels).
@export var lunge_jump_height: float = 70.0
## Seconds to stay after the swing before jumping back.
@export var lunge_hold_seconds: float = 0.1
## The frame of "attack" (counting from 0) where the club hits: the damage shows up then.
@export var attack_impact_frame: int = 3
## The frame of "alter" (counting from 0) where the spell leaves the hands.
@export var alter_impact_frame: int = 4

## Effects (set by the stage from the character / enemy data).
var attack_vfx: PackedScene
var alter_vfx: PackedScene
var guard_vfx: PackedScene
## True once dragged off / faded out, so a window resize doesn't put it back.
var gone: bool = false

var _textures: Dictionary = {}     # pose name -> Texture2D (single pictures)
var _frames: SpriteFrames          # the animated sprite sheet (null = none)
var _sprite: Sprite2D
var _anim: AnimatedSprite2D
var _anchor: Marker2D
var _pose_tween: Tween
var _lunge_tween: Tween
var _lunging: bool = false

func _ready() -> void:
	_sprite = get_node("Sprite")
	_anim = get_node("AnimSprite")
	_anchor = get_node("VfxAnchor")
	_anim.animation_finished.connect(_on_anim_finished)

## Give this fighter its pictures. `textures` is {"idle": Texture2D, "attack": ...}.
## `mirror` flips them (art is drawn facing right; enemies stand on the right and face left).
func set_art(textures: Dictionary, mirror: bool) -> void:
	_textures = textures
	_sprite.flip_h = mirror
	_sprite.texture = textures["idle"]
	_sprite.visible = true
	update_layout()

## Give this fighter an animated sprite sheet: a SpriteFrames with at least an "idle" animation.
## `mirror` flips it (art is drawn facing right).
func set_animated_art(frames: SpriteFrames, mirror: bool) -> void:
	if frames == null or not frames.has_animation("idle") or frames.get_frame_count("idle") == 0:
		return
	var first: Texture2D = frames.get_frame_texture("idle", 0)
	var first_atlas: AtlasTexture = first as AtlasTexture
	if first == null or (first_atlas != null and first_atlas.atlas == null):
		return   # the PNG is not imported (yet): keep the stick figure
	_frames = frames
	_anim.sprite_frames = frames
	_anim.flip_h = mirror
	_anim.visible = true
	_anim.play("idle")
	update_layout()

func is_animated() -> bool:
	return _frames != null

func has_art() -> bool:
	return _frames != null or (_sprite != null and _sprite.visible)

## Call after figure_scale or position changed: redraw, resize the picture, move the effect anchor.
func update_layout() -> void:
	queue_redraw()
	var feet: float = 50.0 * figure_scale
	if _frames != null:
		var frame_height: float = _frames.get_frame_texture("idle", 0).get_height()
		var factor: float = FIGURE_HEIGHT * figure_scale * anim_size / frame_height
		_anim.scale = Vector2(factor, factor)
		# The sprite is centred on its frame: shift it so the FEET (not the bottom edge of the frame)
		# land where the stick figure's feet were. Bigger frames (the 192 px club swing) are centred
		# the same way, so every animation lines up.
		_anim.position = Vector2(0, feet - (anim_feet_y - frame_height / 2.0) * factor)
		_anchor.position = _anim.position   # effects play at the middle of the picture
		return
	var height: float = FIGURE_HEIGHT * figure_scale * art_size
	if has_art():
		var tex: Texture2D = _textures["idle"]
		var factor: float = height / tex.get_height()
		_sprite.scale = Vector2(factor, factor)
		_sprite.position = Vector2(0, feet - height / 2.0)   # feet stay where the stick figure's feet were
		_anchor.position = _sprite.position                  # effects play at the middle of the picture
	elif _anchor != null:
		_anchor.position = Vector2(0, -11.0 * figure_scale)  # middle of the stick figure

## Where effects should appear (in the stage's coordinates).
func vfx_position() -> Vector2:
	return _anchor.global_position

func _draw() -> void:
	if has_art():
		return
	super._draw()

## Show a pose. Single pictures: with seconds > 0 it goes back to idle afterwards.
## Animated sprite sheet: plays the animation with that name (idle if there is none) and goes
## back to idle when it ends, so `seconds` is not used.
func show_pose(pose: String, seconds: float = 0.0) -> void:
	if _frames != null:
		var anim_name: String = pose if _frames.has_animation(pose) else "idle"
		_anim.stop()   # so asking for the animation that is already showing starts it over
		_anim.play(anim_name)
		return
	if not has_art():
		return
	var tex: Texture2D = _textures.get(pose)
	if tex == null:
		tex = _textures["idle"]
	_sprite.texture = tex
	if _pose_tween:
		_pose_tween.kill()
	if seconds > 0.0:
		_pose_tween = create_tween()
		_pose_tween.tween_interval(seconds)
		_pose_tween.tween_callback(show_pose.bind("idle"))

## A one-shot animation (attack, alter, hurt...) ended: back to idle. "defeat" stays down, and during
## a lunge the lunge itself decides what comes next.
func _on_anim_finished() -> void:
	if _lunging or gone or _anim.animation == &"defeat":
		return
	_anim.play("idle")

## A quick blink (used with the Alteration pose of single pictures; the spellcast animation needs none).
func flicker(times: int = 3) -> void:
	if not has_art() or _frames != null:
		return
	var tw: Tween = create_tween()
	for i in range(times):
		tw.tween_property(_sprite, "modulate:a", 0.35, 0.06)
		tw.tween_property(_sprite, "modulate:a", 1.0, 0.06)

# ---- jump to the enemy, swing, jump back ------------------------------------------------

## True if this fighter can do the jump-and-swing (it needs an "attack" animation).
func can_lunge() -> bool:
	return _frames != null and _frames.has_animation("attack")

## How long one whole animation takes, in seconds.
func anim_seconds(anim_name: String) -> float:
	return _seconds_until_frame(anim_name, 1000000)

## How long the animation takes to reach `frame` (counting from 0), in seconds.
func _seconds_until_frame(anim_name: String, frame: int) -> float:
	if _frames == null or not _frames.has_animation(anim_name):
		return 0.0
	var total: float = 0.0
	for i in range(mini(frame, _frames.get_frame_count(anim_name))):
		total += _frames.get_frame_duration(anim_name, i)
	return total / maxf(_frames.get_animation_speed(anim_name), 0.01)

## Seconds from the start of a lunge until the club hits (the damage should show up then).
func lunge_impact_seconds() -> float:
	return lunge_jump_seconds + _seconds_until_frame("attack", attack_impact_frame)

## Seconds a whole lunge takes: jump there + swing + hold + jump back.
func lunge_total_seconds() -> float:
	return lunge_jump_seconds * 2.0 + anim_seconds("attack") + lunge_hold_seconds

## Seconds from the start of the spellcast until the spell leaves the hands.
func alter_impact_seconds() -> float:
	return _seconds_until_frame("alter", alter_impact_frame)

## Jump to `spot` (a position in the stage's coordinates), swing the club, jump back home.
## The stage uses lunge_impact_seconds() / lunge_total_seconds() to time everything else.
func play_lunge(spot: Vector2) -> void:
	if not can_lunge():
		return
	if _lunge_tween:
		_lunge_tween.kill()
	var home: Vector2 = position
	_lunging = true
	z_index = 1   # in front of the enemies while it is over there
	_lunge_tween = create_tween()
	# 1) jump to the target
	_lunge_tween.tween_callback(show_pose.bind("jump"))
	_lunge_tween.tween_method(_jump_step.bind(home, spot), 0.0, 1.0, lunge_jump_seconds)
	# 2) swing the club
	_lunge_tween.tween_callback(show_pose.bind("attack"))
	_lunge_tween.tween_interval(anim_seconds("attack") + lunge_hold_seconds)
	# 3) jump back
	_lunge_tween.tween_callback(show_pose.bind("jump"))
	_lunge_tween.tween_method(_jump_step.bind(spot, home), 0.0, 1.0, lunge_jump_seconds)
	# 4) done
	_lunge_tween.tween_callback(_end_lunge.bind(home))

## One step of a jump (t goes from 0 to 1): a straight line from `from` to `to`, plus an arc upwards.
func _jump_step(t: float, from: Vector2, to: Vector2) -> void:
	position = from.lerp(to, t) + Vector2(0.0, -sin(t * PI) * lunge_jump_height)

func _end_lunge(home: Vector2) -> void:
	_lunging = false
	z_index = 0
	position = home
	show_pose("idle")

# ---- the end of a fight -----------------------------------------------------------------

## A party member went down: dragged off the left side of the screen, wobbling.
func play_drag_off() -> void:
	gone = true
	if _lunge_tween:
		_lunge_tween.kill()
	_lunging = false
	z_index = 0
	if _frames != null and _frames.has_animation("defeat"):
		show_pose("defeat")
	else:
		show_pose("hurt")
	var tw: Tween = create_tween()
	tw.tween_property(self, "position:x", -160.0, 0.9).set_ease(Tween.EASE_IN)
	var wobble: Tween = create_tween()
	for i in range(4):
		wobble.tween_property(self, "rotation", 0.14, 0.11)
		wobble.tween_property(self, "rotation", -0.14, 0.11)
	wobble.tween_property(self, "rotation", 0.0, 0.05)

## An enemy was defeated: it fades out (the next wave replaces it).
func play_fade_out() -> void:
	gone = true
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
