#ifndef ENVELOPE_TOKEN_H
#define ENVELOPE_TOKEN_H
#include <Arduino.h>

class SimpleToken {
   private:
    const byte firstByteInUid;
    const char* const name;

   public:
    SimpleToken(byte id, const char* const name_ = nullptr) : firstByteInUid{id}, name{name_} {}
    virtual ~SimpleToken() = default;
    void printName() const {
        if (name) {
            Serial.print(name);
        } else {
            Serial.print(firstByteInUid);
        }
    }

    bool matches(byte pattern) const {
        return firstByteInUid == pattern;
    }
};

class EnvelopeToken : public SimpleToken {
   private:
    bool isEmpty{true};

   public:
    EnvelopeToken(byte id, const char* const name = nullptr) : SimpleToken{id, name} {}
    ~EnvelopeToken() = default;
    void onInsert() {
        if (isEmpty) {
            Serial.println(F("open"));
            isEmpty = false;
        } else {
            printName();
            Serial.println(F("/reopen"));
        }
    }
    void send() {
        if (!isEmpty) {
            printName();
            Serial.println(F("/send"));
            isEmpty = true;
        }
    }
    void close() const {
        printName();
        Serial.println(F("/close"));
    }
};

class AppToken : public SimpleToken {
   private:
   public:
    AppToken(byte id, const char* const name = nullptr) : SimpleToken{id, name} {}
    ~AppToken() = default;

    void tokenUnshelved() const {
        printName();
        Serial.println(F("/launch"));
        delay(2000);
        printName();
        Serial.println(F("/minmiz"));
    }
    void tokenShelved() const {
        printName();
        Serial.println(F("/quit"));
    }
    void tokenInserted() const {
        printName();
        Serial.println(F("/show"));
    }
    void tokenUninserted() const {
        printName();
        Serial.println(F("/minmiz"));
    }
};

#endif