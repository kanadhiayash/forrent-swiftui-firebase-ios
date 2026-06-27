const {execFileSync} = require("node:child_process");

const fs = require("node:fs");

const trackedFiles = execFileSync("git", [
  "ls-files",
  "--cached",
  "--others",
  "--exclude-standard",
], {
  encoding: "utf8",
}).trim().split("\n").filter(Boolean);

const blockedPaths = trackedFiles.filter((file) =>
  file.endsWith("GoogleService-Info.plist") ||
  file.endsWith(".env") ||
  file.includes("service-account")
);

if (blockedPaths.length > 0) {
  throw new Error(`Blocked secret-bearing paths are tracked: ${blockedPaths.join(", ")}`);
}

const patterns = [
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  /AIza[0-9A-Za-z_-]{30,}/,
  /sk-(?:proj-)?[0-9A-Za-z_-]{20,}/,
];

for (const file of trackedFiles) {
  if (/\.(?:png|jpg|jpeg|gif|xcassets)$/i.test(file)) {
    continue;
  }

  const content = fs.readFileSync(file, "utf8");

  if (patterns.some((pattern) => pattern.test(content))) {
    throw new Error(`Possible secret detected in ${file}.`);
  }
}

console.log(`Scanned ${trackedFiles.length} tracked files with no blocked secret patterns.`);
