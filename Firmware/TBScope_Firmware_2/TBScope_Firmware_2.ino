
#include <SPI.h>
#include <boards.h>
#include <Nordic_nRF8001.h>
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
#define Z_STEP_PIN    12
#define Z_DIR_PIN    0
#define Z_EN_PIN    1
#define FL_LED_PIN 10
#define BF_LED_PIN 11
#define X_LIMIT_PIN A1
#define Y_LIMIT_PIN A0
#define Z_LIMIT_PIN A2
#define BLE_INDICATOR_PIN 13

#define X_HOME_DIR 1
#define Y_HOME_DIR 0
#define Z_HOME_DIR 0

#define POSITION_LIMIT 0
#define POSITION_TEST_TARGET 1
#define POSITION_SLIDE_CENTER 2
#define POSITION_LOADING 3

//all coordinates are relative to limit switches
#define TEST_TARGET_X 3310
#define TEST_TARGET_Y 3020
#define TEST_TARGET_Z 15900
#define SLIDE_CENTER_X 800
#define SLIDE_CENTER_Y 4000
#define SLIDE_CENTER_Z 21900
#define LOADING_X 2000
#define LOADING_Y 10000
#define LOADING_Z 0

#define BLE_BLINK_FREQ 1
#define TIMEOUT_DURATION 20000

//top 3 bits = opcode
#define CMD_MOVE 1
#define CMD_SET_SPEED 2
#define CMD_SPECIAL_POSITION 3
#define CMD_SET_LIGHT 4

//Servo myservo;

static char device_name[11] = "TB Scope";



unsigned int half_step_interval = 500; //micros

unsigned int move_stage(byte axis, byte dir, unsigned int half_step_interval, boolean stop_on_home, boolean disable_after, unsigned int num_steps)
{
  Serial.print(axis,DEC); Serial.print(' '); Serial.print(dir,DEC); Serial.print(' '); Serial.print(half_step_interval,DEC); Serial.print(' '); Serial.print(stop_on_home,DEC); Serial.print(' '); Serial.print(disable_after,DEC); Serial.print(' '); Serial.println(num_steps,DEC);
  
  byte step_pin; byte dir_pin; byte en_pin; byte limit_switch_pin; byte home_dir;

  //get pins for this axis
  switch (axis) {
    case 0x1: //x
      step_pin = X_STEP_PIN;
      dir_pin = X_DIR_PIN;
      en_pin = X_EN_PIN;
      limit_switch_pin = X_LIMIT_PIN;
      home_dir = X_HOME_DIR;
      break;
    case 0x2: //y
      step_pin = Y_STEP_PIN;
      dir_pin = Y_DIR_PIN;
      en_pin = Y_EN_PIN;
      limit_switch_pin = Y_LIMIT_PIN;
      home_dir = Y_HOME_DIR;      
      break;
    case 0x3: //z
      step_pin = Z_STEP_PIN;
      dir_pin = Z_DIR_PIN;
      en_pin = Z_EN_PIN;
      limit_switch_pin = Z_LIMIT_PIN;
      home_dir = Z_HOME_DIR;      
      break;
  }

  //set direction
  if (dir==0) 
    digitalWrite(dir_pin,LOW);
  else if (dir==1)
    digitalWrite(dir_pin,HIGH);
  
  //turn on motor
  if (num_steps>0)
    digitalWrite(en_pin,LOW);
  
  //do stepping
  unsigned int i;
  for (i=0;i<num_steps;i++)
  {
    if (stop_on_home && dir==home_dir)
      if (digitalRead(limit_switch_pin)==0)
        break;
        
    //step    
    digitalWrite(step_pin, HIGH);
    delayMicroseconds(half_step_interval);
    digitalWrite(step_pin, LOW);
    delayMicroseconds(half_step_interval);
   }  

   if (disable_after)
     digitalWrite(en_pin,HIGH);

   //send response
   notify();
   
   return i;
}

void enable_motor(byte axis, boolean enabled) {
  byte en_pin;
  switch (axis) {
    case 0x1: //x
      en_pin = X_EN_PIN;
      break;
    case 0x2: //y
      en_pin = Y_EN_PIN;
      break;
    case 0x3: //z
      en_pin = Z_EN_PIN;
      break;
  } 
  
  if (enabled)
    digitalWrite(en_pin,LOW);
  else
    digitalWrite(en_pin,HIGH);
}

