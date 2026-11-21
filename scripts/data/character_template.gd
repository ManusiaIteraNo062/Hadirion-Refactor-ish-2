extends Resource
class_name CharacterTemplate
## A playable character's base numbers. One .tres file per character in
## res://data/characters/ - open it in the editor and change the numbers in the
## Inspector. Upgrade and equipment bonuses (GearLibrary) are added on top when
## the team is built; skills come from SkillLibrary.

@export var id: String = ""
@export var display_name: String = ""
@export var health: int = 100
@export var attack: int = 10
@export var capability: int = 10
@export var speed: int = 10
## The free "no upgrade" entry in GearLibrary.
@export var base_upgrade_id: String = ""
## Name of the Basic attack.
@export var basic_name: String = "Strike"
@export var color: Color = Color.WHITE

## --- Battle art (optional; with no Idle picture the stick figure is drawn) ---
## One picture per pose, same canvas size, transparent, feet at the bottom
## centre, drawn facing RIGHT. See ASSET_RULES.md.
@export_group("Battle art")
@export var idle_texture: Texture2D
@export var attack_texture: Texture2D
@export var alter_texture: Texture2D
@export var hurt_texture: Texture2D
## OR an animated sprite sheet (a SpriteFrames resource). It wins over the single pictures above.
## Animations: idle (required), attack, alter, hurt, defeat, jump, guard. See ASSET_RULES.md.
@export var sprite_frames: SpriteFrames
## Played on the target when this character's Basic attack hits.
@export var attack_vfx: PackedScene
## Played on this character while they use an Alteration.
@export var alter_vfx: PackedScene
## Played on this character when they Guard.
@export var guard_vfx: PackedScene
## Position in the party (0 = first).
@export var party_order: int = 0
