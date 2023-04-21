import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// Initialise la DIMENSION_SPACE a 100, qui est la dimension pour creer le fractal en 3D
int DIMENSION_SPACE = 100;

// Initialise le maximumIteration a 20
int maximumIterations = 20;

// Initialise un tableau mandelPoints, qui stock tous les points generes
ArrayList <MandelPoint> mandelPoints = new ArrayList <MandelPoint> ();

// Initialise la liste de points avec stringListPoints
StringList stringListPoints = new StringList ();

// Initialise un tableau audioSprectrum, qui est le spectre audio
float [] audioSprectrum;

// Initialise la rotationCamera a 0
float rotationCamera = 0;

// Initialise la distance a 900
float distance = 900;

// Initialise le zoomCamera sur arret
boolean zoomCamera = false;

// Appel minim, qui charge les bibliotheque
Minim minim;

// Appel audioPlayer, qui est li le fichier audio
AudioPlayer audioPlayer;

// Appel fft (fast fourrier transform), qui analyse de spectre audio
FFT fft;

// Methode setup, qui initialise les parametres
void setup () {

  // Plein ecran avec de la 3D
  fullScreen (P3D);

  // Parcourt l'axe horizontale pour la construction du fractal
  for (int i = 0; i < DIMENSION_SPACE; i++) {

    // Parcourt l'axe verticale pour la construction du fractal
    for (int j = 0; j < DIMENSION_SPACE; j++) {

      // edgeScreen n'est pas au bord de la bordure
      boolean edgeScreen = false;

      // Initialise lastIteration a 0, qui est la derniere iteration (fin de la bordure de l'ecran)
      int lastIteration = 0;

      // Parcourt l'axe en profondeur pour la construction du fractal
      for (int k = 0; k < DIMENSION_SPACE; k++) {
        
        // Mapping de la coordonnée i sur l'axe horizontale
        float x = map (i, 0, DIMENSION_SPACE, -1, 1);
        
        // Mapping de la coordonnée i sur l'axe verticale
        float y = map (j, 0, DIMENSION_SPACE, -1, 1);
        
        // Mapping de la coordonnée i sur l'axe en profondeur
        float z = map (k, 0, DIMENSION_SPACE, -1, 1);

        // Initialise le vecteur a nul
        PVector pVector = new PVector (0, 0, 0);

        // Initialise iteratePoint a 8, qui itere le point 
        int iteratePoint = 8;
        
        // Initialise iteration a 0
        int iteration = 0;

        // Tant que c'est vrai
        while (true) {

          // Appel l'objet sphere, qui est la position du vecteur sur les differents axes
          Sphere sphere = sphere (pVector.x, pVector.y, pVector.z);

          // NewX est la nouvelle position horizontale de la sphere
          float newx = pow (sphere.radius, iteratePoint) * sin (sphere.theta * iteratePoint) * cos (sphere.phi * iteratePoint);
          
          // NewY est la nouvelle position verticale de la sphere
          float newy = pow (sphere.radius, iteratePoint) * sin (sphere.theta * iteratePoint) * sin (sphere.phi * iteratePoint);
          
          // NewZ est la nouvelle position en profondeur de la sphere
          float newz = pow (sphere.radius, iteratePoint) * cos (sphere.theta * iteratePoint);

          // Vecteur horizontale change la position horizontale de la sphere
          pVector.x = newx + x;
          
          // Vecteur verticale change la position verticale de la sphere
          pVector.y = newy + y;
          
          // Vecteur en profondeur change la position en profondeur de la sphere
          pVector.z = newz + z;

          // iteration augmente
          iteration++;

          // Si le rayon de la sphère est supérieur à 2
          if (sphere.radius > 2) {

            // LastIteration est egale a l'iteration
            lastIteration = iteration;

            // Si edgeScreen est au bord de la bordure
            if (edgeScreen) {

              // edgeScreen n'est pas au bord de la bordure
              edgeScreen = false;
            }

            // Arrete
            break;
          }

          // Si l'iteration est superieur au maximumIterations
          if (iteration > maximumIterations) {

            // Si edgeScreen n'est pas au bord de la bordure
            if (! edgeScreen) {

              // edgeScreen est au bord de la bordure
              edgeScreen = true;

              // Ajoute un MandelPoints et un Pvector avec lastIteration
              mandelPoints.add (new MandelPoint (new PVector (x * 200, y * 200, z * 200), lastIteration));

              // Ajoute la liste de points sur les differents axes
              stringListPoints.append (x + " " + y + " " + z);
            }

            // Arrete
            break;
          }
        }
      }
    }
  }
  
  // Creation d'un nouvel objet Minim, qui est pour la lecture de fichiers audio
  minim = new Minim (this);

  // Charge le fichier audio "music.mp3" pour la lecture
  audioPlayer = minim.loadFile ("music.mp3");

  // Creation d'un nouvel objet FFT (FastFourrierTransform), qui est pour l'analyse spectrale du fichier audio
  fft = new FFT (audioPlayer.bufferSize (), audioPlayer.sampleRate ());

  // Fenetre de Hamming pour la précision de l'analyse spectrale
  fft.window (FFT.HAMMING);

  // Creer un nouveau tableau Float, qui est pour la largeur du spectre audio
  audioSprectrum = new float [width];

  // Perspective de la caméra avec un angle de vue de 60  à degrés, la largeur qui divise la hauteur de la fenetre et la distance de vue minimale et maximale
  perspective ((60 * (PI / 180)), (width / height), 1, 10000);

  // Camera avec les coordonnees (x, y, z) pourla position de la camera ensuite celle du point et pour finir ceux pour déterminer l'orientation de la camera
  camera (0, 0, 1000, 0, 0, 0, 0, 1, 0);
}

