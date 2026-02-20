extends Node3D
class_name CityGenerator

@export var archivo_zonas: String = "res://data/balvanera_barrio.geojson"

var map_loader: Node
var materials = {}

func _ready():
	map_loader = get_node("../MapLoader")
	_crear_materiales()
	generar_barrio()

func _crear_materiales():
	# Materiales de edificios residenciales - más variedad y realismo estilo Once
	var colores_residenciales = [
		Color(0.85, 0.82, 0.75),  # Amarillo crema
		Color(0.8, 0.75, 0.7),    # Beige
		Color(0.75, 0.7, 0.65),   # Marrón claro
		Color(0.9, 0.88, 0.85),   # Blanco hueso
		Color(0.7, 0.65, 0.6),    # Marrón terracota
		Color(0.85, 0.8, 0.7),    # Arena
		Color(0.65, 0.6, 0.55),   # Gris marrón
		Color(0.8, 0.78, 0.72),   # Marfil
		Color(0.75, 0.72, 0.68),  # Gris cálido
		Color(0.88, 0.85, 0.78),  # Crema
	]
	
	materials["residencial"] = []
	for color in colores_residenciales:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = randf_range(0.75, 0.95)
		mat.metallic = randf_range(0.0, 0.1)
		# Variación aleatoria de color para más realismo
		mat.albedo_color = mat.albedo_color.darkened(randf_range(-0.1, 0.1))
		materials["residencial"].append(mat)
	
	# Edificios comerciales - colores más vibrantes
	var colores_comerciales = [
		Color(0.9, 0.85, 0.4),   # Amarillo mostaza
		Color(0.95, 0.6, 0.3),   # Naranja
		Color(0.6, 0.7, 0.85),   # Azul claro
		Color(0.85, 0.5, 0.5),   # Rojo ladrillo
		Color(0.5, 0.6, 0.5),    # Verde grisáceo
		Color(0.7, 0.55, 0.45),  # Marrón rojizo
		Color(0.85, 0.4, 0.4),   # Rojo intenso
		Color(0.5, 0.5, 0.7),    # Azul grisáceo
	]
	
	materials["comercial"] = []
	for color in colores_comerciales:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = randf_range(0.7, 0.9)
		mat.metallic = randf_range(0.0, 0.15)
		mat.albedo_color = mat.albedo_color.darkened(randf_range(-0.1, 0.15))
		materials["comercial"].append(mat)
	
	# Plaza - verde pasto con variación
	materials["plaza"] = StandardMaterial3D.new()
	materials["plaza"].albedo_color = Color(0.2, randf_range(0.45, 0.55), 0.15)
	materials["plaza"].roughness = 0.95
	
	# Calle - asfalto oscuro con variaciones
	materials["calle"] = StandardMaterial3D.new()
	materials["calle"].albedo_color = Color(0.12 + randf_range(-0.03, 0.05), 0.12 + randf_range(-0.03, 0.05), 0.14 + randf_range(-0.03, 0.05))
	materials["calle"].roughness = randf_range(0.9, 1.0)
	
	# Línea central de calle (amarillo)
	materials["linea_calle"] = StandardMaterial3D.new()
	materials["linea_calle"].albedo_color = Color(0.9, 0.8, 0.15)
	materials["linea_calle"].roughness = 0.85
	materials["linea_calle"].emission_enabled = true
	materials["linea_calle"].emission = Color(0.9, 0.8, 0.15)
	materials["linea_calle"].emission_energy_multiplier = 0.1
	
	# Línea de stop
	materials["linea_stop"] = StandardMaterial3D.new()
	materials["linea_stop"].albedo_color = Color(0.95, 0.95, 0.95)
	materials["linea_stop"].roughness = 0.85
	
	# Estación - rojo y blanco estilo Once
	materials["estacion"] = StandardMaterial3D.new()
	materials["estacion"].albedo_color = Color(0.8, 0.45, 0.3)
	materials["estacion"].roughness = 0.75
	materials["estacion"].metallic = 0.1
	
	# Techo estación
	materials["techo_estacion"] = StandardMaterial3D.new()
	materials["techo_estacion"].albedo_color = Color(0.85, 0.2, 0.2)
	materials["techo_estacion"].roughness = 0.6
	materials["techo_estacion"].metallic = 0.2
	
	# Vereda - gris con textura
	materials["vereda"] = StandardMaterial3D.new()
	materials["vereda"].albedo_color = Color(0.5 + randf_range(-0.1, 0.1), 0.48 + randf_range(-0.1, 0.1), 0.45 + randf_range(-0.1, 0.1))
	materials["vereda"].roughness = randf_range(0.85, 0.95)
	
	# Materiales para decoraciones
	materials["hormigon"] = StandardMaterial3D.new()
	materials["hormigon"].albedo_color = Color(0.45 + randf_range(-0.1, 0.1), 0.45 + randf_range(-0.1, 0.1), 0.45 + randf_range(-0.1, 0.1))
	materials["hormigon"].roughness = 0.9
	
	materials["madera"] = StandardMaterial3D.new()
	materials["madera"].albedo_color = Color(0.3 + randf_range(-0.1, 0.1), 0.18 + randf_range(-0.05, 0.05), 0.08 + randf_range(-0.03, 0.03))
	materials["madera"].roughness = 0.95
	
	materials["metal"] = StandardMaterial3D.new()
	materials["metal"].albedo_color = Color(0.25 + randf_range(-0.05, 0.05), 0.25 + randf_range(-0.05, 0.05), 0.3 + randf_range(-0.05, 0.05))
	materials["metal"].roughness = randf_range(0.4, 0.6)
	materials["metal"].metallic = 0.8
	
	materials["metal_amarillo"] = StandardMaterial3D.new()
	materials["metal_amarillo"].albedo_color = Color(0.85, 0.7, 0.15)
	materials["metal_amarillo"].roughness = randf_range(0.5, 0.7)
	materials["metal_amarillo"].metallic = 0.7
	
	materials["verde_oscuro"] = StandardMaterial3D.new()
	materials["verde_oscuro"].albedo_color = Color(0.08, randf_range(0.3, 0.4), 0.08)
	materials["verde_oscuro"].roughness = 0.9
	
	materials["verde_claro"] = StandardMaterial3D.new()
	materials["verde_claro"].albedo_color = Color(0.12, randf_range(0.45, 0.55), 0.12)
	materials["verde_claro"].roughness = 0.9
	
	materials["cartel"] = StandardMaterial3D.new()
	materials["cartel"].albedo_color = Color(0.95, 0.95, 0.85)
	materials["cartel"].roughness = 0.7
	
	# Nuevo: Poste de luz
	materials["poste"] = StandardMaterial3D.new()
	materials["poste"].albedo_color = Color(0.2, 0.2, 0.2)
	materials["poste"].roughness = 0.6
	materials["poste"].metallic = 0.8
	
	# Nuevo: Vidriera tienda
	materials["vidriera"] = StandardMaterial3D.new()
	materials["vidriera"].albedo_color = Color(0.6, 0.7, 0.8)
	materials["vidriera"].roughness = 0.1
	materials["vidriera"].metallic = 0.3
	materials["vidriera"].transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	materials["vidriera"].albedo_color.a = 0.3

