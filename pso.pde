int cols, rows;
float[][] z;
float domainMin = -3, domainMax = 7;
int gridSize = 150;  // Subdivisiones de la grilla
float minZ = Float.MAX_VALUE;
float maxZ = -Float.MAX_VALUE;

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
PImage surf; // imagen que entrega el fitness
int puntos = 100; // Cantidad de particulas se
Particle[] fl; // arreglo de partículas
float d = 15; // radio del círculo, solo para despliegue
float gbest = Float.MAX_VALUE;
float gbestx, gbesty; // posición y fitness del mejor global
float w = 1000; // inercia: baja (~50): explotación, alta (~5000): exploración (2000 ok)
float C1 = 30, C2 =  100; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 3; // max velocidad (modulo)
int altura = 300; int ancho = 300;
// OBS:
// cartesianToScreenX 7 -> 1000
// cartesianToScreenX -3 -> 0
// cartesianToScreenY 7 -> 0
// cartesianToScreenY -3 -> 700

class Particle{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float px, py, pfit; // position (p-vector) and fitness (p-fitness) of best solution found by particle so far
  float vx, vy; //vector de avance (v-vector)
  
  // ---------------------------- Constructor
  Particle(){
    // Escogemos un valor aleatorio dentro del dominio ]-3,7[, le restamos algo minimo a -3 ya que random(A,B) incluye a A y excluye a B
    float cartX = random(domainMin + 0.01 , domainMax); float cartY = random(domainMin + 0.01, domainMax);
    
    // Lo transformamos para que sea visible (coherentemente) en pantalla
    x = cartesianToScreenX(cartX); y = cartesianToScreenX(cartY);
    // Hacemos que se mantengan dentro de la ventana
    x = constrain(x, -ancho, ancho); y = constrain(y, -altura, altura);

    vx = random(-1,1) ; vy = random(-1,1);
    pfit = Float.POSITIVE_INFINITY; fit = Float.POSITIVE_INFINITY; // Ya que buscamos MINIMIZAR
  }
  
  // ---------------------------- Evalúa partícula
  float Eval(){ //recibe imagen que define función de fitness
    evals++;
    fit = rastrigin(screenToCartesianX(x), screenToCartesianY(y)); // Buscamos el mejor valor
    if(fit < pfit){ // actualiza local best si es mejor
      pfit = fit;
      px = x;
      py = y;
    }
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      // println(str(gbest));
    };
    return fit; //retorna 
  }
  
  // ------------------------------ mueve la partícula
  void move(){
    //actualiza velocidad (fórmula con factores de aprendizaje C1 y C2)
    //vx = vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    //actualiza velocidad (fórmula con inercia, p.250)
    vx = w * vx + random(0,1)*(px - x) + random(0,1)*(gbestx - x);
    vy = w * vy + random(0,1)*(py - y) + random(0,1)*(gbesty - y);
    
    //actualiza velocidad (fórmula mezclada)
    //vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    // trunca velocidad a maxv
    float modu = sqrt(vx*vx + vy*vy);
    if (modu > maxv){
      vx = vx/modu*maxv;
      vy = vy/modu*maxv;
    }
    
    // update position
    x = x + vx;
    y = y + vy;

  // Convierte las coordenadas a cartesianas antes de hacer el rebote
  float cartX = screenToCartesianX(x);
  float cartY = screenToCartesianY(y);

    // println("altura", height); 700
    // println("ancho", width); 1000
    // Rebote en los límites de la pantalla
    if (x > ancho || x < -ancho) { // Rebote en el eje X (coordenadas de pantalla)
        vx = -vx;  // Rebote en el eje X
    }
    if (y > altura || y < -altura) { // Rebote en el eje Y (coordenadas de pantalla)
        vy = -vy;  // Rebote en el eje Y
    }


  }
  
  // ------------------------------ despliega partícula
  void display(){
    ellipse (x,y,d,d);
    // dibuja vector
    stroke(#ffffff); // Color del borde de la partícula
    line(x,y,x-10*vx,y-10*vy);
  }
} //fin de la definición de la clase Particle  
 
// dibuja punto azul en la mejor posición y despliega números
void despliegaBest() {
  fill(#0000ff);
  
  // Convert Cartesian coordinates (6,6) to screen coordinates
  float screenX = cartesianToScreenX(0);
  float screenY = cartesianToScreenY(0);
  
  // Draw the ellipse at the computed screen coordinates
  ellipse(screenX, screenY, d, d);
  
  // Display the coordinates as text next to the ellipse
  fill(255);  // White text for visibility
  textSize(16);
  textAlign(LEFT, CENTER); // Align text to the left of its position
  text("("+ nf(screenX, 0, 2) + ", " + nf(screenY, 0, 2) + ")", screenX + 15, screenY);
}


// ======================================================================

void setup() {
  size(700, 700);  // Use P3D for rendering
  cols = gridSize;
  rows = gridSize;
  z = new float[cols][rows];
  

  // Compute function values
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = map(i, 0, cols - 1, domainMin, domainMax);
      float y = map(j, rows - 1, 0, domainMin, domainMax);
      z[i][j] = rastrigin(x, y);
    }
  }

  // Find min and max Z values
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      minZ = min(minZ, z[i][j]);
      maxZ = max(maxZ, z[i][j]);
    }
  }
  
   // ~~~~~~~~~~~~~~~~~PARTICULAS~~~~~~~~~~~~~~~~~~~~~~~~~
   smooth();
  // crea arreglo de objetos partículas
  fl = new Particle[puntos];
  for(int i =0;i<puntos;i++)
    fl[i] = new Particle();
}

void draw() {
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
  //mueve puntos
  for(int i = 0;i<puntos;i++){
    fl[i].move();
    fl[i].Eval();
  }
}

// Mapea valores a un gradiente como mapa de calor
color getHeatColor(float t) {
  return lerpColor(lerpColor(color(0, 0, 255), color(0, 255, 0), t), 
                   color(255, 0, 0), t);
}

// Funcion Rastrigin 
float rastrigin(float x, float y) {
  float A = 10;
  return A * 2 + (x * x - A * cos(TWO_PI * x)) + (y * y - A * cos(TWO_PI * y));
}
