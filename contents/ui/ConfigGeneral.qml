/*
SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {

    property string cfg_menuLabel: menuLabel.text
    property alias cfg_onlyIcon: menuDisplayIcon.checked
    property alias cfg_onlyText: menuDisplayText.checked
    property alias cfg_boldFont: boldChk.checked
    property alias cfg_italicFont: italicChk.checked
    property string cfg_icon: plasmoid.configuration.icon
    property int cfg_menuDisplay: plasmoid.configuration.menuDisplay
    property int cfg_favoritesDisplay: plasmoid.configuration.favoritesDisplay
    property int cfg_applicationsDisplay: plasmoid.configuration.applicationsDisplay
    property alias cfg_alphaSort: alphaSort.checked
    property var cfg_systemFavorites: String(plasmoid.configuration.systemFavorites)
    property int cfg_primaryActions: plasmoid.configuration.primaryActions
    property alias cfg_showActionButtonCaptions: showActionButtonCaptions.checked

    Kirigami.FormLayout {
        RadioButton {
            id: menuDisplayIcon
            Kirigami.FormData.label: i18n("Menu display mode:")
            text: i18n("Show only menu icon")
            ButtonGroup.group: menuDisplayGroup
            property int index: 0
            checked: plasmoid.configuration.menuDisplay == index
        }

        RadioButton {
            id: menuDisplayText
            text: i18n("Show only menu label")
            ButtonGroup.group: menuDisplayGroup
            property int index: 1
            checked: plasmoid.configuration.menuDisplay == index
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        Button {
            id: iconButton
            visible: menuDisplayIcon.checked

            Kirigami.FormData.label: i18n("Icon:")

            implicitWidth: previewFrame.width + PlasmaCore.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + PlasmaCore.Units.smallSpacing * 2

            KQuickAddons.IconDialog {
                id: iconDialog
                onIconNameChanged: cfg_icon = iconName || "start-here-kde"
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            PlasmaCore.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
                        ? "widgets/panel-background" : "widgets/background"
                width: PlasmaCore.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: PlasmaCore.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                PlasmaCore.IconItem {
                    anchors.centerIn: parent
                    width: PlasmaCore.Units.iconSizes.large
                    height: width
                    source: cfg_icon
                }
            }

            Menu {
                id: iconMenu

                // Appear below the button
                y: +parent.height

                MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    onClicked: iconDialog.open()
                }
                MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                    icon.name: "edit-clear"
                    onClicked: cfg_icon = "start-here-kde"
                }
            }
        }

        TextField {
            visible: menuDisplayText.checked
            Kirigami.FormData.label: i18n("Menu label:")
            id: menuLabel
            y: -menuLabel.height / (PlasmaCore.Units.devicePixelRatio * 2)
            text: plasmoid.configuration.menuLabel
            placeholderText: i18n("Applications")
            onTextEdited: {
                cfg_menuLabel = menuLabel.text
            }
        }

        GridLayout {
            columns: 2
            visible: menuDisplayText.checked

            CheckBox{
                id: boldChk
                text: i18n("Bold")
            }

            CheckBox{
                id: italicChk
                text: i18n("Italic")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: alphaSort
            text: i18n("Always sort applications alphabetically")
        }

        Button {
            enabled: KQuickAddons.KCMShell.authorize("kcm_plasmasearch.desktop").length > 0
            icon.name: "settings-configure"
            text: i18nc("@action:button", "Configure Enabled Search Plugins…")
            onClicked: KQuickAddons.KCMShell.openSystemSettings("kcm_plasmasearch")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RadioButton {
            id: showFavoritesInGrid
            Kirigami.FormData.label: i18n("Show favorites:")
            text: i18nc("Part of a sentence: 'Show favorites in a grid'", "In a grid")
            ButtonGroup.group: favoritesDisplayGroup
            property int index: 0
            checked: plasmoid.configuration.favoritesDisplay == index
        }

        RadioButton {
            id: showFavoritesInList
            text: i18nc("Part of a sentence: 'Show favorites in a list'", "In a list")
            ButtonGroup.group: favoritesDisplayGroup
            property int index: 1
            checked: plasmoid.configuration.favoritesDisplay == index
        }

        RadioButton {
            id: showAppsInGrid
            Kirigami.FormData.label: i18n("Show other applications:")
            text: i18nc("Part of a sentence: 'Show other applications in a grid'", "In a grid")
            ButtonGroup.group: applicationsDisplayGroup
            property int index: 0
            checked: plasmoid.configuration.applicationsDisplay == index
        }

        RadioButton {
            id: showAppsInList
            text: i18nc("Part of a sentence: 'Show other applications in a list'", "In a list")
            ButtonGroup.group: applicationsDisplayGroup
            property int index: 1
            checked: plasmoid.configuration.applicationsDisplay == index
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RadioButton {
            id: powerActionsButton
            Kirigami.FormData.label: i18n("Show buttons for:")
            text: i18n("Power")
            ButtonGroup.group: radioGroup
            property string actions: "suspend,hibernate,reboot,shutdown"
            property int index: 0
            checked: plasmoid.configuration.primaryActions == index
        }

        RadioButton {
            id: sessionActionsButton
            text: i18n("Session")
            ButtonGroup.group: radioGroup
            property string actions: "lock-screen,logout,save-session,switch-user"
            property int index: 1
            checked: plasmoid.configuration.primaryActions == index
        }

        RadioButton {
            id: allActionsButton
            text: i18n("Power and session")
            ButtonGroup.group: radioGroup
            property string actions: "lock-screen,logout,save-session,switch-user,suspend,hibernate,reboot,shutdown"
            property int index: 3
            checked: plasmoid.configuration.primaryActions == index
        }

        CheckBox {
            id: showActionButtonCaptions
            text: i18n("Show action button captions")
        }
    }

    ButtonGroup {
        id: menuDisplayGroup
        onCheckedButtonChanged: {
            if (checkedButton)
            {
                cfg_menuDisplay = checkedButton.index
            }
        }
    }

    ButtonGroup {
        id: favoritesDisplayGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_favoritesDisplay = checkedButton.index
            }
        }
    }

    ButtonGroup {
        id: applicationsDisplayGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_applicationsDisplay = checkedButton.index
            }
        }
    }

    ButtonGroup {
        id: radioGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_primaryActions = checkedButton.index
                cfg_systemFavorites = checkedButton.actions
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
