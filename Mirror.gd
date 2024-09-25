@tool
extends Node3D
class_name Mirror

@onready var mirror_face: MeshInstance3D = $mirror_face
@onready var viewport: SubViewport = $viewport
@onready var camera: Camera3D = $viewport/camera

@export var tracking_camera:Camera3D

func _process(delta:float)->void:
  var default_cam:Camera3D = get_viewport().get_camera_3d()

  if tracking_camera:
    default_cam = tracking_camera

  # set viewport to the size of the mirror face
  viewport.size = mirror_face.mesh.size * 400

  # Set tint color
  #mirror.get_active_material(0).set_shader_param("tint", MirrorColor)

  # Set distortion texture
  #mirror.get_active_material(0).set_shader_param("distort_tex", DistortionTexture)
  # Set distortion strength
  #mirror.get_active_material(0).set_shader_param("distort_strength", MirrorDistortion)

  # reflect the mirror camera to the opposite side of the mirror plane
  var mirror_normal = mirror_face.global_transform.basis.z
  var d = default_cam.global_position - mirror_face.global_position
  camera.global_position = mirror_face.global_position + d.bounce(mirror_normal)

  # ensure that the camera looks perpendicular to the mirror (the mirrors "view")
  # we can't just use the mirrors normal, as it might be rotated.
  # so we look_at, using the up vector of the face
  var mirror_point = (camera.global_position + default_cam.global_position) / 2.0
  camera.global_transform = camera.global_transform.looking_at(mirror_point, mirror_face.global_transform.basis.y)

  # set the near clipping plane to the mirror face
  var near = camera.global_position.distance_to(mirror_point)

  # set the furstrum center to the center of the mirror
  var mirror_cam_local = camera.to_local(mirror_face.global_position)
  var frostum_offset =  Vector2(mirror_cam_local.x, mirror_cam_local.y)
  camera.set_frustum(mirror_face.mesh.size.y, frostum_offset, near, 10000)
