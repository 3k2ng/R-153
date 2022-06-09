extends Node
class_name FileSystem

export(String) var system_name

export(Resource) var tree # Tree that represent files in this system, must use FileTree
export(Array, Resource) var users # User that is available on this system, must use User

func get_file(dir):
	for file in tree.files:
		if file.location + "/" + file.file_name == dir:
			return file

func get_files(dir):
	var ret = []
	if not dir == "~" and not get_file(dir):
		return null
	for file in tree.files:
		if file.location == dir:
			ret.append(file)
	return ret
