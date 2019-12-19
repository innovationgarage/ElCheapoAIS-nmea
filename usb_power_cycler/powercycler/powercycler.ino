#define PIN_POWER 1
#define PIN_SETUP A2 // pin 4
#define PIN_LED 0
#define delay(x) delay(x/6.7)

unsigned long hours_to_wait_in_ms, next_reset;
const int measurements = 10; // Read the configuration value using N samples
const int blinks_before_reset = 30,
          blinks_speed_on = 10, blinks_speed_off = 300;
const int blinks_hours_on_0 = 1000,
          blinks_hours_on = 200,
          blinks_hours_off = 200;

void blink(int on = blinks_speed_on, int off = blinks_speed_off, bool fade = true)
{
  if (fade)
  {
    for (int i = 0; i < 255; i += 5)
    {
      analogWrite(PIN_LED, i);
      delay(7);
    }
    delay(on);
    for (int i = 0; i < 255; i += 5)
    {
      analogWrite(PIN_LED, 255 - i);
      delay(8);
    }
    digitalWrite(PIN_LED, LOW);
    delay(off);
  }
  else
  {
    digitalWrite(PIN_LED, HIGH);
    delay(on);
    digitalWrite(PIN_LED, LOW);
    delay(off);
  }
}

void blink(bool fade)
{
  blink(blinks_speed_on, blinks_speed_off, fade);
}

void setup() {
  OSCCAL = 181;
  pinMode(PIN_LED, OUTPUT);

  // blink test
  /*while(true)
    {
    int t = map(analogRead(PIN_SETUP),0,1024,10,1000);
    blink(t,400);
    }*/

  pinMode(PIN_POWER, OUTPUT);
  digitalWrite(PIN_POWER, LOW); // Start powered

  // Read the current configuration for times
  int v = 0;
  for (int i = 0; i < measurements; i++)
  {
    v += analogRead(PIN_SETUP);
    delay(10);
  }

  int hours = max(1, min(24, map(v / measurements, 0, 1024, 0, 25))); // Min 1 hour, max 24 hour
  hours_to_wait_in_ms = hours * 60 * 60 * 1000; // In millis

  // Blink the number of hours in setup
  for (int i = 0; i < hours; i++)
    blink(i == 0 ? blinks_hours_on_0 : blinks_hours_on, blinks_hours_off);

    digitalWrite(PIN_POWER, HIGH); // Start powered
}

void loop()
{
  next_reset = millis() + hours_to_wait_in_ms - (2 * blinks_before_reset * (blinks_speed_on + blinks_speed_off));

  do
  {
    delay(60000-blinks_speed_off-blinks_speed_on); // Blink every minute
    blink(false);
  }
  while (millis() < next_reset);
  while (true);

  // Do the reset now
  for (int i = 0; i < blinks_before_reset; i++)
    blink();

  digitalWrite(PIN_POWER, LOW); // Power down
  blink(blinks_before_reset * (blinks_speed_on + blinks_speed_off), 0); // Keep the light on while it resets
  digitalWrite(PIN_POWER, HIGH); // Power on
}
