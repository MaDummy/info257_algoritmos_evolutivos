// Variables usadas para la ventana y grafica
int altura = 700; int ancho = 700; // Dimensiones de la ventana
int cols, rows;
float[][] z;
float domainMin = -3, domainMax = 7;
int gridSize = 150; // Subdivisiones de la grilla
float minZ = Float.MAX_VALUE;
float maxZ = -Float.MAX_VALUE;

// Variables usadas para particulas
int puntos = 100; // Cantidad de particulas 
Individuo[] fl; // arreglo de partículas

float d = 15; // radio del círculo, solo para despliegue
float gbest = Float.MAX_VALUE; // Fitness del mejor global
float gbestx, gbesty; // posición del mejor global, en cartesiano
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue

// Variables usadas para la seleccion de individuos
int k = 10; // Cantidad de individuos que participaran en el torneo
int cantTorneos = 5; // Cantidad de torneos a realizar

// ======================= FUNCIONES DE CONVERSIÓN ============================
 
float screenToCartesianX(float sx) {
  return map(sx, 0, width, -3, 7);
}
float screenToCartesianY(float sy) {
  return map(sy, 0, height, 7, -3);
}

float cartesianToScreenX(float x) {
  return map(x, -3, 7, 0, width);
}

float cartesianToScreenY(float y) {
  return map(y, -3, 7, height, 0);
}

String floatToBinary(float num) {
  int bits = Float.floatToIntBits(num);
  return String.format("%32s", Integer.toBinaryString(bits)).replace(" ", "0");
}

float binaryToFloat(String binario) {
  int bits = (int) Long.parseLong(binario, 2);
  return Float.intBitsToFloat(bits);
}


// ======================= FUNCION DE TORNEO ============================

// Funcion para seleccionar a los k individuos aleatorios
void selectIndividuo(IntList seleccionados) {
  int n = fl.length; 
  IntList index = new IntList(); // Hacemos una lista con los indices
  for (int i = 0; i < n; i++){
    index.append(i);
  }
  index.shuffle(); // "Desordena" aleatoriamente la lista de indices
  
  // Tomamos los primeros k indices aleatorios 
  for (int i = 0; i < k; i++){
    seleccionados.append(index.get(i));
  }
}

// Selecciona un individuo con algoritmo de torneo, asumiendo que se elegiran k individuos para comparar, retorna el indice del ganador
int tournamentSelection(Individuo[] particulas) {
  IntList seleccionados = new IntList();
  selectIndividuo(seleccionados); //
  
  while(seleccionados.size() != 1 ){
    IntList continuan = new IntList();
    
    // Verificamos si la lista tiene un número impar de elementos, si no lo tiene entonces, eliminamos el primer perdedor
    if (seleccionados.size() % 2 != 0) {
      // Obtenemos el fitness de dos individuos
      float a = particulas[seleccionados.get(0)].getFit();
      float b = particulas[seleccionados.get(1)].getFit();
      // Comparamos, el menor pasa para poder seguir compitiendo
      if (a < b) seleccionados.remove(1); else seleccionados.remove(0);
    }
    
    // Comparar en pares y seleccionar el menor
    for (int i = 0; i < seleccionados.size(); i += 2) {
      // Obtenemos el fitness de dos individuos
      float a = particulas[seleccionados.get(i)].getFit();
      float b = particulas[seleccionados.get(i + 1)].getFit();
      // Comparamos, el menor pasa
      if (a < b) continuan.append(i); else continuan.append(i+1);
    }
    
    seleccionados = continuan;  // La nueva lista reemplaza a la anterior
  }
  return seleccionados.get(0); // Retornamos el indice del ganador
}

