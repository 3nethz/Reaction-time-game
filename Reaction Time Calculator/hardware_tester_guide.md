# Hardware Testing Guide for Basys3 Reaction Timer

## Method 1: Self-Test (No Extra Equipment)

### Test 1: Visual/Manual Verification
1. **Power on** the Basys3 board
2. **Press CLEAR** (BTN2 - W19) - All displays should show "0.000"
3. **Press START** (BTN0 - U18)
   - Wait 3-10 seconds (use phone stopwatch)
   - LED (U16) should turn on
4. **Press STOP** (BTN1 - T18) as soon as you see LED
5. **Check display** - Should show 0.XXX seconds
6. **Repeat** 5-10 times, record results

**Expected Results:**
- Random delays: 3-10 seconds ✓
- Reaction times: 150-400ms (typical human) ✓
- Display format: X.XXX seconds ✓

---

## Method 2: Automated Test with Arduino/Second Board

### Hardware Setup:
```
Arduino/Tester Board:
  Digital Out Pin → Basys3 START button (U18)
  Digital Out Pin → Basys3 STOP button (T18)
  Digital In Pin  → Basys3 LED (U16)
  Timer/Counter   → Measure actual time
```

### Arduino Test Code:
```cpp
// Arduino Hardware Tester for Basys3 Reaction Timer
#define START_PIN 2    // Connect to Basys3 START (U18)
#define STOP_PIN 3     // Connect to Basys3 STOP (T18)
#define LED_PIN 4      // Connect to Basys3 LED (U16)
#define CLEAR_PIN 5    // Connect to Basys3 CLEAR (W19)

void setup() {
  Serial.begin(9600);
  pinMode(START_PIN, OUTPUT);
  pinMode(STOP_PIN, OUTPUT);
  pinMode(LED_PIN, INPUT);
  pinMode(CLEAR_PIN, OUTPUT);
  
  digitalWrite(START_PIN, LOW);
  digitalWrite(STOP_PIN, LOW);
  digitalWrite(CLEAR_PIN, LOW);
  
  Serial.println("Basys3 Reaction Timer Hardware Tester");
  Serial.println("====================================");
}

void loop() {
  // Test cycle
  Serial.println("\n--- Starting Test Cycle ---");
  
  // 1. Clear
  digitalWrite(CLEAR_PIN, HIGH);
  delay(100);
  digitalWrite(CLEAR_PIN, LOW);
  delay(500);
  
  // 2. Press START
  Serial.println("Pressing START...");
  digitalWrite(START_PIN, HIGH);
  delay(100);
  digitalWrite(START_PIN, LOW);
  
  // 3. Wait for LED to turn on
  Serial.println("Waiting for LED...");
  unsigned long start_wait = millis();
  while(digitalRead(LED_PIN) == LOW) {
    if(millis() - start_wait > 15000) {
      Serial.println("ERROR: LED timeout (>15s)");
      return;
    }
  }
  unsigned long led_on_time = millis();
  unsigned long countdown = led_on_time - start_wait;
  Serial.print("Countdown time: ");
  Serial.print(countdown);
  Serial.println(" ms");
  
  // Check countdown range (3-10 seconds)
  if(countdown < 3000 || countdown > 10000) {
    Serial.println("WARNING: Countdown out of range!");
  } else {
    Serial.println("✓ Countdown in valid range");
  }
  
  // 4. Wait a known time (e.g., 347ms) then press STOP
  delay(347);  // Known reaction time
  
  digitalWrite(STOP_PIN, HIGH);
  unsigned long stop_time = millis();
  delay(100);
  digitalWrite(STOP_PIN, LOW);
  
  // 5. Calculate expected reaction time
  unsigned long actual_reaction = stop_time - led_on_time;
  Serial.print("Expected reaction: 347 ms");
  Serial.print("Actual measured: ");
  Serial.print(actual_reaction);
  Serial.println(" ms");
  
  // Check accuracy (allow ±5ms tolerance)
  if(abs(actual_reaction - 347) <= 5) {
    Serial.println("✓ PASS: Timing accurate!");
  } else {
    Serial.print("✗ FAIL: Error = ");
    Serial.print(actual_reaction - 347);
    Serial.println(" ms");
  }
  
  Serial.println("\nNow check Basys3 display - should show 0.347");
  Serial.println("Press any key to continue...");
  
  // Wait for user input
  while(!Serial.available()) delay(100);
  while(Serial.available()) Serial.read();
  
  delay(2000);
}
```

