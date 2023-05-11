#include <ESP8266WiFi.h>
#include <SPI.h>
#include <espnow.h>

#include <memory>
#include <vector>
using std::vector;

#include "simple_rfid.h"
#include "simple_tokens.h"

using Pin = uint8_t;
constexpr Pin chipSelect{5};
constexpr Pin reset{4};

SimpleRfid rfid{chipSelect, reset};

vector<AppToken> apps;

AppToken testApp{0xCC};

void setup() {
    Serial.begin(9600);
    beginEspNowAsReceiver(OnDataReceive);
    SPI.begin();
    rfid.begin();
    apps.reserve(3);
}

void loop() {
    rfid.monitorConnection();

    switch (rfid.getTokenPresence()) {
        case SimpleRfid::tokenAdded: {
            // auto currentToken{selectTokenById(rfid.getFirstUidByte())};
            // if (currentToken) currentToken->tokenInserted();

            // break;
            auto currentToken{selectTokenById2(rfid.getFirstUidByte(), apps)};
            if (currentToken) {
                currentToken->tokenInserted();
            } else {
                AppToken newApp{rfid.getFirstUidByte()};
                apps.push_back(newApp);
                Serial.println(F("New object dynamically allocated"));
                apps.back().tokenInserted();
            }
            break;
        }
        case SimpleRfid::tokenRemoved: {
            auto currentToken{selectTokenById2(rfid.getFirstUidByte(), apps)};
            if (currentToken) currentToken->tokenUninserted();
            break;
        }
        default:
            break;
    }
}

AppToken* const selectTokenById(byte id) {
    static AppToken tokens[]{};
    for (auto& token : tokens) {
        if (token.matches(id)) return &token;
    }
    return nullptr;
}

AppToken* selectTokenById2(byte id, vector<AppToken>& apps) {
    for (auto& token : apps) {
        if (token.matches(id)) return &token;
    }
    return nullptr;
}

void OnDataReceive(byte* macAddress, byte* incomingData, byte length) {
    if (length >= 2) {
        auto currentToken{selectTokenById2(incomingData[0], apps)};
        if (!currentToken) {
            AppToken newApp{incomingData[0]};
            apps.push_back(newApp);
            Serial.println(F("New object dynamically allocated"));
            currentToken = &(apps.back());
        }
        enum commands : unsigned char {
            shelved = 's',
            unshelved = 'u'
        };

        switch (incomingData[1]) {
            case shelved:
                currentToken->tokenShelved();
                break;
            case unshelved:
                currentToken->tokenUnshelved();
                break;
            default:
                break;
        }
    }
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