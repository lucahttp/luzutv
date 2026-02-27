# City Generator con LOD
extends Node3D
class_name CityGenerator

var map_loader: Node
var materials = {}
var building_texture: ImageTexture

const LOD_BUILDING_DISTANCE := 30.0
const LOD_DETAIL_DISTANCE := 50.0

func _ready():
	map_loader = get_node_or_null("../MapLoader")
	_crear_textura_edificios()
	_crear_materiales()
	generar_barrio()

func _crear_textura_edificios():
	var size = 128
	var img = Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1)) # Base blanca/neutra
	
	# Dibujar cuadrícula (ventanas)
	for x in range(size):
		for y in range(size):
			var in_window_x = (x % 32) > 4
			var in_window_y = (y % 32) > 4
			if in_window_x and in_window_y:
				# Simular reflejo/sombra de ventana interior
				var shade = randf_range(0.2, 0.4)
				img.set_pixel(x, y, Color(shade, shade, shade + 0.1, 1.0))
	
	building_texture = ImageTexture.create_from_image(img)


func generar_barrio():
	var tamano_cuadra = 80.0
	var ancho_calle = 10.0
	var num_cuadras = 5 # Reducido para web
	var half: int = num_cuadras / 2
	
	for x in range(-half, half + 1):
		for z in range(-half, half + 1):
			var pos_cuadra = Vector3(x * tamano_cuadra, 0, z * tamano_cuadra)
			var dist = pos_cuadra.length()
			var show_windows = dist <= LOD_BUILDING_DISTANCE
			
			if x != 0:
				_crear_calle(
					Vector3(x * tamano_cuadra - tamano_cuadra / 2 + ancho_calle / 2, 0.01, z * tamano_cuadra),
					Vector3(ancho_calle, 0.1, tamano_cuadra)
				)
			
			if z != 0:
				_crear_calle(
					Vector3(x * tamano_cuadra, 0.01, z * tamano_cuadra - tamano_cuadra / 2 + ancho_calle / 2),
					Vector3(tamano_cuadra, 0.1, ancho_calle)
				)
			
			if x == 0 and z == 0:
				_crear_plaza(pos_cuadra)
			elif x == 1 and z == 0:
				_crear_estacion(pos_cuadra)
			else:
				_crear_manzana(pos_cuadra, x, z, show_windows)
	
	for x in range(-half, half + 1):
		for z in range(-half, half + 1):
			var pos = Vector3(x * tamano_cuadra, 0.02, z * tamano_cuadra)
			if pos.length() <= LOD_DETAIL_DISTANCE:
				_crear_vereda(pos, tamano_cuadra, ancho_calle)

