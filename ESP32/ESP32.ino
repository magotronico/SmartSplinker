#include <WiFi.h>
#include <WebServer.h>
#include <Servo.h>
#include <SoftwareSerial.h>

// Initialize a web server on port 80
WebServer server(80);

// WiFi credentials
const char* ssid = "ESP32-Access-Point";
const char* password = "12345678";

// Variables for flow rate calculation
float gasto = 0.0; // Flow rate
int pos = 0; // Unused variable for servo position
int val = 0; // Unused variable
int ang; // Unused variable
const int caudal = 2; // Pin for flow meter
const int pinSer1 = 4; // Pin for first servo
const int pinSer2 = 3; // Pin for second servo
float pulsos; // Pulse count from flow meter
float k = 7.5; // Calibration constant for flow meter
uint32_t time2; // Timing variable
uint32_t timeServo1; // Timing for servo control
uint32_t timeServo2; // Timing for servo control
uint16_t elapsedServo; // Elapsed time for servo control
uint32_t time = millis(); // Current time
uint16_t elapsedtime; // Elapsed time for main loop
uint32_t time1 = millis(); // Previous time for main loop
uint32_t time3; // Unused timing variable
int gate1 = 1; // Unused variable
int timerInter; // Timer for interrupt
#define BTRX 7 // Bluetooth RX pin
#define BTTX 6 // Bluetooth TX pin

// Bluetooth serial communication
SoftwareSerial BT(BTRX, BTTX);

// Servo instances
Servo servo1;
Servo servo2;

void setup() {
  Serial.begin(9600); // Start serial communication for debugging
  BT.begin(9600); // Start Bluetooth communication

  // Attach servos to their pins
  servo1.attach(9, 500, 2500); // Servo 1 with min/max pulse width
  servo2.attach(5); // Servo 2 on pin 5

  pinMode(caudal, INPUT); // Set flow meter pin as input
  attachInterrupt(digitalPinToInterrupt(2), contar, RISING); // Attach interrupt for flow meter
  delay(100); // Short delay after setting up interrupt

  time1 = millis(); // Reset timing variable
  timeServo1 = millis(); // Reset servo timing variable

  // Initial positioning of servos
  servo2.write(120); // Move servo 2 to 120 degrees
  delay(5000); // Wait 5 seconds

  servo2.write(50); // Move servo 2 to 50 degrees

  // Setup WiFi access point
  WiFi.softAP(ssid, password); // Start the WiFi access point
  IPAddress myIP = WiFi.softAPIP(); // Get the IP address
  Serial.print("AP IP address: "); // Print IP address to serial
  Serial.println(myIP);

  // Setup web server routes
  server.on("/", HTTP_GET, [](){
    server.send(200, "text/plain", "ESP32 Server"); // Root path
  });

  server.on("/counter", HTTP_GET, [](){
    server.send(200, "text/plain", String(gasto)); // Send flow rate
  });

  server.on("/command", HTTP_GET, [](){
    // Handle command route
    String message;
    if (server.hasArg("value")) {
      String value = server.arg("value");
      Serial.println("Received command: " + value);
      if (value == "1") {
        // Handle "on" command
        message = "Turned on";
      } else if (value == "2") {
        // Handle "off" command
        message = "Turned off";
      } else {
        // Handle invalid command
        message = "Invalid command";
      }
      server.send(200, "text/plain", message); // Send response
    } else {
      server.send(404, "text/plain", "Argument not found"); // Argument not found
    }
  });

  server.begin(); // Start the web server
  Serial.println("HTTP server started"); // Indicate server start in serial monitor
}

void loop() {
  // Main loop for handling flow rate and servo control
  time2 = millis();
  elapsedtime = time2 - time1;
  if (elapsedtime > 100) {
    float hz = frecuencia(); // Calculate frequency
    float gasto = hz / k; // Calculate flow rate
    // Print and send flow rate data
    Serial.print(time);
    Serial.print(",");
    Serial.print(servo2.read());
    Serial.print(",");
    Serial.println(gasto);
    BT.print(time);
    BT.print(",");
    BT.print(servo2.read());
    BT.print(",");
    BT.println(gasto);
    elapsedtime = 0;
    time1 = millis();
  }

  // Servo control logic based on elapsed time
  timeServo2 = millis();
  elapsedServo = timeServo2 - timeServo1;
  if (elapsedServo > 2000 && elapsedServo < 8000) {
    servo2.write(15); // Move servo 2 to 15 degrees
  }

  if (elapsedServo > 8000 && elapsedServo < 11000) {
    servo2.write(120); // Move servo 2 back to 120 degrees
    delay(10000); // Wait 10 seconds
  }

  server.handleClient(); // Handle any incoming web server requests
  delay(100); // Short delay in loop
}

void contar() {
  pulsos++; // Increment pulse count for flow meter
}

float frecuencia() {
  // Calculate frequency for flow meter
  float hz = pulsos / (millis() - timerInter) * 1000;
  Serial.println(hz); // Print frequency to serial
  pulsos = 0; // Reset pulse count
  timerInter = millis(); // Reset timer
  return hz; // Return calculated frequency
}
