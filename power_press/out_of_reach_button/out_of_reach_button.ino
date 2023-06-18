#include "debouncer.h"
#include "Keyboard.h"

using PinNumber = int;
using Key = unsigned char;

constexpr PinNumber inputPin{3};
constexpr Key command{KEY_LEFT_GUI};

void setup() {
    Keyboard.begin();
    Serial.begin(9600);
    pinMode(inputPin, INPUT_PULLUP);
}

void loop() {
    static Debouncer button{inputPin};
    button.monitor();
    
    if (button.wasPressed()) {
       screenshot();
        Serial.println("I'll do the thing!");

    }
}

void screenshot(){
 Keyboard.press(KEY_LEFT_SHIFT); 
        Keyboard.press(command);
        Keyboard.press('3');
        Keyboard.releaseAll();
}
