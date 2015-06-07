//this is firmware for the revised custom TB scope board

#include <SPI.h>
#include <Wire.h> //required for temp/humidity sensor

//BLE mini sheild
#include <ble_mini.h>

//if you're using the big BLE shield
#include <boards.h>
#include <RBL_nRF8001.h>

//steppers
#define MICROSTEP1 34
#define MICROSTEP2 35
#define MICROSTEP3 36
#define STP1_STEP_PIN 22
#define STP1_DIR_PIN 23
#define STP1_EN_PIN 24
#define STP2_STEP_PIN 25
#define STP2_DIR_PIN 26
#define STP2_EN_PIN 27
#define STP3_STEP_PIN 28
#define STP3_DIR_PIN 29
#define STP3_EN_PIN 30
#define STP4_STEP_PIN 31
#define STP4_DIR_PIN 32
#define STP4_EN_PIN 33

//limit switches
#define LIM1_PIN A8
#define LIM2_PIN A9
#define LIM3_PIN A10
#define LIM4_PIN A11
#define LIM5_PIN A12
#define LIM6_PIN A13

//front panel indicator
#define IND1_PIN 40
#define IND2_PIN 41
#define IND3_PIN 42

//led drivers
#define LED1_PWM 44
#define LED1_EN 47
#define LED2_PWM 45
#define LED2_EN 48
#define LED3_PWM 46
#define LED3_EN 49

//accessories
#define ACC1_PWR_EN 37
#define ACC2_PWR_EN 38
#define ACC3_PWR_EN 39

//ble
#define BLE_RESET A2

#define KILL_PIN 43

#define BATT_PIN A14

static char device_name[11] = "TB Scope";


unsigned int half_step_interval = 2000; //micros

void test_stepper()
{
   digitalWrite(MICROSTEP1,LOW);
   digitalWrite(MICROSTEP2,HIGH);
   digitalWrite(MICROSTEP3,HIGH);
   
   digitalWrite(STP1_EN_PIN,LOW); //motor on
   //step one direction
   Serial.println("Testing Stepper 1 (forward)...");   
   digitalWrite(STP1_DIR_PIN,LOW);
   for (int i=0;i<500;i++) 
   {
      digitalWrite(STP1_STEP_PIN, HIGH);
      delayMicroseconds(half_step_interval);
      digitalWrite(STP1_STEP_PIN, LOW);
      delayMicroseconds(half_step_interval);
   }

   //step other direction
   Serial.println("Testing Stepper 1 (backward)...");
   digitalWrite(STP1_DIR_PIN,HIGH);
   for (int i=0;i<500;i++) 
   {
      digitalWrite(STP1_STEP_PIN, HIGH);
      delayMicroseconds(half_step_interval);
      digitalWrite(STP1_STEP_PIN, LOW);
      delayMicroseconds(half_step_interval);
   }
   digitalWrite(STP1_EN_PIN,HIGH); //motor off
   
   digitalWrite(STP2_EN_PIN,LOW); //motor on
   
   //step one direction
   Serial.println("Testing Stepper 2 (forward)...");   
   digitalWrite(STP2_DIR_PIN,LOW);
   for (int i=0;i<500;i++) 
   {
      digitalWrite(STP2_STEP_PIN, HIGH);
      delayMicroseconds(half_step_interval);
      digitalWrite(STP2_STEP_PIN, LOW);
      delayMicroseconds(half_step_interval);
   }

   //step other direction
   Serial.println("Testing Stepper 2 (backward)...");
   digitalWrite(STP2_DIR_PIN,HIGH);
   for (int i=0;i<500;i++) 
   {
      digitalWrite(STP2_STEP_PIN, HIGH);
      delayMicroseconds(half_step_interval);
      digitalWrite(STP2_STEP_PIN, LOW);
      delayMicroseconds(half_step_interval);
   }
   
   digitalWrite(STP2_EN_PIN,HIGH); //motor off

   digitalWrite(STP3_EN_PIN,LOW); //motor on
   
   //step one direction
   Serial.println("Testing Stepper 3 (forward)...");   
   digitalWrite(STP3_DIR_PIN,LOW);
   for (int i=0;i<500;i++) 
   {
      digitalWrite(STP3_STEP_PIN, HIGH);
      delayMicroseconds(half_step_interval);
      digitalWrite(STP3_STEP_PIN, LOW);
      delayMicroseconds(half_step_interval);
   }

   //step other direction
   Serial.println("Testing Stepper 3 (backward)...");
   digitalWrite(STP3_DIR_PIN,HIGH);
   for (int i=0;i<500;i++) 
   {
      digitalWrite(STP3_STEP_PIN, HIGH);
      delayMicroseconds(half_step_interval);
      digitalWrite(STP3_STEP_PIN, LOW);
      delayMicroseconds(half_step_interval);
   }
   
   digitalWrite(STP3_EN_PIN,HIGH); //motor off   
}

