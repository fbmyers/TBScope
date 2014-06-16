#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
//#include <Servo.h> 

//#include <Arduino.h>
 

#define X_STEP_PIN    6
#define X_DIR_PIN    4
#define X_EN_PIN    2
#define Y_STEP_PIN    7
#define Y_DIR_PIN    5
#define Y_EN_PIN    3
#define Z_STEP_PIN    10
#define Z_DIR_PIN    11
#define Z_EN_PIN    12
#define FL_LED_PIN 0
#define BF_LED_PIN 1
#define X_LIMIT_PIN A0
#define Y_LIMIT_PIN A1

//Servo myservo;

void setup()
{
  Serial.begin(57600);
  Serial.println("TB Scope Firmware 2014-1-2");
   
  pinMode(X_STEP_PIN, OUTPUT);
  pinMode(X_DIR_PIN, OUTPUT);
  pinMode(X_EN_PIN, OUTPUT);
  pinMode(Y_STEP_PIN, OUTPUT);
  pinMode(Y_DIR_PIN, OUTPUT);
  pinMode(Y_EN_PIN, OUTPUT);
  pinMode(Z_STEP_PIN, OUTPUT);
  pinMode(Z_DIR_PIN, OUTPUT);
  pinMode(Z_EN_PIN, OUTPUT);
  pinMode(FL_LED_PIN, OUTPUT);
  pinMode(BF_LED_PIN, OUTPUT);
  pinMode(X_LIMIT_PIN, INPUT);
  pinMode(Y_LIMIT_PIN, INPUT);
  
  digitalWrite(X_STEP_PIN, HIGH); 
  digitalWrite(Y_STEP_PIN, HIGH);   
  digitalWrite(Z_STEP_PIN, HIGH);
  digitalWrite(X_DIR_PIN, HIGH); 
  digitalWrite(Y_DIR_PIN, HIGH); 
  digitalWrite(Z_DIR_PIN, HIGH); 
  digitalWrite(X_EN_PIN, HIGH);   
  digitalWrite(Y_EN_PIN, HIGH);   
  digitalWrite(Z_EN_PIN, HIGH);   

  digitalWrite(FL_LED_PIN, HIGH);   
  digitalWrite(BF_LED_PIN, HIGH);   

  ble_begin();
  
}

void loop()
{
  static boolean analog_enabled = false;
  static byte old_state = LOW;
  
  // If data is ready
  while(ble_available())
  {
    // read out command and data
    byte data0 = ble_read(); //command
    byte data1 = ble_read(); //arg 1
    byte data2 = ble_read(); //arg 2
    
    //Serial.print(data0,HEX);
    //Serial.print(' ');
    //Serial.print(data1,HEX);
    //Serial.print(' ');
    //Serial.println(data2,HEX);
    
    char axis_pin;


    if (data0 == 0x01)
    {
      //step
      //data1: axis (0x01=X, 0x02=Y, 0x03=Z)
      //data2: # steps
      //each step is 1 ms
    
      if (data1==0x01)
        axis_pin = X_STEP_PIN;
      else if (data1==0x02)
        axis_pin = Y_STEP_PIN;
      else if (data1==0x03)
        axis_pin = Z_STEP_PIN;
      
      int i=0;
      while (i<data2)
      {
        digitalWrite(axis_pin, HIGH);
        delayMicroseconds(500);
        digitalWrite(axis_pin, LOW);
        delayMicroseconds(500);
        i=i+1;
       }
    }
    else if (data0 == 0x02)
    {
      //set direction
      //data1: axis
      //data2: direction (0x00 or 0x01)
    
      if (data1==0x01)
        axis_pin = X_DIR_PIN;
      else if (data1==0x02)
        axis_pin = Y_DIR_PIN;
      else if (data1==0x03)
        axis_pin = Z_DIR_PIN;
        
      if (data2==0x00)
        digitalWrite(axis_pin,LOW);
      else if (data2==0x01)
        digitalWrite(axis_pin,HIGH);   
    }
    else if (data0 == 0x03)
    {
      //enable motor
      //data1: axis
      //data2: enable (0x00==OFF, 0x01==ON)
      
      if (data1==0x01)
        axis_pin = X_EN_PIN;
      else if (data1==0x02)
        axis_pin = Y_EN_PIN;
      else if (data1==0x03)
        axis_pin = Z_EN_PIN;
        
      if (data2==0x00)
        digitalWrite(axis_pin,HIGH);
      else if (data2==0x01)
        digitalWrite(axis_pin,LOW);   
    }
    else if (data0 == 0x04)
    {
      //led on/off
      //data1: which LED (0x01=FL, 0x02=BF)
      //data2: enable (0x00==OFF, 0x01==ON)
      
      if (data1==0x01)
        axis_pin = FL_LED_PIN;
      else if (data1==0x02)
        axis_pin = BF_LED_PIN;
        
      if (data2==0x00)
        digitalWrite(axis_pin,HIGH);
      else if (data2==0x01)
        digitalWrite(axis_pin,LOW);   
    }    
  }
  
  if (!ble_connected())
  {
  }
  // Allow BLE Shield to send/receive data
  ble_do_events();  

}


