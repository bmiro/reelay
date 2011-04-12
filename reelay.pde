/*
 *              Taller de robòtica 2011
 *          Universitat de les Illes Balears
 *
 *               11-15 d'Abril de 2011
 *            Taller-concurs robot de sumo     
 *
 *  Bartomeu Canyelles Escarrer { bce892 a gmail punt com }
 *  Bartomeu Miró Mateu { bartomeumiro a gmail punt com }
 *  Marcos Rullan de Vargas { marcosrullan a gmail punt com }
 *
 */ 

#include <Servo.h> 

#define PIN_FLS A0     // Front Line Sensor
#define PIN_BLS A1     // Back Line Sensor
#define WHITE  200     // Si el valor de lectura del sensor de linia és menor a BLANC estem sobre una linia blanca.
                       // Si és major, estem sobre sòl negre.
                       
#define PIN_EYE A5          // Hem connectat el sensor d'atac al pin A5.
#define ATACK_TH 150    //  Atack threshold

#define PIN_SERVO1  10  // Configurarem aquestes constants segons on haguem enxufat
#define PIN_SERVO2  11  // el cable blau dels servo motors 1 i 2.
#define FORWARD     180 // Constant per a que el servo avançi (en graus)
#define STOP        90  // Constant per a que el servo aturi  (en graus)
#define BACKWARD    0   // Constant per a que el servo retrocedeixi (en graus)
   
   
int sFls = 0;           // Variables on guardarem els valors de mesura
int sBls = 0;           // dels sensors de linia 1 i 2

int sAtack  = 0;        // Variables on guardarem els valors de mesura del sensor d'atac

Servo servoD;           // Cream les variables que ens deixaràn manipular els servos 1..
Servo servoE;           // .. i 2.

void setup() { 
   servoD.attach(PIN_SERVO1);  // Vinculem els pins que hem configurat abans 
   servoE.attach(PIN_SERVO2);  //   amb les variables de cada servo respectivament.
   
   delay(1000);  //Esperem 1segon 
}

void loop() { 
   
   // Llegim els sensors de linia:
   s_line1 = analogRead(PIN_S1);
   s_line2 = analogRead(PIN_S2);

   if(s_line1 > BLANC && s_line2 > BLANC){ //Si el terra sobre el que estem és NEGRE ::> Podem atacar
   
         // Llegim els sensor d'atac:
         s_atak = analogRead(PIN_ATAC);
         
         if(s_atak > MIN_ATAK){    //Si l'enemic és aprop
         
            myservo1.write(AVAN);//Feim que el servo1 avançi
            myservo2.write(AVAN);//Feim que el servo2 avançi
            
         }else{
         
         myservo1.write(STOP);//Feim que el servo1 aturi
         myservo2.write(STOP);//Feim que el servo2 aturi
         delay(1000);  //Esperem 1segon
         }
   
   }else{  //Si el terra al davant nostre és BLANC ::> Ens sortim de la pista!!
   
         myservo1.write(STOP);//Feim que el servo1 aturi
         myservo2.write(STOP);//Feim que el servo2 aturi
   }
   
   /*Repeteix el bucle*/  
}

