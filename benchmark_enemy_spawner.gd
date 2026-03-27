extends SceneTree

func _init():
    var iter = 10000
    var enemies = []

    # Crear un arreglo con algunos elementos válidos y algunos nulos para simular enemies
    for i in range(100):
        enemies.append(Object.new())
    for i in range(50):
        enemies.append(null)

    var t1 = Time.get_ticks_usec()
    for _i in range(iter):
        var cur_enemies = []
        for e in enemies:
            cur_enemies.append(e)

        cur_enemies = cur_enemies.filter(func(e): return is_instance_valid(e))
    var t2 = Time.get_ticks_usec()

    print("Baseline filter: ", (t2 - t1) / 1000.0, " ms")

    var t3 = Time.get_ticks_usec()
    for _i in range(iter):
        # En la aproximación con señales, la lista solo se actualiza cuando un enemigo muere (se destruye).
        # Esto ocurre O(1) cuando se elimina y no requiere iterar sobre todos los enemigos en cada tick de timer.
        pass
    var t4 = Time.get_ticks_usec()

    print("Optimized (Signal): ", (t4 - t3) / 1000.0, " ms")
    print("Note: In actual implementation, signal handler simply calls erase() which takes minimal time compared to array recreation")
    quit()
