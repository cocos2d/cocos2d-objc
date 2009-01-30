/* Copyright (c) 2007 Scott Lembcke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
// Used for resizing hash tables.
// Values approximately double.

static int primes[] = {
	5,          //2^2  + 1
	11,         //2^3  + 3
	17,         //2^4  + 1
	37,         //2^5  + 5
	67,         //2^6  + 3
	131,        //2^7  + 3
	257,        //2^8  + 1
	521,        //2^9  + 9
	1031,       //2^10 + 7
	2053,       //2^11 + 5
	4099,       //2^12 + 3
	8209,       //2^13 + 17
	16411,      //2^14 + 27
	32771,      //2^15 + 3
	65537,      //2^16 + 1
	131101,     //2^17 + 29
	262147,     //2^18 + 3
	524309,     //2^19 + 21
	1048583,    //2^20 + 7
	2097169,    //2^21 + 17
	4194319,    //2^22 + 15
	8388617,    //2^23 + 9
	16777259,   //2^24 + 43
	33554467,   //2^25 + 35
	67108879,   //2^26 + 15
	134217757,  //2^27 + 29
	268435459,  //2^28 + 3
	536870923,  //2^29 + 11
	1073741827, //2^30 + 3
	0,
};

static int
next_prime(int n)
{
	int i = 0;
	while(n > primes[i]){
		i++;
		assert(primes[i]); // realistically this should never happen
	}
	
	return primes[i];
}
