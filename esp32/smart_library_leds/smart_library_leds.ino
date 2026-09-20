/*
  Smart Library — ESP32 shelf LEDs
  Board: ESP-32S NodeMCU — use pins labeled P25, P26, P27, GND
  On boot: each LED turns on for 3 seconds (watch Serial Monitor).
*/

#include <WiFi.h>
#include <WebServer.h>

const char* WIFI_SSID = "yathu04";
const char* WIFI_PASSWORD = "y@thu#047";

// Labels on your board bottom: P25, P26, P27
const int LED_S01 = 25; // S-01 → P25
const int LED_S02 = 26; // S-02 → P26
const int LED_S03 = 27; // S-03 → P27
const int LED_ONBOARD = 2; // small blue LED on many boards (P2)

// Keep shelf LED on for 30 seconds, then auto off
const unsigned long LED_ON_MS = 30000;

WebServer server(80);

unsigned long ledOffAt = 0;
bool ledIsOn = false;

void allOff() {
  digitalWrite(LED_S01, LOW);
  digitalWrite(LED_S02, LOW);
  digitalWrite(LED_S03, LOW);
  digitalWrite(LED_ONBOARD, LOW);
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
  digitalWrite(LED_ONBOARD, HIGH); // proves software ran even if external LED fails
  ledIsOn = true;
  ledOffAt = millis() + LED_ON_MS;
}

void testPin(int pin, const char* name) {
  Serial.print("TEST ON: ");
  Serial.println(name);
  digitalWrite(pin, HIGH);
  digitalWrite(LED_ONBOARD, HIGH);
  delay(3000);
  digitalWrite(pin, LOW);
  digitalWrite(LED_ONBOARD, LOW);
  Serial.print("TEST OFF: ");
  Serial.println(name);
  delay(500);
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
  Serial.println("Light request: " + shelf);
  server.send(200, "text/plain", "lit " + shelf + " (auto-off 30s)");
}

void handleOff() {
  sendCors();
  allOff();
  server.send(200, "text/plain", "off");
}

void setup() {
  Serial.begin(115200);
  delay(500);
  pinMode(LED_S01, OUTPUT);
  pinMode(LED_S02, OUTPUT);
  pinMode(LED_S03, OUTPUT);
  pinMode(LED_ONBOARD, OUTPUT);
  allOff();

  Serial.println();
  Serial.println("=== LED self-test (3s each) ===");
  Serial.println("Watch external LEDs on P25/P26/P27");
  Serial.println("Onboard P2 should also blink each time");
  testPin(LED_S01, "P25 / S-01");
  testPin(LED_S02, "P26 / S-02");
  testPin(LED_S03, "P27 / S-03");
  Serial.println("=== Self-test done ===");

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
