import MuseScore 3.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FileIO 3.0

MuseScore {
    version: "1.0"
    description: qsTr("This plugin takes text as input, and encodes it in the score as morse code")
    pluginType: "dialog"
    menuPath: "Plugins.UI"
    title: "textToMorse"
    thumbnailName: "morseImage.png"

    width: 500
    height: 200

    Item { //UI code below
        id: dialog
        anchors.fill: parent

        //I'm unsure why the layout is so messed up
        // The button should be above the dropdowns, but it isn't, 
        //along with some awkwards spacing. I apologize for the ugliness,
        //this is just my first plugin
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            Text {
                text: "Translate to morse"
                font.pointSize: 16
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            TextField { //User inputs their text
                id: inputField
                placeholderText: "Input text..."
                Layout.preferredWidth: 310
                
            }
            Button { //Button to translate
                text: "Translate"
                Layout.topMargin: 20
                Layout.preferredWidth: 310
                onClicked: {
                    if (!curScore) {
                        console.log("No score found!");
                        return;
                    }


                    var rhythm = combo1.currentText; // "8th", "16th", or "32nd"
                    var pitchName = combo2.currentText; // "C", "C#", or "D"

                    var rhythmMap = { "8th": 8, "16th": 16, "32nd": 32 };
                    var smallest = rhythmMap[rhythm]; // returns 8, 16, or 32


                    var pitchMap = {
                        "C": 60,
                        "C#": 61,
                        "D": 62,
                        "D#": 63,
                        "E": 64,
                        "F": 65,
                        "F#": 66,
                        "G": 67,
                        "G#": 68,
                        "A": 69,
                        "A#": 70,
                        "B": 71
                    };
                    var pitch = pitchMap[pitchName];


                    var userInput = inputField.text;
                    var morse = dialog.toMorseCode(userInput);

                    //var morse = ".--";

                    var cursor = curScore.newCursor();
                    cursor.rewind(1); // Start at beginning of score

                    curScore.startCmd();

                    for (var i = 0; i < morse.length; i++) {
                        var c = morse[i];

                        // Add a note or rest only if the cursor is valid
                        if (!cursor.segment || cursor.voice !== 0) {
                            console.log("Cursor not ready at position " + i);
                            continue;
                        }

                        if (c === ".") {
                            cursor.setDuration(1, smallest);
                            cursor.addNote(pitch);
                            console.log("Added dot");

                            // only add short rest if next symbol is dot or dash
                            if (i + 1 < morse.length && (morse[i + 1] === "." || morse[i + 1] === "-")) {
                                cursor.setDuration(1, smallest);
                                cursor.addRest();
                            }
                        } else if (c === "-") {
                            cursor.setDuration(3, smallest);
                            cursor.addNote(pitch);
                            console.log("Added dash");

                            if (i + 1 < morse.length && (morse[i + 1] === "." || morse[i + 1] === "-")) {
                                cursor.setDuration(1, smallest);
                                cursor.addRest();
                            }
                        } else if (c === " ") {
                            // inter-letter space
                            cursor.setDuration(3, smallest);
                            cursor.addRest();
                        } else if (c === "/") {
                            // inter-word space
                            cursor.setDuration(7, smallest);
                            cursor.addRest();
                        }
                    }


                    curScore.endCmd();
                }

            }
            RowLayout { // Row layout groups the two combo boxes next to eachother
                    anchors.centerIn: parent
                    spacing: 10
                    Layout.topMargin: 20
                    ComboBox { //combo box for selecting smallest rhtyhm
                        id: combo1
                        Layout.preferredWidth: 150
                        model: ["8th", "16th", "32nd"]
                }

                    ComboBox { //Combo box for selecting pitch
                        id: combo2
                        Layout.preferredWidth: 150  
                        model: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
                }
            }
            
        }
        function toMorseCode(text) {
        var morseMap = {
            A: ".-", B: "-...", C: "-.-.", D: "-..", E: ".", F: "..-.",
            G: "--.", H: "....", I: "..", J: ".---", K: "-.-", L: ".-..",
            M: "--", N: "-.", O: "---", P: ".--.", Q: "--.-", R: ".-.",
            S: "...", T: "-", U: "..-", V: "...-", W: ".--", X: "-..-",
            Y: "-.--", Z: "--..", " ": "/"
        };

        var result = "";
        for (var i = 0; i < text.length; i++) {
            var c = text[i].toUpperCase();
            result += (morseMap[c] || "?") + " ";
        }
        return result.trim();
    }
    }
    
}
