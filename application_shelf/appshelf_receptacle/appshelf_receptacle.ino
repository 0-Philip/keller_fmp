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
            auto currentToken{lookUpToken(rfid, apps)};
            if (currentToken) {
                currentToken->tokenInserted();
            } else {
                rememberToken(rfid, apps);
                apps.back().tokenInserted();
            }
            break;
        }
        case SimpleRfid::tokenRemoved: {
            auto currentToken{lookUpToken(rfid, apps)};
            if (currentToken) currentToken->tokenUninserted();
            break;
        }
        default:
            break;
    }
}

AppToken* lookUpToken(SimpleRfid& rfid, vector<AppToken>& apps) {
    return selectTokenById(rfid.getFirstUidByte(), apps);
}

void rememberToken(SimpleRfid& rfid, vector<AppToken>& apps) {
    AppToken newApp{rfid.getFirstUidByte()};
    apps.push_back(newApp);
    Serial.println(F("New object dynamically allocated"));
}

AppToken* selectTokenById(byte id, vector<AppToken>& apps) {
    for (auto& token : apps) {
        if (token.matches(id)) return &token;
    }
    return nullptr;
}

void OnDataReceive(byte* macAddress, byte* incomingData, byte length) {
    if (length >= 2) {
        auto currentToken{selectTokenById(incomingData[0], apps)};
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
    Serial.print("ESP8266 Board MAC Address:  ");
    Serial.println(WiFi.macAddress());
    WiFi.mode(WIFI_STA);
    if (esp_now_init() != 0) {
        Serial.println(F("Error initializing ESP-NOW"));
        return;
    }
    esp_now_set_self_role(ESP_NOW_ROLE_SLAVE);
    esp_now_register_recv_cb(callback);
}