func generar_barrio():
	var tamano_cuadra = 80.0
	var ancho_calle = 10.0
	var num_cuadras = 7
	var half = num_cuadras / 2
	
	# Generar calles y cuadras
	for x in range(-half, half + 1):
		for z in range(-half, half + 1):
			var pos_cuadra = Vector3(x * tamano_cuadra, 0, z * tamano_cuadra)
			
			# Calles horizontales
			if x != 0:
				_crear_calle(
					Vector3(x * tamano_cuadra - tamano_cuadra / 2 + ancho_calle / 2, 0.01, z * tamano_cuadra),
					Vector3(ancho_calle, 0.1, tamano_cuadra)
				)
			
			# Calles verticales
			if z != 0:
				_crear_calle(
					Vector3(x * tamano_cuadra, 0.01, z * tamano_cuadra - tamano_cuadra / 2 + ancho_calle / 2),
					Vector3(tamano_cuadra, 0.1, ancho_calle)
				)
			
			# Plaza central o manzanas
			if x == 0 and z == 0:
				_crear_plaza(pos_cuadra)
			elif x == 1 and z == 0:
				_crear_estacion(pos_cuadra)
			else:
				_crear_manzana(pos_cuadra, x, z)
	
	# Agregar veredas alrededor de cada manzana
	for x in range(-half, half + 1):
		for z in range(-half, half + 1):
			var pos = Vector3(x * tamano_cuadra, 0.02, z * tamano_cuadra)
			_crear_vereda(pos, tamano_cuadra, ancho_calle)
	
	# Agregar decoraciones urbanas (postes, árboles, etc.)
	_agregar_decoraciones_urbanas(tamano_cuadra, ancho_calle, half)

