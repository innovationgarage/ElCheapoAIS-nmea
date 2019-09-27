void setup(void)
{
#if defined(ESP8266)
    // TTGO SH1106 ESP8266 screen
    Wire.begin(LCD_CLK, LCD_SDA);   // change hardware I2C pins to (5,4) (D1,D2)
#endif

  Serial.begin(9600);         // Start the serial port.

  Scheduler.start(&screen_task);
  Scheduler.start(&keyboard_task);
  Scheduler.start(&terminal_task);
  Scheduler.begin();
}
