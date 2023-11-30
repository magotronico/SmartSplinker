#include <WiFi.h>
#include <WebServer.h>

WebServer server(80);

const char* ssid = "ESP32-Access-Point";
const char* password = "12345678";

float counter = 20.00;

void setup() {
  Serial.begin(115200);

  // Setting up the WiFi Access Point
  WiFi.softAP(ssid, password);
  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(myIP);

  // Start the server
  server.on("/", HTTP_GET, [](){
    server.send(200, "text/plain", "ESP32 Server");
  });

  server.on("/counter", HTTP_GET, [](){
    server.send(200, "text/plain", String(counter));
  });

  server.on("/command", HTTP_GET, [](){
    String message;
    if (server.hasArg("value")) {
      String value = server.arg("value");
      Serial.println("Received command: " + value);
      if (value == "1") {
        // Turned on logic
        message = "Turned on";
      } else if (value == "2") {
        // Turned off logic
        message = "Turned off";
      } else {
        message = "Invalid command";
      }
      server.send(200, "text/plain", message);
    } else {
      server.send(404, "text/plain", "Argument not found");
    }
  });

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
  delay(100);

  // Counter logic
  counter += 0.01;
  if (counter > 30.00) {
    counter = 20.00;
  }
}
