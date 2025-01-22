@tool
extends MeshInstance3D

@export var update = false

var point_material :ShaderMaterial
var line_material :ShaderMaterial

var aMesh = ArrayMesh.new()
var points = PackedVector3Array();
var colors = PackedColorArray()
var arr = []
var selected_point_index = NAN
var selection
var moving = false
var move_plane:Plane

func _init() -> void:
	pass

func _ready() -> void:
	point_material = ShaderMaterial.new()
	point_material.shader = load("res://points.gdshader")
	point_material.set_shader_parameter("point_size", 15)
	line_material = ShaderMaterial.new()
	line_material.shader = load("res://lines.gdshader")
	gen_mesh()
	pass # Replace with function body.

func gen_mesh() -> void:
	arr.resize(Mesh.ARRAY_MAX)
	var parent_mesh
	parent_mesh = $"../Cube".mesh.get_mesh_arrays()
	print(typeof(parent_mesh))
	
	#aMesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, parent_mesh)
	points.clear()
	colors.clear()
	for v in parent_mesh[Mesh.ARRAY_VERTEX]:
		if (!points.has(v)):
			points.append(v)
			colors.append(Color(1,1,1))
	arr[Mesh.ARRAY_VERTEX] = points
	arr[Mesh.ARRAY_COLOR] = colors
	reDraw()
	
func	 reDraw():
	aMesh.clear_surfaces()
	aMesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arr)
	aMesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arr)
	aMesh.surface_set_material(0, line_material)
	aMesh.surface_set_material(1, point_material)
	mesh = aMesh
	
	
func  _input(event):
	if event is InputEventMouseButton and event.pressed == true and event.button_index == 1:
		var click_pos: Vector2 = event.position
		var sel = []
		for i in range(points.size()):
			var pos: Vector2 = get_viewport().get_camera_3d().unproject_position(points[i]+position)
			if (click_pos.distance_to(pos) < 10):
				sel.append(i)
		if (sel.size()>1): # проверка какая точка из попавших в область - ближайшая
			while (sel.size()>1):
				if (get_viewport().get_camera_3d().global_position - points[sel[0]] < 
					get_viewport().get_camera_3d().global_position - points[sel[1]]):
					sel.remove_at(1)
				else:
					sel.remove_at(0)
		if (sel):
			move(sel[0])
		else:
			select(NAN)
		
func select(index):
	if (!is_nan(selected_point_index)):
		colors[selected_point_index] = Color(1,1,1)
	if (!is_nan(index)):
		
		colors[index] = Color(0,1,0)
		selected_point_index = index
	reDraw()
	pass
	
func move(index):
	colors[index] = Color(0,1,0)
	selected_point_index = index
	var normal = basis.y #get_viewport().get_camera_3d().basis.z
	move_plane = Plane(normal, points[index] + position) 
	reDraw()
	draw_plane(normal, points[index] + position)
	moving = true
	pass
	
func draw_plane(normal:Vector3, pos:Vector3):
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(100, 100)
	plane_mesh.orientation = 1
	var surface = SurfaceTool.new()
	surface.create_from(plane_mesh, 0)
	plane_mesh = MeshInstance3D.new()
	plane_mesh.mesh = surface.commit()
	plane_mesh.material_override = load("res://plane.tres")
	add_child(plane_mesh)
	plane_mesh.position = plane_mesh.to_local(pos)
	plane_mesh.cast_shadow = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (update):
		update = false
		_ready()
	if (moving): #selected_point_index
		var mouse_pos = get_viewport().get_mouse_position()
		var cam_pos = get_viewport().get_camera_3d().position
		var ray = get_viewport().get_camera_3d().project_ray_normal(mouse_pos)
		
		var projected_point = move_plane.intersects_ray(cam_pos, ray)
		if (projected_point):
			points[selected_point_index] = projected_point - position
		
		if (!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			moving = false
			colors[selected_point_index] = Color(1,1,1)
			selected_point_index = NAN
			remove_child(get_child(0))
		reDraw()
	pass
	
