/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.kicker 0.1 as Kicker

import "code/tools.js" as Tools

Item {
    id: kickoff

    // The properties are defined here instead of the singleton because each
    // instance of Kickoff requires different instances of these properties

    // Used to display the menu label on the only text mode
    property string menuLabel: plasmoid.configuration.menuLabel

    property bool inPanel: plasmoid.location === PlasmaCore.Types.TopEdge
        || plasmoid.location === PlasmaCore.Types.RightEdge
        || plasmoid.location === PlasmaCore.Types.BottomEdge
        || plasmoid.location === PlasmaCore.Types.LeftEdge
    property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    property string defaultIcon: "start-here-kde"

    // Used to prevent the width from changing frequently when the scrollbar appears or disappears
    property bool mayHaveGridWithScrollBar: plasmoid.configuration.applicationsDisplay === 0
        || (plasmoid.configuration.favoritesDisplay === 0 && plasmoid.rootItem.rootModel.favoritesModel.count > 16)

    //BEGIN Models
    property Kicker.RootModel rootModel: Kicker.RootModel {
        autoPopulate: false

        appletInterface: plasmoid

        flat: true // have categories, but no subcategories
        sorted: plasmoid.configuration.alphaSort
        showSeparators: false
        showTopLevelItems: true

        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showRecentContacts: false
        showPowerSession: false
        showFavoritesPlaceholder: true

        Component.onCompleted: {
            favoritesModel.initForClient("org.kde.plasma.kickoff.favorites.instance-" + plasmoid.id)

            if (!plasmoid.configuration.favoritesPortedToKAstats) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(plasmoid.configuration.favorites);
                }
                plasmoid.configuration.favoritesPortedToKAstats = true;
            }
        }
    }

    property Kicker.RunnerModel runnerModel: Kicker.RunnerModel {
        query: kickoff.searchField ? kickoff.searchField.text : ""
        appletInterface: plasmoid
        mergeResults: true
        favoritesModel: rootModel.favoritesModel
    }

    property Kicker.ComputerModel computerModel: Kicker.ComputerModel {
        appletInterface: plasmoid
        favoritesModel: rootModel.favoritesModel
        systemApplications: plasmoid.configuration.systemApplications
        Component.onCompleted: {
            //systemApplications = plasmoid.configuration.systemApplications;
        }
    }

    property Kicker.RecentUsageModel recentUsageModel: Kicker.RecentUsageModel {
        favoritesModel: rootModel.favoritesModel
    }

    property Kicker.RecentUsageModel frequentUsageModel: Kicker.RecentUsageModel {
        favoritesModel: rootModel.favoritesModel
        ordering: 1 // Popular / Frequently Used
    }
    //END

    //BEGIN UI elements
    // Set in FullRepresentation.qml
    property Item header: null

    // Set in Header.qml
    property PC3.TextField searchField: null

    // Set in FullRepresentation.qml, ApplicationPage.qml, PlacesPage.qml
    property Item sideBar: null // is null when searching
    property Item contentArea: null // is searchView when searching

    // Set in NormalPage.qml
    property Item footer: null
    //END

    //BEGIN Metrics
    readonly property PlasmaCore.FrameSvgItem backgroundMetrics: PlasmaCore.FrameSvgItem {
        // Inset defaults to a negative value when not set by margin hints
        readonly property real leftPadding: margins.left - Math.max(inset.left, 0)
        readonly property real rightPadding: margins.right - Math.max(inset.right, 0)
        readonly property real topPadding: margins.top - Math.max(inset.top, 0)
        readonly property real bottomPadding: margins.bottom - Math.max(inset.bottom, 0)
        readonly property real spacing: leftPadding
        visible: false
        imagePath: plasmoid.formFactor === PlasmaCore.Types.Planar ? "widgets/background" : "dialogs/background"
    }
    //END

    Plasmoid.switchWidth: plasmoid.fullRepresentationItem ? plasmoid.fullRepresentationItem.Layout.minimumWidth : -1
    Plasmoid.switchHeight: plasmoid.fullRepresentationItem ? plasmoid.fullRepresentationItem.Layout.minimumHeight : -1

    Plasmoid.preferredRepresentation: plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: FullRepresentation { focus: true }

    Plasmoid.icon: plasmoid.configuration.icon

    Plasmoid.compactRepresentation: MouseArea {
        id: compactRoot

        // Taken from DigitalClock to ensure uniform sizing when next to each other
        readonly property bool panelIsSmall: plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= PlasmaCore.Theme.smallestFont.pixelSize
        readonly property bool panelIsMedium: plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 8)) <= PlasmaCore.Theme.smallestFont.pixelSize

        implicitWidth: PlasmaCore.Units.iconSizeHints.panel
        implicitHeight: PlasmaCore.Units.iconSizeHints.panel

        Layout.minimumWidth: {
            if (!kickoff.inPanel) {
                return Tools.dynamicSetWidgetWidth(plasmoid.icon, buttonIcon.width, kickoff.menuLabel, labelTextField.width, PlasmaCore.Units.smallSpacing * 2);
            }

            if (kickoff.vertical) {
                return -1;
            } else {
                return Tools.dynamicSetWidgetWidth(plasmoid.icon, buttonIcon.width, kickoff.menuLabel, labelTextField.width, PlasmaCore.Units.smallSpacing * 2);
            }
        }

        Layout.minimumHeight: {
            if (!kickoff.inPanel) {
                return PlasmaCore.Units.iconSizes.small
            }

            if (kickoff.vertical) {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.width) * buttonIcon.aspectRatio;
            } else {
                return -1;
            }
        }

        Layout.maximumWidth: {
            if (!kickoff.inPanel) {
                return -1;
            }

            if (kickoff.vertical) {
                return PlasmaCore.Units.iconSizeHints.panel;
            } else {
                return Tools.dynamicSetWidgetWidth(plasmoid.icon, buttonIcon.width, kickoff.menuLabel, labelTextField.width, PlasmaCore.Units.smallSpacing * 2);
            }
        }

        Layout.maximumHeight: {
            if (!kickoff.inPanel) {
                return -1;
            }

            if (kickoff.vertical) {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.width) * buttonIcon.aspectRatio;
            } else {
                return PlasmaCore.Units.iconSizeHints.panel;
            }
        }

        hoverEnabled: true
        // For some reason, onClicked can cause the plasmoid to expand after
        // releasing sometimes in plasmoidviewer.
        // plasmashell doesn't seem to have this issue.
        onClicked: plasmoid.expanded = !plasmoid.expanded

        DropArea {
            id: compactDragArea
            anchors.fill: parent
        }

        Timer {
            id: expandOnDragTimer
            // this is an interaction and not an animation, so we want it as a constant
            interval: 250
            running: compactDragArea.containsDrag
            onTriggered: plasmoid.expanded = true
        }

        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: PlasmaCore.Units.smallSpacing

            PlasmaCore.IconItem {
                id: buttonIcon

                readonly property double aspectRatio: (kickoff.vertical ? implicitHeight / implicitWidth
                    : implicitWidth / implicitHeight)
                readonly property int iconSize: Tools.returnValueIfExists(plasmoid.icon, compactRoot.height)

                anchors.verticalCenter: parent.verticalCenter
                
                height: iconSize
                width: iconSize

                source: !kickoff.vertical ? plasmoid.icon : plasmoid.icon ? plasmoid.icon : kickoff.defaultIcon
                visible: plasmoid.icon

                active: parent.containsMouse || compactDragArea.containsDrag
                smooth: true
                roundToIconSize: aspectRatio === 1
            }

            PC3.Label {
                id: labelTextField

                text: !kickoff.vertical ? kickoff.menuLabel : ''
                height: compactRoot.height
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                fontSizeMode: compactRoot.panelIsMedium ? Text.VerticalFit : undefined
                font.pixelSize: compactRoot.panelIsSmall 
                    ? PlasmaCore.Theme.defaultFont.pixelSize
                    : compactRoot.panelIsMedium
                        ? PlasmaCore.Units.roundToIconSize(PlasmaCore.Units.gridUnit)
                        : PlasmaCore.Units.roundToIconSize(PlasmaCore.Units.gridUnit * 2)
                minimumPointSize: PlasmaCore.Theme.smallestFont.pointSize

                visible: !kickoff.vertical
            }
        }
    }

    Kicker.ProcessRunner {
        id: processRunner;
    }

    function action_menuedit() {
        processRunner.runMenuEditor();
    }

    Component.onCompleted: {
        if (plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            plasmoid.activationTogglesExpanded = true
        }
        if (plasmoid.immutability !== PlasmaCore.Types.SystemImmutable) {
            plasmoid.setAction("menuedit", i18n("Edit Applications…"), "kmenuedit");
        }
    }
} // root
