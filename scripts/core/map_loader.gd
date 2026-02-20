extends Node
class_name MapLoader

const ESCALA: float = 80.0
const CENTRO_LAT: float = -34.6098
const CENTRO_LON: float = -58.4065

var zonas: Array = []

func cargar_zonas(ruta: String) -> bool:
	zonas = []
	return true

func latlon_a_vector3(lat: float, lon: float) -> Vector3:
	var x = (lon - CENTRO_LON) * ESCALA
	var z = (lat - CENTRO_LAT) * ESCALA
	return Vector3(x, 0, z)

func obtener_zonas() -> Array:
	return zonas
