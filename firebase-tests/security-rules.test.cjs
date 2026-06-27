const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  doc,
  getDoc,
  setDoc,
  updateDoc,
} = require("firebase/firestore");
const {
  ref,
  uploadBytes,
  deleteObject,
} = require("firebase/storage");

const projectId = "for-rent-ci";
let environment;

test.before(async () => {
  environment = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync(path.join(process.cwd(), "firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
    storage: {
      rules: fs.readFileSync(path.join(process.cwd(), "storage.rules"), "utf8"),
      host: "127.0.0.1",
      port: 9199,
    },
  });
});

test.after(async () => {
  await environment.cleanup();
});

test.beforeEach(async () => {
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "users", "landlord-a"), {
      id: "landlord-a",
      email: "landlord@example.invalid",
      role: "landlord",
    });
    await setDoc(doc(db, "users", "tenant-a"), {
      id: "tenant-a",
      email: "tenant@example.invalid",
      role: "tenant",
    });
    await setDoc(doc(db, "users", "tenant-b"), {
      id: "tenant-b",
      email: "other@example.invalid",
      role: "tenant",
    });
    await setDoc(doc(db, "properties", "listing-a"), {
      id: "listing-a",
      landlordId: "landlord-a",
      title: "Public rental",
      isListed: true,
      isAssigned: false,
    });
  });
});

test("public users can read published listings but cannot write them", async () => {
  const publicDb = environment.unauthenticatedContext().firestore();

  await assertSucceeds(getDoc(doc(publicDb, "properties", "listing-a")));
  await assertFails(updateDoc(doc(publicDb, "properties", "listing-a"), {
    title: "Tampered",
  }));
});

test("users cannot escalate their account role", async () => {
  const tenantDb = environment.authenticatedContext("tenant-a").firestore();

  await assertFails(updateDoc(doc(tenantDb, "users", "tenant-a"), {
    role: "landlord",
  }));
});

test("only the owner can edit a listing", async () => {
  const ownerDb = environment.authenticatedContext("landlord-a").firestore();
  const otherDb = environment.authenticatedContext("tenant-b").firestore();

  await assertSucceeds(updateDoc(doc(ownerDb, "properties", "listing-a"), {
    title: "Owner update",
  }));
  await assertFails(updateDoc(doc(otherDb, "properties", "listing-a"), {
    title: "Unauthorized update",
  }));
});

test("tenants can submit a valid inquiry but cannot change its status", async () => {
  const tenantDb = environment.authenticatedContext("tenant-a").firestore();
  const inquiryRef = doc(tenantDb, "requests", "tenant-a_listing-a");

  await assertSucceeds(setDoc(inquiryRef, {
    id: "tenant-a_listing-a",
    tenantId: "tenant-a",
    landlordId: "landlord-a",
    propertyId: "listing-a",
    status: "submitted",
  }));
  await assertFails(updateDoc(inquiryRef, {
    status: "accepted",
  }));
});

test("listing media writes and deletes are restricted to the owner", async () => {
  const ownerStorage = environment.authenticatedContext("landlord-a").storage();
  const otherStorage = environment.authenticatedContext("tenant-b").storage();
  const ownerReference = ref(
    ownerStorage,
    "listing-media/landlord-a/listing-a/photo.jpg"
  );
  const otherReference = ref(
    otherStorage,
    "listing-media/landlord-a/listing-a/other.jpg"
  );
  const imageBytes = new Uint8Array([255, 216, 255, 217]);

  await assertSucceeds(uploadBytes(ownerReference, imageBytes, {
    contentType: "image/jpeg",
  }));
  await assertFails(uploadBytes(otherReference, imageBytes, {
    contentType: "image/jpeg",
  }));
  await assertSucceeds(deleteObject(ownerReference));
});

test("fixture uses reserved invalid domains rather than real account data", () => {
  const fixture = JSON.parse(
    fs.readFileSync(
      path.join(process.cwd(), "For Rent", "Resources", "DemoSeed.json"),
      "utf8"
    )
  );
  const serialized = JSON.stringify(fixture);

  assert.equal(serialized.includes("@example.invalid"), true);
  assert.equal(serialized.includes("password"), false);
});