func _crear_calle(pos, tamano):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = tamano
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = materials["calle"]
	add_child(mesh)
	
	# Líneas amarillas en el centro de la calle
	if tamano.x > tamano.z:
		# Calle horizontal - línea central
		var linea = MeshInstance3D.new()
		var box_linea = BoxMesh.new()
		box_linea.size = Vector3(tamano.x - 2, 0.02, 0.3)
		linea.mesh = box_linea
		linea.position = pos + Vector3(0, 0.06, 0)
		linea.material_override = materials["linea_calle"]
		add_child(linea)
	else:
		# Calle vertical - línea central
		var linea = MeshInstance3D.new()
		var box_linea = BoxMesh.new()
		box_linea.size = Vector3(0.3, 0.02, tamano.z - 2)
		linea.mesh = box_linea
		linea.position = pos + Vector3(0, 0.06, 0)
		linea.material_override = materials["linea_calle"]
		add_child(linea)
	
	var body = StaticBody3D.new()
	body.position = pos
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = tamano
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)

func _crear_vereda(pos: Vector3, tamano_cuadra: float, ancho_calle: float):
	var ancho_vereda = 2.0
	var largo = tamano_cuadra - ancho_calle
	# Vereda norte
	_crear_bloque_vereda(pos + Vector3(0, 0, -largo / 2 - ancho_vereda / 2), Vector3(largo, 0.15, ancho_vereda))
	# Vereda sur
	_crear_bloque_vereda(pos + Vector3(0, 0, largo / 2 + ancho_vereda / 2), Vector3(largo, 0.15, ancho_vereda))
	# Vereda este
	_crear_bloque_vereda(pos + Vector3(largo / 2 + ancho_vereda / 2, 0, 0), Vector3(ancho_vereda, 0.15, largo))
	# Vereda oeste
	_crear_bloque_vereda(pos + Vector3(-largo / 2 - ancho_vereda / 2, 0, 0), Vector3(ancho_vereda, 0.15, largo))

func _crear_bloque_vereda(pos: Vector3, tamano: Vector3):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = tamano
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = materials["vereda"]
	add_child(mesh)

func _crear_plaza(pos):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(60, 0.2, 60)
	mesh.mesh = box
	mesh.position = pos
	mesh.position.y = 0.1
	mesh.material_override = materials["plaza"]
	add_child(mesh)
	
	# Colisión del piso de la plaza
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, 0.1, pos.z)
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(60, 0.2, 60)
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)
	
	# Árboles
	for i in range(16):
		# Tronco
		var tronco = MeshInstance3D.new()
		var cyl_tronco = CylinderMesh.new()
		cyl_tronco.top_radius = 0.15
		cyl_tronco.bottom_radius = 0.2
		cyl_tronco.height = 3
		tronco.mesh = cyl_tronco
		var offset = Vector3(randf_range(-25, 25), 1.5, randf_range(-25, 25))
		tronco.position = pos + offset
		var mat_tronco = StandardMaterial3D.new()
		mat_tronco.albedo_color = Color(0.35, 0.2, 0.1)
		tronco.material_override = mat_tronco
		add_child(tronco)
		
		# Copa del árbol (esfera)
		var copa = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 1.5
		sphere.height = 3.0
		copa.mesh = sphere
		copa.position = pos + offset + Vector3(0, 2.5, 0)
		var mat_copa = StandardMaterial3D.new()
		mat_copa.albedo_color = Color(0.1, randf_range(0.3, 0.5), 0.1)
		copa.material_override = mat_copa
		add_child(copa)
	
	# Bancos de plaza
	for i in range(8):
		var banco = MeshInstance3D.new()
		var box_banco = BoxMesh.new()
		box_banco.size = Vector3(2, 0.5, 0.6)
		banco.mesh = box_banco
		var angulo = i * TAU / 8
		banco.position = pos + Vector3(cos(angulo) * 18, 0.25, sin(angulo) * 18)
		banco.rotation.y = angulo + PI / 8
		var mat_banco = StandardMaterial3D.new()
		mat_banco.albedo_color = Color(0.4, 0.25, 0.1)
		banco.material_override = mat_banco
		add_child(banco)

