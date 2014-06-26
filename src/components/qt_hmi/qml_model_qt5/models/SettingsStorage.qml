/**
 * @file SettingsStorage.qml
 * @brief Storage for keeping settings.
 * Copyright (c) 2013, Ford Motor Company
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided with the
 * distribution.
 *
 * Neither the name of the Ford Motor Company nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import "../hmi_api/Common.js" as Common
import "../models/RequestToSDL.js" as RequestToSDL
import "../models/Internal.js" as Internal

Item
{
    property var sdlLanguagesList: [
        Common.Language.EN_US,
        Common.Language.ES_MX,
        Common.Language.FR_CA,
        Common.Language.DE_DE,
        Common.Language.ES_ES,
        Common.Language.EN_GB,
        Common.Language.RU_RU,
        Common.Language.TR_TR,
        Common.Language.PL_PL,
        Common.Language.FR_FR,
        Common.Language.IT_IT,
        Common.Language.SV_SE,
        Common.Language.PT_PT,
        Common.Language.NL_NL,
        Common.Language.ZH_TW,
        Common.Language.JA_JP,
        Common.Language.AR_SA,
        Common.Language.KO_KR,
        Common.Language.PT_BR,
        Common.Language.CS_CZ,
        Common.Language.DA_DK,
        Common.Language.NO_NO
    ]

    property var displayCapabilities: {
        "displayType": Common.DisplayType.GEN2_8_DMA,
        "textFields": [
            Common.TextFieldName.mainField1,
            Common.TextFieldName.mainField2,
            Common.TextFieldName.mainField3,
            Common.TextFieldName.mainField4,
            Common.TextFieldName.statusBar,
            Common.TextFieldName.mediaClock,
            Common.TextFieldName.mediaTrack,
            Common.TextFieldName.alertText1,
            Common.TextFieldName.alertText2,
            Common.TextFieldName.alertText3,
            Common.TextFieldName.scrollableMessageBody,
            Common.TextFieldName.initialInteractionText,
            Common.TextFieldName.navigationText1,
            Common.TextFieldName.navigationText2,
            Common.TextFieldName.ETA,
            Common.TextFieldName.totalDistance,
            Common.TextFieldName.navigationText,
            Common.TextFieldName.audioPassThruDisplayText1,
            Common.TextFieldName.audioPassThruDisplayText2,
            Common.TextFieldName.sliderHeader,
            Common.TextFieldName.sliderFooter,
            Common.TextFieldName.notificationText
        ],
        "mediaClockFormats": [
            Common.MediaClockFormat.CLOCK1,
            Common.MediaClockFormat.CLOCK2,
            Common.MediaClockFormat.CLOCK3,
            Common.MediaClockFormat.CLOCKTEXT1,
            Common.MediaClockFormat.CLOCKTEXT2,
            Common.MediaClockFormat.CLOCKTEXT3,
            Common.MediaClockFormat.CLOCKTEXT4
        ],
        "graphicSupported": true,
        "imageCapabilities": [ Common.ImageType.DYNAMIC ],
        "templatesAvailable": [ "" ],
        "screenParams": {
            "resolution": {
                "resolutionWidth": 800,
                "resolutionHeight": 480
            },
            "touchEventAvailable": {
                "pressAvailable": true,
                "multiTouchAvailable": true,
                "doublePressAvailable": true
            }
        },
        "numCustomPresetsAvailable": 6
    }

    property var softButtonCapabilities: {
        "shortPressAvailable": true,
        "longPressAvailable": true,
        "upDownAvailable": true,
        "imageSupported": true
    }

    property var buttonCapabilities: []

    property string filePTSnapshot: "IVSU/PROPRIETARY_REQUEST"

    property int timeoutPTExchange: 500

    property int retriesPTExchange: []

    property var urlsPTExchange: []

    property int currentRetry: 0

    property int currentUrl: 0

    function updateStatus(result) {
        console.debug("Result update SDL:", result);
        var text = {}
        text[Common.UpdateResult.UP_TO_DATE] = "UP_TO_DATE";
        text[Common.UpdateResult.UPDATING] = "UPDATING";
        text[Common.UpdateResult.UPDATE_NEEDED] = "UPDATE_NEEDED";
        ttsPopUp.activate(text[result])
    }

    function startPTExchange(urls) {
        urlsPTExchange = urls;
        currentRetry = 0;
        currentUrl = 0;
        sendSystemRequest();
    }

    function getUrl() {
        if (currentUrl >= 0 && currentUrl < urlsPTExchange.length) {
          var url = urlsPTExchange[currentUrl];
          currentUrl = (currentUrl + 1) / urlsPTExchange.length;
          return url;
        } else {
          return {url: ""}
        }
    }

    function getInterval() {
        if (currentRetry >= 0 && currentRetry < retriesPTExchange.length) {
            var interval = (timeoutPTExchange + retriesPTExchange[currentRetry]) * 1000;
            currentRetry++;
            return interval;
        } else {
            return 0;
        }
    }

    function sendSystemRequest() {
        var url = getUrl();
        var offset = 1000;
        var length = 10000;
        var appId = url.policyAppId ? url.policyAppId : "default";

        sdlBasicCommunication.onSystemRequest(Common.RequestType.PROPRIETARY,
                                              url.url, Common.FileType.JSON,
                                              offset, length,
                                              timeoutPTExchange,
                                              filePTSnapshot,
                                              appId);

        retriesTimer.interval = getInterval();
        if (retriesTimer.interval > 0) {
            retriesTimer.start();
        }
    }

    function stopPTExchange(fileName) {
        retriesTimer.stop();
        sdlSDL.onReceivedPolicyUpdate(fileName);
    }

    Timer {
        id: retriesTimer
        interval: timeoutPTExchange; running: false; repeat: false
        onTriggered: sendSystemRequest()
    }

    function activateApp (appId) {

        console.debug("SDL.ActivateApp Request enter", appId);

        RequestToSDL.SDL_ActivateApp(appId, function(params){
            settingsContainer.activateApp_Response(appId, params)
        })

        console.debug("SDL.ActivateApp Request exit");
    }

    function activateApp_Response (appId, params) {

        console.debug("activateApp_Response enter", appId);

        if (!params.isSDLAllowed) {

            userActionPopUp.activate("Allow SDL Functionality request",
                                        "Would you like to allow SDL functionality for device '" + params.device.name + "'?",
                                        function(result){
                                            allowSDLFunctionality(result, params.device)
                                        }
                                    )
        }

        if (params.isPermissionsConsentNeeded) {
            //GetListOfPermissions
        }

        if (params.isAppPermissionsRevoked) {
            //setAppPermissions remove revoked permissions
        }

        if (params.isAppRevoked) {
            //popupActivate("Current version of app is no longer supported!");
            //? unregister app or set to level NONE
        } else if (params.isSDLAllowed) {
            dataContainer.setCurrentApplication(appId)
            contentLoader.go(
                Internal.chooseAppStartScreen(
                    dataContainer.currentApplication.appType,
                    dataContainer.currentApplication.isMediaApplication
                ),
                appId
            )
        }
    }

    function allowSDLFunctionality (result, device) {
        console.log("allowSDLFunctionality enter");
        sdlSDL.onAllowSDLFunctionality(device, result, Common.ConsentSource.GUI)
    }
}
