#ifndef PINOUT_H_
#define PINOUT_H_


/*
 * pinout of RAMPS 1.4
 *
 * source: http://reprap.org/wiki/RAMPS_1.4
 */

//RAMPS 1.4 PINS
#define X_STEP_PIN         54
#define X_DIR_PIN          55
#define X_ENABLE_PIN       38
#define X_MIN_PIN           3
#define X_MAX_PIN           2

#define Y_STEP_PIN         60
#define Y_DIR_PIN          61
#define Y_ENABLE_PIN       56
#define Y_MIN_PIN          14
#define Y_MAX_PIN          15

#define Z_STEP_PIN         46
#define Z_DIR_PIN          48
#define Z_ENABLE_PIN       62
#define Z_MIN_PIN          18
#define Z_MAX_PIN          19

#define E_STEP_PIN         26
#define E_DIR_PIN          28
#define E_ENABLE_PIN       24

#define Q_STEP_PIN         36
#define Q_DIR_PIN          34
#define Q_ENABLE_PIN       30

#define SDPOWER            -1
#define SDSS               53
#define LED_PIN            13

#define FAN_PIN             9

#define PS_ON_PIN          12
#define KILL_PIN           -1

#define HEATER_0_PIN       10
#define HEATER_1_PIN        8
#define TEMP_0_PIN         13   // ANALOG NUMBERING
#define TEMP_1_PIN         14   // ANALOG NUMBERING

//RAMPS AUX-1 - stepper gripper
#define STEPPER_GRIPPER_PIN_0 40
#define STEPPER_GRIPPER_PIN_1 59
#define STEPPER_GRIPPER_PIN_2 63
#define STEPPER_GRIPPER_PIN_3 64

//RAMPS SERVO -
#define MOTOR_IN1 11 // for vaccum gripper
#define MOTOR_IN2 6  // for vaccum gripper
#define VALVE_PIN 5  // for vaccum gripper
#define SERVO_PIN 4  // for servo gripper

//RAMPS ENDSTOPS -
#define ENDSTOP_X_PIN 3
#define ENDSTOP_Y_PIN 2
#define ENDSTOP_Z_PIN 14

//STACKER SERVO -
#define STACKER_SERVO 40

#endif
