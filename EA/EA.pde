// Variables usadas para la ventana y grafica
int altura = 700; int ancho = 700; // Dimensiones de la ventana
int cols, rows;
float[][] z;
float domainMin = -3, domainMax = 7;
int gridSize = 150; // Subdivisiones de la grilla
float minZ = Float.MAX_VALUE;
float maxZ = -Float.MAX_VALUE;

float MUTATE_CHANCE = 0.000003; // MUTATE_CHANCE*100 % de que ocurra

// Variables usadas para particulas
int puntos = 160; // Cantidad de particulas
int EXPECT_VIDA = 10;
Individuo[] fl; // arreglo de partículas
ArrayList<Individuo> Individuos;
ArrayList<Individuo> Seleccionados;

float d = 15; // radio del círculo, solo para despliegue
float gbest = Float.MAX_VALUE; // Fitness del mejor global
float gbestx, gbesty; // posición del mejor global, en cartesiano
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue

// Variables usadas para la seleccion de individuos
int k = 8; // Cantidad de individuos que participaran en el torneo
int cantTorneos = 20; // Cantidad de torneos a realizar

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

// Funcion para seleccionar a los k individuos aleatorios y el mejor
void selectIndividuo() {
  int n = Individuos.size(); 
  IntList index = new IntList(); // Hacemos una lista con los indices
  for (int i = 0; i < k; i++){
    index.append((int) random(n));
  }
  
  // Buscamos el mejor fit entre los indices de index
  int best = index.get(0);
  float bestValue = Individuos.get(index.get(0)).fit;
  for (int i = 1; i < k; i++){
    if (Individuos.get(index.get(i)).fit < bestValue){
      bestValue = Individuos.get(index.get(i)).fit;
      best = index.get(i);
    }
  }
  
  // Añadimos el mejor a seleccionados 
  Seleccionados.add(Individuos.get(best));
}


