const fs = require("node:fs");
const path = require("node:path");

const fixturePath = path.join(
  process.cwd(),
  "For Rent",
  "Resources",
  "DemoSeed.json"
);
const fixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
const expectedStatuses = new Set([
  "submitted",
  "acknowledged",
  "viewing_scheduled",
  "accepted",
  "rejected",
  "cancelled",
  "expired",
]);
const actualStatuses = new Set(fixture.requests.map((request) => request.status));

if (fixture.properties.length < 12 || fixture.properties.length > 20) {
  throw new Error("DemoSeed.json must contain 12 to 20 listings.");
}

if (!fixture.properties.every((listing) =>
  listing.locationName.endsWith(", Canada")
)) {
  throw new Error("Every demo listing must use a public Canadian location.");
}

if ([...expectedStatuses].some((status) => !actualStatuses.has(status))) {
  throw new Error("DemoSeed.json must cover every legacy inquiry status.");
}

const serialized = JSON.stringify(fixture);
if (serialized.includes("password") || !serialized.includes("@example.invalid")) {
  throw new Error("Demo personas must not contain passwords or routable email addresses.");
}

console.log(`Validated ${fixture.properties.length} deterministic demo listings.`);
