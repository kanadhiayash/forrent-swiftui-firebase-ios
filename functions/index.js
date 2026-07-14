const {onCall} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {createHandlers} = require("./handlers");

initializeApp();

const db = getFirestore();
const handlers = createHandlers(db);

exports.publishListing = onCall(handlers.publishListing);
exports.transitionInquiry = onCall(handlers.transitionInquiry);
