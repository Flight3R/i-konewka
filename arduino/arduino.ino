#include <BluetoothSerial.h>

#define PUMP 2
#define MAX_LENGTH 100
#define PUMP_CAPACITY 0.0015 // ml/msec

BluetoothSerial SerialBT;


class Command {
  public:

    char head[MAX_LENGTH];
    char val[MAX_LENGTH];

    void read() {
      char com[2 * MAX_LENGTH + 1];
      int len = SerialBT.readBytes(com, 2 * MAX_LENGTH + 1);

      int i = 0;
      int spacePos = -1;
      while (i < len) {
        if (com[i] == ' ') {
          spacePos = i;
          head[i] = 0;
        }
        else if (spacePos == -1) {
          head[i] = com[i];
        }
        else {
          val[i - spacePos - 1] = com[i];
        }
        i++;
      }

      if (spacePos == -1) {
        head[i] = 0;
        val[0] = 0;
      }
      else val[i - spacePos - 1] = 0;
    }


    bool is(char* s) {
      if (strcmp(head, s) == 0) return true;
      else return false;
    }

    bool isVal(char* s) {
      if (strcmp(val, s) == 0) return true;
      else return false;
    }

    int valToInt() {
      int i;
      sscanf(val, "%d", &i);
      return i;
    }
};

int millilitersToMilliseconds(int milliliters){
  return milliliters/PUMP_CAPACITY;
}


int timeToTurnOffPump = 0;
int previousTime = 0;

void setup() {
  pinMode(PUMP, OUTPUT);
  
  Serial.begin(9600);
  SerialBT.begin("IKonewka");
}

void loop() {
  if (SerialBT.available()) {
    Command c;
    c.read();

    if(c.is("connect")) {
      SerialBT.println("ok");
    } 
    else if (c.is("water")) {
      timeToTurnOffPump = millilitersToMilliseconds(c.valToInt());
    }
  }

  int elapsedTime = millis() - previousTime;

  if(timeToTurnOffPump > 0) {
    digitalWrite(PUMP, HIGH);
    timeToTurnOffPump -= elapsedTime;
  } else {
    digitalWrite(PUMP, LOW);
    timeToTurnOffPump = 0;
  }

  previousTime = millis();
  delay(5);
}
