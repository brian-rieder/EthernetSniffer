#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

#include "PCIE.h"

//MAX BUFFER FOR DMA
#define MAXDMA 16

//BASE ADDRESS FOR CONTROL REGISTER
//#define CRA 0x00004080		// This is the starting address of the Custom Slave module. This maps to the address space of the custom module in the Qsys subsystem.
#define CRA 0x00000000		// This is the starting address of the Custom Slave module. This maps to the address space of the custom module in the Qsys subsystem.

//BASE ADDRESS TO SDRAM
#define SDRAM 0x08000000	// This is the starting address of the SDRAM controller. This maps to the address space of the SDRAM controller in the Qsys subsystem.
#define START_BYTE 0xF00BF00B
#define STOP_BYTE 0xDEADF00B
#define RWSIZE (32 / 8)
PCIE_BAR pcie_bars[] = { PCIE_BAR0, PCIE_BAR1 , PCIE_BAR2 , PCIE_BAR3 , PCIE_BAR4 , PCIE_BAR5 };

void test32( PCIE_HANDLE hPCIe, DWORD addr );
DWORD convertToDWord( char input[], int bits);
//void testDMA( PCIE_HANDLE hPCIe, DWORD addr);
DWORD floatToDWORD(char input[], int bits);
int main(void)
{
	void *lib_handle;
	PCIE_HANDLE hPCIe;

	lib_handle = PCIE_Load();		// Dynamically Load the PCIE library
	if (!lib_handle)
	{
		printf("PCIE_Load failed\n");
		return 0;
	}
	hPCIe = PCIE_Open(0,0,0);		// Every device is a like a file in UNIX. Opens the PCIE device for reading/writing

	if (!hPCIe)
	{
		printf("PCIE_Open failed\n");
		return 0;
	}

	//test CRA
	test32(hPCIe, CRA);			// Test the Configuration Registers for reads and writes
	PCIE_Write32( hPCIe, pcie_bars[0], CRA, START_BYTE);
	//test SDRAM
	//testDMA(hPCIe,SDRAM);			// Test the SDRAM for reads and writes

	PCIE_Write32( hPCIe, pcie_bars[0], CRA, STOP_BYTE);
	//printf("\nPush up SW[16] to view data stored in SDRAM and use SW[3:0] to select different addresses.\n");
	return 0;
}

//Tests 16 consecutive PCIE_Write32 to address

void test32( PCIE_HANDLE hPCIe, DWORD addr )
{
	BOOL bPass;
	DWORD testVal = 0xf;
	DWORD readVal;
	char input [37];
	//char testChar = 'n';
	int testChar = 0;
	printf("There's No Place Like 127.0.0.1: Ethernet Sniffer and Packet Flagger\n");
	printf("Created by Brian Rieder, Catie Cowden, and Shaughan Gladden\n\n");
	printf("------------------------------------------------------------\n\n");

	while (testChar != 1) {
	  printf("Please provide an IP address to flag: ");
	  scanf("%u",&testVal);
	  // testVal = floatToDWORD(input,18);
	  bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr, testVal);
	  PCIE_Read32( hPCIe, pcie_bars[0], addr, &readVal);
	  printf("Flagged IP: %u\t%u\n",testVal,readVal);

	  printf("Please provide a MAC address to flag: ");
	  scanf("%u",&testVal);
	  // testVal = floatToDWORD(input,18);
	  bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr+4, testVal);
	  PCIE_Read32( hPCIe, pcie_bars[0], addr+4, &readVal);
	  printf("Flagged MAC: %u\t%u\n",testVal,readVal);

	  printf("Please provide a port to flag: ");
	  scanf("%u",&testVal);
	  // testVal = floatToDWORD(input,18);
	  bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr+8, testVal);
	  PCIE_Read32( hPCIe, pcie_bars[0], addr+8, &readVal);
	  printf("Flagged Port: %u\t%u\n",testVal,readVal);

	  printf("Please provide a URL to flag: ");
	  scanf("%u",&testVal);
	  // testVal = floatToDWORD(input,18);
	  bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr+12, testVal);
	  PCIE_Read32( hPCIe, pcie_bars[0], addr+12, &readVal);
	  printf("Flagged URL: %u\t%u\n",testVal,readVal);

	  printf("Please choose a packet to transmit: 1) Purdue, 2) Wired, 3) ExtremeTech");
	  scanf("%u",&testVal);
	  // testVal = floatToDWORD(input,18);
	  bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr+16, testVal);
	  PCIE_Read32( hPCIe, pcie_bars[0], addr+16, &readVal);
	  printf("Chosen packet: %u\t%u\n",testVal,readVal);

	  while(1) {}

	 //  while(1) {
		// PCIE_Read32( hPCIe, pcie_bars[0], addr+20, &readVal);
		// printf("Addr 20: %u\n",readVal);
	 //  }

	  // printf("Would you like to exit? (1/0) ");
	  // scanf("%i",&testChar);
	  // printf("\n\n");
	  /*	  if (!bPass)
	  {
	    printf("test FAILED: write did not return success");
            return;
	  }
	  bPass = PCIE_Read32( hPCIe, pcie_bars[0], addr, &readVal);
	  if (!bPass)
	  {
	    printf("test FAILED: read did not return success");
	    return;
	  }
	  printf("Testing register at addr %x with value %x: ", addr, testVal);

	  if (testVal == readVal)
	  {
	    printf("Test PASSED: expected %x, received %x\n", testVal, readVal);
	  }
	  else
	  {
	    printf("Test FAILED: expected %x, received %x\n", testVal, readVal);
	  }
	  //testVal = testVal + 1;*/
	 
	}
	return;
}

DWORD convertToDWord(char input[], int bits)
{
  DWORD out = 0;
  int i;
  for(i = 0; i < bits; i++){
    if (input[i]=='1') {
      out |= (1<<(bits-1-i));
    }
  }
  return out;
}

DWORD floatToDWORD(char input[], int bits)
{
  float f = atof(input);
  DWORD out = 0;
  int i;
  float div = 2;
  for (i=0; i < bits; i++) {
//    printf("%f\t%f\t%u\n",f,div,out);

    if ((f-div) >= 0) {
      out |= (1<<(bits-1-i));
      f=f-div;
    }
    div=div/2;
  }
  return out;
}

//tests DMA write of buffer to address
/*void testDMA( PCIE_HANDLE hPCIe, DWORD addr)
{
	BOOL bPass;
	DWORD testArray[MAXDMA];
	DWORD readArray[MAXDMA];
	
	WORD i = 1;
	testArray[0] = START_BYTE;
	while ( i < MAXDMA )
	{
		testArray[i] = i  + 0x0f;
		i++;
	}

	//bPass = PCIE_DmaWrite(hPCIe, addr, testArray, MAXDMA * RWSIZE );
	//if (!bPass)
	//{
	//	printf("test FAILED: write did not return success");
	//	return;
	//}
	bPass = PCIE_DmaRead(hPCIe, addr, readArray, MAXDMA * RWSIZE );
	if (!bPass)
	{
		printf("test FAILED: read did not return success");
		return;
	}
	i = 0;
	while ( i < MAXDMA )
	{
		printf("Testing SDRAM at addr %x: ", addr);
		if (testArray[i] == readArray[i])
		{
			printf("Test PASSED: expected %x, received %x\n", testArray[i], readArray[i]);
		}
		else
		{
			printf("Test FAILED: expected %x, received %x\n", testArray[i], readArray[i]);
		}
		i++;
		addr = addr + 4;
	}
	return;
	}
*/
