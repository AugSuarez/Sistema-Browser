/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the QtWebEngine module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.2
import QtWebEngine 1.2
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
import QtQuick.Controls.Private 1.0
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

ApplicationWindow {

        id: browserWindow
        property QtObject applicationRoot
        property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null

        width: 1000
        height: 800
        visible: true

    // Create a styleItem to determine the platform.
    // When using style "mac", ToolButtons are not supposed to accept focus.
    StyleItem { id: styleItem }
    property bool platformIsMac: styleItem.style == "mac"

    Settings {
        id : appSettings
        property alias errorPageEnabled: errorPageEnabled.checked;
    }
    Action {
        shortcut: StandardKey.Close
        onTriggered: {
            currentWebView.triggerWebAction(WebEngineView.RequestClose);
        }
    }

    Action {
        shortcut: StandardKey.Copy
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Copy)
    }
    Action {
        shortcut: StandardKey.Cut
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Cut)
    }
    Action {
        shortcut: StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Paste)
    }
    Action {
        shortcut: StandardKey.SelectAll
        onTriggered: currentWebView.triggerWebAction(WebEngineView.SelectAll)
    }
    Action {
        shortcut: StandardKey.Undo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Undo)
    }
    Action {
        shortcut: StandardKey.Redo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Redo)
    }

    toolBar: ToolBar {
        id: navigationBar
            RowLayout {
                visible: true
                anchors.fill: parent;
                ToolButton {
                    visible: false
                    id: settingsMenuButton
                    menu: Menu {
                        MenuItem {
                            id: errorPageEnabled
                            text: "Pagina de depuracion activada"
                            checkable: true
                            visible: false
                            checked: WebEngine.settings.errorPageEnabled
                        }
                    }
                }
            }
    }

    TabView {
        id: tabs
        function createEmptyTab(profile) {
            var tab = addTab("", tabComponent)
            // We must do this first to make sure that tab.active gets set so that tab.item gets instantiated immediately.
            tab.active = true
            tab.title = Qt.binding(function() { return tab.item.title })
            tab.item.profile = profile
            return tab
        }

        anchors.fill: parent
        Component.onCompleted: createEmptyTab(defaultProfile)

        Component {
            id: tabComponent
            WebEngineView {
                id: webEngineView
                focus: true

                settings.errorPageEnabled: appSettings.errorPageEnabled

                onCertificateError: {
                    error.defer()
                    sslDialog.enqueue(error)
                }

                onRenderProcessTerminated: {
                    var status = ""
                    switch (terminationStatus) {
                    case WebEngineView.NormalTerminationStatus:
                        status = "(normal exit)"
                        break;
                    case WebEngineView.AbnormalTerminationStatus:
                        status = "(abnormal exit)"
                        break;
                    case WebEngineView.CrashedTerminationStatus:
                        status = "(crashed)"
                        break;
                    case WebEngineView.KilledTerminationStatus:
                        status = "(killed)"
                        break;
                    }

                    print("Render process exited with code " + exitCode + " " + status)
                    reloadTimer.running = true
                }

                onWindowCloseRequested: {
                    if (tabs.count == 1)
                        browserWindow.close()
                    else
                        tabs.removeTab(tabs.currentIndex)
                }

                Timer {
                    id: reloadTimer
                    interval: 0
                    running: false
                    repeat: false
                    onTriggered: currentWebView.reload()
                }
            }
        }
    }

    function onDownloadRequested(download) {
        downloadView.visible = true
        downloadView.append(download)
        download.accept()
    }
}
