/*
 * Spidey Wall LED strip class
 *
 */
 
 #include "LED.hxx"
 
 class LedStrip
 {
	 private:
		char m_spiDevice;
		int m_numLeds;
		LED* m_ledsArray;
		unsigned char m_spiMode;
		unsigned char m_spiBits;
		unsigned long m_spiSpeed;
		unsigned m_spiDelay;		
	 
	 public:
		LedStrip (int spiPort, int numLeds);	 
		LED* LEDs ();	 
		void Show();
 };
