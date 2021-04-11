#include <Arduino.h>
#include <Stepper.h>
#include <Servo.h>
#include "pinout.h"
#include "robotGeometry.h"
#include "interpolation.h"
#include "fanControl.h"
#include "RampsStepper.h"
#include "queue.h"
#include "command.h"
#include "GPIOservo.hpp"

Servo stackerServo;
Stepper stepper(2400, STEPPER_GRIPPER_PIN_0, STEPPER_GRIPPER_PIN_1, STEPPER_GRIPPER_PIN_2, STEPPER_GRIPPER_PIN_3);
RampsStepper stepperRotate(Z_STEP_PIN, Z_DIR_PIN, Z_ENABLE_PIN);
RampsStepper stepperLower(Y_STEP_PIN, Y_DIR_PIN, Y_ENABLE_PIN);
RampsStepper stepperHigher(X_STEP_PIN, X_DIR_PIN, X_ENABLE_PIN);
RampsStepper stepperExtruder(E_STEP_PIN, E_DIR_PIN, E_ENABLE_PIN);
FanControl fan(FAN_PIN);
RobotGeometry geometry;
Interpolation interpolator;
Queue<Cmd> queue(15);
Command command;

//
GPIOservo gripperValve(VALVE_PIN);
GPIOservo gripperServo(SERVO_PIN);
int angle = 90;
int angle_offset = 0; // offset to compensate deviation from 90 degree(middle position)
const int angle_offset_default=30;

unsigned long cmdGripperOffTime = 0;

void setup() {
  Serial.begin(9600);
  Serial1.begin(9600);

  //various pins..
  pinMode(HEATER_0_PIN  , OUTPUT);
  pinMode(HEATER_1_PIN  , OUTPUT);
  pinMode(LED_PIN       , OUTPUT);

  //unused Stepper..
  pinMode(E_STEP_PIN   , OUTPUT);
  pinMode(E_DIR_PIN    , OUTPUT);
  pinMode(E_ENABLE_PIN , OUTPUT);

  //unused Stepper..
  pinMode(Q_STEP_PIN   , OUTPUT);
  pinMode(Q_DIR_PIN    , OUTPUT);
  pinMode(Q_ENABLE_PIN , OUTPUT);

  //GripperPins
  pinMode(STEPPER_GRIPPER_PIN_0, OUTPUT);
  pinMode(STEPPER_GRIPPER_PIN_1, OUTPUT);
  pinMode(STEPPER_GRIPPER_PIN_2, OUTPUT);
  pinMode(STEPPER_GRIPPER_PIN_3, OUTPUT);
  digitalWrite(STEPPER_GRIPPER_PIN_0, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_1, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_2, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_3, LOW);

  //  vaccum motor control
  pinMode(MOTOR_IN1  , OUTPUT);
  pinMode(MOTOR_IN2  , OUTPUT);
  digitalWrite(MOTOR_IN1, LOW);
  digitalWrite(MOTOR_IN2, LOW);

  //
  gripperServo.attach();
  gripperServo.write(angle);
  delay(20);
  gripperServo.detach();
  //
  gripperValve.attach();
  gripperValve.write(0);


  //reduction of steppers..
  stepperHigher.setReductionRatio(32.0 / 9.0, 200 * 16);  //big gear: 32, small gear: 9, steps per rev: 200, microsteps: 16
  stepperLower.setReductionRatio( 32.0 / 9.0, 200 * 16);
  stepperRotate.setReductionRatio(32.0 / 9.0, 200 * 16);
  stepperExtruder.setReductionRatio(32.0 / 9.0, 200 * 16);

  //start positions..
  stepperHigher.setPositionRad(PI / 2.0);  //90°
  stepperLower.setPositionRad(0);          // 0°
  stepperRotate.setPositionRad(0);         // 0°
  stepperExtruder.setPositionRad(0);

  //enable and init..
  setStepperEnable(false);
  interpolator.setInterpolation(0, 180, 180, 0, 0, 180, 180, 0);

  Serial.println("started");
  //Serial1.println("started");
}

void setStepperEnable(bool enable) {
  stepperRotate.enable(enable);
  stepperLower.enable(enable);
  stepperHigher.enable(enable);
  stepperExtruder.enable(enable);
  fan.enable(enable);
}

void loop () {
  //gripperServo.sweep();
  //update and Calculate all Positions, Geometry and Drive all Motors...
  interpolator.updateActualPosition();
  geometry.set(interpolator.getXPosmm(), interpolator.getYPosmm(), interpolator.getZPosmm());
  stepperRotate.stepToPositionRad(geometry.getRotRad());
  stepperLower.stepToPositionRad (geometry.getLowRad());
  stepperHigher.stepToPositionRad(geometry.getHighRad());
  stepperExtruder.stepToPositionRad(interpolator.getEPosmm());
  stepperRotate.update();
  stepperLower.update();
  stepperHigher.update();
  fan.update();

  if (!queue.isFull()) {
    if (command.handleGcode()) {
      queue.push(command.getCmd());
      printOk();
    }
  }
  if ((!queue.isEmpty()) && interpolator.isFinished()) {
    executeCommand(queue.pop());
  }

  if (millis() % 500 < 250) {
    digitalWrite(LED_PIN, HIGH);
  } else {
    digitalWrite(LED_PIN, LOW);
  }
  //
  static long cmdGripperOffPrevTime = 0;
  if ((cmdGripperOffTime - cmdGripperOffPrevTime) > 1000) { // every second check -
    gripperValve.write(0);  // for vaccum gripper- deactivate the valve in case there is a gripper off command
    gripperServo.detach();  // for servo gripper - turn off servo power
    cmdGripperOffPrevTime = cmdGripperOffTime;
    //Serial.println("Gripper off Timer");
  }
}




