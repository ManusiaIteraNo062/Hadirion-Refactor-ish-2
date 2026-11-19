extends CharacterPlaceholder
class_name UnitVisual
# One fighter on the battlefield (unit_visual.tscn): a stick figure, or a picture per
# pose ("idle", "attack", "alter", "hurt") when the stage gives art. A missing pose shows idle.

# The stick figure is about 122 units tall (head top -72, feet +50) at figure_scale 1.
# The picture is scaled to the same height so names, numbers and markers still fit.
const FIGURE_HEIGHT := 122.0

# Make the picture bigger or smaller than the stick figure (1.0 = same height).
@export var art_size: float = 1.0

# Effects (set by the stage from the character / enemy data).
var attack_vfx: PackedScene
var alter_vfx: PackedScene
# True once dragged off / faded out, so a window resize doesn't put it back.
var gone: bool = false

var _textures: Dictionary = {}     # pose name -> Texture2D
var _sprite: Sprite2D
var _anchor: Marker2D
var _pose_tween: Tween

func _ready() -> void:
	_sprite = get_node("Sprite")
	_anchor = get_node("VfxAnchor")

# Give this fighter its pictures. `textures` is {"idle": Texture2D, "attack": ...}.
# `mirror` flips them (art is drawn facing right; enemies stand on the right and face left).
func set_art(textures: Dictionary, mirror: bool) -> void:
	_textures = textures
	_sprite.flip_h = mirror
	_sprite.texture = textures["idle"]
	_sprite.visible = true
	update_layout()

func has_art() -> bool:
	return _sprite != null and _sprite.visible

# Call after figure_scale or position changed: redraw, resize the picture, move the effect anchor.
func update_layout() -> void:
	queue_redraw()
	var feet: float = 50.0 * figure_scale
	var height: float = FIGURE_HEIGHT * figure_scale * art_size
	if has_art():
		var tex: Texture2D = _textures["idle"]
		var factor: float = height / tex.get_height()
		_sprite.scale = Vector2(factor, factor)
		_sprite.position = Vector2(0, feet - height / 2.0)   # feet stay where the stick figure's feet were
		_anchor.position = _sprite.position                  # effects play at the middle of the picture
	elif _anchor != null:
		_anchor.position = Vector2(0, -11.0 * figure_scale)  # middle of the stick figure

# Where effects should appear (in the stage's coordinates).
func vfx_position() -> Vector2:
	return _anchor.global_position

func _draw() -> void:
	if has_art():
		return
	super._draw()

# Show a pose. With seconds > 0 it goes back to idle afterwards.
func show_pose(pose: String, seconds: float = 0.0) -> void:
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

# A quick blink (used with the Alteration pose).
func flicker(times: int = 3) -> void:
	if not has_art():
		return
	var tw: Tween = create_tween()
	for i in range(times):
		tw.tween_property(_sprite, "modulate:a", 0.35, 0.06)
		tw.tween_property(_sprite, "modulate:a", 1.0, 0.06)

# A party member went down: dragged off the left side of the screen, wobbling.
func play_drag_off() -> void:
	gone = true
	show_pose("hurt")
	var tw: Tween = create_tween()
	tw.tween_property(self, "position:x", -160.0, 0.9).set_ease(Tween.EASE_IN)
	var wobble: Tween = create_tween()
	for i in range(4):
		wobble.tween_property(self, "rotation", 0.14, 0.11)
		wobble.tween_property(self, "rotation", -0.14, 0.11)
	wobble.tween_property(self, "rotation", 0.0, 0.05)

# An enemy was defeated: it fades out (the next wave replaces it).
func play_fade_out() -> void:
	gone = true
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