func _crear_materiales():
	var colores_residenciales = [
		Color(0.85, 0.82, 0.75),
		Color(0.8, 0.75, 0.7),
		Color(0.75, 0.7, 0.65),
		Color(0.9, 0.88, 0.85),
		Color(0.7, 0.65, 0.6),
		Color(0.85, 0.8, 0.7),
		Color(0.65, 0.6, 0.55),
		Color(0.8, 0.78, 0.72),
		Color(0.75, 0.72, 0.68),
		Color(0.88, 0.85, 0.78),
	]
	
	materials["residencial"] = []
	for color in colores_residenciales:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color.darkened(randf_range(-0.1, 0.1))
		mat.albedo_texture = building_texture
		mat.uv1_scale = Vector3(0.5, 0.5, 0.5)
		mat.uv1_triplanar = true
		mat.roughness = randf_range(0.75, 0.95)
		mat.metallic = randf_range(0.0, 0.1)
		materials["residencial"].append(mat)
	
	var colores_comerciales = [
		Color(0.9, 0.85, 0.4),
		Color(0.95, 0.6, 0.3),
		Color(0.6, 0.7, 0.85),
		Color(0.85, 0.5, 0.5),
		Color(0.5, 0.6, 0.5),
		Color(0.7, 0.55, 0.45),
		Color(0.85, 0.4, 0.4),
		Color(0.5, 0.5, 0.7),
	]
	
	materials["comercial"] = []
	for color in colores_comerciales:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color.darkened(randf_range(-0.1, 0.15))
		mat.albedo_texture = building_texture
		mat.uv1_scale = Vector3(0.5, 0.5, 0.5)
		mat.uv1_triplanar = true
		mat.roughness = randf_range(0.7, 0.9)
		mat.metallic = randf_range(0.0, 0.15)
		materials["comercial"].append(mat)
	
	materials["plaza"] = StandardMaterial3D.new()
	materials["plaza"].albedo_color = Color(0.2, randf_range(0.45, 0.55), 0.15)
	materials["plaza"].roughness = 0.95
	
	materials["calle"] = StandardMaterial3D.new()
	materials["calle"].albedo_color = Color(0.12 + randf_range(-0.03, 0.05), 0.12 + randf_range(-0.03, 0.05), 0.14 + randf_range(-0.03, 0.05))
	materials["calle"].roughness = randf_range(0.9, 1.0)
	
	materials["linea_calle"] = StandardMaterial3D.new()
	materials["linea_calle"].albedo_color = Color(0.9, 0.8, 0.15)
	materials["linea_calle"].roughness = 0.85
	materials["linea_calle"].emission_enabled = true
	materials["linea_calle"].emission = Color(0.9, 0.8, 0.15)
	materials["linea_calle"].emission_energy_multiplier = 0.1
	
	materials["estacion"] = StandardMaterial3D.new()
	materials["estacion"].albedo_color = Color(0.8, 0.45, 0.3)
	materials["estacion"].roughness = 0.75
	materials["estacion"].metallic = 0.1
	
	materials["vereda"] = StandardMaterial3D.new()
	materials["vereda"].albedo_color = Color(0.5 + randf_range(-0.1, 0.1), 0.48 + randf_range(-0.1, 0.1), 0.45 + randf_range(-0.1, 0.1))
	materials["vereda"].roughness = randf_range(0.85, 0.95)
	
	materials["poste"] = StandardMaterial3D.new()
	materials["poste"].albedo_color = Color(0.2, 0.2, 0.2)
	materials["poste"].roughness = 0.6
	materials["poste"].metallic = 0.8
	
	materials["vidriera"] = StandardMaterial3D.new()
	materials["vidriera"].albedo_color = Color(0.6, 0.7, 0.8)
	materials["vidriera"].roughness = 0.1
	materials["vidriera"].metallic = 0.3
	materials["vidriera"].transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	materials["vidriera"].albedo_color.a = 0.3
	
	# Materiales para arboles
	materials["tronco"] = StandardMaterial3D.new()
	materials["tronco"].albedo_color = Color(0.4, 0.25, 0.1)
	materials["tronco"].roughness = 0.9
	
	materials["hojas"] = StandardMaterial3D.new()
	materials["hojas"].albedo_color = Color(0.2, 0.6, 0.2)
	materials["hojas"].roughness = 0.8

func _crear_calle(pos, tamano):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = tamano
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = materials["calle"]
	add_child(mesh)
	
	if tamano.x > tamano.z:
		var linea = MeshInstance3D.new()
		var box_linea = BoxMesh.new()
		box_linea.size = Vector3(tamano.x - 2, 0.02, 0.3)
		linea.mesh = box_linea
		linea.position = pos + Vector3(0, 0.06, 0)
		linea.material_override = materials["linea_calle"]
		add_child(linea)
	else:
		var linea = MeshInstance3D.new()
		var box_linea = BoxMesh.new()
		box_linea.size = Vector3(0.3, 0.02, tamano.z - 2)
		linea.mesh = box_linea
		linea.position = pos + Vector3(0, 0.06, 0)
		linea.material_override = materials["linea_calle"]
		add_child(linea)

func _crear_vereda(pos: Vector3, tamano_cuadra: float, ancho_calle: float):
	var ancho_vereda = 2.0
	var largo = tamano_cuadra - ancho_calle
	
	var v1 = MeshInstance3D.new()
	var b1 = BoxMesh.new()
	b1.size = Vector3(largo, 0.15, ancho_vereda)
	v1.mesh = b1
	v1.position = pos + Vector3(0, 0, -largo / 2 - ancho_vereda / 2)
	v1.material_override = materials["vereda"]
	add_child(v1)
	
	var v2 = MeshInstance3D.new()
	var b2 = BoxMesh.new()
	b2.size = Vector3(largo, 0.15, ancho_vereda)
	v2.mesh = b2
	v2.position = pos + Vector3(0, 0, largo / 2 + ancho_vereda / 2)
	v2.material_override = materials["vereda"]
	add_child(v2)
	
	# Agregar arboles simples (LOD)
	var num_arboles = int(largo / 10.0)
	for i in range(num_arboles):
		var x_offset = - largo / 2.0 + 5.0 + i * 10.0
		if randf() > 0.3: # 70% chance of a tree
			_crear_arbol(pos + Vector3(x_offset, 0.15, -largo / 2 - ancho_vereda / 2))
		if randf() > 0.3:
			_crear_arbol(pos + Vector3(x_offset, 0.15, largo / 2 + ancho_vereda / 2))