void test_led()
{
  //LED1
  Serial.println("Testing LED1 (brightness values 1-10)...");
  digitalWrite(LED1_EN, HIGH); 
  for (int i=1;i<=10;i++)
  {
    analogWrite(LED1_PWM, i);
    delay(500);
  }
  digitalWrite(LED1_EN, LOW); 
    
  //LED2
  Serial.println("Testing LED2 (brightness values 1-10)...");
  digitalWrite(LED2_EN, HIGH); 
  for (int i=1;i<=10;i++)
  {
    analogWrite(LED2_PWM, i);
    delay(500);
  }
  digitalWrite(LED2_EN, LOW); 


  //LED3
  Serial.println("Testing LED3 (brightness values 1-10)...");
  digitalWrite(LED3_EN, HIGH); 
  for (int i=1;i<=10;i++)
  {
    analogWrite(LED3_PWM, i);
    delay(500);
  }
  digitalWrite(LED3_EN, LOW);   
}

void test_indicators()
{
  Serial.println("Testing Indicator 1...");
  digitalWrite(IND1_PIN, LOW);
  digitalWrite(IND2_PIN, HIGH);
  digitalWrite(IND3_PIN, HIGH);
  delay(2000);
  
  Serial.println("Testing Indicator 2...");
  digitalWrite(IND1_PIN, HIGH);
  digitalWrite(IND2_PIN, LOW);
  digitalWrite(IND3_PIN, HIGH);
  delay(2000);
  
  Serial.println("Testing Indicator 3...");
  digitalWrite(IND1_PIN, HIGH);
  digitalWrite(IND2_PIN, HIGH);
  digitalWrite(IND3_PIN, LOW);
  delay(2000);
  
}

void test_peripherals()
{
  Serial.println("Testing Peripheral 1 Power...");
  digitalWrite(ACC1_PWR_EN, LOW);
  digitalWrite(ACC2_PWR_EN, HIGH);
  digitalWrite(ACC3_PWR_EN, HIGH);
  delay(2000);
  
  Serial.println("Testing Peripheral 2 Power...");
  digitalWrite(ACC1_PWR_EN, HIGH);
  digitalWrite(ACC2_PWR_EN, LOW);
  digitalWrite(ACC3_PWR_EN, HIGH);
  delay(2000);
  
  Serial.println("Testing Peripheral 3 Power)...");
  digitalWrite(ACC1_PWR_EN, HIGH);
  digitalWrite(ACC2_PWR_EN, HIGH); 
  digitalWrite(ACC3_PWR_EN, LOW);
  delay(2000);  
}

void test_limits()
{

  
  Serial.println("Testing Limit Switches (10 seconds)...");
  for (int i=0;i<10;i++)
  {
    int lim1 = analogRead(LIM1_PIN);
    int lim2 = analogRead(LIM2_PIN);
    int lim3 = analogRead(LIM3_PIN);
    int lim4 = analogRead(LIM4_PIN);
    int lim5 = analogRead(LIM5_PIN);
    int lim6 = analogRead(LIM6_PIN);  
    Serial.print(lim1);
    Serial.print(' ');
    Serial.print(lim2);
    Serial.print(' ');
    Serial.print(lim3);
    Serial.print(' ');
    Serial.print(lim4);
    Serial.print(' ');
    Serial.print(lim5);
    Serial.print(' ');
    Serial.print(lim6);
    Serial.print(' ');
    Serial.println();
    
    delay(1000);
  }
  
}

