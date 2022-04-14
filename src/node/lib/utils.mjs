import fs from "fs";
import path from "path";

export function readTextFile(path) {
  return fs.readFileSync(path, "utf-8");
}

export function readTextFileLines(path) {
  return readTextFile(path).split("\n");
}

export const filesDir = {
  release: path.join("files", "release"),
  eslint: path.join("files", "eslint"),
  ghActions: path.join("files", "gh-actions"),
  pr: path.join("files", "pr"),
  changelogs: path.join("files", "changelogs"),
  repos: path.join("files", "repos"),
};

const repoPs = readTextFileLines(path.join(filesDir.repos, "purescript.txt"));
const repoContrib = readTextFileLines(path.join(filesDir.repos, "purescript-contrib.txt"));
const repoNode = readTextFileLines(path.join(filesDir.repos, "purescript-node.txt"));
const repoWeb = readTextFileLines(path.join(filesDir.repos, "purescript-web.txt"));

const getRepoInfo = (content) => {
  const repoUrl = content.replace(/git@github\.com:([^.]+).git$/g, "$1");
  const ghRepoParts = repoUrl.split("/");
  const repoOrg = ghRepoParts[0];
  const repoProj = ghRepoParts[1];
  const pkg = repoProj.slice("purescript-".length);
  const defaultBranch =
    ["filterable", "js-uri"].some((p) => p === pkg)
      ? "main"
      : ["purescript", "purescript-node", "purescript-web"].some((org) => org === repoOrg)
        ? "master"
        : "main";
  const res = { repoUrl, repoOrg, repoProj, pkg, defaultBranch };
  return res;
};

// export const reposArray = [repoContrib]
export const reposArray = [repoPs, repoContrib, repoNode, repoWeb]
  .reduce((acc, nextRepo) => acc.concat(nextRepo.map(getRepoInfo)), []);

export const repos = reposArray.reduce((acc, next) => {
  acc[next.pkg] = next
  return acc;
}, {});

export function mkdirP(path) {
  if (!fs.existsSync(path)) {
    fs.mkdir(path, { recursive: true });
  }
}

export function spawnResultToObj({ error, status, signal, stderr }) {
  return {
    error,
    status,
    signal,
    stderr: stderr.toString("utf-8")
  };
}

export function decode(str, fromEncoding, toEncoding) {
  return Buffer.from(str, fromEncoding).toString(toEncoding);
}

export function handleSpawn(spawnResult, handlers) {
  if (spawnResult.status != undefined && handlers.hasOwnProperty(spawnResult.status + "")) {
    handlers[spawnResult.status + ""](spawnResult);
  } else {
    console.log("Error trace:");
    console.log(spawnResult.stderr.toString("utf-8"));
    console.log(spawnResult.stdout.toString("utf-8"));
    throw new Error(`Unhandled exit code: ${spawnResult.status}`);
  }
}