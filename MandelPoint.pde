// Creation de la class MandelPoint
class MandelPoint {
  
  // Variable pVectorVelocity de type PVector
  PVector pVectorVelocity;
  
  // Variable brightless de type int
  int brightness;
  
  // Variable i de type float
  float i;

  // Creation d'un constructeur MandelPoint avec 2 parametres pVectorVelocity de type PVector et i de type float
  MandelPoint (PVector pVectorVelocity, float i) {

    // Brightless donne valeur aleatoire entre 120 et 200
    this.brightness = int (random (120, 200));
    
    // pVectorVelocity
    this.pVectorVelocity = pVectorVelocity;
    
    // I
    this.i = i;
  }
}
