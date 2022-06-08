extends Node
class_name FileSystem

export(String) var system_name: String

export(Array, Resource) var files

func get_file(dir):
	for file in files:
		if file.location + "/" + file.file_name == dir:
			return file

func get_files(dir):
	var ret = []
	for file in files:
		if dir in file.location:
			ret.append(file)
	return ret
