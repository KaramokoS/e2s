import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// PrescriptionEditor.qml
// Fenêtre QML pour édition d'une ordonnance
// Usage: instancier comme composant dans votre application bureautique.
// Émet des signaux pour sauvegarde/partage afin d'être intégrés au backend.

Item {
    id: root
    anchors.fill: parent

    // Signaux à connecter depuis votre backend C++/JS
    signal saveRequested(string prescriptionJson)
    signal printRequested(string prescriptionJson)
    signal shareRequested(string prescriptionJson, string target)

    // Modèle de données local (peut être remplacé par un ListModel côté C++).
    ListModel {
        id: medsModel
        // Exemple initial (vide de préférence en production)
        ListElement { name: ""; dosage: ""; unit: "mg"; frequency: ""; duration: ""; notes: "" }
    }

    property string patientName: ""
    property string patientId: ""
    property date prescriptionDate: new Date()
    property string doctorName: ""
    property string clinicName: ""

    // Génère un JSON de l'ordonnance (pour envoi au backend)
    function buildPrescriptionJson() {
        var meds = [];
        for (var i = 0; i < medsModel.count; ++i) {
            var e = medsModel.get(i);
            // Validation minimale: ignore les lignes vides
            if (!e.name || e.name.trim() === "") continue;
            meds.push({
                name: e.name,
                dosage: e.dosage,
                unit: e.unit,
                frequency: e.frequency,
                duration: e.duration,
                notes: e.notes
            });
        }

        var payload = {
            patientName: root.patientName,
            patientId: root.patientId,
            prescriptionDate: root.prescriptionDate.toISOString(),
            doctorName: root.doctorName,
            clinicName: root.clinicName,
            medications: meds
        };
        return JSON.stringify(payload);
    }

    // Layout principal
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        //padding: 12

        // En-tête patient / médecin
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Label { text: qsTr("Patient"); font.bold: true }
                RowLayout {
                    spacing: 6
                    TextField {
                        id: patientNameField
                        placeholderText: qsTr("Nom du patient")
                        text: root.patientName
                        onTextChanged: root.patientName = text
                    }
                    TextField {
                        id: patientIdField
                        placeholderText: qsTr("ID patient")
                        text: root.patientId
                        onTextChanged: root.patientId = text
                        width: 160
                    }
                }
            }

            ColumnLayout {
                spacing: 6
                Label { text: qsTr("Médecin") ; font.bold: true }
                TextField {
                    id: doctorField
                    placeholderText: qsTr("Nom du médecin")
                    text: root.doctorName
                    onTextChanged: root.doctorName = text
                    width: 260
                }
                RowLayout {
                    spacing: 6
                    TextField {
                        id: clinicField
                        placeholderText: qsTr("Cabinet / Clinique")
                        text: root.clinicName
                        onTextChanged: root.clinicName = text
                        width: 260
                    }
                    TextField {
                        placeholderText: qsTr("Date (JJ/MM/AAAA)")
                        text: Qt.formatDate(root.prescriptionDate, "dd/MM/yyyy")
                        onEditingFinished: {
                            var parts = text.split("/");
                            if (parts.length === 3) {
                                var d = new Date(parts[2], parts[1]-1, parts[0]);
                                if (!isNaN(d)) root.prescriptionDate = d;
                            }
                        }
                        width: 120
                    }

                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "lightgray"
            opacity: 0.6
        }

        // Liste des médicaments
        Label { text: qsTr("Médicaments") ; font.bold: true }

        ListView {
            id: medsListView
            Layout.fillWidth: true
            Layout.preferredHeight: 380
            model: medsModel
            clip: true
            delegate: Item {
                width: parent.width
                height: contentRow.implicitHeight + 12

                Rectangle {
                    anchors.fill: parent
                    color: index % 2 === 0 ? "transparent" : "#f8f8f8"
                }

                ColumnLayout {
                    id: contentRow
                    anchors.margins: 6
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        TextField {
                            id: medName
                            placeholderText: qsTr("Nom du médicament")
                            text: name
                            onTextChanged: medsModel.set(index, { name: text, dosage: dosage, unit: unit, frequency: frequency, duration: duration, notes: notes })
                            Layout.fillWidth: true
                        }

                        TextField {
                            id: medDosage
                            placeholderText: qsTr("Dosage")
                            text: dosage
                            onTextChanged: medsModel.set(index, { name: name, dosage: text, unit: unit, frequency: frequency, duration: duration, notes: notes })
                            width: 120
                        }

                        ComboBox {
                            id: unitCombo
                            model: ["mg", "g", "ml", "unité(s)"]
                            currentIndex: unit ? (model.indexOf(unit) >= 0 ? model.indexOf(unit) : 0) : 0
                            onCurrentTextChanged: medsModel.set(index, { name: name, dosage: dosage, unit: currentText, frequency: frequency, duration: duration, notes: notes })
                            width: 110
                        }

                        Button {
                            text: qsTr("Supprimer")
                            onClicked: medsModel.remove(index)
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        TextField {
                            id: medFreq
                            placeholderText: qsTr("Posologie / fréquence, ex: 1 comprimé 2x/j")
                            text: frequency
                            onTextChanged: medsModel.set(index, { name: name, dosage: dosage, unit: unit, frequency: text, duration: duration, notes: notes })
                            Layout.fillWidth: true
                        }

                        TextField {
                            id: medDuration
                            placeholderText: qsTr("Durée, ex: 7 jours")
                            text: duration
                            onTextChanged: medsModel.set(index, { name: name, dosage: dosage, unit: unit, frequency: frequency, duration: text, notes: notes })
                            width: 160
                        }
                    }

                    TextArea {
                        id: medNotes
                        placeholderText: qsTr("Observations / instructions")
                        text: notes
                        onTextChanged: medsModel.set(index, { name: name, dosage: dosage, unit: unit, frequency: frequency, duration: duration, notes: text })
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        //maximumLineCount: 4
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Ajouter un médicament")
                onClicked: medsModel.append({ name: "", dosage: "", unit: "mg", frequency: "", duration: "", notes: "" })
            }

            Button {
                text: qsTr("Dupliquer ligne")
                onClicked: {
                    if (medsModel.count > 0) {
                        var e = medsModel.get(medsModel.count - 1);
                        medsModel.append({ name: e.name, dosage: e.dosage, unit: e.unit, frequency: e.frequency, duration: e.duration, notes: e.notes })
                    }
                }
                enabled: medsModel.count > 0
            }

            Item { Layout.fillWidth: true }

            // Actions globales
            Button {
                text: qsTr("Prévisualiser PDF")
                onClicked: {
                    var json = buildPrescriptionJson();
                    // Émettre signal printRequested; backend doit générer le PDF et l'ouvrir/printer
                    root.printRequested(json);
                    print("json content : "  + json)
                }
                //shortcut: StandardKey.Print
            }

            Button {
                text: qsTr("Partager")
                onClicked: {
                    var json = buildPrescriptionJson();
                    // Option: ouvrir menu de partage (email, messagerie interne)
                    shareMenu.open()
                }
            }

            Menu {
                id: shareMenu
                title: qsTr("Partager")
                MenuItem { text: qsTr("Envoyer par e-mail"); onTriggered: root.shareRequested(buildPrescriptionJson(), "email") }
                MenuItem { text: qsTr("Partager dossier partagé"); onTriggered: root.shareRequested(buildPrescriptionJson(), "sharedRecord") }
                MenuItem { text: qsTr("Exporter JSON"); onTriggered: {
                    // Si vous voulez gérer côté JS/C++ l'export
                    var json = buildPrescriptionJson();
                    // émettre saveRequested pour que le backend écrive le fichier
                    root.saveRequested(json);
                }}
            }

            Button {
                text: qsTr("Sauvegarder")
                onClicked: {
                    var json = buildPrescriptionJson();
                    // Valider: au moins un médicament non vide
                    if (json === "") return;
                    root.saveRequested(json);
                    savedToast.open();
                }
                //shortcut: Qt.modifierKeys.Control ? "Ctrl+S" : "" // comportement indicatif; voir Shortcut ci-dessous
            }
        }

        // Indicateur simple de sauvegarde
        Popup {
            id: savedToast
            x: (parent.width - width) / 2
            y: parent.height - height - 40
            modal: false
            focus: false
            visible: false
            background: Rectangle {
                color: "#323232"
                radius: 10
                opacity: 0.9
            }
            contentItem: Label {
                text: qsTr("Ordonnance sauvegardée")
                color: "white"
                padding: 10
                font.bold: true
            }

            function openToast() {
                savedToast.open()
                Qt.createQmlObject('import QtQuick 2.15; Timer { interval: 2000; running: true; repeat: false; onTriggered: savedToast.close() }', savedToast, "toastTimer")
            }
        }

        // Raccourcis clavier
        Shortcut {
            sequence: "Ctrl+S"
            onActivated: {
                var json = buildPrescriptionJson();
                root.saveRequested(json);
                savedToast.open();
            }
        }

        Shortcut {
            sequence: "Ctrl+P"
            onActivated: {
                var json = buildPrescriptionJson();
                root.printRequested(json);
            }
        }

        // Validation légère avant fermeture
        //onClosing: {
            // Ici vous pouvez vérifier si des modifications non sauvegardées existent
        //}
    }

    // Styles / Accessibilité supplémentaires
    Component.onCompleted: {
        // Par défaut : une ligne vide pour aider l'utilisateur
        if (medsModel.count === 0) medsModel.append({ name: "", dosage: "", unit: "mg", frequency: "", duration: "", notes: "" })
    }

    // Exemple de méthode utilitaire exposée au backend si besoin
    function loadFromJson(prescriptionJson) {
        try {
            var obj = JSON.parse(prescriptionJson);
            root.patientName = obj.patientName || "";
            root.patientId = obj.patientId || "";
            root.doctorName = obj.doctorName || "";
            root.clinicName = obj.clinicName || "";
            root.prescriptionDate = obj.prescriptionDate ? new Date(obj.prescriptionDate) : new Date();

            medsModel.clear();
            if (obj.medications && obj.medications.length > 0) {
                for (var i = 0; i < obj.medications.length; ++i) {
                    var m = obj.medications[i];
                    medsModel.append({ name: m.name || "", dosage: m.dosage || "", unit: m.unit || "mg", frequency: m.frequency || "", duration: m.duration || "", notes: m.notes || "" });
                }
            } else {
                medsModel.append({ name: "", dosage: "", unit: "mg", frequency: "", duration: "", notes: "" });
            }
        } catch (e) {
            console.warn("Chargement ordonnance: JSON invalide", e);
        }
    }

    // Notes d'intégration :
    // - Connectez les signaux saveRequested/printRequested/shareRequested depuis C++ ou JS pour effectuer
    //   la persistance (BD, dossier partagé), génération PDF, ou envoi sécurisé.
    // - Implémentez côté backend toutes les règles de sécurité et audit (horodatage, utilisateur auteur).
    // - Respectez la réglementation locale (signature numérique, traçabilité, confidentialité).
}
