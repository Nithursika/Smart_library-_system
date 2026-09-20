# ESP32 LED — beginner step-by-step

Phone/PC and ESP32 must be on the **same Wi‑Fi**.
Books stay in Supabase; ESP32 only turns LEDs on over local Wi‑Fi.

## What you need
- ESP32 Dev Board
- USB cable (data cable, not charge-only)
- 3 LEDs + 3 × 220Ω resistors
- Jumper wires / breadboard
- Arduino IDE on your laptop

## Wiring (LED → ESP32)

```
GPIO pin ──► 220Ω resistor ──► LED long leg (+)
                                 LED short leg (−) ──► GND
```

| Shelf in app | ESP32 pin |
|--------------|-----------|
| S-01 | GPIO **25** |
| S-02 | GPIO **26** |
| S-03 | GPIO **27** |
| All LEDs | share **GND** |

## 1. Install Arduino IDE + ESP32 board
1. Install [Arduino IDE](https://www.arduino.cc/en/software)
2. **File → Preferences → Additional boards manager URLs**, add:
   `https://espressif.github.io/arduino-esp32/package_esp32_index.json`
3. **Tools → Board → Boards Manager** → search **esp32** → Install **esp32 by Espressif**
4. Plug ESP32 into laptop USB
5. **Tools → Board → ESP32 Arduino → ESP32 Dev Module**
6. **Tools → Port** → pick the COM port (e.g. COM3)

If Port is empty: install USB driver (CP210x or CH340, depending on your board).

## 2. Put your Wi‑Fi in the code
1. Open `esp32/smart_library_leds/smart_library_leds.ino`
2. Change:
   ```cpp
   const char* WIFI_SSID = "YOUR_WIFI_NAME";
   const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
   ```
3. Use the same Wi‑Fi your phone will use (not a guest network if possible)

## 3. Upload to ESP32
1. Click **Upload** (→ arrow)
2. If it fails with “connecting…”, hold the ESP32 **BOOT** button during upload
3. When done: **Tools → Serial Monitor**, set baud to **115200**
4. Press ESP32 **EN/RESET**
5. You should see:
   ```
   Connecting WiFi.....
   ESP32 IP: 192.168.1.45
   ```
6. **Copy that IP**

## 4. Connect the app
### Easiest (in the app)
1. Open app → **Settings**
2. ESP32 address: `http://192.168.1.45` (your IP)
3. Tap **Save**

### Or in code
In `frontend/lib/config.dart`:
```dart
static const esp32BaseUrl = 'http://192.168.1.45';
```

## 5. Test
1. Same Wi‑Fi on phone and ESP32
2. Browser on phone: `http://YOUR_IP/light?shelf=S-02` → S-02 LED on
3. App: Search book → **Navigate to Shelf** → matching LED on  
   Or **Add book** with “Light shelf LED” on

## If it does not work
| Problem | Fix |
|---------|-----|
| No COM port | Wrong USB cable / install CP210x or CH340 driver |
| Upload fails | Hold **BOOT**, try again |
| No IP in Serial | Wrong Wi‑Fi name/password; 2.4 GHz Wi‑Fi (many ESP32 boards don’t do 5 GHz) |
| App can’t reach ESP32 | Same Wi‑Fi; correct `http://IP`; turn off AP isolation on router |
| All LEDs light when touched | Check separate wires per GPIO; shared GND only |

## Flow reminder
```
App  →  Wi‑Fi  →  ESP32  →  one shelf LED
Supabase = book database (cloud)
ESP32    = lights only (local)
```
