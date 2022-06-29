extends Node
class_name FileSystem

export(String) var system_name

export(String) var system_owner

export(Array, Resource) var files

func get_file(dir):
	for file in files:
		if file.location + "/" + file.file_name == dir:
			return file

func get_files(dir):
	var ret = []
	if not dir == "~" and not get_file(dir):
		return null
	for file in files:
		if file.location == dir:
			ret.append(file)
	return ret
