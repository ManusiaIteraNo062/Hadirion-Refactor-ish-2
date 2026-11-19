extends RefCounted
class_name MissionLibrary
# Loads missions from res://data/missions/<NN_name>/ (mission.tres, intro.txt,
# victory.txt, optional defeat.txt). Folder name order = board order; a new
# mission is just a new folder. Export: add "*.txt" to the export filters.

const MISSIONS_DIR := "res://data/missions"
const LOBBY_INTRO := "res://data/lobby/intro.txt"
const DEFEAT_DEFAULT := "res://data/defeat_default.txt"

static func build_all() -> Array[Mission]:
	var out: Array[Mission] = []
	var dirs := DirAccess.get_directories_at(MISSIONS_DIR)
	dirs.sort()
	for d in dirs:
		var m := _load_mission("%s/%s" % [MISSIONS_DIR, d])
		if m:
			out.append(m)
	if out.is_empty():
		push_error("No missions found in %s" % MISSIONS_DIR)
	return out

static func _load_mission(dir: String) -> Mission:
	var path := dir + "/mission.tres"
	if not ResourceLoader.exists(path):
		push_warning("Skipping %s (no mission.tres)" % dir)
		return null
	var m := load(path) as Mission
	if m == null:
		push_error("%s is not a Mission resource" % path)
		return null
	m.intro_lines = DialogueParser.load_file(dir + "/intro.txt")
	m.victory_lines = DialogueParser.load_file(dir + "/victory.txt")
	m.defeat_lines = DialogueParser.load_file(dir + "/defeat.txt")
	m.tutorial_pages = TutorialPage.load_file(dir + "/tutorial.txt")
	if m.title_background == null and ResourceLoader.exists(dir + "/title_bg.png"):
		m.title_background = load(dir + "/title_bg.png")
	# No (or empty) defeat.txt in the folder -> the shared default scene.
	if m.defeat_lines.is_empty() and m.wave_count() > 0:
		m.defeat_lines = DialogueParser.load_file(DEFEAT_DEFAULT)
	return m

# Lobby dialogue played on entering the lobby (first visit only for now).
static func lobby_visit_lines(state: GameState) -> Array[DialogueLine]:
	if not state.seen_lobby_intro:
		return DialogueParser.load_file(LOBBY_INTRO)
	return [] as Array[DialogueLine]
