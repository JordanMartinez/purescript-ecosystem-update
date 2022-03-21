import process from "process";
import fs from "fs";

// find src -type f -wholename "**/*.js" -print0 -exec node "$REMOVE_USE_STRICT_SCRIPT" "{}" \;

const fileName = process.argv[2];
const content = fs.readFileSync(fileName, "utf-8");
const fixed = content.replaceAll(/[ \t]*"use strict";\n+/g, "");

fs.writeFileSync(fileName, fixed);
