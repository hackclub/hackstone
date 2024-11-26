@tool
extends EditorNode3DGizmoPlugin

var node_references = {}

func get_name():
	return "ColliderGizmos"
	
# Create the gizmo visuals
func _create_gizmo(node):
	print_debug("gizmo created!")
	var gizmo = EditorNode3DGizmo.new()
	node_references[gizmo] = node as CollisionShape3D
	return gizmo

# Define when to apply the gizmo
func _has_gizmo(spatial):
	var yup = spatial is CollisionShape3D
	if yup:
		print_debug("yes has gizmo")
	return yup

func _free_gizmo(spatial):
	if spatial in node_references:
		node_references.erase(spatial)

func _redraw(gizmo):
	if gizmo not in node_references:
		return
	print_debug("redraw")
	var node = node_references.get(gizmo)
	if not node or node.shape is not BoxShape3D:
		return

	print_debug("got here")
	var mesh = BoxMesh.new()
	mesh.size = (node.shape as BoxShape3D).size
	gizmo.add_mesh(mesh, Transform3D.IDENTITY, get_material("handles"))

	return gizmo
