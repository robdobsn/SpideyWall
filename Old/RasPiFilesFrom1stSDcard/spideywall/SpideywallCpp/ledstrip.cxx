/*
 * Spidey Wall LED strip class
 *
 */
 
 #include "ledstrip.hxx"
 
 LedStrip::LedStrip (int spiPort, int mode, int bits, uint32_t speed, int delay, int numLeds)
 {
	 m_ledsArray = new LED [numLeds];
	 m_spiPort = spiPort;
	 m_numLeds = numLeds;
				

	 
 }
 
 LED* LedStrip::LEDs ()
 {
	 return m_ledsArray;
 }
 
 void LedStrip::Show()
 {
	 
 }
 
