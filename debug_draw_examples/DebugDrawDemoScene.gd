tool
extends Spatial

export var custom_font : Font
export var zylann_example = false
export var test_graphs = false
export var more_test_cases = false

var time := 0.0
var time2 := 0.0
var time3 := 0.0
var toogle_frustum_key = false

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	DebugDraw.draw_line_3d(Vector3.ZERO, Vector3.ONE, DebugDraw.empty_color, 10)
	DebugDraw.draw_line_3d(Vector3.ZERO, Vector3.ONE * 1, DebugDraw.empty_color, 1)
	DebugDraw.draw_line_3d(Vector3.ZERO, Vector3.ONE * 2, DebugDraw.empty_color, 1)
	DebugDraw.draw_line_3d(Vector3.ZERO, Vector3.ONE * 3, DebugDraw.empty_color, 1)
	DebugDraw.draw_line_3d(Vector3.ZERO, Vector3.ONE * 4, DebugDraw.empty_color, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_F1:
				zylann_example = !zylann_example

func _process(delta: float) -> void:
	# Zylann's example :D
	if zylann_example:
		DebugDraw.clear_graphs()
		var _time = OS.get_ticks_msec() / 1000.0
		var box_pos = Vector3(0, sin(_time * 4), 0)
		var line_begin = Vector3(-1, sin(_time * 4), 0)
		var line_end = Vector3(1, cos(_time * 4), 0)
		
		DebugDraw.draw_aabb_ab(box_pos, Vector3(1, 2, 1), Color(0, 1, 0), 0) # Box need to be NOT centered
		DebugDraw.draw_line_3d(line_begin, line_end, Color(1, 1, 0))
		DebugDraw.set_text("Time", _time)
		DebugDraw.set_text("Frames drawn", Engine.get_frames_drawn())
		DebugDraw.set_text("FPS", Engine.get_frames_per_second())
		DebugDraw.set_text("delta", delta)
		return
	
	DebugDraw.freeze_3d_render = Input.is_key_pressed(KEY_ENTER)
	DebugDraw.force_use_camera_from_scene = Input.is_key_pressed(KEY_UP)
	DebugDraw.debug_enabled = !Input.is_key_pressed(KEY_DOWN)
	DebugDraw.draw_instance_bounds = Input.is_key_pressed(KEY_RIGHT)
	if toogle_frustum_key and !Input.is_key_pressed(KEY_LEFT):
		DebugDraw.use_frustum_culling = !DebugDraw.use_frustum_culling
	toogle_frustum_key = Input.is_key_pressed(KEY_LEFT)
	
	# Enable FPSGraph
	_create_graph("FPS", true, false, DebugDraw.BlockPosition_LeftTop if Engine.editor_hint else DebugDraw.BlockPosition_RightTop, DebugDraw.GraphTextFlags_Current | DebugDraw.GraphTextFlags_Avarage | DebugDraw.GraphTextFlags_Max | DebugDraw.GraphTextFlags_Min, Vector2(200, 80), custom_font)
	
	if test_graphs:
		_graph_test()
	
	# Zones
	var col = Color.black
	for z in $Zones.get_children():
		DebugDraw.draw_box_xf(z.global_transform, col)
	
	# Spheres
	DebugDraw.draw_sphere_xf($SphereTransform.global_transform, Color.crimson)
	DebugDraw.draw_sphere_hd_xf($SphereHDTransform.global_transform, Color.orangered)
	
	if time <= 0:
		DebugDraw.draw_sphere($SpherePosition.global_transform.origin, 2, Color.blueviolet, 2)
		DebugDraw.draw_sphere_hd($SpherePosition.global_transform.origin + Vector3.FORWARD * 4, 2, Color.cornflower, 2)
		time = 2
	time -= delta
	
	# Cylinders
	DebugDraw.draw_cylinder_xf($Cylinder1.global_transform, Color.crimson)
	DebugDraw.draw_cylinder($Cylinder2.global_transform.origin, Quat(), 1, 1, Color.red)
	
	# Boxes
	DebugDraw.draw_box_xf($Box1.global_transform, Color.purple)
	DebugDraw.draw_box($Box2.global_transform.origin, Quat(), Vector3.ONE, Color.rebeccapurple)
	DebugDraw.draw_box($Box3.global_transform.origin, Quat(Vector3.UP, PI * 0.25), Vector3.ONE * 2, Color.rosybrown)
	
	var r = $AABB
	DebugDraw.draw_aabb_ab(r.get_child(0).global_transform.origin, r.get_child(1).global_transform.origin, Color.deeppink)
	
	DebugDraw.draw_aabb(AABB($AABB_fixed.global_transform.origin, Vector3(2, 1, 2)), Color.aqua)
	
	# Lines
	var target = $Lines/Target
	DebugDraw.draw_billboard_square(target.global_transform.origin, 0.5, Color.red)
	
	# Normal
	DebugDraw.draw_line_3d($"Lines/1".global_transform.origin, target.global_transform.origin, Color.fuchsia)
	DebugDraw.draw_ray_3d($"Lines/3".global_transform.origin, (target.global_transform.origin - $"Lines/3".global_transform.origin).normalized(), 3, Color.crimson)
	
	if time3 <= 0:
		DebugDraw.draw_line_3d($"Lines/6".global_transform.origin, target.global_transform.origin, Color.fuchsia, 2)
		time3 = 2
	time3 -= delta
	
	# Arrow
	DebugDraw.draw_arrow_line_3d($"Lines/2".global_transform.origin, target.global_transform.origin, Color.blue)
	DebugDraw.draw_arrow_ray_3d($"Lines/4".global_transform.origin, (target.global_transform.origin - $"Lines/4".global_transform.origin).normalized(), 8, Color.lavender)
	# Path
	var points: PoolVector3Array = []
	var points_below: PoolVector3Array = []
	var lines_above: PoolVector3Array = []
	for c in $LinePath.get_children():
		points.append(c.global_transform.origin)
		points_below.append(c.global_transform.origin + Vector3.DOWN)
	for x in points.size()-1:
		lines_above.append(points[x] + Vector3.UP)
		lines_above.append(points[x+1] + Vector3.UP)
	
	DebugDraw.draw_lines_3d(lines_above)
	DebugDraw.draw_line_path_3d(points, Color.beige)
	DebugDraw.draw_arrow_path_3d(points_below, Color.gold, 0.75)
	DebugDraw.draw_line_3d_hit_offset($"Lines/5".global_transform.origin, target.global_transform.origin, true, abs(sin(OS.get_ticks_msec() / 1000.0)), 0.25, Color.aqua)
	# Misc
	DebugDraw.draw_camera_frustum($Camera, Color.darkorange)
	
	DebugDraw.draw_billboard_square($Misc/Billboard.global_transform.origin, 0.5, Color.green)
	
	DebugDraw.draw_position_3d_xf($Misc/Position.global_transform, Color.brown)
	
	DebugDraw.draw_gizmo_3d($Misc/Gizmo.global_transform.origin, $Misc/Gizmo.global_transform.basis.get_rotation_quat(), Vector3.ONE)
	DebugDraw.draw_gizmo_3d_xf($Misc/GizmoTransform.global_transform, true)
	
	# Text
	DebugDraw.text_custom_font = custom_font
	DebugDraw.set_text("FPS", "%.2f" % Engine.get_frames_per_second(), 0, Color.gold)
	
	DebugDraw.begin_text_group("-- First Group --", 2, Color.forestgreen)
	DebugDraw.set_text("Simple text")
	DebugDraw.set_text("Text", "Value", 0, Color.aquamarine)
	DebugDraw.set_text("Text out of order", null, -1, Color.silver)
	DebugDraw.begin_text_group("-- Second Group --", 1, Color.beige)
	DebugDraw.set_text("Rendered frames", Engine.get_frames_drawn())
	DebugDraw.end_text_group()
	
	DebugDraw.begin_text_group("-- Stats --", 3, Color.wheat)
	
	var RenderCount = DebugDraw.get_rendered_primitives_count()
	if RenderCount.size():
		DebugDraw.set_text("Total", RenderCount.total, 0)
		DebugDraw.set_text("Instances", RenderCount.instances, 1)
		DebugDraw.set_text("Wireframes", RenderCount.wireframes, 2)
		DebugDraw.set_text("Total Visible", RenderCount.total_visible, 3)
		DebugDraw.set_text("Visible Instances", RenderCount.visible_instances, 4)
		DebugDraw.set_text("Visible Wireframes", RenderCount.visible_wireframes, 5)
		DebugDraw.end_text_group()
	
	# Lag Test
	$LagTest.translation = $LagTest/RESET.get_animation("RESET").track_get_key_value(0,0).origin + Vector3(sin(OS.get_ticks_msec() / 100.0) * 2.5, 0, 0)
	DebugDraw.draw_box($LagTest.global_transform.origin, Quat(), Vector3.ONE * 2.01)
	
	if more_test_cases:
		for ray in $HitTest/RayEmitter.get_children():
			ray.set_physics_process_internal(true)
		
		_more_tests()
	else:
		for ray in $HitTest/RayEmitter.get_children():
			ray.set_physics_process_internal(false)

func _more_tests():
	for ray in $HitTest/RayEmitter.get_children():
		if ray is RayCast:
			DebugDraw.draw_line_3d_hit(ray.global_transform.origin, ray.global_transform.translated(ray.cast_to).origin, ray.get_collision_point(), ray.is_colliding(), 0.15)
	
	if time2 <= 0:
		for x in 50:
			for y in 50:
				for z in 3:
					DebugDraw.draw_box(Vector3(x, z, y), Quat(), Vector3.ONE, DebugDraw.empty_color, false, 1.25)
		time2 = 1.25
	time2 -= get_process_delta_time()
	
		# Delayed line render
	DebugDraw.draw_line_3d($LagTest.global_transform.origin + Vector3.UP, $LagTest.global_transform.origin + Vector3(0,3,sin(OS.get_ticks_msec() / 50.0)), DebugDraw.empty_color, 0.5)

func _graph_test():
	_create_graph("fps", true, true, DebugDraw.BlockPosition_RightTop, DebugDraw.GraphTextFlags_Current)
	_create_graph("fps2", true, false, DebugDraw.BlockPosition_RightTop, DebugDraw.GraphTextFlags_Current)
	_create_graph("fps3", true, true, DebugDraw.BlockPosition_RightTop, DebugDraw.GraphTextFlags_Current)
	
	_create_graph("randf", false, true, DebugDraw.BlockPosition_RightBottom, DebugDraw.GraphTextFlags_Avarage, Vector2(256, 60), custom_font)
	_create_graph("fps5", true, false, DebugDraw.BlockPosition_RightBottom, DebugDraw.GraphTextFlags_All)
	_create_graph("fps6", true, true, DebugDraw.BlockPosition_RightBottom, DebugDraw.GraphTextFlags_All)
	
	_create_graph("fps7", true, false, DebugDraw.BlockPosition_LeftTop, DebugDraw.GraphTextFlags_All)
	_create_graph("fps8", true, true, DebugDraw.BlockPosition_LeftBottom, DebugDraw.GraphTextFlags_All)
	_create_graph("fps9", true, true, DebugDraw.BlockPosition_LeftBottom, DebugDraw.GraphTextFlags_All)
	_create_graph("fps10", true, false, DebugDraw.BlockPosition_LeftBottom, DebugDraw.GraphTextFlags_All)
	
	if DebugDraw.get_graph_config("randf"):
		DebugDraw.get_graph_config("randf").text_suffix = "utf8 ноль zéro"
		if Engine.editor_hint:
			DebugDraw.get_graph_config("fps5").offset = Vector2(0, -30)
			DebugDraw.get_graph_config("fps8").offset = Vector2(280, -60)
			DebugDraw.get_graph_config("fps9").offset = Vector2(0, -75)
		else:
			DebugDraw.get_graph_config("fps5").offset = Vector2(0, 0)
			DebugDraw.get_graph_config("fps8").offset = Vector2(280, 0)
			DebugDraw.get_graph_config("fps9").offset = Vector2(0, -75)
	
	DebugDraw.graph_update_data("randf", randf())

func _create_graph(title, is_fps, show_title, pos, flags, size = Vector2(256, 60), font = null):
	var graph = DebugDraw.get_graph_config(title)
	if !graph:
		if is_fps:
			graph = DebugDraw.create_fps_graph(title)
		else:
			graph = DebugDraw.create_graph(title)
		
		if graph:
			graph.size = size
			graph.buffer_size = 50
			graph.position = pos
			graph.show_title = show_title
			graph.show_text_flags = flags
			graph.custom_font = font
