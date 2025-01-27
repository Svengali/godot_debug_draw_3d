#pragma once
#ifndef DISABLE_DEBUG_RENDERING

#include "common/colors.h"
#include "geometry_generators.h"
#include "render_instances.h"
#include "utils/math_utils.h"
#include "utils/utils.h"

GODOT_WARNING_DISABLE()
#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/canvas_item.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/classes/mesh.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/multi_mesh.hpp>
#include <godot_cpp/classes/multi_mesh_instance3d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
#include <godot_cpp/classes/texture.hpp>
GODOT_WARNING_RESTORE()

#include <map>

using namespace godot;

class DebugDrawStats3D;

class DebugGeometryContainer {
	friend class DebugDraw3D;
	class DebugDraw3D *owner;

	struct MultiMeshStorage {
		RID instance;
		Ref<MultiMesh> mesh;

		~MultiMeshStorage() {
			RS()->free_rid(instance);
			mesh.unref();
		}
	};
	MultiMeshStorage multi_mesh_storage[InstanceType::ALL] = {};

	struct ImmediateMeshStorage {
		RID instance;
		Ref<ArrayMesh> mesh;
		Ref<StandardMaterial3D> material;

		~ImmediateMeshStorage() {
			RS()->free_rid(instance);
			mesh.unref();
			material.unref();
		}
	};
	ImmediateMeshStorage immediate_mesh_storage;

	GeometryPool geometry_pool;
	Node *scene_world_node = nullptr;
	int32_t render_layers = 1;

	void CreateMMI(InstanceType type, const String &name, Ref<ArrayMesh> mesh);

	template <class TVertices, class TIndices = std::array<int, 0>, class TColors = std::array<Color, 0> >
	Ref<ArrayMesh> CreateMesh(Mesh::PrimitiveType type, const TVertices &vertices, const TIndices &indices = {}, const TColors &colors = {}) {
		return CreateMesh(type,
				Utils::convert_to_pool_array<PackedVector3Array>(vertices),
				Utils::convert_to_pool_array<PackedInt32Array>(indices),
				Utils::convert_to_pool_array<PackedColorArray>(colors));
	}

	Ref<ArrayMesh> CreateMesh(Mesh::PrimitiveType type, const PackedVector3Array &vertices, const PackedInt32Array &indices = {}, const PackedColorArray &colors = {});

	std::recursive_mutex datalock;

public:
	DebugGeometryContainer(class DebugDraw3D *root);
	~DebugGeometryContainer();

	void set_world(Node *new_world);
	Node *get_world();

	void update_geometry(double delta);

	void set_render_layer_mask(int32_t layers);
	int32_t get_render_layer_mask() const;

	Ref<DebugDrawStats3D> get_render_stats();
	void clear_3d_objects();
};

#endif