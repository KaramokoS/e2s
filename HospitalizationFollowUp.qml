import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Item {
    id: root
    anchors.fill: parent
    anchors.margins: 20

    // === Signaux pour intégration backend ===
    signal saveRequested(string followupJson)
    signal printRequested(string followupJson)
    signal shareRequested(string followupJson, string target)

    // === Données ===
    property date visitDate: new Date()
    property string patientName: ""
    property string followUpText: ""
    property string complementaryExam: ""
    property string reporterDoctor: ""


    // === Fonction utilitaire pour générer le JSON ===
    function buildJson() {
        var data = {
            visitDate: visitDate.toISOString(),
            patientName: patientName,
            followUpText: followUpText,
            complementaryExam: complementaryExam,
            reporterDoctor: reporterDoctor
        }
        return JSON.stringify(data)
    }

    // === Layout principal ===
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        contentWidth: parent.width
        contentHeight: column.implicitHeight

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 14

            // === En-tête ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Label {
                    text: qsTr("Suivi d'hospitalisation")
                    font.pixelSize: 26
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "← Retour"
                    onClicked: {
                        var view = root.parent
                        if (view && view.pop) view.pop()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

            // === Informations patient ===
            GroupBox {
                title: qsTr("Informations du patient")
                Layout.fillWidth: true

                GridLayout {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Label { text: qsTr("Nom du patient :") }
                    TextField {
                        readOnly: true
                        text: root.patientName
                        placeholderText: qsTr("Nom du patient")
                    }

                    Label { text: qsTr("Identifiant patient :") }
                    TextField {
                        readOnly: true
                        text: root.patientId
                        placeholderText: qsTr("Identifiant patient")
                    }
                }
            }

            GroupBox {
                title: qsTr("Informations médicales")
                Layout.fillWidth: true

                GridLayout {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Label { text: qsTr("Date d'admission :") }
                    RowLayout {
                        spacing: 6
                        TextField {
                            readOnly: true
                            placeholderText: qsTr("Date (JJ/MM/AAAA)")
                            text: Qt.formatDate(root.admissionDate, "dd/MM/yyyy")
                            onEditingFinished: {
                                var parts = text.split("/");
                                if (parts.length === 3) {
                                    var d = new Date(parts[2], parts[1]-1, parts[0]);
                                    if (!isNaN(d)) root.admissionDate = d;
                                }
                            }
                            width: 120
                        }
                    }

                    Label { text: qsTr("Date de visite :") }
                    RowLayout {
                        spacing: 6
                        TextField {
                            placeholderText: qsTr("Date (JJ/MM/AAAA)")
                            text: Qt.formatDate(root.visitDate, "dd/MM/yyyy")
                            onEditingFinished: {
                                var parts = text.split("/");
                                if (parts.length === 3) {
                                    var d = new Date(parts[2], parts[1]-1, parts[0]);
                                    if (!isNaN(d)) root.visitDate = d;
                                }
                            }
                            width: 120
                        }
                        Button { text: "📅"; onClicked: dischargeDialog.open() }
                    }

                    Label { text: qsTr("Identité du rédacteur :") }
                    TextField { text: root.reporterDoctor; onTextChanged: root.reporterDoctor = text }
                }
            }

            // === Suivi médical ===
            GroupBox {
                title: qsTr("Observations")
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 12

                    Label { text: qsTr("Observation et Suivie : ") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.followUpText
                        wrapMode: Text.Wrap
                        onTextChanged: root.followUpText = text
                    }

                    // --- Antécédents médicaux + boutons d'ajout ---
                    
                    Label { text: qsTr("Examens complémentaires :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.complementaryExam
                        wrapMode: Text.Wrap
                        onTextChanged: root.complementaryExam = text
                    }
                }
            }


            // === Actions ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }

                Button {
                    text: qsTr("Sauvegarder PDF")
                    onClicked: {
                        var json = root.buildJson()
                        saveDialog.open()

                    }
                }
                Button {
                    text: qsTr("Partager")
                    onClicked: shareMenu.open()
                }

                Menu {
                    id: shareMenu
                    title: qsTr("Partager")
                    MenuItem { text: "E-mail"; onTriggered: root.shareRequested(root.buildJson(), "email") }
                    MenuItem { text: "Dossier partagé"; onTriggered: root.shareRequested(root.buildJson(), "sharedRecord") }
                }
            }
        }
    }

    SavePdfDialog {
        id: saveDialog
        onFileSelected: function(path) {
            console.log("PDF sera sauvegardé dans :", path)
            var json = root.buildJson()
            PrescriptionBackend.generate_followup_report(json, path)
        }
    }

    // === Fonction utilitaire pour charger depuis JSON ===
    function loadFromJson(json) {
        try {
            var o = JSON.parse(json)
            patientName = o.patientName || ""
            followUpText = o.followUpText || ""
            complementaryExam = o.complementaryExam || ""
            reporterDoctor = o.reporterDoctor || ""
            visitDate = o.visitDate ? new Date(o.visitDate) : new Date()
        } catch (e) {
            console.warn("FollowUp load error:", e)
        }
    }
}