void cmdMove(Cmd (&cmd)) {
  //  Serial.println(cmd.valueX);
  //  Serial.println(cmd.valueY);
  //  Serial.println(cmd.valueZ);
  interpolator.setInterpolation(cmd.valueX, cmd.valueY, cmd.valueZ, cmd.valueE, cmd.valueF);
}

void cmdDwell(Cmd (&cmd)) {
  delay(int(cmd.valueT * 1000));
}

void cmdGripperOn(Cmd (&cmd)) {
  //Serial.print("Gripper on ");
  // Stack servo push a chess





  stackerServo.attach(STACKER_SERVO);
  delay(15);
  stackerServo.write(140);
  delay(500);
  stackerServo.write(120);
  delay(100);
  
  stackerServo.write(170);
  delay(100);
  stackerServo.detach();
  
  //




  // vaccum gripper
  digitalWrite(MOTOR_IN1, HIGH); //turn on motor
  digitalWrite(MOTOR_IN2, LOW);
  gripperValve.write(0);  // deactivate the valve, no air through

  // servo gripper
  gripperServo.attach();
  gripperServo.write(angle);

  // stepper gripper
  stepper.setSpeed(5);
  stepper.step(int(cmd.valueT));
  delay(50);
  digitalWrite(STEPPER_GRIPPER_PIN_0, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_1, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_2, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_3, LOW);
  //printComment("// NOT IMPLEMENTED");
  //printFault();
}

void cmdGripperOff(Cmd (&cmd)) {
  cmdGripperOffTime = millis();


  // vaccum gripper
  digitalWrite(MOTOR_IN1, LOW); // turn off motor
  digitalWrite(MOTOR_IN2, LOW); //
  gripperValve.write(180);  // activate the valve, allow air through.

  // servo gripper
  angle_offset = int(cmd.valueT);
  if (angle_offset <=0) {
    angle_offset=angle_offset_default;
  } else if (angle_offset > 90) {
    angle_offset=90;
  }
  gripperServo.write(angle + -angle_offset);
  //Serial.println("Gripper off " + String(angle_offset));

  // 28BYJ-48 stepper gripper
  stepper.setSpeed(5);
  stepper.step(-int(cmd.valueT));
  delay(50);
  digitalWrite(STEPPER_GRIPPER_PIN_0, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_1, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_2, LOW);
  digitalWrite(STEPPER_GRIPPER_PIN_3, LOW);
  //printComment("// NOT IMPLEMENTED");
  //printFault();
}

void cmdStepperOn() {
  setStepperEnable(true);
}

void cmdStepperOff() {
  setStepperEnable(false);
}

void cmdFanOn() {
  fan.enable(true);
}

void cmdFanOff() {
  fan.enable(false);
}

void handleAsErr(Cmd (&cmd)) {
  printComment("Unknown Cmd " + String(cmd.id) + String(cmd.num) + " (queued)");
  printFault();
}

void executeCommand(Cmd cmd) {
  if (cmd.id == -1) {
    String msg = "parsing Error";
    printComment(msg);
    handleAsErr(cmd);
    return;
  }

  if (cmd.valueX == NAN) {
    cmd.valueX = interpolator.getXPosmm();
  }
  if (cmd.valueY == NAN) {
    cmd.valueY = interpolator.getYPosmm();
  }
  if (cmd.valueZ == NAN) {
    cmd.valueZ = interpolator.getZPosmm();
  }
  if (cmd.valueE == NAN) {
    cmd.valueE = interpolator.getEPosmm();
  }

  //decide what to do
  if (cmd.id == 'G') {
    switch (cmd.num) {
      case 0: cmdMove(cmd); break;
      case 1: cmdMove(cmd); break;
      case 4: cmdDwell(cmd); break;
      //case 21: break; //set to mm
      //case 90: cmdToAbsolute(); break;
      //case 91: cmdToRelative(); break;
      //case 92: cmdSetPosition(cmd); break;
      default: handleAsErr(cmd);
    }
  } else if (cmd.id == 'M') {
    switch (cmd.num) {
      //case 0: cmdEmergencyStop(); break;
      case 3: cmdGripperOn(cmd); break;
      case 5: cmdGripperOff(cmd); break;
      case 17: cmdStepperOn(); break;
      case 18: cmdStepperOff(); break;
      case 106: cmdFanOn(); break;
      case 107: cmdFanOff(); break;
      default: handleAsErr(cmd);
    }
  } else {
    handleAsErr(cmd);
  }
}
