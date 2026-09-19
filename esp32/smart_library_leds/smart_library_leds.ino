/*
  Smart Library — ESP32 shelf LEDs
  Auto-off: LED turns off after LED_ON_MS milliseconds.
*/

#include <WiFi.h>
#include <WebServer.h>

const char* WIFI_SSID = "yathu04";
const char* WIFI_PASSWORD = "y@thu#047";

// TEST MODE: onboard LED (GPIO 2). Later use 25, 26, 27 with resistors.
const int LED_S01 = 2;
const int LED_S02 = 2;
const int LED_S03 = 2;

// Keep LED on for 30 seconds, then auto off
const unsigned long LED_ON_MS = 30000;

WebServer server(80);

unsigned long ledOffAt = 0;
bool ledIsOn = false;

void allOff() {
  digitalWrite(LED_S01, LOW);
  digitalWrite(LED_S02, LOW);
  digitalWrite(LED_S03, LOW);
  ledIsOn = false;
  ledOffAt = 0;
}

void lightShelf(const String& shelf) {
  allOff();
  if (shelf == "S-01" || shelf == "S1") {
    digitalWrite(LED_S01, HIGH);
  } else if (shelf == "S-02" || shelf == "S2") {
    digitalWrite(LED_S02, HIGH);
  } else if (shelf == "S-03" || shelf == "S3") {
    digitalWrite(LED_S03, HIGH);
  } else {
    return;
  }
  ledIsOn = true;
  ledOffAt = millis() + LED_ON_MS;
}

void sendCors() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "*");
}

void handleOptions() {
  sendCors();
  server.send(204);
}

void handleRoot() {
  sendCors();
  server.send(200, "text/plain", "Smart Library ESP32 OK");
}

void handleLight() {
  sendCors();
  if (!server.hasArg("shelf")) {
    server.send(400, "text/plain", "missing shelf");
    return;
  }
  String shelf = server.arg("shelf");
  lightShelf(shelf);
  server.send(200, "text/plain", "lit " + shelf + " (auto-off 30s)");
}

void handleOff() {
  sendCors();
  allOff();
  server.send(200, "text/plain", "off");
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_S01, OUTPUT);
  pinMode(LED_S02, OUTPUT);
  pinMode(LED_S03, OUTPUT);
  allOff();

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  server.on("/", HTTP_GET, handleRoot);
  server.on("/light", HTTP_GET, handleLight);
  server.on("/off", HTTP_GET, handleOff);
  server.on("/", HTTP_OPTIONS, handleOptions);
  server.on("/light", HTTP_OPTIONS, handleOptions);
  server.on("/off", HTTP_OPTIONS, handleOptions);
  server.begin();
}

void loop() {
  server.handleClient();
  if (ledIsOn && millis() >= ledOffAt) {
    allOff();
    Serial.println("LED auto-off");
  }
}