void verSeleccionado(Individuo[] particulas){
  int seleccionado = tournamentSelection(particulas);
  particulas[seleccionado].setColor(#db48bb);

}

//=========================== CRUZAMIENTO =================================


//Aqui va la mutacion ALVARO uwu
float genetic(float a, float b){
  return a;
}

Individuo cruzar(Individuo juan, Individuo maria){
  
  float x1 = juan.getCartX();
  float x2 = maria.getCartX();
  
  float y1 = juan.getCartY();
  float y2 = maria.getCartY();
  
  float x_new = genetic(x1,x2);
  float y_new = genetic(y1,y2);
  
  Individuo rafael = new Individuo(x_new,y_new);
  return rafael;
}

// ========================= PARTICULA ====================================

class Individuo{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  color c; // Color del individuo
  // ---------------------------- Constructor
  Individuo(){
    // Le asignamos un color por defecto
    c = color(#b2db48); 
    
    // Escogemos un valor aleatorio dentro del dominio ]-3,7[, le restamos algo minimo a -3 ya que random(A,B) incluye a A y excluye a B
    float cartX = random(domainMin + 0.01 , domainMax); 
    float cartY = random(domainMin + 0.01, domainMax);
    
    // Obtenemos su valor en la funcion rastrigin
    fit = rastrigin(cartX, cartY);
    
    // Verificamos si al nacer la particula es el mejor fit
    if (fit < gbest){
      gbest = fit;
      gbestx = cartX;
      gbesty = cartY;
    }
    
    // Lo transformamos para que sea visible (coherentemente) en pantalla
    x = cartesianToScreenX(cartX); 
    y = cartesianToScreenX(cartY);
    
    // Hacemos que se mantengan dentro de la ventana
    x = constrain(x, -ancho, ancho); y = constrain(y, -altura, altura);
  }
  Individuo(float x, float y){
    // Le asignamos un color por defecto
    c = color(#b2db48); 
    
    // Obtenemos su valor en la funcion rastrigin
    fit = rastrigin(x, y);
    
    // Verificamos si al nacer la particula es el mejor fit
    if (fit < gbest){
      gbest = fit;
      gbestx = x;
      gbesty = y;
    }
    
    // Lo transformamos para que sea visible (coherentemente) en pantalla
    this.x = cartesianToScreenX(x); 
    this.y = cartesianToScreenX(y);
    
    // Hacemos que se mantengan dentro de la ventana
    this.x = constrain(this.x, -ancho, ancho); this.y = constrain(this.y, -altura, altura);
  }
  
  
  // ------------------------------ despliega individuo
  void display(){
    ellipse (x,y,d,d);
    // dibuja vector
    fill(c);
    stroke(#ffffff); // Color del borde de la partícula
  }
  // ------------------------------ Función para cambiar color manualmente
  void setColor(color nuevoColor) {
    c = nuevoColor;
  }
  float getFit() {
    return fit;
  }
  
  float getCartX(){
    return screenToCartesianX(this.x);
  }
  float getCartY(){
    return screenToCartesianY(this.y);
  }
  
} // Fin de la definición de la clase Individuo


// =============================== SETUP VENTANA ===============================

void setup() {
  size(700, 700); // Dimensiones ventana
  cols = gridSize;
  rows = gridSize;
  z = new float[cols][rows];
  

  // Obtiene valores de la funcion en distintas celdas de la grilla
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = map(i, 0, cols - 1, domainMin, domainMax);
      float y = map(j, rows - 1, 0, domainMin, domainMax);
      z[i][j] = rastrigin(x, y);
    }
  }

  // Encuentra valores minimo y maximo de Z 
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      minZ = min(minZ, z[i][j]);
      maxZ = max(maxZ, z[i][j]);
    }
  }
  
   // ~~~~~~~~~~~~~~~~~INDIVIDUOS~~~~~~~~~~~~~~~~~~~~~~~~~
   smooth();
  // crea arreglo de objetos partículas
  fl = new Individuo[puntos];
  for(int i =0;i<puntos;i++)
    fl[i] = new Individuo();


}


// ============================ ACTUALIZACIONES PANTALLA ============================

void draw() {
  // ~~~~~~~~~~~~~~ GRAFICO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  background(0);

  float cellSize = width / cols;  // Ajusta tamaño de los elementos a la pantalla
  
  for (int x = 0; x < cols - 1; x++) {
    for (int y = 0; y < rows - 1; y++) {
      // Usa map para pasar x e y a sus valores equivalentes en la pantalla
      float px = map(x, 0, cols, 0, width);
      float py = map(y, 0, rows, 0, height);
      
      float normZ = map(z[x][y], minZ, maxZ, 0, 1);  // Usa map para pasar Z a valores entre 0 y 1
      color c = getHeatColor(normZ);  // Obtiene color basandose en z

      fill(c);
      noStroke();
      rect(px, py, cellSize, cellSize);
    }
    
  }
  
  // ~~~~~~~~~~~~~~ PARTICULAS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  for(int i = 0;i<puntos;i++){
    fl[i].display();
  }
  
  despliegaBest();
  
  // ~~~~~~~~~~~~~~ SELECCION DE PADRES ~~~~~~~~~~~~~~~~
  verSeleccionado(fl);
  
  delay(1000);
}

// Mapea valores a un gradiente como mapa de calor
color getHeatColor(float t) {
  return lerpColor(lerpColor(color(0, 0, 255), color(0, 255, 0), t), 
                   color(255, 0, 0), t);
}

void despliegaBest() {
  // Color de mejor punto
  fill(#0000ff);
  
  // Obtiene mejores posiciones en coordenadas de pantalla
  float screenX = cartesianToScreenX(gbestx);
  float screenY = cartesianToScreenY(gbesty);
  
  // Dibuja mejor punto en coordenadas
  ellipse(screenX, screenY, d, d);
  
  // Despliega coordenadas del mejor punto
  fill(255);  // Texto blanco
  textSize(16); // Tamaño de texto
  textAlign(LEFT, CENTER); // Alineacion de texto
  text("("+ nf(gbestx, 0, 2) + ", " + nf(gbestx, 0, 2) + ")", screenX + 15, screenY);
}


// ============================ RASTRIGIN ============================

// Funcion Rastrigin 
float rastrigin(float x, float y) {
  float A = 10;
  return A * 2 + (x * x - A * cos(TWO_PI * x)) + (y * y - A * cos(TWO_PI * y));
}
