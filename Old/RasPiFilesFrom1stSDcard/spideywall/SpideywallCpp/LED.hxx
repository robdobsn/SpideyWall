/*
 * Spidey Wall LED strip class
 *
 */
 
 class LED
 {
	 private:
	  unsigned char R;
	  unsigned char G;
	  unsigned char B;
	 
	 public:	
	 LED()
	 {
		 R = G = B = 0;
	 }
	 
	 LED(int iR, int iG, int iB)
	 {
		 R = (unsigned char)iR;
		 G = (unsigned char)iG;
		 B = (unsigned char)iB;
	 }
	 
	 void GetBytes(unsigned char *buf)
	 {
		 buf[0] = R;
		 buf[1] = G;
		 buf[2] = B;
	 }
	 
 };
