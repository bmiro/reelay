/*******************************************************************************
 *                       Taller de robòtica 2011
 *                  Universitat de les Illes Balears
 *
 *                        11-15 d'Abril de 2011
 *                    Taller-concurs robot de sumo     
 *    
 *            Bartomeu Canyelles Escarrer { bce892 a gmail punt com }
 *            Bartomeu Miró Mateu { bartomeumiro a gmail punt com }
 *           Marcos Rullan de Vargas { marcosrullan a gmail punt com }
 *
 ******************************************************************************/ 

#include <Servo.h>

/******************************* Connectivity *******************************/ 
#define PIN_FLS     A0   // Front Line Sensor
#define PIN_BLS     A1   // Back Line Sensor
#define PIN_EYE     A2   // Senor ull
#define PIN_SERVO_R  10  // Pin del servo dret
#define PIN_SERVO_L  11  // Pin del servo esquerre
/******************************************************************************/

/******************************** Envirorment *********************************/ 
#define EYE_TH      200  // Atack threshold
#define LS_TH       200  // Llintar per distingir blanc de negre, m < 200 -> blanc
#define RING_RADIUS 45   // Radi del ring en centímetres
/******************************************************************************/

/********************************** Movment **********************************/ 
#define SERVO_STOP          90   // Angle perque el servo aturi
#define LEFT_SERVO_FRWRD    180  
#define RIGHT_SERVO_FRWRD   0
#define LEFT_SERVO_BCKWRD   0
#define RIGHT_SERVO_BCKWRD  180

#define T_TWIST_45   250   // Temps en girar sobre si mateix 45 graus en ms
#define T_MOV_1CM    250   // Temps en avançar 1 cm en ms
#define T_ARCH_45    500   // Temps rotacio 45º sobre una de les rodes en ms
#define CLOCKWISE    1
#define COUNTERWISE  2
#define RIGHT        4
#define LEFT         8
/**** Externs ****/
#define DEGREE_90    2  // Per fer girs de 180 graus
#define DEGREE_180   4  // Per fer girs de 180 graus
#define DEGREE_270   6  // Per fer girs de 180 graus
/******************************************************************************/

#define FISH_MEMORY 3

#define SINCE_CHANGE 0
#define CENTER       0x2

/********************************** Var Glob **********************************/ 
char feelings;
char memories[FISH_MEMORY]; //memoria de peix, 0 el record més proper

Servo servoL, servoR;
/******************************************************************************/

void refreshMemories() {
  if (memories[0] != feelings) { 
    for (int i = 1; i < FISH_MEMORY; i++) {
      memories[i] = memories[i-1];
    }
    memories[0] = feelings;
  }
} 

char suspiciousDelay(int ms) {
  /* Fa el delay a no ser que hi hagi canvis en els sensors, així ens estalviam
   * haver de programar interrupcions i problemes de control de flux. */
  for (int i = ms; i; i--) {
    delay(1);
    if (feelings != getSenses()) {
      return 0;
    }
  }
}

char getSenses() {
  int rawFls = 0;           // Variables on guardarem els valors de mesura
  int rawBls = 0;           // dels sensors de linia 1 i 2
  int rawEye = 0;          // Variables on guardarem els valors de mesura del sensor d'atac

  char fls, bls, eye;
  
  rawFls = analogRead(PIN_FLS);
  rawBls = analogRead(PIN_BLS);
  rawEye = analogRead(PIN_EYE);
  fls = (rawFls > LS_TH) ? 1 : 0; // 1 quan detecta blanc que simbolitza la alerta
  bls = (rawBls > LS_TH) ? 1 : 0;
  eye = (rawEye > EYE_TH) ? 1 : 0; // 1 quan detecta presència
  
  Serial.println(rawEye);
  
  return eye << 2 + fls << 1 + bls;
}

/************************ Capa abstracció dels servos ************************/
void forward(int d) {
  /* Avança d centímetres, si es passa 0 avança fins a canvi en els sensors */
  servoR.write(RIGHT_SERVO_FRWRD);
  servoL.write(LEFT_SERVO_FRWRD);
  if (d != SINCE_CHANGE) {
     suspiciousDelay(T_MOV_1CM * d);
  }
}

