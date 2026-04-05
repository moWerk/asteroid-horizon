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

import QtQuick 2.9
import QtSensors 5.11
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Item {
    id: root

    // --- Debug ---
    property bool debugMode: true

    // --- Sensor smoothing ---
    property real smoothedX: 0
    property real smoothedY: 0
    property real smoothedZ: 1
    property real smoothingFactor: 0.15

    // --- Derived angles (degrees) ---
    // pitch: tilt top-edge down (away from user). Positive = top edge dips.
    // roll:  tilt left-right. Positive = left edge dips.
    // Signs confirmed via debug log — flip multipliers if inverted on device.
    property real pitch: Math.atan2(-smoothedY, Math.abs(smoothedZ)) * 180 / Math.PI
    property real roll:  Math.atan2( smoothedX, Math.abs(smoothedZ)) * 180 / Math.PI

    // --- User zero / delta mode ---
    property bool userZero:   false
    property real zeroPitch:  0
    property real zeroRoll:   0
    property real dispPitch:  userZero ? pitch - zeroPitch : pitch
    property real dispRoll:   userZero ? roll  - zeroRoll  : roll

    // --- Horizon mode (auto, blocked by userZero) ---
    // Hysteresis: enter >60°, exit <50°
    property bool horizonMode: false
    property real horizonRoll: Math.atan2(smoothedX, smoothedY) * 180 / Math.PI

    onPitchChanged: {
        if (userZero) return
        var absPitch = Math.abs(pitch)
        if (!horizonMode && absPitch > 60) horizonMode = true
        if ( horizonMode && absPitch < 50) horizonMode = false
    }

    // --- Axis snap-lock: 0=none, 1=X (dot moves only horizontally), 2=Y (dot moves only vertically) ---
    property int axisLock: 0

    // --- Scale geometry ---
    property real scaleRange:     30        // degrees shown on each half-axis
    property int  tickCount:      6         // ticks per side (5°, 10°, 15°, 20°, 25°, 30°)
    property real tickStep:       5         // degrees per tick
    property real scaleHalfWidth: Dims.l(36)  // half-length of scale lines from center
    property real tickMajorLen:   Dims.l(4)
    property real tickMinorLen:   Dims.l(2.5)

    // pixels per degree on the scale
    property real pxPerDeg: scaleHalfWidth / scaleRange

    // --- Dot target position (clamped to scale bounds) ---
    property real dotTargetX: {
        var v = axisLock === 2 ? 0 : Math.max(-scaleRange, Math.min(scaleRange, dispRoll))
        return width  / 2 + v * pxPerDeg
    }
    property real dotTargetY: {
        var v = axisLock === 1 ? 0 : Math.max(-scaleRange, Math.min(scaleRange, dispPitch))
        return height / 2 + v * pxPerDeg
    }

    // --- Accelerometer ---
    Accelerometer {
        id: accel
        active: true
        dataRate: 30
        onReadingChanged: {
            root.smoothedX = root.smoothedX + root.smoothingFactor * (reading.x - root.smoothedX)
            root.smoothedY = root.smoothedY + root.smoothingFactor * (reading.y - root.smoothedY)
            root.smoothedZ = root.smoothedZ + root.smoothingFactor * (reading.z - root.smoothedZ)

            if (root.debugMode) {
                console.log("HORIZON raw x=" + reading.x.toFixed(3)
                    + " y=" + reading.y.toFixed(3)
                    + " z=" + reading.z.toFixed(3)
                    + " | smX=" + root.smoothedX.toFixed(3)
                    + " smY=" + root.smoothedY.toFixed(3)
                    + " smZ=" + root.smoothedZ.toFixed(3)
                    + " | pitch=" + root.pitch.toFixed(1)
                    + " roll=" + root.roll.toFixed(1))
            }
        }
    }

    // =========================================================
    // Scale root — rotates in horizon mode to stay level
    // =========================================================
    Item {
        id: scaleRoot
        anchors.centerIn: parent
        width:  parent.width
        height: parent.height

        rotation: horizonMode ? horizonRoll : 0

        Behavior on rotation {
            SmoothedAnimation { velocity: 120; duration: 300 }
        }

        // --- X axis line ---
        Rectangle {
            id: xAxisLine
            anchors.centerIn: parent
            width:  scaleRoot.width * 0.72   // generous, labels+locks sit at Dims.l(36) from center
            height: Dims.l(0.3)
            color:  "#ffffff"
            opacity: 0.35
        }

        // --- Y axis line ---
        Rectangle {
            id: yAxisLine
            anchors.centerIn: parent
            width:  Dims.l(0.3)
            height: scaleRoot.height * 0.72
            color:  "#ffffff"
            opacity: 0.35
        }

        // --- Center cross mark ---
        Rectangle {
            anchors.centerIn: parent
            width:  Dims.l(2)
            height: Dims.l(0.3)
            color:  "#ffffff"
            opacity: 0.6
        }
        Rectangle {
            anchors.centerIn: parent
            width:  Dims.l(0.3)
            height: Dims.l(2)
            color:  "#ffffff"
            opacity: 0.6
        }

        // --- X axis tick marks (both sides) ---
        Repeater {
            model: tickCount * 2   // negative and positive side
            delegate: Rectangle {
                property int idx:    index < tickCount ? -(tickCount - index) : (index - tickCount + 1)
                property real degVal: idx * tickStep
                property bool isMajor: Math.abs(idx) % 2 === 0

                x: parent.width  / 2 + degVal * pxPerDeg - width  / 2
                y: parent.height / 2 - height / 2
                width:  Dims.l(0.3)
                height: isMajor ? tickMajorLen : tickMinorLen
                color:  "#ffffff"
                opacity: 0.45
            }
        }

        // --- Y axis tick marks (both sides) ---
        Repeater {
            model: tickCount * 2
            delegate: Rectangle {
                property int idx:    index < tickCount ? -(tickCount - index) : (index - tickCount + 1)
                property real degVal: idx * tickStep
                property bool isMajor: Math.abs(idx) % 2 === 0

                x: parent.width  / 2 - width  / 2
                y: parent.height / 2 + degVal * pxPerDeg - height / 2
                width:  isMajor ? tickMajorLen : tickMinorLen
                height: Dims.l(0.3)
                color:  "#ffffff"
                opacity: 0.45
            }
        }

        // --- X degree label (left end of X axis) ---
        Label {
            id: xAxisLabel
            x: parent.width / 2 - scaleHalfWidth - width - Dims.l(2)
            y: parent.height / 2 - height / 2
            text: dispRoll.toFixed(1) + "°"
            font.pixelSize:  Dims.l(9)
            font.family:     "Noto Sans"
            font.styleName:  "SemiCondensed SemiBold"
            color: "#ffffff"
            opacity: axisLock !== 0 ? 0.4 : 0.9
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // --- X lock icon (right end of X axis) ---
        Icon {
            id: xLockIcon
            x: parent.width / 2 + scaleHalfWidth + Dims.l(2)
            y: parent.height / 2 - height / 2
            width:  Dims.l(9)
            height: Dims.l(9)
            name: axisLock === 1 ? "ios-lock" : "ios-unlock"
            color: "#ffffff"
            opacity: axisLock === 1 ? 0.9 : (axisLock === 0 ? 0.9 : 0.4)
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Dims.l(4)
                onClicked: axisLock = (axisLock === 1) ? 0 : 1
            }
        }

        // --- Y degree label (top end of Y axis) ---
        Label {
            id: yAxisLabel
            x: parent.width  / 2 - width / 2
            y: parent.height / 2 - scaleHalfWidth - height - Dims.l(2)
            text: dispPitch.toFixed(1) + "°"
            font.pixelSize:  Dims.l(9)
            font.family:     "Noto Sans"
            font.styleName:  "SemiCondensed SemiBold"
            color: "#ffffff"
            opacity: axisLock !== 0 ? 0.4 : 0.9
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // --- Y lock icon (bottom end of Y axis) ---
        Icon {
            id: yLockIcon
            x: parent.width  / 2 - width  / 2
            y: parent.height / 2 + scaleHalfWidth + Dims.l(2)
            width:  Dims.l(9)
            height: Dims.l(9)
            name: axisLock === 2 ? "ios-lock" : "ios-unlock"
            color: "#ffffff"
            opacity: axisLock === 2 ? 0.9 : (axisLock === 0 ? 0.9 : 0.4)
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Dims.l(4)
                onClicked: axisLock = (axisLock === 2) ? 0 : 2
            }
        }
    }

    // =========================================================
    // Indicator dot — hidden in horizon mode
    // =========================================================
    Rectangle {
        id: dot
        width:  Dims.l(7)
        height: Dims.l(7)
        radius: width / 2
        color:  userZero ? "#FF4444" : "#ffffff"
        opacity: horizonMode ? 0.0 : 1.0
        visible: !horizonMode

        x: dotTargetX - width  / 2
        y: dotTargetY - height / 2

        Behavior on x {
            SmoothedAnimation { velocity: Dims.l(200); duration: 80 }
        }
        Behavior on y {
            SmoothedAnimation { velocity: Dims.l(200); duration: 80 }
        }
        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Border ring for visibility against any background
        Rectangle {
            anchors.centerIn: parent
            width:  parent.width  + Dims.l(0.8)
            height: parent.height + Dims.l(0.8)
            radius: width / 2
            color:  "transparent"
            border.color: "#000000"
            border.width: Dims.l(0.4)
            z: -1
        }

        // --- Dot value label (visible when axis is locked) ---
        Label {
            id: dotLabel
            visible: axisLock !== 0
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.bottom
                topMargin: Dims.l(1.5)
            }
            text: {
                if      (axisLock === 1) return dispRoll.toFixed(1)  + "°"
                else if (axisLock === 2) return dispPitch.toFixed(1) + "°"
                return ""
            }
            font.pixelSize:  Dims.l(12)
            font.family:     "Noto Sans"
            font.styleName:  "SemiCondensed SemiBold"
            color: "#ffffff"
        }

        // --- Tap to toggle user zero ---
        MouseArea {
            anchors.fill: parent
            anchors.margins: -Dims.l(5)
            onClicked: {
                if (!userZero) {
                    zeroPitch = pitch
                    zeroRoll  = roll
                    userZero  = true
                } else {
                    userZero  = false
                    zeroPitch = 0
                    zeroRoll  = 0
                }
            }
        }
    }

    // =========================================================
    // Horizon mode horizon line indicator
    // =========================================================
    Item {
        id: horizonIndicator
        anchors.centerIn: parent
        visible: horizonMode
        opacity: horizonMode ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { duration: 250 } }

        // Horizon line — stays horizontal, represents the true horizon
        Rectangle {
            anchors.centerIn: parent
            width:  Dims.l(50)
            height: Dims.l(0.5)
            color:  "#44ff88"
            opacity: 0.8
        }

        // Roll angle label in horizon mode
        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.bottom
                topMargin: Dims.l(3)
            }
            text: roll.toFixed(1) + "°"
            font.pixelSize:  Dims.l(12)
            font.family:     "Noto Sans"
            font.styleName:  "SemiCondensed SemiBold"
            color: "#ffffff"
            opacity: 0.9
        }
    }
}
