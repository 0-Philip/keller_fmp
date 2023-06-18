#include "debouncer.h"

bool Debouncer::enoughTimePassedSince(Time time) {
    return (millis() - time) > m_threshold;
}

int Debouncer::getLatestStableReading(int reading, Time lastDebounceTime, int lastStableReading) {
    return enoughTimePassedSince(lastDebounceTime) ? reading : lastStableReading;
}

unsigned long Debouncer::getTimeOfLastChange(int reading, int previousState, Time lastTimeOfChange) {
    return reading != previousState ? millis() : lastTimeOfChange;
}

void Debouncer::monitor() {
    const int reading = digitalRead(m_buttonPin);
    const unsigned long currentDebounceTime = getTimeOfLastChange(reading, lastButtonState, lastDebounceTime);
    const int currentStableReading = getLatestStableReading(reading, currentDebounceTime, lastStableReading);

    if (lastStableReading == HIGH && currentStableReading == LOW) {
        m_shouldRunThisLoop = true;
    } else {
        m_shouldRunThisLoop = false;
    }

    lastDebounceTime = currentDebounceTime;
    lastButtonState = reading;
    lastStableReading = currentStableReading;
}