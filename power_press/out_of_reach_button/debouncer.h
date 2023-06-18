#ifndef DEBOUNCER_H
#define DEBOUNCER_H
#include <Arduino.h>

class Debouncer {
    using Time = unsigned long;

   private:
    const Time m_threshold = 50UL;
    const int m_buttonPin;
    bool m_shouldRunThisLoop = false;
    Time lastDebounceTime = 0UL;
    int lastButtonState = LOW;
    int lastStableReading = LOW;
    bool enoughTimePassedSince(Time);
    unsigned long getTimeOfLastChange(int, int, Time);
    int getLatestStableReading(int, Time, int);

   public:
    bool wasPressed() { return m_shouldRunThisLoop; };

    Debouncer(int buttonPin): m_buttonPin{buttonPin}{} //buttonPin must be set to INPUT_PULLUP before construction
    Debouncer(int buttonPin, Time threshold): m_buttonPin{buttonPin}, m_threshold{threshold}{} 
    ~Debouncer() = default;
    void monitor();
};

#endif  // DEBOUNCER_H
