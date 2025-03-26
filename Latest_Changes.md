# Cambios codigo

Cambios a la estructura

Cambios nombres (particle → individuo)

Eliminacion variables y funcion de PSO, como w, c1, c2, maxv

Eliminacion metodo Eval() de individuo, a diferencia de PSO el individuo no se mueve de acuerdo a local y global best fit

Eliminacion metodo move() de individuo, a diferencia particle de PSO, el individuo de EA no se mueve, en vez de eso sus descendientes (si los tiene) tendran una posicion diferente

Cambio comentarios ingles a español

Ahora se confirma el nuevo gbest, gbestx, gbesty cuando nace un individuo

Se quito movimiento de particulas de la funcion draw()

Se cambio funcionamiento de coordenadas, ahora todas las coordenadas se guardan y trabajan en cartesiano y se generan versiones de pantalla cuando se quieren dibujar

## siguiente version

Hacer funcion para transformar coordenadas a su representacion binaria sin discretizar

Guardar una version de las coordenadas de los individuos como representacion binaria