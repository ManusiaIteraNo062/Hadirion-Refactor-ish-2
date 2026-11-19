extends Resource
class_name EnemyType
# A reusable enemy template (data/enemies/<id>.tres). build_unit() makes a fresh BattleUnit.
# Damage is fixed: a move's `power` is the damage, so attack/capability are unused.

@export var display_name: String = "Altered"
@export var health: int = 50
@export var speed: int = 0
@export var moves: Array[Move] = []
@export var ai: EnemyMoveset.Mode = EnemyMoveset.Mode.PRIORITIZE_BIG
# Bosses act more than once per turn.
@export var actions_per_turn: int = 1
@export var is_boss: bool = false
# Training dummies never act.
@export var is_dummy: bool = false

# --- Battle art (optional; with no Idle picture the stick figure is drawn) ---
# Same rules as characters (see ASSET_RULES.md). Enemies are mirrored automatically.
@export var idle_texture: Texture2D
@export var attack_texture: Texture2D
# Played on the target when this enemy attacks (every move uses it).
@export var attack_vfx: PackedScene

# "sloppy_altered": the file name, used for the encyclopedia and the "met" record.
func enemy_id() -> String:
	return resource_path.get_file().get_basename()

func build_unit() -> BattleUnit:
	var move_list: Array[Move] = []
	move_list.assign(moves)
	var unit := UnitFactory.make_enemy(display_name, health, 0, 0, speed, move_list)
	unit.moveset.mode = ai
	unit.actions_per_turn = actions_per_turn
	unit.is_boss = is_boss
	unit.is_dummy = is_dummy
	unit.enemy_id = enemy_id()
	return unit
