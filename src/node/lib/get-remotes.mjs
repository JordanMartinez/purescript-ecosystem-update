import cp from "child_process";
import fs from "fs";
import path from "path";
import * as utils from "./utils.mjs";

var fileObj = {};

for (const i in utils.reposArray) {
  const repoInfo = utils.reposArray[i];
  console.log(`Getting remote info for ${repoInfo.repoProj}`);

  const repoDir = path.join("..", repoInfo.repoOrg, repoInfo.repoProj);

  const needsRemoteSwitch = cp.execSync("git remote -v", { cwd: repoDir })
    .toString("utf-8")
    .split("\n")
    .filter((s) => s !== "")
    .map((str) => {
      const arr = str.split("\t").map((s) => s.trim()).filter((s) => s !== "");
      const arr2 = arr[1].split("(").map((s) => s.trim()).filter((s) => s !== "")[0];
      const obj = {};
      obj[arr[0]] = arr2
      return obj;
    })
    .some((el) => el.hasOwnProperty("origin") && el["origin"] !== repoInfo.repoUrl);

  if (needsRemoteSwitch) {
    cp.execSync("git remote rename upstream correct", { cwd: repoDir });
    cp.execSync("git remote rename origin self", { cwd: repoDir });
    cp.execSync("git remote rename correct origin", { cwd: repoDir });
  } else {
    console.log(`${repoInfo.pkg}'s 'origin' remote matches URL`);
  }
  // const remotes = [ ... new Set(lines) ];

  // fileObj[repoInfo.pkg] = remotes;
};

// utils.mkdirP(utils.filesDir.release);
// const outFile = path.join(utils.filesDir.release, "remote-info_" + (new Date().toISOString()) +".json");
// fs.writeFileSync(outFile, JSON.stringify(fileObj, null, 2));
