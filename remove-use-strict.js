import process from "process";
import fs from "fs";

const fileName = process.argv[1];
const content = fs.readFileSync(fileName, "utf-8");
const fixed = content.replaceAll(/[ \t]*"use strict";\n+/g, "");

fs.writeFileSync(fileName, fixed);