void backward(int d) {
  /* Retrocedeix d centímetres, si es passa 0 avança fins a canvi en els sensors */
  servoR.write(RIGHT_SERVO_BCKWRD);
  servoL.write(LEFT_SERVO_BCKWRD);
  if (d != SINCE_CHANGE) {
     suspiciousDelay(T_MOV_1CM * d);
     servoR.write(SERVO_STOP);
     servoL.write(SERVO_STOP);
  }
}

void arch(int units, char wise, char side) {
  /* Rotació de units * 45 º sobre una de les rodes, el robot fa un arc */
  switch (wise | side) {
  case RIGHT | CLOCKWISE:
    servoR.write(SERVO_STOP);
    servoL.write(LEFT_SERVO_FRWRD);
    break;
  case LEFT | CLOCKWISE:
    servoR.write(RIGHT_SERVO_FRWRD);
    servoL.write(SERVO_STOP);
    break;
  case RIGHT | COUNTERWISE:
    servoR.write(SERVO_STOP);
    servoL.write(LEFT_SERVO_BCKWRD);
    break;
  case LEFT | COUNTERWISE:
    servoR.write(RIGHT_SERVO_BCKWRD);
    servoL.write(SERVO_STOP);
    break;
  }
  if (units != SINCE_CHANGE) {
     suspiciousDelay(T_ARCH_45 * units);
     servoR.write(SERVO_STOP);
     servoL.write(SERVO_STOP);
  } 
}

void rotate(int a, char wise) {
  if (wise == CLOCKWISE) {
    servoR.write(RIGHT_SERVO_BCKWRD);
    servoL.write(LEFT_SERVO_FRWRD);
  } else {
    servoR.write(RIGHT_SERVO_FRWRD);
    servoL.write(LEFT_SERVO_BCKWRD);
  }
  if (a != SINCE_CHANGE) {
    suspiciousDelay(T_TWIST_45 * a);
    servoR.write(SERVO_STOP);
    servoL.write(SERVO_STOP);
  }
}
/******************************************************************************/

/********************************** Cos principal **********************************/ 

void setup() { 
  servoL.attach(PIN_SERVO_L);  // Vinculem els pins que hem configurat abans 
  servoR.attach(PIN_SERVO_R);
  Serial.begin(9600);
  delay(1000);  //Esperem 1segon 
}

void loop() { 
   
  // Escoltam els nostres sentits
  feelings = getSenses();
  switch (feelings) {
            //EFB
    case 0: //000
      /* No dectectam l'enemic ni la línia, hem de cercar */
      Serial.println("---");
      rotate(SINCE_CHANGE, CLOCKWISE);
      break;
    case 1: //001
      /* Detectarm al sensor de darrera, hem d'avançar */
      Serial.println("--B");
      forward(RING_RADIUS);
      break;
    case 2: //010
      /* Esteim de cap a l´abisme per voluntat propia, girar i partir */
      Serial.println("-F-");
      forward(5);
      rotate(DEGREE_180, CLOCKWISE);
      forward(RING_RADIUS - 5);
      break;
    case 3: //011
      Serial.println("-FB");
      /* Fer zig-zag per trobar negre i avançar, reguereix memoria*/
      break;
    case 4: //100
      /* Detectam l'oponent i cap linia, hem de atacar! */
      Serial.println("E--");
      forward(SINCE_CHANGE);
      break;
    case 5: //101
      /* Detectam l´enemic i linia blanca, ens empenyen a l´abisme
       * feim manobra d'esquivament, gir sobre una roda de 90 graus */
       arch(DEGREE_90, CLOCKWISE, LEFT); /* Els dos ultims parametres son arbitraris */
      break;
    case 6: //110
      Serial.println("EF-");
      /* Enemic i linia a davant, ell deu haver caigut i nosaltres encara no
       * suposadament haurem guanyat */
       backward(5);
       rotate(DEGREE_180, CLOCKWISE);
       forward(RING_RADIUS - 5);       
      break;
    case 7: //111
      Serial.println("EFB");
      /* WTF! atacam, per fer alguan cosa...*/
      forward(SINCE_CHANGE);
      break;
  }
  refreshMemories(); 
}

