@tool
extends EditorPlugin

var gizmo_plugin: EditorNode3DGizmoPlugin

func _enter_tree():
	# Load and instantiate the gizmo plugin
	gizmo_plugin = preload("res://addons/collider_helper/collidergizmos.gd").new()
	add_node_3d_gizmo_plugin(gizmo_plugin)
	print("Custom Gizmo Plugin added to editor.")

func _exit_tree():
	# Remove the gizmo plugin when the editor plugin is disabled
	if gizmo_plugin:
		remove_node_3d_gizmo_plugin(gizmo_plugin)
		gizmo_plugin = null
		print("Custom Gizmo Plugin removed from editor.")
