extends Resource
class_name CharacterStats
# The 4 base stats: Health, Attack (Basic moves), Capability (Alterations),
# Speed (flat dodge %, not turn order). Crit is a global rate in BattleManager.

@export var character_name: String = "Unnamed"
@export var max_health: int = 100
@export var attack: int = 10
@export var capability: int = 10
@export var speed: int = 10 # 10 = 10% chance to dodge an incoming hit
