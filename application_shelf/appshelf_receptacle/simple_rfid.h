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
    byte connectionStatuses{0b0000};
    TokenPresence tokenPresence{noTokenDetected};
    using Pin = uint8_t;

   public:
    SimpleRfid(Pin chipSelect, Pin reset) : MFRC522{chipSelect, reset} {}
    void begin() { return PCD_Init(); }
    byte getFirstUidByte() { return uid.uidByte[0]; }
    TokenPresence getTokenPresence() { return tokenPresence; }
    void monitorConnection() {
        connectionStatuses <<= 1;
        if (PICC_IsNewCardPresent() && PICC_ReadCardSerial()) {
            connectionStatuses |= 1;
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
            // intentional fallthrough
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
