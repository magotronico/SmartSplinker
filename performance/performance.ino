// This code makes a simulation of how to control the system. It only shows a way in which all components works together in order to demonstrate concept.

// Global variables
int counter = 0; // Counter for the number of interrupts (possibly flow rate pulses)
hw_timer_t *timer = NULL; // Pointer to a hardware timer
int pwmval; // Variable to store PWM values

// setup() function - runs once when the program starts
void setup() {
  // Initialize two PWM channels with a frequency of 50 Hz and 16-bit resolution
  ledcSetup(1, 50, 16); // Channel 1
  ledcSetup(2, 50, 16); // Channel 2

  // Attach GPIO pins to the PWM channels
  ledcAttachPin(2, 1); // GPIO 2 to channel 1
  ledcAttachPin(4, 2); // GPIO 4 to channel 2

  // Start serial communication at 115200 baud rate
  Serial.begin(115200);

  // Attach an interrupt to a pin (presumably for flow meter)
  attachInterrupt(15, caudal, RISING);

  // Initialize and configure a hardware timer
  timer = timerBegin(0, 100, true); // Timer 0, prescaler 100, counting up
  timerAttachInterrupt(timer, &onTimer, true); // Attach onTimer function to the timer interrupt
  timerAlarmWrite(timer, 200000, true); // Set timer alarm for 200000 microseconds
  timerAlarmEnable(timer); // Enable the timer alarm
}

// onTimer() function - called when the timer interrupt occurs
void onTimer() {
  // Print PWM values mapped to degrees for servos and flow rate calculated from counter
  Serial.print(map(ledcRead(1), 65536 / 20 * 0.5, 65536 / 20 * 2.5, 0, 180));
  Serial.print(",");
  Serial.print(map(ledcRead(2), 65536 / 20 * 0.5, 65536 / 20 * 2.5, 0, 180));
  Serial.print(",");
  Serial.println(counter * 5 / 7.5); // Flow rate calculation (unit conversion may vary)
  counter = 0; // Reset the counter for the next interval
}

// caudal() function - ISR for the flow meter
void caudal() {
  counter++; // Increment counter on each pulse from the flow meter
}

// loop() function - runs repeatedly after setup()
void loop() {
  // Loop to vary PWM output for channel 1
  for (int i = 30; i < 100; i = i + 20) {
    // Map angle to PWM value and write to channel 1
    pwmval = map(i, 0, 180, 65536 / 20 * 0.5, 65536 / 20 * 2.5);
    ledcWrite(1, pwmval);

    // Nested loop to vary PWM output for channel 2
    for (int x = 0; x <= 60; x++) {
      pwmval = map(x, 0, 180, 65536 / 20 * 0.5, 65536 / 20 * 2.5);
      ledcWrite(2, pwmval);
      delay(40); // Short delay for smoother motion
    }

    // Increase angle slightly for channel 1
    pwmval = map(i + 10, 0, 180, 65536 / 20 * 0.5, 65536 / 20 * 2.5);
    ledcWrite(1, pwmval);

    // Reverse loop for channel 2 to return to starting position
    for (int x = 60; x >= 0; x--) {
      pwmval = map(x, 0, 180, 65536 / 20 * 0.5, 65536 / 20 * 2.5);
      ledcWrite(2, pwmval);
      delay(40); // Short delay for smoother motion
    }
  }
}
