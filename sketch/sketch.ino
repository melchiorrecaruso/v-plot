//  vPlotter server for Arduino uno R3 board

//  Author:   Melchiorre Caruso
//  Date:     20 November 2019
//  Modified: 11 January  2020

//  Librerie utilizzate nel codice sorgente

#include <math.h>
#include <Servo.h>

// definizione PIN shield CNC V3

#define MOTOR_ONOFF_PIN   8

#define MOTOR_X_STEP_PIN  2
#define MOTOR_X_DIR_PIN   5
#define MOTOR_Y_STEP_PIN  3
#define MOTOR_Y_DIR_PIN   6
#define MOTOR_Z_PIN       11

// define serial protocol consts

#define GETXCOUNT         240
#define GETYCOUNT         241
#define GETZCOUNT         242
#define SETXCOUNT         230
#define SETYCOUNT         231
#define SETZCOUNT         232

// define ramp consts

#define RAMP_KB           40000
#define RAMP_KC           1
#define RAMP_MIN          1
#define RAMP_MAX          200

// define main variables

static byte Buffer[128];
static long BufferIndex;
static long BufferSize;
static unsigned long LoopStart;
static unsigned long LoopDelay;
static long RampIndex;
static long xCount;
static long yCount;
static long zCount;
static long zDelay;

Servo motorZ;

union {
  byte asbytes[4];
  long aslong;
} data;

// Motor xy & z routines

void ExecRamp(byte bt) {  
  if (bitRead(bt, 6) == 1) { RampIndex++; }
  if (bitRead(bt, 7) == 1) { RampIndex--; }
  RampIndex = max(RAMP_MIN, min(RAMP_MAX, RampIndex));
}

void ExecServo(byte bt) {
  long dz = bitRead(bt, 4);
  if (bitRead(bt, 5) == 1) { dz *= -1; }
 
  zCount += dz;
  if (dz != 0) {
    motorZ.write(zCount);
    delay(zDelay);
  }
}

void ExecStepper(byte bt) {
  long dx = bitRead(bt, 0);
  long dy = bitRead(bt, 2);
  if (bitRead(bt, 1) == 1) { dx *= -1; }
  if (bitRead(bt, 3) == 1) { dy *= -1; }

  xCount += dx;
  if (dx < 0) {
    digitalWrite(MOTOR_X_DIR_PIN, HIGH);
  } else {
    digitalWrite(MOTOR_X_DIR_PIN, LOW );
  }

  yCount += dy;
  if (dy < 0) {
    digitalWrite(MOTOR_Y_DIR_PIN, LOW );
  } else {
    digitalWrite(MOTOR_Y_DIR_PIN, HIGH);
  }

  if ((dx != 0) || (dy != 0)) {
    if (dx != 0) { digitalWrite(MOTOR_X_STEP_PIN, HIGH); }
    if (dy != 0) { digitalWrite(MOTOR_Y_STEP_PIN, HIGH); }
    delayMicroseconds(20);

    if (dx != 0) { digitalWrite(MOTOR_X_STEP_PIN, LOW ); }
    if (dy != 0) { digitalWrite(MOTOR_Y_STEP_PIN, LOW ); }
  }
}

void ExecInternal(byte bt) {
  switch (bt) {
    case SETXCOUNT:
      Serial.readBytes(data.asbytes, 4);
      Serial.write(SETXCOUNT);
      xCount = data.aslong;
      break;
    case SETYCOUNT:
      Serial.readBytes(data.asbytes, 4);
      Serial.write(SETYCOUNT);
      yCount = data.aslong;
      break;
    case SETZCOUNT:
      Serial.readBytes(data.asbytes, 4);
      Serial.write(SETZCOUNT);
      zCount = data.aslong;
      break; 
    case GETXCOUNT:
      data.aslong = xCount;
      Serial.write(GETXCOUNT);
      Serial.write(data.asbytes, 4);
      break;
    case GETYCOUNT:
      data.aslong = yCount;
      Serial.write(GETYCOUNT);
      Serial.write(data.asbytes, 4);
      break;
    case GETZCOUNT:
      data.aslong = zCount;
      Serial.write(GETZCOUNT);
      Serial.write(data.asbytes, 4);
      break;
    default:
      Serial.write(bt);
      break;      
  }
}

// Setup routine

void setup() {
  // init serial
  Serial.begin(115200);
  Serial.setTimeout(1000);
  // clear serial
  while (Serial.available() > 0) {
    Serial.read();
    delay(50);
  }  
  // init stepper X/Y
  pinMode(MOTOR_X_STEP_PIN, OUTPUT);
  pinMode(MOTOR_Y_STEP_PIN, OUTPUT);
  pinMode(MOTOR_X_DIR_PIN,  OUTPUT);
  pinMode(MOTOR_Y_DIR_PIN,  OUTPUT);
  pinMode(MOTOR_ONOFF_PIN,  OUTPUT);
  // enable steppers
  digitalWrite(MOTOR_ONOFF_PIN, LOW);  
  // init servo Z
  motorZ.attach(MOTOR_Z_PIN);
  // init variables
  BufferIndex = 0;
  BufferSize = 0;
  LoopStart = micros();
  LoopDelay = 400;
  RampIndex = RAMP_MIN;
  xCount = 0;
  yCount = 0;
  zCount = motorZ.read();
  zDelay = 5;  
}

// Main Loop

void loop() {
  if ((unsigned long)(micros() - LoopStart) >= LoopDelay) {
    LoopStart = micros();
    if (BufferIndex == BufferSize) {
      BufferIndex = 0;
      BufferSize = Serial.available();
      if (BufferSize > 0) {
        Serial.readBytes(Buffer, BufferSize);
        Serial.write(BufferSize);
      }
    }

    if (BufferIndex < BufferSize) {
      byte bt = Buffer[BufferIndex];
      if (bt < B11000000) {
        ExecRamp(bt);
        ExecServo(bt);
        ExecStepper(bt);
      } else {
        ExecInternal(bt);
      }
      BufferIndex++;          
    }   
    LoopDelay = round(RAMP_KB*(sqrt(RampIndex/RAMP_KC+1)-sqrt(RampIndex/RAMP_KC)));   
  }
}
