#ifndef SIMPLERFID_H
#include <MFRC522.h>
class SimpleRfid : private MFRC522

{
   public:
    enum TokenPresence : int {
        noTokenDetected,
        tokenPresent,
        tokenRemoved,
        tokenAdded
    };

   private:
   /* 
        each bit represents whether a token was detected on a loop iteration
        right most bit is most recent 
    */ 
    byte connectionStatuses{0b0000}; 

    TokenPresence tokenPresence{noTokenDetected};
    using Pin = uint8_t;

   public:
    SimpleRfid(Pin chipSelect, Pin reset) : MFRC522{chipSelect, reset} {}
    void begin() { return PCD_Init(); }
    byte getFirstUidByte() { return uid.uidByte[0]; }
    TokenPresence getTokenPresence() { return tokenPresence; }

    /* 
        when a card only detected every other loop when present
        monitorConnection() compensates for this and sets 
        the tokenPresence appropriately
    */

    void monitorConnection() {
        connectionStatuses <<= 1; 
        if (PICC_IsNewCardPresent() && PICC_ReadCardSerial()) {
            connectionStatuses |= 1;    //rightmost bit set to 1 if detected
        }

        switch (connectionStatuses & 0b0111) {
            case 0b0000:
                tokenPresence = noTokenDetected;
                break;
            case 0b0001:
                tokenPresence = tokenAdded;
                break;
            case 0b0100:
                tokenPresence = tokenRemoved;
                break;
            case 0b0101:
            case 0b0010:
                tokenPresence = tokenPresent;
                break;
            default:
                tokenPresence = noTokenDetected;
                break;
        }
    }
};

#define SIMPLERFID_H
#endif