void seleccion(){
  // Selecciona cantTorneos individuos y cambia color de estos
  for (int i = 0; i < cantTorneos; i++){
    selectIndividuo();
    Seleccionados.get(i).setColor(#4d24b7);
  }
}

void deshacerSeleccion(){
  // Selecciona cantTorneos individuos y cambia color de estos
  for (int i = 0; i < Seleccionados.size(); i++){
    Seleccionados.get(i).setColor(#b2db48);
  }
  Seleccionados.clear();
}

//=========================== CRUZAMIENTO =================================

float mutate(float coord){
   char[] bits = floatToBinary(coord).toCharArray();
   String mutated_bits = "";
   float mutated;
   int chance;
   char aux='0';
   for(char i:bits){
     chance = int(random(0,1/MUTATE_CHANCE));
     if(chance == 1){
       if(i=='1'){
         aux = '0';
       }
       else{
         aux = '1';
       }
       mutated_bits+=aux;
     }
     else{
       mutated_bits+=i;
     }
   }
   float temp = binaryToFloat(mutated_bits);
   int temp_int = constrain((int) temp,-2,6);
   mutated = temp_int+(temp-(int)temp);
   mutated = (float)((int)(mutated*10000000))/10000000.0f;
   return mutated;
}

void cruzar(Individuo juan, Individuo maria){
  float x1 = juan.getCartX();
  float x2 = maria.getCartX();
  
  float y1 = juan.getCartY();
  float y2 = maria.getCartY();
  
  float y_new = mutate(random(min(y1, y2), max(y1, y2)));
  float x_new = mutate(random(min(x1, x2), max(x1, x2)));

  Individuo rafael = new Individuo(x_new, y_new);
  juan.ciclos-=1;
  maria.ciclos-=1;
  Individuos.add(rafael);
}

void cruzamiento(){
  int iteraciones = Seleccionados.size();
  if (iteraciones % 2 == 0){
    for(int i = 0; i < iteraciones / 2; i++){
      cruzar(Seleccionados.get(i), Seleccionados.get(i+1));
    }
  }
  else{
    for(int i = 0; i < (iteraciones / 2)-1; i++){
      cruzar(Seleccionados.get(i), Seleccionados.get(i+1));
    }
    cruzar(Seleccionados.get(0), Seleccionados.get(iteraciones));
  }
}
// ========================= PARTICULA ====================================
// Function to mutate a coordinate by flipping a random bit


class Individuo{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float cartX, cartY;
  int ciclos;
  color c; // Color del individuo
  
    
  // ---------------------------- Constructor
  Individuo(){
    // Le asignamos un color por defecto
    c = color(#b2db48); 
    
    // Ciclos con vida
    ciclos = 1;
    
    // Escogemos un valor aleatorio dentro del dominio ]-3,7[, le restamos algo minimo a -3 ya que random(A,B) incluye a A y excluye a B
    cartX = random(domainMin + 0.01 , domainMax); 
    cartY = random(domainMin + 0.01, domainMax);
    
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
  Individuo(float parentX, float parentY){
    // Le asignamos un color por defecto
    
    c = color(#b2db48); 
    
    // Ciclos con vida
    ciclos = 1;
    
    // Obtenemos su valor en la funcion rastrigin
    fit = rastrigin(parentX, parentY);
    
    // Verificamos si al nacer la particula es el mejor fit
    if (fit < gbest){
      gbest = fit;
      gbestx = parentX;
      gbesty = parentY;
    }
    
    // Lo transformamos para que sea visible (coherentemente) en pantalla
    this.x = cartesianToScreenX(parentX); 
    this.y = cartesianToScreenY(parentY);
    this.cartX = parentX;
    this.cartY = parentY;
    
    // Hacemos que se mantengan dentro de la ventana
    this.x = constrain(this.x, -ancho, ancho); this.y = constrain(this.y, -altura, altura);
  }
  
  
  // ------------------------------ despliega individuo
  void display(){
    stroke(#ffffff); // Color del borde de la partícula
    ellipse (x,y,d,d);
    // dibuja vector
    fill(c);
    //Cada vez que se despliega significa que paso un ciclo
    ciclos++;
  }
  // ------------------------------ Función para cambiar color manualmente
  void setColor(color nuevoColor) {
    c = nuevoColor;
  }
  float getFit() {
    return fit;
  }
  
  float getCartX(){
    return this.cartX;
  }
  float getCartY(){
    return this.cartY;
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
  Individuos = new ArrayList<Individuo>();
  Seleccionados = new ArrayList<Individuo>();
  for(int i =0;i<puntos;i++)
    Individuos.add(new Individuo());


}


// ============================ ACTUALIZACIONES PANTALLA ============================

void draw() {
  // ~~~~~~~~~~~~~~ GRAFICO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  background(0);

  float cellSize = width / cols;  // Ajusta tamaño de los elementos a la pantalla
  
  for (int x = 0; x < cols ; x++) {
    for (int y = 0; y < rows ; y++) {
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
  
  // ~~~~~~~~~~~~~~ SELECCION PARTICULAS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  deshacerSeleccion();
  
  seleccion();
  
  cruzamiento();
  
  
  // ~~~~~~~~~~~~~~ DESPLIEGE PARTICULAS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  for(int i = 0;i<Individuos.size();i++){
    Individuos.get(i).display();

    if (Individuos.get(i).ciclos == EXPECT_VIDA){
      Individuos.remove(i);
    }
  }
  
  despliegaBest();
  
  // ~~~~~~~~~~~~~~ CRUZAMIENTO ~~~~~~~~~~~~~~~~
  

  
  // Display the size of Individuos at the top left corner
  fill(255);  // Set text color to white
  textSize(16);  // Set the text size
  text("global best: " + gbest, 10, 20);  // Display the size of Individuos
  text("Num individuos: " + Individuos.size(), 10, 50);  // Display the size of Individuos

  
  delay(500);
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
