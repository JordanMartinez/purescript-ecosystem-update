import cp from "child_process";
import fs from "fs";
import path from "path";
import * as utils from "./utils.mjs";

var fileObj = {};

for (const i in utils.reposArray) {
  const repoInfo = utils.reposArray[i];
  console.log(`Getting release info for ${repoInfo.repoProj}`);

  const repoDir = path.join("..", repoInfo.repoOrg, repoInfo.repoProj);

  const obj = {};

  console.log("... Fetching latest tags");
  utils.handleSpawn(
    cp.spawnSync("git", ["fetch", "--tags", "origin"], { cwd: repoDir }),
    {
      "0": () => {
        utils.handleSpawn(
          cp.spawnSync( "git", ["tag"], { cwd: repoDir }),
          {
            "0": (result) => {
              obj.gitTags = result.stdout.toString("utf-8").split("\n").filter((str) => str !== "");
            }
          }
        );
      }
    }
  );

  console.log("... Checking whether package is in Bower registry or not");
  utils.handleSpawn(
    cp.spawnSync("bower", ["info", repoInfo.repoProj]),
    {
      "1": () => {
        obj.inBowerRegistry = false;
      },
      "0": () => {
        obj.inBowerRegistry = true;
      }
    }
  );

  console.log("... Resetting to HEAD");
  utils.handleSpawn(
    cp.spawnSync("git", ["reset", "--hard", "HEAD"], { cwd: repoDir }),
    {
      "0": () => {}
    }
  );
  console.log("... Fetching from origin");
  utils.handleSpawn(
    cp.spawnSync("git", ["fetch", "origin"], { cwd: repoDir }),
    {
      "0": () => {}
    }
  );
  console.log("... Checking out origin/<default branch>");
  utils.handleSpawn(
    cp.spawnSync("git", ["checkout", `origin/${repoInfo.defaultBranch}`], { cwd: repoDir }),
    {
      "0": () => {}
    }
  );

  console.log("... Storing bower dependencies (if bower.json exists)");
  utils.handleSpawn(
    cp.spawnSync("cat", ["bower.json"], { cwd: repoDir }),
    {
      "1": () => {
        obj.hasBowerJsonFile = false;
      },
      "0": (catResult) => {
        obj.hasBowerJsonFile = true;

        const bowerContent = JSON.parse(catResult.stdout.toString("utf-8"));
        const pkgDeps =
          bowerContent.hasOwnProperty("dependencies")
            ? Object.keys(bowerContent.dependencies).map((str) => str.slice("purescript-".length)).sort()
            : [];
            const pkgDevDeps =
          bowerContent.hasOwnProperty("devDependencies")
            ? Object.keys(bowerContent.devDependencies).map((str) => str.slice("purescript-".length)).sort()
            : [];

        obj.bowerDependencies = pkgDeps;
        obj.bowerDevDependencies = pkgDevDeps;
      }
    }
  );

  const getDhallDependenciesField = (dhallToJsonInput, cb) => {
    utils.handleSpawn(
      cp.spawnSync("dhall-to-json", { input: dhallToJsonInput }),
      {
        "0": (dtjResult) => {
          const spagoJson = JSON.parse(dtjResult.stdout.toString("utf-8"));
          cb([...new Set(spagoJson.dependencies)].sort());
        }
      }
    );
  }

  console.log("... Storing spago dependencies (if spago.dhall exists)");
  utils.handleSpawn(
    cp.spawnSync("cat", ["spago.dhall"], { cwd: repoDir }),
    {
      "1": () => {
        obj.hasSpagoDhallFile = false;
      },
      "0": (catResult) => {
        obj.hasSpagoDhallFile = true;

        // We can get the dependencies listed in the spago dhall file by
        // - removing the `packages` field
        // - converting the dhall to json
        // - accessing the 'dependencies' field
        const spagoContents = catResult.stdout.toString("utf-8");
        const packagesFieldRegex = /, +packages =[ \n]+[^,]+,/;
        const spagoContentsNoPkgField = spagoContents.replace(packagesFieldRegex, ",");
        getDhallDependenciesField(spagoContentsNoPkgField, (deps) => {
          obj.spagoDependencies = deps;
        });
      }
    }
  );

  console.log("... Storing spago (test) dependencies (if test.dhall exists)");
  utils.handleSpawn(
    cp.spawnSync("cat", ["test.dhall"], { cwd: repoDir }),
    {
      "1": () => {
        obj.hasTestDhallFile = false;
      },
      "0": (catResult) => {
        obj.hasTestDhallFile = true;

        // We can get the dependencies listed in the spago dhall file by
        // - removing the `packages` field
        // - converting the dhall to json
        // - accessing the 'dependencies' field
        const spagoContents = catResult.stdout.toString("utf-8");
        const packagesFieldRegex = /let +([^ ]+) +=.+in +([^ ]+)/ms;
        const spagoContentsNoPkgField = spagoContents.replace(packagesFieldRegex, "let $1 = { sources = [] : List Text, dependencies = [] : List Text }\nin $1");
        getDhallDependenciesField(spagoContentsNoPkgField, (deps) => {
          obj.spagoTestDependencies = deps;
        });
      }
    }
  );

  fileObj[repoInfo.pkg] = obj;
};

utils.mkdirP(utils.filesDir.release);
const outFile = path.join(utils.filesDir.release, "next-release-info_" + (new Date().toISOString()) +".json");
fs.writeFileSync(outFile, JSON.stringify(fileObj, null, 2));
