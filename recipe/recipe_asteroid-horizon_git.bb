SUMMARY = "Precision spirit level and angle meter for AsteroidOS"
HOMEPAGE = "https://github.com/moWerk/asteroid-horizon"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=84dcc94da3adb52b53ae4fa38fe49e5d"

SRC_URI = "git://github.com/moWerk/asteroid-horizon.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"
PR = "r1"
PV = "+git${SRCPV}"
S = "${WORKDIR}/git"

inherit cmake_qt5 pkgconfig

DEPENDS += "nemo-keepalive qml-asteroid qtsensors qttools-native qtdeclarative-native"

FILES:${PN} += "/usr/lib/asteroid-horizon.so /usr/share/translations/"
