extends RefCounted
class_name ResourceFolder
## Loads every .tres file inside a folder (and its subfolders).
## ItemLibrary, SkillLibrary and Roster use this to read their data files.

static func load_all(folder: String) -> Array[Resource]:
	var found: Array[Resource] = []
	_collect(folder, found)
	return found

static func _collect(folder: String, found: Array[Resource]) -> void:
	# subfolders first
	var subfolders: PackedStringArray = DirAccess.get_directories_at(folder)
	subfolders.sort()
	for sub in subfolders:
		_collect(folder.path_join(sub), found)

	# then the files in this folder
	var files: PackedStringArray = DirAccess.get_files_at(folder)
	files.sort()
	for file_name in files:
		# A game exported from Godot lists "name.tres.remap" instead of "name.tres"
		var clean_name: String = file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var res: Resource = load(folder.path_join(clean_name))
		if res != null:
			found.append(res)
