# Asset rules (for whoever makes the art)

Everything is optional. A character or enemy with no art keeps its stick figure,
so you can add them one at a time.

## 1. Battle pictures (one PNG per pose, no animation)
Put the files under `assets/characters/` or `assets/enemies/` (any sub-folders),
then open the character's `.tres` (`data/characters/`) or enemy's `.tres`
(`data/enemies/`) in the editor and drag each PNG into **Battle art** in the Inspector.

| Who | Poses | When it shows |
|---|---|---|
| Character | Idle | standing around (the default) |
| | Attack | for a moment when they use their Basic attack |
| | Alter | for a moment when they use an Alteration (it also blinks) |
| | Hurt | for a moment when they lose HP, and while being dragged off when defeated |
| Enemy | Idle | standing around |
| | Attack | for a moment when they attack (all their moves) |

* **Idle is required.** Any other pose you leave empty just shows Idle.
* **PNG, transparent background.**
* **All poses of one character: the exact same canvas size**, with the feet at the
  bottom centre of the image. (Otherwise the puppet jumps when the pose changes.)
* **Draw everyone facing RIGHT.** Enemies stand on the right, so the game mirrors them.
* The picture is shrunk to the height of the old stick figure (about 80 px on screen),
  so a big canvas (e.g. 512 x 768) is fine. To make everyone bigger or smaller, change
  **Art Size** on the root node of `scenes/battle/unit_visual.tscn`.
* Defeated party member: dragged off to the left. Defeated enemy: fades out.

## 1b. Animated sprite sheets (instead of single pictures)
A character can use an animated sprite sheet instead of one picture per pose. Helder does
(`assets/characters/helder/helder_frames.tres`). It is a **SpriteFrames** resource: drag it into
**Sprite Frames** under *Battle art* in the character's `.tres`. It wins over the single pictures.

Animation names matter. Only `idle` is required; a missing one just shows idle.

| Animation | When it plays |
|---|---|
| `idle` | loops while standing around (LPC "combat" row, 2 frames) |
| `jump` | the hop to the target and back (Basic attack) |
| `attack` | the club swing, once the jump has landed (Basic attack) |
| `alter` | the spellcast (Alterations) |
| `hurt` | a short flinch when hit |
| `defeat` | falls down and stays down (while dragged off when defeated) |
| `guard` | Guard |

* **Basic attack** = jump next to the first target, swing, jump back. The damage shows up when the
  swing reaches *Attack Impact Frame*: the BattleManager waits for it (`visual_lead_in`), and the next
  turn starts when the fighter is home again (`visual_follow_through`). An **Alteration** waits until
  *Alter Impact Frame* the same way. Enemy turns never wait.
* Tune it in the Inspector on the root node of `scenes/battle/unit_visual.tscn`: *Anim Size*,
  *Anim Feet Y*, *Lunge Distance / Jump Seconds / Jump Height / Hold Seconds*, *Attack / Alter Impact Frame*.
  Speed and loop of each animation: open the `.tres` and use the SpriteFrames panel at the bottom.
* The frames of one animation may be bigger than another's (LPC's club swing is 192 x 192, the rest
  64 x 64) as long as the character is centred in the frame.
* LPC sheets: 64 x 64 frames; the rows are up / left / down / **right** (we use the right row, index 3).
  `hurt` has only one row (facing the camera).
* LPC art needs credit: keep `assets/characters/helder/credits/credits.txt` and show it in the game's credits.
* Check your work: `godot --headless --path . --script res://tests/anim_test.gd` -> ALL PASSED.

## 2. Effects (VFX)
Each effect is a scene (`.tscn`). Put them in `assets/vfx/` or `scenes/vfx/`, then drag
them into the character / enemy `.tres`:

* **Attack Vfx** (character or enemy): plays on the *target* when the attack hits.
* **Alter Vfx** (character only): plays on the character while they use an Alteration.

The effect is centred on the middle of the fighter (its (0, 0) point is where it appears).
What the scene can be:
* `CPUParticles2D` or `GPUParticles2D` - played once (the game turns One Shot on).
* `AnimatedSprite2D` - its animation is played once, so turn **Loop off**.
* Anything with an `AnimationPlayer` child - the first animation plays once.
* Anything else is shown for one second.

Effects remove themselves. At most **12** play at the same time (the rest are skipped),
and any effect is removed after 3 seconds at most, to keep the game light.
Two starter effects to copy and edit: `scenes/vfx/hit_burst.tscn`, `scenes/vfx/alter_glow.tscn`.

## 3. Dialogue portraits
A PNG named after the speaker in `assets/portraits/`: lowercase, spaces become `_`.

| Speaker in the story text | File |
|---|---|
| Helder | `assets/portraits/helder.png` |
| Admin | `assets/portraits/admin.png` |
| WYG-01 | `assets/portraits/wyg-01.png` |

Square pictures look best (the frame is 150 x 150). No file = the coloured placeholder.

## 4. Check your work
`godot --headless --path . --script res://tests/art_test.gd` -> ends with ALL PASSED.
Keep a note of where each free asset came from and its license (credit if required).
