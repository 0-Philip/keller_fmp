#include <ESP8266WiFi.h>
#include <SPI.h>
#include <espnow.h>

#include "simple_rfid.h"
// #include "simple_tokens.h"

using Pin = int;

enum Commands : unsigned char {
    shelved = 's',
    unshelved = 'u'
};

constexpr Pin chipSelectPin{5};
constexpr Pin resetPin{4};
uint8_t broadcastAddress[]{0xA4, 0xCF, 0x12, 0xD7, 0x37, 0xCB};

SimpleRfid rfid{chipSelectPin, resetPin};

void OnDataSent(byte* mac_addr, byte sendStatus) {
    Serial.print("Last Packet Send Status: ");
    if (sendStatus == 0) {
        Serial.println("Delivery success->");

    } else {
        Serial.println("Delivery fail");
    }
}

void setup() {
    // put your setup code here, to run once:
    delay(2000);
    Serial.begin(9600);
    beginEspNowAsSenderTo(broadcastAddress, OnDataSent);
    SPI.begin();   // Init SPI bus
    rfid.begin();  // Init MFRC522
}

void loop() {
    rfid.monitorConnection();

    switch (rfid.getTokenPresence()) {
        case SimpleRfid::tokenRemoved:
            sendCommandString(broadcastAddress, rfid.getFirstUidByte(), unshelved);
            break;
        case SimpleRfid::tokenAdded:
            sendCommandString(broadcastAddress, rfid.getFirstUidByte(), shelved);
            break;
        default:
            break;
    }
}

void sendCommandString(byte* adress, const unsigned char appId, const Commands command) {
    unsigned char commandString[] = {appId, command};
    esp_now_send(adress, commandString, sizeof(commandString));
}

void beginEspNowAsSenderTo(byte receiverAdress[], esp_now_send_cb_t callback) {
    WiFi.mode(WIFI_STA);
    if (esp_now_init() != 0) {
        Serial.println("Error initializing ESP-NOW");
        return;
    }

    esp_now_set_self_role(ESP_NOW_ROLE_CONTROLLER);
    esp_now_register_send_cb(callback);

    constexpr int channel{1};
    constexpr byte* key{nullptr};
    constexpr int keyLength{0};
    esp_now_add_peer(receiverAdress, ESP_NOW_ROLE_SLAVE, channel, key, keyLength);
}