func _crear_estacion(pos):
	# Edificio principal de la estación (más grande)
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	var altura = 12.0
	box.size = Vector3(55, altura, 40)
	mesh.mesh = box
	mesh.position = pos
	mesh.position.y = altura / 2.0
	mesh.material_override = materials["estacion"]
	add_child(mesh)
	
	# Colisión
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, altura / 2.0, pos.z)
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(55, altura, 40)
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)
	
	# Techo abovedado (cilindro acostado)
	var techo = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 20
	cyl.bottom_radius = 20
	cyl.height = 55
	techo.mesh = cyl
	techo.position = pos + Vector3(0, altura + 2, 0)
	techo.rotation.z = PI / 2
	var mat_techo = StandardMaterial3D.new()
	mat_techo.albedo_color = Color(0.5, 0.55, 0.6)
	techo.material_override = mat_techo
	add_child(techo)

func _crear_manzana(pos, x, z):
	# Determinar tipo basado en posición para variedad
	var seed_val = abs(x * 13 + z * 7)
	var es_comercial = (seed_val % 3) != 0
	
	# Generar entre 1 y 4 edificios por manzana para más realismo
	var num_edificios = 1 + (seed_val % 4)
	var tamano_manzana = 50.0
	
	if num_edificios == 1:
		# Un edificio grande que ocupa toda la manzana
		var altura = 8.0 + float(seed_val % 8) * 4.0
		_crear_edificio(pos, Vector3(tamano_manzana, altura, tamano_manzana), es_comercial)
	else:
		# Múltiples edificios en la manzana
		var mitad = tamano_manzana / 2.0
		var gap = 2.0
		for i in range(num_edificios):
			var sub_ancho = (tamano_manzana - gap * (num_edificios - 1)) / num_edificios
			var sub_pos = pos + Vector3(
				- mitad + sub_ancho / 2 + i * (sub_ancho + gap),
				0,
				0
			)
			var altura = 8.0 + float((seed_val + i * 5) % 10) * 3.0
			var sub_comercial = es_comercial if i % 2 == 0 else !es_comercial
			_crear_edificio(sub_pos, Vector3(sub_ancho, altura, tamano_manzana), sub_comercial)

func _crear_edificio(pos: Vector3, tamano: Vector3, es_comercial: bool):
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
	
	# Agregar ventanas al edificio
	_agregar_ventanas(pos, tamano, es_comercial)
	
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, tamano.y / 2.0, pos.z)
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = tamano
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)