// Methode sphere avec 3 parametres radius, theta et phi, qui sont de types float
Sphere sphere (float x, float y, float z) {

  // Calcul le rayon de la sphere avec le theoreme de Pythagore (distance euclidienne entre le point (x, y, z) et l'origine (0,0,0))
  float radius = sqrt ((x * x) + (y * y) + (z * z));
  
  // Calcul la valeur de l'angle theta
  float theta = atan2 (sqrt ((x * x) + (y * y)), z);
  
  // Calcul la valeur de l'angle phi
  float phi = atan2 (y, x);

  // Retourne le nouvel objet Sphere
  return new Sphere (radius, theta, phi);
}

// Methode draw, qui affiche le dessin (animation)
void draw () {
  
  // Translation sur la hauteur, pour faire un deplacement de la camera (en avant et en arriere)
  translate (0, 0, distance);
  
  // Couleur des spheres en HSB (gamme de violet)
  colorMode (HSB, 250, 250, 150);

  // Couleur de l'arriere plan (violet)
  background (220, 220, 20);
  
  // Pousse la transformation de la matrice
  pushMatrix ();
  
  // Rotation horizontale pour faire bouger la camera
  rotateX ((PI / 3) + rotationCamera);
  
  // Rotation verticale pour faire bouger la camera
  rotateY ((- PI / 3) + rotationCamera);

  // Si audioPlayer n'est pas lancer
  if (! audioPlayer.isPlaying ()) {

    // Lance l'audioPlayer en continu
    audioPlayer.loop ();
  }

  // Mélangeur audio de la transformation de Fourrier pour obtenir les fréquences
  fft.forward (audioPlayer.mix);
  
  // BandWith est la largeur de bande en fréquence
  float bandWidth = (float) (fft.specSize () / (float) width);

  // Parcourt chaque bande de frequence
  for (int i = 0; i < width; i++) {

    // bandIndex est l'indice actuel de la bande en fréquence
    int bandIndex = (int) (i * bandWidth);

    // Amplitude de la bande de fréquence qui est multiplie par 5 pour amplifier les valeurs
    audioSprectrum [i] = fft.getBand (bandIndex) * 5;
  }

  // xMove est un mappage de la valeur de la fréquence a partir de 0 jusqu'à un deplacement horizontal x
  float xMove = map (audioSprectrum [0], 0, 255, 140, 255);
  
  // zMove est un mappage de la valeur de la fréquence a partir de 20 jusqu'à un deplacement vertical z
  float zMove = map (audioSprectrum [20], 0, 255, 1, 150);

  // Parcourt tous les points de la forme mandelPoints pour les afficher en 3D
  for (MandelPoint mandelPoint : mandelPoints) {

    // Modifie la couleur du point en fonction de l'iteration a laquelle il a ete calcule
    stroke (map (mandelPoint.i, 0, maximumIterations, 255, 185), xMove, mandelPoint.brightness);

    // Modifie l'epaisseur de la ligne en fonction de la fréquence 20 de la variable zMove
    strokeWeight (zMove);

    // Affiche le point en 3D
    point (mandelPoint.pVectorVelocity.x, mandelPoint.pVectorVelocity.y, mandelPoint.pVectorVelocity.z);
  }
   
   // Arrete la transformation de la matrice
   popMatrix ();
   
   // RotationCamera est egale a 0.01, pour simuler une caméra qui tourne lentement en hauteur
   rotationCamera += 0.01;
   
   // S'il n'y a pas de zoomCamera
   if (! zoomCamera) {
     
     // distance diminue
     distance --;
     
     // Si la distance est inferieur ou egale a 400
     if (distance <= 400) { 
     
       // Active le zoomCamera
       zoomCamera = true; 
     }
     
   // Sinon la distance augmente
   } else {
     
     // distance augmente
     distance++;
     
     // Si la distance est superieur ou egale a 900
     if (distance >= 900) { 
     
       // Arrete le zoom
       zoomCamera = false; 
     }
   }
}
