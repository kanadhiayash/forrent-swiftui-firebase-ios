const test = require("node:test");
const assert = require("node:assert/strict");
const {createHandlers, requireAuth} = require("./handlers");

function baseState(overrides = {}) {
  return {
    properties: {
      "listing-a": {
        id: "listing-a",
        landlordId: "landlord-a",
        isListed: true,
        isAssigned: false,
      },
    },
    requests: {
      "tenant-a_listing-a": {
        id: "tenant-a_listing-a",
        tenantId: "tenant-a",
        landlordId: "landlord-a",
        propertyId: "listing-a",
        status: "submitted",
      },
    },
    ...overrides,
  };
}

function createMockDb(initialState) {
  const state = structuredClone(initialState);
  const updates = [];

  function collection(name) {
    return {
      doc(id) {
        return {collection: name, id};
      },
    };
  }

  async function runTransaction(callback) {
    const transaction = {
      async get(ref) {
        const record = state[ref.collection]?.[ref.id];
        return {
          exists: Boolean(record),
          data: () => structuredClone(record),
        };
      },
      update(ref, patch) {
        const collectionState = state[ref.collection] ?? {};
        const existing = collectionState[ref.id] ?? {};
        collectionState[ref.id] = {...existing, ...patch};
        state[ref.collection] = collectionState;
        updates.push({ref, patch});
      },
    };

    await callback(transaction);
  }

  return {
    db: {collection, runTransaction},
    state,
    updates,
  };
}

function request(uid, data) {
  return {
    auth: uid ? {uid} : undefined,
    data,
  };
}

async function assertRejectsWithCode(action, code) {
  await assert.rejects(action, (error) => error.code === code);
}

test("requireAuth rejects unauthenticated callable requests", () => {
  assert.throws(
    () => requireAuth({}),
    (error) => error.code === "unauthenticated",
  );
});

test("landlord can reject a submitted inquiry", async () => {
  const {db, state} = createMockDb(baseState());
  const handlers = createHandlers(db);

  const result = await handlers.transitionInquiry(request("landlord-a", {
    requestId: "tenant-a_listing-a",
    status: "rejected",
  }));

  assert.deepEqual(result, {
    requestId: "tenant-a_listing-a",
    status: "rejected",
  });
  assert.equal(state.requests["tenant-a_listing-a"].status, "rejected");
  assert.equal(state.properties["listing-a"].isAssigned, false);
});

test("landlord accept assigns and unlists the property", async () => {
  const {db, state} = createMockDb(baseState({
    requests: {
      "tenant-a_listing-a": {
        id: "tenant-a_listing-a",
        tenantId: "tenant-a",
        landlordId: "landlord-a",
        propertyId: "listing-a",
        status: "acknowledged",
      },
    },
  }));
  const handlers = createHandlers(db);

  const result = await handlers.transitionInquiry(request("landlord-a", {
    requestId: "tenant-a_listing-a",
    status: "accepted",
  }));

  assert.equal(result.status, "accepted");
  assert.equal(state.requests["tenant-a_listing-a"].status, "accepted");
  assert.equal(state.properties["listing-a"].isAssigned, true);
  assert.equal(state.properties["listing-a"].isListed, false);
});

test("tenant can cancel their own submitted inquiry", async () => {
  const {db, state} = createMockDb(baseState());
  const handlers = createHandlers(db);

  await handlers.transitionInquiry(request("tenant-a", {
    requestId: "tenant-a_listing-a",
    status: "cancelled",
  }));

  assert.equal(state.requests["tenant-a_listing-a"].status, "cancelled");
});

test("tenant and unrelated users cannot accept inquiries", async () => {
  const handlers = createHandlers(createMockDb(baseState()).db);

  await assertRejectsWithCode(
    () => handlers.transitionInquiry(request("tenant-a", {
      requestId: "tenant-a_listing-a",
      status: "accepted",
    })),
    "permission-denied",
  );
  await assertRejectsWithCode(
    () => handlers.transitionInquiry(request("tenant-b", {
      requestId: "tenant-a_listing-a",
      status: "rejected",
    })),
    "permission-denied",
  );
});

test("transitionInquiry rejects bad inputs and unavailable transitions", async () => {
  const {db} = createMockDb(baseState());
  const handlers = createHandlers(db);

  await assertRejectsWithCode(
    () => handlers.transitionInquiry(request("landlord-a", {
      requestId: "",
      status: "rejected",
    })),
    "invalid-argument",
  );
  await assertRejectsWithCode(
    () => handlers.transitionInquiry(request("landlord-a", {
      requestId: "tenant-a_listing-a",
    })),
    "invalid-argument",
  );
  await assertRejectsWithCode(
    () => handlers.transitionInquiry(request("landlord-a", {
      requestId: "tenant-a_listing-a",
      status: "accepted",
    })),
    "failed-precondition",
  );
});

test("publishListing only lets the listing owner publish", async () => {
  const {db, state} = createMockDb(baseState({
    properties: {
      "listing-a": {
        id: "listing-a",
        landlordId: "landlord-a",
        isListed: false,
        isAssigned: true,
      },
    },
  }));
  const handlers = createHandlers(db);

  await assertRejectsWithCode(
    () => handlers.publishListing(request("tenant-a", {listingId: "listing-a"})),
    "permission-denied",
  );

  const result = await handlers.publishListing(
    request("landlord-a", {listingId: "listing-a"}),
  );

  assert.deepEqual(result, {listingId: "listing-a", status: "published"});
  assert.equal(state.properties["listing-a"].isListed, true);
  assert.equal(state.properties["listing-a"].isAssigned, false);
});