void test_kill()
{
  Serial.println("Testing Kill (unit should now turn off)...");
  delay(1000);
  digitalWrite(KILL_PIN,HIGH);  
}


void test_ble_mini()
{
  Serial.println("Testing BLE Tx...");
  BLEMini_write(0xF0);
  BLEMini_write(0xF1);
  BLEMini_write(0xF2);
  delay(1000);
  
  Serial.println("Testing BLE Rx...");
  while (BLEMini_available()) {
    
    unsigned char in = BLEMini_read();
    Serial.print(in,HEX);
    Serial.print(' ');
  }  
  Serial.println();
}


void test_ble_big()
{
  Serial.println("Testing BLE Tx (ensure that device 'TB Scope' appears in device list)...");
  
  Serial.println("Testing BLE Rx...");
  while(ble_available())
  {  
      byte data = ble_read(); 
      Serial.print(data,HEX);
      Serial.print(' ');
  }
  Serial.println();

  ble_do_events();
  
}

void test_temp_sensor()
{
   byte _status;
   unsigned int H_dat, T_dat;
   float RH, T_C;  
  
   Serial.println("Testing Temp/Humidity Sensor...");

    _status = fetch_humidity_temperature(&H_dat, &T_dat);
    
    switch(_status)
    {
        case 0:  Serial.println("Normal.");
                 break;
        case 1:  Serial.println("Stale Data.");
                 break;
        case 2:  Serial.println("In command mode.");
                 break;
        default: Serial.println("Diagnostic."); 
                 break; 
    }       
    
    RH = (float) H_dat * 6.10e-3;
    T_C = (float) T_dat * 1.007e-2 - 40.0;
    
    print_float(RH, 1);
    Serial.print("%  ");
    print_float(T_C, 2);
    Serial.print("C");
    Serial.println();
    delay(1000);
}


byte fetch_humidity_temperature(unsigned int *p_H_dat, unsigned int *p_T_dat)
{
      byte address, Hum_H, Hum_L, Temp_H, Temp_L, _status;
      unsigned int H_dat, T_dat;
      address = 0x27;
      Wire.beginTransmission(address); 
      Wire.endTransmission();
      delay(100);
      
      Wire.requestFrom((int)address, (int) 4);
      Hum_H = Wire.read();
      Hum_L = Wire.read();
      Temp_H = Wire.read();
      Temp_L = Wire.read();
      Wire.endTransmission();
      
      _status = (Hum_H >> 6) & 0x03;
      Hum_H = Hum_H & 0x3f;
      H_dat = (((unsigned int)Hum_H) << 8) | Hum_L;
      T_dat = (((unsigned int)Temp_H) << 8) | Temp_L;
      T_dat = T_dat / 4;
      *p_H_dat = H_dat;
      *p_T_dat = T_dat;
      return(_status);
}
   
void print_float(float f, int num_digits)
{
    int f_int;
    int pows_of_ten[4] = {1, 10, 100, 1000};
    int multiplier, whole, fract, d, n;

    multiplier = pows_of_ten[num_digits];
    if (f < 0.0)
    {
        f = -f;
        Serial.print("-");
    }
    whole = (int) f;
    fract = (int) (multiplier * (f - (float)whole));

    Serial.print(whole);
    Serial.print(".");

    for (n=num_digits-1; n>=0; n--) // print each digit with no leading zero suppression
    {
         d = fract / pows_of_ten[n];
         Serial.print(d);
         fract = fract % pows_of_ten[n];
    }
}      

