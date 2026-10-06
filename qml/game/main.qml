/*
 * Copyright (C) 2026 - Timo Könnecke <github.com/moWerk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import QtGraphicalEffects 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.KeepAlive 1.2
import QtMultimedia 5.6
import "."

// SailfishOS: Application of org.asteroid.utils draws a radial background;
// here a plain Item does the same. DisplaySettings comes from
// org.nemomobile.systemsettings instead of org.asteroid.settings.
Item {
    id: app
    anchors.fill: parent

    property color centerColor: "#003D1A"
    property color outerColor:  "#001508"

    // SailfishOS: in horizon mode (phone held upright, tilted more than 60°
    // towards the user) the background is the back camera's viewfinder.
    // The camera keeps running while the app is in front and is only
    // covered by the background, so switching is a 120 ms fade, not a
    // camera start. Covered, the video is not drawn.
    readonly property bool cameraShown: level.horizonMode || selftestCameraOn

    readonly property bool selftestCameraOn: typeof selftestCamera !== "undefined" && selftestCamera

    Camera {
        id: cam
        position: Camera.BackFace
        captureMode: Camera.CaptureViewfinder
        // released in the background, so other apps get the camera and the
        // cover does not keep it busy; the one slow start is on returning
        cameraState: Qt.application.active || app.selftestCameraOn
                     ? Camera.ActiveState : Camera.UnloadedState
        onCameraStatusChanged: console.log("HORIZON camera status " + cameraStatus
                                           + " orientation " + orientation)
        onErrorStringChanged: if (errorString !== "") console.log("HORIZON camera error: " + errorString)
    }

    VideoOutput {
        id: viewfinder
        anchors.fill: parent
        source: cam
        fillMode: VideoOutput.PreserveAspectCrop
        // No rotation, as in the stock camera app (jolla-camera's camera.qml:
        // a VideoOutput in the native portrait window with only source set;
        // camera.orientation, 270 on the C2, is used there for focus areas
        // only). autoOrientation would follow the screen orientation, which
        // the horizon mode's roll would flip at 45°.
        // SFOS_HORIZON_CAM_ROTATION=<0|90|180|270> overrides it for a test.
        orientation: typeof camRotationOverride !== "undefined" && camRotationOverride >= 0
                     ? camRotationOverride : 0
        visible: background.opacity < 1
    }

    // a light scrim keeps the white scale readable over a bright picture
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.25
        visible: viewfinder.visible
    }

    RadialGradient {
        id: background
        anchors.fill: parent
        opacity: app.cameraShown ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 120 } }
        gradient: Gradient {
            GradientStop { position: 0.0; color: app.centerColor }
            GradientStop { position: 0.5; color: app.outerColor }
        }
    }

    // Test hook (set from main.cpp): show the viewfinder without tilting
    // and log what the camera pipeline does
    Timer {
        interval: 4000
        running: app.selftestCameraOn
        onTriggered: console.log("HORIZON selftest camera: status " + cam.cameraStatus
                                 + " state " + cam.cameraState
                                 + " orientation " + cam.orientation
                                 + " videoOrientation " + viewfinder.orientation
                                 + " contentRect " + viewfinder.contentRect
                                 + " sourceRect " + viewfinder.sourceRect
                                 + " error '" + cam.errorString + "'")
    }


    property int startBrightness: -1

    DisplayBlanking { preventBlanking: true }

    Component.onDestruction: {
        if (startBrightness !== -1)
            displaySettings.brightness = startBrightness
    }

    DisplaySettings {
        id: displaySettings
        onBrightnessChanged: {
            if (app.startBrightness !== -1) return
            app.startBrightness = brightness
            brightness = maximumBrightness
        }
    }

    LevelPage {
        id: level
        anchors.fill: parent
    }
}
