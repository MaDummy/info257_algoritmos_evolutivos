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


// ========================= PARTICULA ====================================

class Individuo{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  
  // ---------------------------- Constructor
  Individuo(){
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
  
  
  // ------------------------------ despliega individuo
  void display(){
    ellipse (x,y,d,d);
    // dibuja vector
    stroke(#ffffff); // Color del borde de la partícula
  }
} //fin de la definición de la clase Individuo


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
