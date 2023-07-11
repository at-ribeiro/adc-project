/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationToAllUsers = functions.https.onCall(async (data, context) => {
    const title = data.title;
    const body = data.body;
    // Fetch all tokens from database

    const message = {
        notification: {
            title: title,
            body: body,
        },
        tokens: tokens, // List of all user tokens
    };

    // Send a message to devices subscribed to the provided topic.
    await admin.messaging().sendMulticast(message);

    // Response is a message ID string.
    console.log('Successfully sent message:', response);
    return { success: true };
});
