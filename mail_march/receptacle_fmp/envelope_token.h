#ifndef ENVELOPE_TOKEN_H
#define ENVELOPE_TOKEN_H
#include <Arduino.h>

class EnvelopeToken {
   private:
    bool isEmpty{true};
    const byte firstByteInUid;
    const char* const name; // for compatibility with old implementation

   public:
    EnvelopeToken(byte id, const char* const name_ = nullptr) : firstByteInUid{id}, name{name_} {}
    ~EnvelopeToken() = default;
    virtual void printName() const {
        if (name) {
            Serial.print(name);
        } else {
            Serial.print(firstByteInUid);
        }
    }
    virtual void onInsert() {
        if (isEmpty) {
            Serial.println(F("create"));
            isEmpty = false;
        } else {
            printName();
            Serial.println(F("/reopen"));
        }
    }
    virtual void send() {
        if (!isEmpty) {
            printName();
            Serial.println(F("/send"));
            isEmpty = true;
        }
    }
    virtual void close() const {
        printName();
        Serial.println(F("/close"));
    }
    virtual bool matches(byte pattern) const {
        return firstByteInUid == pattern;
    }
};

class NullToken : public EnvelopeToken
{
private:
    /* data */
public:
    NullToken() : EnvelopeToken{0x00}{}
    ~NullToken() = default;
   void printName() const override {}
   void onInsert() override{}
   void send() override{}
   void close() const override{}
   bool matches(byte pattern) const override{
    return false;
   }

};


#endif