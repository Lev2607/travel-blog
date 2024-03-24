const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

// Funktion zum Speichern eines neuen Kommentars in DynamoDB
const saveComment = async (comment) => {
    const params = {
        TableName: 'travelBlogComments', // Name der DynamoDB-Tabelle
        Item: {
            id: Date.now().toString(), // Eindeutige ID für den Kommentar
            comment: comment // Der Kommentarinhalt
        }
    };
    await dynamoDB.put(params).promise(); // Kommentar in die Tabelle einfügen
};

// Funktion zum Abrufen aller Kommentare aus DynamoDB
const getComments = async () => {
    const params = {
        TableName: 'travelBlogComments' // Name der DynamoDB-Tabelle
    };
    const data = await dynamoDB.scan(params).promise(); // Alle Einträge aus der Tabelle abrufen
    return data.Items; // Rückgabe der Liste von Kommentaren
};

exports.handler = async (event) => {
    try {
        if (event.httpMethod === 'GET') {
            // Bei GET-Anfragen alle Kommentare abrufen und zurückgeben
            const comments = await getComments();
            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(comments)
            };
        } else if (event.httpMethod === 'POST') {
            // Bei POST-Anfragen neuen Kommentar speichern und Status 200 OK zurückgeben
            const requestBody = JSON.parse(event.body);
            await saveComment(requestBody.comment);
            return {
                statusCode: 200,
                body: JSON.stringify({ message: 'Kommentar erfolgreich gespeichert' })
            };
        } else {
            // Bei anderen HTTP-Methoden einen Fehler zurückgeben
            return {
                statusCode: 405,
                body: JSON.stringify({ message: 'Methode nicht erlaubt' })
            };
        }
    } catch (error) {
        // Bei Fehlern einen Fehlerstatus zurückgeben
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Interner Serverfehler' })
        };
    }
};
