const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in to continue.");
  }
  return request.auth.uid;
}

exports.publishListing = onCall(async (request) => {
  const uid = requireAuth(request);
  const listingId = request.data?.listingId;
  if (typeof listingId !== "string" || listingId.length === 0) {
    throw new HttpsError("invalid-argument", "A listing ID is required.");
  }

  const listingRef = db.collection("properties").doc(listingId);
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(listingRef);
    if (!snapshot.exists || snapshot.data().landlordId !== uid) {
      throw new HttpsError("permission-denied", "You do not own this listing.");
    }
    transaction.update(listingRef, {
      isListed: true,
      isAssigned: false,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return {listingId, status: "published"};
});

exports.transitionInquiry = onCall(async (request) => {
  const uid = requireAuth(request);
  const requestId = request.data?.requestId;
  const nextStatus = request.data?.status;

  if (typeof requestId !== "string" || typeof nextStatus !== "string") {
    throw new HttpsError("invalid-argument", "Invalid inquiry transition.");
  }

  const inquiryRef = db.collection("requests").doc(requestId);
  await db.runTransaction(async (transaction) => {
    const inquiry = await transaction.get(inquiryRef);
    if (!inquiry.exists) {
      throw new HttpsError("not-found", "Inquiry not found.");
    }

    const data = inquiry.data();
    const transitions = {
      submitted: new Set(["acknowledged", "rejected", "cancelled", "expired"]),
      acknowledged: new Set([
        "viewing_scheduled",
        "accepted",
        "rejected",
        "cancelled",
        "expired",
      ]),
      viewing_scheduled: new Set([
        "accepted",
        "rejected",
        "cancelled",
        "expired",
      ]),
    };
    const isLandlordAction =
      data.landlordId === uid &&
      new Set(["acknowledged", "viewing_scheduled", "accepted", "rejected"])
        .has(nextStatus);
    const isRenterCancellation =
      data.tenantId === uid && nextStatus === "cancelled";

    if (!isLandlordAction && !isRenterCancellation) {
      throw new HttpsError("permission-denied", "You cannot update this inquiry.");
    }
    if (!transitions[data.status]?.has(nextStatus)) {
      throw new HttpsError("failed-precondition", "This inquiry transition is unavailable.");
    }

    transaction.update(inquiryRef, {
      status: nextStatus,
      updatedAt: FieldValue.serverTimestamp(),
    });

    if (nextStatus === "accepted") {
      const listingRef = db.collection("properties").doc(data.propertyId);
      transaction.update(listingRef, {
        isAssigned: true,
        isListed: false,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  });

  return {requestId, status: nextStatus};
});