void setup()
{
  Wire.begin();        // join i2c bus for temp/humidity sensor

  Serial.begin(57600); //setup terminal output
  Serial.println("TB Scope Test Routine");
  
  pinMode(MICROSTEP1, OUTPUT);
  pinMode(MICROSTEP2, OUTPUT);
  pinMode(MICROSTEP3, OUTPUT);
  pinMode(STP1_STEP_PIN, OUTPUT);
  pinMode(STP1_DIR_PIN, OUTPUT);
  pinMode(STP1_EN_PIN, OUTPUT);
  pinMode(STP2_STEP_PIN, OUTPUT);
  pinMode(STP2_DIR_PIN, OUTPUT);
  pinMode(STP2_EN_PIN, OUTPUT);
  pinMode(STP3_STEP_PIN, OUTPUT);
  pinMode(STP3_DIR_PIN, OUTPUT);
  pinMode(STP3_EN_PIN, OUTPUT);
  pinMode(STP4_STEP_PIN, OUTPUT);
  pinMode(STP4_DIR_PIN, OUTPUT);
  pinMode(STP4_EN_PIN, OUTPUT);
  /*
  pinMode(LIM1_PIN, INPUT);
  pinMode(LIM2_PIN, INPUT);
  pinMode(LIM3_PIN, INPUT);
  pinMode(LIM4_PIN, INPUT);
  pinMode(LIM5_PIN, INPUT);
  pinMode(LIM6_PIN, INPUT);
  */
  pinMode(LED1_EN, OUTPUT);
  pinMode(LED1_PWM, OUTPUT);
  pinMode(LED2_EN, OUTPUT);
  pinMode(LED2_PWM, OUTPUT);
  pinMode(LED3_EN, OUTPUT);
  pinMode(LED3_PWM, OUTPUT);
  
  pinMode(IND1_PIN, OUTPUT);
  pinMode(IND2_PIN, OUTPUT);
  pinMode(IND3_PIN, OUTPUT);
  
  pinMode(ACC1_PWR_EN, OUTPUT);
  pinMode(ACC2_PWR_EN, OUTPUT);
  pinMode(ACC3_PWR_EN, OUTPUT);
  
  pinMode(KILL_PIN, OUTPUT);
  
  pinMode(BATT_PIN, INPUT);
  
  digitalWrite(STP1_STEP_PIN, HIGH); 
  digitalWrite(STP1_DIR_PIN, HIGH); 
  digitalWrite(STP1_EN_PIN, HIGH);
  digitalWrite(STP2_STEP_PIN, HIGH); 
  digitalWrite(STP2_DIR_PIN, HIGH); 
  digitalWrite(STP2_EN_PIN, HIGH);
  digitalWrite(STP3_STEP_PIN, HIGH); 
  digitalWrite(STP3_DIR_PIN, HIGH); 
  digitalWrite(STP3_EN_PIN, HIGH);
  digitalWrite(STP4_STEP_PIN, HIGH); 
  digitalWrite(STP4_DIR_PIN, HIGH); 
  digitalWrite(STP4_EN_PIN, HIGH);

  digitalWrite(IND1_PIN, LOW);
  digitalWrite(IND2_PIN, LOW);
  digitalWrite(IND3_PIN, LOW);
  
  digitalWrite(KILL_PIN, LOW);
  
  digitalWrite(ACC1_PWR_EN, HIGH);
  digitalWrite(ACC2_PWR_EN, HIGH);
  digitalWrite(ACC3_PWR_EN, HIGH);
  
  digitalWrite(LED1_EN, LOW);
  digitalWrite(LED2_EN, LOW);
  digitalWrite(LED3_EN, LOW);
  analogWrite(LED1_PWM, 0);
  analogWrite(LED2_PWM, 0);
  analogWrite(LED3_PWM, 0);
  
  //BLE big board
  ble_set_name(device_name);

  ble_begin();
  
  //BLE small board
  //BLEMini_begin(57600);
}

void loop()
{
  
  test_stepper();
  
  test_led();
  
  test_indicators();
  
  test_limits();
  
  test_peripherals();
  
  test_temp_sensor();
  
  test_kill();
  
  
  //test_ble_mini();
  
  test_ble_big(); 
  
  
  delay(1000);
}





