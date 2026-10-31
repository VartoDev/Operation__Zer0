@tool
extends EditorScenePostImport

func _post_import(scene):
	add_collisions(scene)
	return scene

func add_collisions(node):
	if node is MeshInstance3D and node.mesh != null:
		node.create_trimesh_collision()

	for child in node.get_children():
		add_collisions(child)
