@tool
extends EditorScenePostImport

const STYLIZED_BASE_MATERIAL : String = "res://materials/stylized_base.tres"
const LIGHTS_OFF_MATERIAL : String = "res://materials/lights_off.tres"
const LIGHTS_ON_MATERIAL : String = "res://materials/lights_on.tres"

func _post_import(scene):
    print("Changing materials to toon mode...")
    toonify(scene, preload(STYLIZED_BASE_MATERIAL))
    return scene

func toonify(node: Node, base_material: ShaderMaterial, material_map: Dictionary = {}):
    if node is MeshInstance3D:
        for i in range(node.mesh.get_surface_count()):
            var existing_material = node.mesh.surface_get_material(i)
            if existing_material.resource_name == "Glass":
                if randf_range(0.0, 1.0) < 0.5:
                    node.mesh.surface_set_material(i, preload(LIGHTS_OFF_MATERIAL))
                else:
                    node.mesh.surface_set_material(i, preload(LIGHTS_ON_MATERIAL))
            elif existing_material.resource_name in material_map:
                node.mesh.surface_set_material(i, material_map[existing_material.resource_name])
            else:
                if existing_material is StandardMaterial3D:
                    var new_material = base_material.duplicate()
                    new_material.set_shader_parameter("albedo_color", existing_material.albedo_color)
                    new_material.set_shader_parameter("albedo_texture", existing_material.albedo_texture)
                    # new_material.set_shader_parameter("albedo_affect", 1.0)
                    new_material.set_shader_parameter("specular", 1.0 - existing_material.roughness)
                    if existing_material.normal_texture:
                        new_material.set_shader_parameter("normal_strength", 0.5)
                        new_material.set_shader_parameter("normal_texture", existing_material.normal_texture)
                    new_material.set_shader_parameter("emissive_color", existing_material.emission if existing_material.emission_enabled else Color(0, 0, 0))
                    new_material.set_shader_parameter("emissive_strength", 1.0 if existing_material.emission_enabled else 0.0)
                    node.mesh.surface_set_material(i, new_material)
                    material_map[existing_material.resource_name] = new_material
                else:
                    push_warning("Warning: MeshInstance3D has non-StandardMaterial3D material, skipping toonification for that material.")
    for child in node.get_children():
        toonify(child, base_material, material_map)