README
Ian Laffey
260820791
4/4/19

General:

	All code is working and stable on my machine using a fixed delay of 1 instruction 
	execution. However some bugs may crop up using higher delays

	On my machine, in order to properly use the display in the MMIO simulator on MIPS 
	I have to disconnect and reconnect the simulator from MIPS every time I run 	
	otherwise it will never print anything 

Q1:

	I do not use sys calls to print any fixed strings in Q1, they all appear on MMIO 
	display

Q2:

	As per https://mycourses2.mcgill.ca/d2l/le/387444/discussions/threads/636586/View
	I assume that the user inputs a SPACE before s or c (it doesn't really matter if 	they do for q because that just quits). The discussion boards weren't 100% clear 	on the matter, and if I lose marks for that its ok just know that the program 		works exactly as intended when you input space before s

	If you're curious this is because SPACE is what actually saves the inputted 		digits to the array and reduces a lot of headache with converting two dig ascii 	to int

