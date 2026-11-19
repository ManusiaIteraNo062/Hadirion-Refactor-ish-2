extends Resource
class_name EnemyMoveset
# An enemy's moves and how it picks one (see Mode). No energy, and `type` /
# `energy_cost` are ignored; the Move class is shared with the player side.

# CYCLE = the original fixed repeating pattern.
# PRIORITIZE_BIG = mobs: random ready "big" move (one with a cooldown), else a random
#   ready basic move.
# RANDOM = bosses: random move among those that are off cooldown.
enum Mode { CYCLE, PRIORITIZE_BIG, RANDOM }

@export var moves: Array[Move] = []
@export var mode: Mode = Mode.CYCLE

var _index: int = 0

# Picks this turn's move for `unit`, respecting its cooldowns. Returns null
# only if the moveset is empty.
func choose(unit: BattleUnit) -> Move:
	if mode == Mode.CYCLE:
		return next_move()
	if moves.is_empty():
		return null
	var ready: Array = []
	for m in moves:
		if unit.is_ready(m):
			ready.append(m)
	if ready.is_empty():
		return moves.pick_random() # every move cooling down: shouldn't happen, but never stall
	if mode == Mode.PRIORITIZE_BIG:
		var big: Array = []
		for m in ready:
			if m.cooldown > 0:
				big.append(m)
		if not big.is_empty():
			return big.pick_random()
	return ready.pick_random()

# Returns the next move in the pattern and advances the cycle.
func next_move() -> Move:
	if moves.is_empty():
		return null
	var move := moves[_index % moves.size()]
	_index += 1
	return move

func reset() -> void:
	_index = 0
