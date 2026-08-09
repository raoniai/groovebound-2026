import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const landingDir = resolve(scriptDir, "..");
const gameDir = resolve(landingDir, "..", "groove-bound");

const git = (args) => execFileSync("git", ["-C", gameDir, ...args], { encoding: "utf8" }).trim();
const branch = git(["branch", "--show-current"]) || "detached";
const commit = git(["rev-parse", "--short", "HEAD"]);
const gameWorkingLines = git(["status", "--porcelain", "--", "."]).split("\n").filter(Boolean);
const history = git(["log", "--date=short", "--pretty=format:%h%x1f%cs%x1f%cI%x1f%s"])
  .split("\n")
  .filter(Boolean)
  .map((line) => {
    const [hash, date, sortKey, subject] = line.split("\x1f");
    return { hash, date, dateLabel: date, sortKey, subject };
  });

const changelog = readFileSync(resolve(landingDir, "CHANGELOG.md"), "utf8");
const siteEntries = changelog.split(/^## /gm).slice(1).map((section, index) => {
  const [heading, ...body] = section.trim().split("\n");
  const [date, id, title] = heading.split("|").map((part) => part.trim());
  return {
    date,
    dateLabel: date,
    id,
    title,
    summary: body.join(" ").trim().replace(/\s+/g, " "),
    sortKey: `${date}T23:59:${String(59 - index).padStart(2, "0")}`
  };
});

const generatedAt = new Date();
const generatedAtLabel = new Intl.DateTimeFormat("en-AU", {
  timeZone: "Australia/Sydney",
  day: "2-digit",
  month: "short",
  year: "numeric",
  hour: "2-digit",
  minute: "2-digit"
}).format(generatedAt);

const data = {
  generatedAt: generatedAt.toISOString(),
  generatedAtLabel,
  game: {
    branch,
    commit,
    dirty: gameWorkingLines.length > 0,
    workingChanges: gameWorkingLines.length,
    history
  },
  site: { history: siteEntries }
};

writeFileSync(resolve(landingDir, "status-data.js"), `window.GROOVE_STATUS = ${JSON.stringify(data, null, 2)};\n`);
console.log(`Status updated: ${history.length} game commits, ${siteEntries.length} site entries, ${gameWorkingLines.length} game working changes.`);
