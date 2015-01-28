#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Public domain XXTEA algorithm
// Source http://en.wikipedia.org/wiki/XXTEA
#define DELTA 0x9e3779b9
#define MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z)))
static void TEA_encrypt(uint32_t *v, int n, uint32_t const key[4]) {
    uint32_t y, z, sum;
    unsigned p, rounds, e;
	rounds = 6 + 52/n;
	sum = 0;
	z = v[n-1];
	do {
		sum += DELTA;
		e = (sum >> 2) & 3;
		for (p=0; p<n-1; p++) {
			y = v[p+1]; 
			z = v[p] += MX;
		}
		y = v[0];
		z = v[n-1] += MX;
	} while (--rounds);
}

static void TEA_decrypt(uint32_t *v, int n, uint32_t const key[4]) {
    uint32_t y, z, sum;
    unsigned p, rounds, e;
	rounds = 6 + 52/n;
	sum = rounds*DELTA;
	y = v[0];
	do {
		e = (sum >> 2) & 3;
		for (p=n-1; p>0; p--) {
			z = v[p-1];
			y = v[p] -= MX;
		}
		z = v[n-1];
		y = v[0] -= MX;
		sum -= DELTA;
	} while (--rounds);
}

// Block size in 4 byte words
#define BLOCK_SIZE 1024

static void
Usage()
{
	fprintf(stderr, "Usage teacrypt {--encrypt | --decrypt} [key] < infile > outfile\n");
	abort();
}

int main(int argc, char **argv)
{
	if(argc != 3) Usage();
	
	uint32_t key[4] = {};
	sscanf(argv[2], "%08x%08x%08x%08x", &key[0], &key[1], &key[2], &key[3]);
	
	uint32_t buffer[BLOCK_SIZE];
	
	if(strcmp(argv[1], "--encrypt") == 0){
		for(;;){
			// Store the block length in the first word.
			// Does not bother to handle endianness!
			buffer[0] = fread(buffer + 1, 1, BLOCK_SIZE*4 - 4, stdin);
			if(buffer[0] == 0) break;
			
			TEA_encrypt(buffer, BLOCK_SIZE, key);
			
			// Write out the full block.
			// This may expand small files slightly.
			fwrite(buffer, 4, BLOCK_SIZE, stdout);
		}
	} else if(strcmp(argv[1], "--decrypt") == 0) {
		for(;;){
			fread(buffer, 4, BLOCK_SIZE, stdin);
			TEA_decrypt(buffer, BLOCK_SIZE, key);
			
			// The block size is stored in the first word.
			fwrite(buffer + 1, 1, buffer[0], stdout);
			if(buffer[0] < BLOCK_SIZE - 1) break;
		}
	} else {
		Usage();
	}
	
	return 0;
}