### Wiring Diagram:
```
Arduino GND ──────────────── Basys3 GND
Arduino Pin 2 (START) ────── Basys3 U18 (via 1kΩ resistor)
Arduino Pin 3 (STOP) ─────── Basys3 T18 (via 1kΩ resistor)
Arduino Pin 4 (LED) ──────── Basys3 U16 (LED output)
Arduino Pin 5 (CLEAR) ────── Basys3 W19 (via 1kΩ resistor)

Note: Use resistors to protect pins!
```

---

## Method 3: Logic Analyzer / Oscilloscope Test

### Equipment Needed:
- Logic analyzer (e.g., Saleae, Analog Discovery)
- OR Oscilloscope with digital channels

### Test Procedure:

1. **Connect probes:**
   - Channel 1: Basys3 LED output (U16)
   - Channel 2: Basys3 internal ms_tick (if accessible via test point)
   - Channel 3: Clock (W5)

2. **Capture timing:**
   - Trigger on LED rising edge
   - Capture 1 second of data

3. **Verify ms_tick frequency:**
   - Count ms_tick pulses in 1 second
   - Should be exactly **1000 pulses/second**
   - Each pulse = 100,000 clock cycles

4. **Check clock frequency:**
   - Measure clock period
   - Should be **10ns** (100 MHz)

---

## Method 4: Modified Test Firmware

### Quick Accuracy Check
Add a test mode to your Verilog that bypasses random delay:

```verilog
// Add to reactionTimer.v for testing
input wire test_mode,

// In countdown_timer_next logic:
assign countdown_timer_next = 
    (countdown_go && countdown_timer_reg > 0) ? countdown_timer_reg - 1 :
    test_mode ? 29'd100000000 :  // TEST: Always 1 second
    start ? random_counter_reg * 29'd100000000 : countdown_timer_reg;
```

**Benefits:**
- Predictable 1-second countdown
- Easier to verify with stopwatch
- Quick sanity check

---

## Accuracy Verification Checklist

### ✓ Clock Frequency Check
```
Expected: 100 MHz (10ns period)
Measure: Use logic analyzer or scope on W5 pin
Tolerance: ±0.01%
```

### ✓ Millisecond Tick Check
```
Expected: 1000 ticks/second
Method: Count ms_tick pulses
Tolerance: ±1 tick/second
```

### ✓ Display Accuracy Check
```
Test: Known delay (e.g., 347ms via Arduino)
Expected: Display shows "0.347"
Tolerance: ±1 ms (display shows "0.346" to "0.348")
```

### ✓ Countdown Range Check
```
Expected: 3-10 seconds random
Method: Time with stopwatch, repeat 10 times
All results should be 3.0-10.0 seconds
```

---

## Common Issues and Solutions

### Issue 1: Display always shows "0.000"
**Causes:**
- ms_counter not incrementing
- ms_tick not pulsing
- reaction_timer not counting

**Debug:**
- Check ms_go signal in timing state
- Verify clock is running (LED should blink if you toggle in code)
- Use logic analyzer on internal signals

### Issue 2: Times too short/long
**Causes:**
- Clock frequency wrong
- Counter thresholds wrong

**Debug:**
- Measure actual clock frequency
- Check ms_counter threshold (should be 99,999 for 100MHz)
- Verify countdown multiplier (100,000,000 for 100MHz)

### Issue 3: No LED turn on
**Causes:**
- Countdown timer not counting
- State machine stuck

**Debug:**
- Check countdown_go in LOAD state
- Verify state transitions (use ILA if available)
- Check countdown_done signal

---

## Expected Test Results Summary

| Test | Expected Result | Tolerance |
|------|----------------|-----------|
| Countdown delay | 3-10 seconds | ±0.01s |
| Human reaction | 150-400ms | N/A |
| Known delay (347ms) | Display: 0.347 | ±0.001s |
| Clock frequency | 100 MHz | ±100 Hz |
| ms_tick rate | 1000 Hz | ±1 Hz |

---

## Final Verification

Run these tests in order:
1. ✓ Visual test (5 trials) - Verify basic operation
2. ✓ Manual stopwatch test (10 trials) - Check countdown range
3. ✓ Arduino automated test (20 trials) - Verify accuracy
4. ✓ Logic analyzer (optional) - Confirm timing precision

**If all tests pass → Your hardware is working correctly!** 🎉
