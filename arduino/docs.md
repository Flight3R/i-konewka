In our project, we use an Arduino ESP32 board. We use the default Arduino library and the BluetoothSerial library for Bluetooth connections. The pump is connected to the Arduino on pin 2.

# Bluetooth connection
Each command contains a **header** and a **value**. None of them should exceed the length of 100 characters. They are received as plain text and separated by a space. There are two commands that can be executed on the board:
- connect - it has no value and returns the text "ok". It is used to make sure you are connected to a good device
- water - contains an integer value as the number of milliliters that will be pumped. Returns no value 

# Code
Arduino's code is divided into three crucial segments: 
## Setup 
Part of code that runs once, after running Arduino. In our code, we define the pump pin as a digital output and open Bluetooth serial.

## Loop
This part of the code works in a loop after setup. In each iteration, we check Bluetooth serial availability and receive commands. The main part of the code is watering, called by the command "water". Its parameter is the number of milliliters, converted to the number of milliseconds the pump has to work by the constant PUMP_CAPACITY = 0.0015 [ml/msec]. Executing watering is not blocking. That means when watering is on, Arduino isn't waiting for watering to be finished, and other activities can be executed. It measures time in each iteration and subtracts it from the total time the pump should be on. When this time comes to zero, the watering will stop.

## Command class
This class is used for interpreting input commands. It has several public methods:
- read - read data from serial and divide it into two char arrays: header and value (each max 100 characters length).
- is - get a char array as input and check if the header equals the input array
- isVal - get a char array as input and check if the value equals the input array
- valToInt - try to convert a value from a char array to an integer 
