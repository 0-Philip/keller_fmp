
#include <ESP8266WiFi.h>
#include <SPI.h>
#include <espnow.h>

#include "envelope_token.h"
#include "simple_rfid.h"

using Pin = uint8_t;
constexpr Pin chipSelect{5};
constexpr Pin reset{4};

SimpleRfid rfid{chipSelect, reset};

void setup() {
    Serial.begin(9600);
    beginEspNowAsReceiver(OnDataReceive);
    SPI.begin();
    rfid.begin();
    Serial.println(WiFi.macAddress());
}

void loop() {
    rfid.monitorConnection();

    switch (rfid.getTokenPresence()) {
        case SimpleRfid::tokenAdded: {
            selectTokenById(rfid.getFirstUidByte())->onInsert();
            break;
        }
        case SimpleRfid::tokenRemoved: {
            selectTokenById(rfid.getFirstUidByte())->close();
            break;
        }
        default:
            break;
    }
}

EnvelopeToken* const selectTokenById(byte id) {
    static EnvelopeToken tokens[]{
        EnvelopeToken{0x30, "YB"},  // the two character names are an artifact from
        EnvelopeToken{0x77, "MG"},  // previous implementations and remain only for
        EnvelopeToken{0x53, "KR"},  // compatibility
        EnvelopeToken{0xE3},
        EnvelopeToken{0xD3}};
    for (auto& token : tokens) {
        if (token.matches(id)) return &token;
    }
    static NullToken nulltkn{};
    return &nulltkn;
}

void OnDataReceive(byte* macAddress, byte* incomingData, byte length) {
    selectTokenById(*incomingData)->send();
}

void beginEspNowAsReceiver(esp_now_recv_cb_t callback) {
    WiFi.mode(WIFI_STA);
    if (esp_now_init() != 0) {
        Serial.println(F("Error initializing ESP-NOW"));
        return;
    }
    esp_now_set_self_role(ESP_NOW_ROLE_SLAVE);
    esp_now_register_recv_cb(callback);
}