void goto_special_position(byte position) {

  switch (position) {
    case POSITION_LIMIT:
    {
      //move_stage(3,1,100,1,1,200); //backup in Z
      //while (move_stage(3,0,100,1,1,20000)==20000); 
      
      unsigned long timeout_millis = millis() + TIMEOUT_DURATION;
      move_stage(2,1,100,1,1,200); //backup in Y
      while ((move_stage(2,0,100,1,1,10000)==10000)) //move Y, and continue until it hits limit (if the tray is out/unmeshed to gear, it will keep spinning)
      {
        if (millis()>timeout_millis)
          return;
      }
      
      move_stage(1,0,100,1,1,200); //backup in X
      
      while ((move_stage(1,1,100,1,1,10000)==10000)) //move X till limit
      {
        if (millis()>timeout_millis)
          return;
      }
      
      break;    
    }
    case POSITION_TEST_TARGET:
      goto_special_position(POSITION_LIMIT);
      move_stage(2,1,100,1,1,TEST_TARGET_Y);
      move_stage(1,0,100,1,1,TEST_TARGET_X);
      //move_stage(3,1,100,1,1,TEST_TARGET_Z);
      break;
      
    case POSITION_SLIDE_CENTER:
      goto_special_position(POSITION_LIMIT);
      move_stage(2,1,100,1,1,SLIDE_CENTER_Y);
      move_stage(1,0,100,1,1,SLIDE_CENTER_X);  
      //move_stage(3,1,100,1,1,SLIDE_CENTER_Z);  
      break;
    case POSITION_LOADING:
      goto_special_position(POSITION_LIMIT);
      move_stage(1,0,100,1,1,LOADING_X);        
      move_stage(2,1,100,1,1,LOADING_Y);
      break;
  }  
  
  notify();
}

void notify()
{
  byte buf[3] = {0xFF, 0x00, 0x00};
  if (digitalRead(X_LIMIT_PIN)==0)
    buf[1] |= 0b00000100;
  if (digitalRead(Y_LIMIT_PIN)==0)
    buf[1] |= 0b00000010;    
  if (digitalRead(Z_LIMIT_PIN)==0)
    buf[1] |= 0b00000001;        
    
  ble_write_bytes(buf,3);
}

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
  pinMode(X_LIMIT_PIN, INPUT);
  pinMode(Y_LIMIT_PIN, INPUT);
  pinMode(Z_LIMIT_PIN, INPUT_PULLUP);
  
  pinMode(BLE_INDICATOR_PIN, OUTPUT);
  
  digitalWrite(X_STEP_PIN, HIGH); 
  digitalWrite(Y_STEP_PIN, HIGH);   
  digitalWrite(Z_STEP_PIN, HIGH);
  digitalWrite(X_DIR_PIN, HIGH); 
  digitalWrite(Y_DIR_PIN, HIGH); 
  digitalWrite(Z_DIR_PIN, HIGH); 
  digitalWrite(X_EN_PIN, HIGH);   
  digitalWrite(Y_EN_PIN, HIGH);   
  digitalWrite(Z_EN_PIN, HIGH);   
  digitalWrite(BLE_INDICATOR_PIN, LOW);
  
  analogWrite(FL_LED_PIN, 0xFF);   
  analogWrite(BF_LED_PIN, 0xFF);   

  ble_begin();
  
  ble_set_name(device_name);
  
  //goto_special_position(POSITION_LOADING);
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
    
    byte cmd = (data0 & B11100000) >> 5;
    
    Serial.print(data0,HEX);
    Serial.print(' ');
    Serial.print(data1,HEX);
    Serial.print(' ');
    Serial.println(data2,HEX);
    
    byte axis;
    byte dir;
    boolean stop_on_home;
    boolean disable_after;
    unsigned int num_steps;
    
    switch (cmd) {
      case CMD_MOVE:
        axis = (data0 & B00011000) >> 3;
        dir =  (data0 & B00000100) >> 2;
        stop_on_home = (data0 & B00000010) >> 1;
        disable_after = (data0 & B00000001);
        num_steps = (data1 << 8) | data2;
        
        move_stage(axis,dir,half_step_interval,stop_on_home,disable_after,num_steps);
        notify();
        
        break;
      case CMD_SET_SPEED:
        half_step_interval = (data1 << 8) | data2;
        
        break;
        
      case CMD_SPECIAL_POSITION:
        goto_special_position(data1);
        break;
        
      case CMD_SET_LIGHT:
        if (data1==0x01)
          analogWrite(FL_LED_PIN,0xFF-data2); 
        else if (data1==0x02)
          analogWrite(BF_LED_PIN,0xFF-data2); 
        break;
    }
  }  
    
  if (ble_connected())
  {
    digitalWrite(BLE_INDICATOR_PIN,LOW); //old FLAMB is active highb
  }
  else
  {
    if (sin(2*3.14159*BLE_BLINK_FREQ*millis()/1000.0)>0)
     digitalWrite(BLE_INDICATOR_PIN,HIGH);
    else
     digitalWrite(BLE_INDICATOR_PIN,LOW); 
  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();  

}


