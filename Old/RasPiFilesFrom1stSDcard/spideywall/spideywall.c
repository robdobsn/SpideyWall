/*
 * Spidey Wall Software
 * V0.2
 * 
 * Rob 2012/09/30
 * 
 */

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <ctype.h>

#include "ledstrip.h"


#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define numLeds 1800
#define valsPerLed 3
#define bufLen (numLeds * valsPerLed)

static void pabort(const char *s)
{
	perror(s);
	abort();
}

static const char *device = "/dev/spidev0.0";
static uint8_t mode;
static uint8_t bits = 8;
static uint32_t speed = 1000000;
static uint16_t delay;
	
static void transfer(int fd, int stepIdx, int colrIdx)
{
	int ret;
	uint8_t tx[bufLen];
	uint8_t rx[bufLen] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = ARRAY_SIZE(tx),
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};

	memset(tx, 0, ARRAY_SIZE(tx));
//	int i = 0;
//	for (i = 0; i < ARRAY_SIZE(tx); i++)
//		tx[i] = 0x0;
	int j = 0;
	for (j = 0; j < numLeds; j+=10)
	{
		int k = stepIdx + j;
		if (k > numLeds)
			continue;
		tx[k*valsPerLed] = colrIdx * 87;
		tx[k*valsPerLed+1] = colrIdx * 93;
		tx[k*valsPerLed+2] = colrIdx * 13;
	}
/*		for (j = 0; j < 10; j++)
	{
		int k = numLeds - stepIdx - j * numLeds / 10;
		if (k > numLeds)
			k = 0;
		tx[k*valsPerLed] = colrIdx * 43;
		tx[k*valsPerLed+1] = colrIdx * 27;
		tx[k*valsPerLed+2] = colrIdx * 93;
	}
*/
	tr.tx_buf = (unsigned long)tx;
	
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
	{
		usleep(50000);
		printf(".");
	}
		//pabort("can't send spi message");

//	for (ret = 0; ret < ARRAY_SIZE(tx); ret++) {
//		if (!(ret % 6))
//			puts("");
//		printf("%.2X ", rx[ret]);
//	}
//	puts("");
	
}

static void print_usage(const char *prog)
{
	printf("Usage: %s [-DsbdlHOLC3]\n", prog);
	puts("  -D --device   device to use (default /dev/spidev1.1)\n"
	     "  -s --speed    max speed (Hz)\n"
	     "  -d --delay    delay (usec)\n"
	     "  -b --bpw      bits per word \n"
	     "  -l --loop     loopback\n"
	     "  -H --cpha     clock phase\n"
	     "  -O --cpol     clock polarity\n"
	     "  -L --lsb      least significant bit first\n"
	     "  -C --cs-high  chip select active high\n"
	     "  -3 --3wire    SI/SO signals shared\n");
	exit(1);
}

static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "device",  1, 0, 'D' },
			{ "speed",   1, 0, 's' },
			{ "delay",   1, 0, 'd' },
			{ "bpw",     1, 0, 'b' },
			{ "loop",    0, 0, 'l' },
			{ "cpha",    0, 0, 'H' },
			{ "cpol",    0, 0, 'O' },
			{ "lsb",     0, 0, 'L' },
			{ "cs-high", 0, 0, 'C' },
			{ "3wire",   0, 0, '3' },
			{ "no-cs",   0, 0, 'N' },
			{ "ready",   0, 0, 'R' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "D:s:d:b:lHOLC3NR", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'D':
			device = optarg;
			break;
		case 's':
			speed = atoi(optarg);
			break;
		case 'd':
			delay = atoi(optarg);
			break;
		case 'b':
			bits = atoi(optarg);
			break;
		case 'l':
			mode |= SPI_LOOP;
			break;
		case 'H':
			mode |= SPI_CPHA;
			break;
		case 'O':
			mode |= SPI_CPOL;
			break;
		case 'L':
			mode |= SPI_LSB_FIRST;
			break;
		case 'C':
			mode |= SPI_CS_HIGH;
			break;
		case '3':
			mode |= SPI_3WIRE;
			break;
		case 'N':
			mode |= SPI_NO_CS;
			break;
		case 'R':
			mode |= SPI_READY;
			break;
		default:
			print_usage(argv[0]);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	int ret = 0;
	int fd;

	parse_opts(argc, argv);

	fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("can't open device");

	/*
	 * spi mode
	 */
	ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
	if (ret == -1)
		pabort("can't set spi mode");

	ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
	if (ret == -1)
		pabort("can't get spi mode");

	/*
	 * bits per word
	 */
	ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't set bits per word");

	ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't get bits per word");

	/*
	 * max speed hz
	 */
	ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't set max speed hz");

	ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't get max speed hz");

	printf("spi mode: %d\n", mode);
	printf("bits per word: %d\n", bits);
	printf("max speed: %d Hz (%d KHz)\n", speed, speed/1000);

	int stepIdx = 0;
	int colrIdx = 0;
	while(1)
	{
		usleep(25000);
//		int ch = toupper(getchar());
//		if (ch == 'X')
//			break;
		stepIdx++;
		if (stepIdx >= 10)
		{
			stepIdx = 0;
			colrIdx++;
		}
		transfer(fd, stepIdx, colrIdx);
	}

	close(fd);

	return ret;
}
