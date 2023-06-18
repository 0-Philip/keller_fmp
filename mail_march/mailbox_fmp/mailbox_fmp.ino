#include <ESP8266WiFi.h>
#include <FastLED.h>
#include <SPI.h>
#include <espnow.h>
#include <array>

#include "simple_rfid.h"

enum class FeedbackType {
    none,
    sent,
    error
};

using MacAdress = std::array<byte, 6>;

namespace {  // FastLED also has type called Pin. Namespace prevents conflicting declarations
using Pin = uint8_t;
constexpr Pin dataPin{0};
constexpr Pin chipSelectPin{5};
constexpr Pin resetPin{4};
} 

constexpr int ledCount{64};

constexpr MacAdress broadcastAddress{0xA4, 0xCF, 0x12, 0xD7, 0x37, 0xCB}; // pretty receptacle
// constexpr MacAdress broadcastAddress{0x7C, 0x87, 0xCE, 0xB5, 0x23, 0xD4};  // ugly receptacle

SimpleRfid rfid{chipSelectPin, resetPin};
CRGB leds[ledCount];
FeedbackType feedback{FeedbackType::none};

void OnDataSent(byte* mac_addr, byte sendStatus) {
    Serial.print("Last Packet Send Status: ");
    if (sendStatus == 0) {
        Serial.println("Delivery success->");
        feedback = FeedbackType::sent;

    } else {
        Serial.println("Delivery fail");
        feedback = FeedbackType::error;
    }
}

void setup() {
    // put your setup code here, to run once:
    delay(2000);
    Serial.begin(9600);
    beginEspNowAsSenderTo(broadcastAddress, OnDataSent);
    SPI.begin();   // Init SPI bus
    rfid.begin();  // Init MFRC522
    FastLED.addLeds<NEOPIXEL, dataPin>(leds, ledCount);
    setAllTo(CRGB::Black);
}

void loop() {
    rfid.monitorConnection();
    if (rfid.getTokenPresence() == SimpleRfid::tokenRemoved) {
        sendByte(broadcastAddress, rfid.getFirstUidByte());
        Serial.println(rfid.getFirstUidByte());
    }

    switch (feedback) {
        case FeedbackType::sent: {
            playLoadingAnimation();
            break;
        }
        case FeedbackType::error: {
            setAllTo(CRGB::Red);
            blockingDelay(1000);
            setAllTo(CRGB::Black);
            blockingDelay(1000);
            break;
        }
        case FeedbackType::none: {
            setAllTo(CRGB::Black);
            break;
        }
    }
    feedback = FeedbackType::none;
}

void sendByte(MacAdress const& adress, const byte outgoingData) {
    byte dataMutableCopy = outgoingData;
    MacAdress adressMutableCopy = adress; // esp now api needs the address to be mutable 🤷🏻‍♂️
    esp_now_send(adressMutableCopy.data(), &dataMutableCopy, sizeof(outgoingData));
}

void playLoadingAnimation() {
    setAllTo(CRGB::Blue);
    for (byte i = 0; i < 8; i++) {
        setColumn(i, CRGB::Green);
        blockingDelay(100);  // waits for 100ms
    }
    blockingDelay(500);
    setAllTo(CRGB::Black);
}

void setAllTo(CRGB color) {
    for (auto& led : leds) led = color;
    FastLED.show();
}

void setColumn(int columnIndex, CRGB color) {
    for (byte j = 0; j <= 48; j += 16) {
        leds[7 - columnIndex + j] = color;
        leds[8 + columnIndex + j] = color;
    }
    FastLED.show();
}

void blockingDelay(int timeInMs) {
    auto timeNow = millis();
    while (millis() < timeNow + timeInMs)
        ;
        yield(); // prevents crash from esp not keeping up
}

void beginEspNowAsSenderTo(MacAdress const& receiverAdress, esp_now_send_cb_t callback) {
    WiFi.mode(WIFI_STA);
    if (esp_now_init() != 0) {
        Serial.println("Error initializing ESP-NOW");
        return;
    }
    esp_now_set_self_role(ESP_NOW_ROLE_CONTROLLER);
    esp_now_register_send_cb(callback);

    MacAdress adressMutableCopy = receiverAdress;  // esp now api needs the address to be mutable 🤷🏻‍♂️
    constexpr int channel{1};
    constexpr byte* key{nullptr};
    constexpr int keyLength{0};
    esp_now_add_peer(adressMutableCopy.data(), ESP_NOW_ROLE_SLAVE, channel, key, keyLength);
}