func _crear_arbol(pos: Vector3):
	# Tronco
	var tronco = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.2
	cyl.bottom_radius = 0.3
	cyl.height = 2.0
	tronco.mesh = cyl
	tronco.position = pos + Vector3(0, 1.0, 0)
	tronco.material_override = materials["tronco"]
	add_child(tronco)
	
	# Hojas (estilo Mario 64 - esfera simple)
	var hojas = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.5
	sphere.height = 3.0
	hojas.mesh = sphere
	hojas.position = pos + Vector3(0, 2.5, 0)
	hojas.material_override = materials["hojas"]
	add_child(hojas)

func _crear_plaza(pos):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(60, 0.2, 60)
	mesh.mesh = box
	mesh.position = pos
	mesh.position.y = 0.1
	mesh.material_override = materials["plaza"]
	add_child(mesh)

func _crear_estacion(pos):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	var altura = 12.0
	box.size = Vector3(55, altura, 40)
	mesh.mesh = box
	mesh.position = pos
	mesh.position.y = altura / 2.0
	mesh.material_override = materials["estacion"]
	add_child(mesh)

func _crear_manzana(pos, x, z, show_windows: bool):
	var seed_val = abs(x * 13 + z * 7)
	var es_comercial = (seed_val % 3) != 0
	var num_edificios = 1 + (seed_val % 4)
	var tamano_manzana = 50.0
	
	if num_edificios == 1:
		var altura = 8.0 + float(seed_val % 8) * 4.0
		_crear_edificio(pos, Vector3(tamano_manzana, altura, tamano_manzana), es_comercial, show_windows)
	else:
		var mitad = tamano_manzana / 2.0
		var gap = 2.0
		for i in range(num_edificios):
			var sub_ancho = (tamano_manzana - gap * (num_edificios - 1)) / num_edificios
			var sub_pos = pos + Vector3(-mitad + sub_ancho / 2 + i * (sub_ancho + gap), 0, 0)
			var altura = 8.0 + float((seed_val + i * 5) % 10) * 3.0
			_crear_edificio(sub_pos, Vector3(sub_ancho, altura, tamano_manzana), es_comercial, show_windows)

func _crear_edificio(pos: Vector3, tamano: Vector3, es_comercial: bool, show_windows: bool):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = tamano
	
	if es_comercial:
		mesh.material_override = materials["comercial"].pick_random()
	else:
		mesh.material_override = materials["residencial"].pick_random()
	
	mesh.position = pos
	mesh.position.y = tamano.y / 2.0
	mesh.mesh = box
	add_child(mesh)
	
	if show_windows:
		_agregar_ventanas(pos, tamano)

func _agregar_ventanas(pos: Vector3, tamano: Vector3):
	var _mat_vidrio = materials["vidriera"]
	var mat_negro = StandardMaterial3D.new()
	mat_negro.albedo_color = Color(0.1, 0.1, 0.12)
	mat_negro.roughness = 0.5
	mat_negro.metallic = 0.3
	
	var altura = tamano.y
	var ancho_edificio = tamano.x
	var profundidad_edificio = tamano.z
	
	var altura_piso = 3.0
	var num_pisos = int(altura / altura_piso)
	var ventana_ancho = 0.8
	var ventana_alto = 1.2
	var separacion_horizontal = 4.0 # Mayor separación para reducir objetos
	
	for cara in [Vector3.FORWARD, Vector3.BACK]:
		for piso in range(num_pisos):
			var y_pos = pos.y + altura_piso / 2.0 + piso * altura_piso
			var z_offset = cara.z * (profundidad_edificio / 2.0 + 0.01)
			
			var num_ventanas = int(ancho_edificio / separacion_horizontal)
			for i in range(min(num_ventanas, 4)): # Max 4 ventanas
				var x_offset = - ancho_edificio / 2.0 + separacion_horizontal / 2.0 + i * separacion_horizontal
				
				var marco = MeshInstance3D.new()
				var box_marco = BoxMesh.new()
				box_marco.size = Vector3(ventana_ancho + 0.1, ventana_alto + 0.1, 0.05)
				marco.mesh = box_marco
				marco.position = Vector3(pos.x + x_offset, y_pos, pos.z + z_offset)
				marco.material_override = mat_negro
				add_child(marco)
