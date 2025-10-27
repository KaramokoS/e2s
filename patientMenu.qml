import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    // --- Signaux pour intégration ---
    signal newPatientClicked()
    signal followupClicked()
    signal dischargeClicked()

    Rectangle {
        anchors.fill: parent
        color: "white"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 40
            width: parent.width * 0.6

            // === Titre principal ===
            Text {
                text: qsTr("Patient")
                font.pixelSize: 30
                font.bold: true
                color: "#2c3e50"
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            // === Ligne de boutons ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 30
                Layout.alignment: Qt.AlignHCenter

                // --- Bouton : Nouveau patient ---
                Rectangle {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 100
                    radius: 20
                    color: "white"
                    border.color: "#2980b9"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.newPatientClicked()
                        hoverEnabled: true
                        onEntered: parent.color = "#2c3e50"
                        onExited: parent.color = "white"
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            source: "icons/add_patient.png"
                            width: 48
                            height: 48
                        }
                        Text {
                            text: qsTr("Nouveau patient")
                            font.bold: true
                            color: "black"
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // --- Bouton : Identifié Patient ---
                Rectangle {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 100
                    radius: 20
                    color: "white"
                    border.color: "#2980b9"
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.followupClicked()
                        hoverEnabled: true
                        onEntered: parent.color = "#2c3e50"
                        onExited: parent.color = "white"
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            source: "icons/follow_patient.png"
                            width: 48
                            height: 48
                        }
                        Text {
                            text: qsTr("Identifié Patient")
                            font.bold: true
                            color: "black"
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    onNewPatientClicked: {
        console.log("📋 Nouveau patient demandé")
        stack.push("PrescriptionEditor.qml")
    }

    onFollowupClicked : {
        stack.push("PatientIdentification.qml", { buttonName: "prescriptionButton" })
    }
}