func _agregar_ventanas(pos: Vector3, tamano: Vector3, es_comercial: bool):
	var mat_vidrio = materials["vidriera"]
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
	var separacion_horizontal = 3.0
	
	# Ventanas en las caras frontal y trasera
	for cara in [Vector3.FORWARD, Vector3.BACK]:
		for piso in range(num_pisos):
			var y_pos = pos.y + altura_piso / 2.0 + piso * altura_piso
			var z_offset = cara.z * (profundidad_edificio / 2.0 + 0.01)
			
			var num_ventanas = int(ancho_edificio / separacion_horizontal)
			for i in range(num_ventanas):
				var x_offset = -ancho_edificio / 2.0 + separacion_horizontal / 2.0 + i * separacion_horizontal
				
				# Marco de ventana
				var marco = MeshInstance3D.new()
				var box_marco = BoxMesh.new()
				box_marco.size = Vector3(ventana_ancho + 0.1, ventana_alto + 0.1, 0.05)
				marco.mesh = box_marco
				marco.position = Vector3(pos.x + x_offset, y_pos, pos.z + z_offset)
				marco.material_override = mat_negro
				add_child(marco)
				
				# Vidrio de ventana
				var vidrio = MeshInstance3D.new()
				var box_vidrio = BoxMesh.new()
				box_vidrio.size = Vector3(ventana_ancho, ventana_alto, 0.02)
				vidrio.mesh = box_vidrio
				vidrio.position = Vector3(pos.x + x_offset, y_pos, pos.z + z_offset + cara.z * 0.04)
				vidrio.material_override = mat_vidrio
				add_child(vidrio)
	
	# Ventanas en las caras laterales
	for cara in [Vector3.RIGHT, Vector3.LEFT]:
		var num_ventanas = int(profundidad_edificio / separacion_horizontal)
		for piso in range(num_pisos):
			var y_pos = pos.y + altura_piso / 2.0 + piso * altura_piso
			var x_offset = cara.x * (ancho_edificio / 2.0 + 0.01)
			
			for i in range(num_ventanas):
				var z_offset = -profundidad_edificio / 2.0 + separacion_horizontal / 2.0 + i * separacion_horizontal
				
				# Marco de ventana
				var marco = MeshInstance3D.new()
				var box_marco = BoxMesh.new()
				box_marco.size = Vector3(0.05, ventana_alto + 0.1, ventana_ancho + 0.1)
				marco.mesh = box_marco
				marco.position = Vector3(pos.x + x_offset, y_pos, pos.z + z_offset)
				marco.material_override = mat_negro
				add_child(marco)
				
				# Vidrio de ventana
				var vidrio = MeshInstance3D.new()
				var box_vidrio = BoxMesh.new()
				box_vidrio.size = Vector3(0.02, ventana_alto, ventana_ancho)
				vidrio.mesh = box_vidrio
				vidrio.position = Vector3(pos.x + x_offset + cara.x * 0.04, y_pos, pos.z + z_offset)
				vidrio.material_override = mat_vidrio
				add_child(vidrio)

func _agregar_decoraciones_urbanas(tamano_cuadra: float, ancho_calle: float, half: int):
	# Postes de luz en las esquinas de las calles
	for x in range(-half, half + 1):
		for z in range(-half, half + 1):
			if x == 0 and z == 0:
				continue
			
			var pos_esquina = Vector3(x * tamano_cuadra, 0, z * tamano_cuadra)
			var offset = (tamano_cuadra - ancho_calle) / 2.0
			
			# Poste en cada esquina de la manzana
			_crear_poste(Vector3(pos_esquina.x - offset, 0, pos_esquina.z - offset))
			_crear_poste(Vector3(pos_esquina.x + offset, 0, pos_esquina.z - offset))
			_crear_poste(Vector3(pos_esquina.x - offset, 0, pos_esquina.z + offset))
			_crear_poste(Vector3(pos_esquina.x + offset, 0, pos_esquina.z + offset))

func _crear_poste(pos: Vector3):
	# Poste de luz
	var poste = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.08
	cyl.bottom_radius = 0.1
	cyl.height = 5.0
	poste.mesh = cyl
	poste.position = pos + Vector3(0, 2.5, 0)
	poste.material_override = materials["poste"]
	add_child(poste)
	
	# Brazo del poste
	var brazo = MeshInstance3D.new()
	var box_brazo = BoxMesh.new()
	box_brazo.size = Vector3(1.5, 0.1, 0.1)
	brazo.mesh = box_brazo
	brazo.position = pos + Vector3(0.75, 5.0, 0)
	brazo.material_override = materials["poste"]
	add_child(brazo)
	
	# Lámpara
	var lampara = MeshInstance3D.new()
	var sphere_lampara = SphereMesh.new()
	sphere_lampara.radius = 0.2
	sphere_lampara.height = 0.4
	lampara.mesh = sphere_lampara
	lampara.position = pos + Vector3(1.5, 4.8, 0)
	var mat_lampara = StandardMaterial3D.new()
	mat_lampara.albedo_color = Color(1.0, 0.95, 0.8)
	mat_lampara.emission_enabled = true
	mat_lampara.emission = Color(1.0, 0.95, 0.8)
	mat_lampara.emission_energy_multiplier = 0.5
	lampara.material_override = mat_lampara
	add_child(lampara)
