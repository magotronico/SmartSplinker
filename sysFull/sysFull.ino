#include <Servo.h>

Servo myservo;  // Create servo object to control a servo

void setup() {
  myservo.attach(4);  // Attaches the servo on pin 4 to the servo object
}

void loop() {
  for (int pos = 0; pos <= 180; pos += 1) {  // Goes from 0 degrees to 180 degrees
    // in steps of 1 degree
    myservo.write(pos);              // Tell servo to go to position in variable 'pos'
    delay(15);                       // Waits 15ms for the servo to reach the position
  }
  delay(1000);  // Wait for a second at 180 degrees before next loop starts
  for (int pos = 180; pos <= 0; pos -= 1) {  // Goes from 0 degrees to 180 degrees
    // in steps of 1 degree
    myservo.write(pos);              // Tell servo to go to position in variable 'pos'
    delay(15);                       // Waits 15ms for the servo to reach the position
  }
}
