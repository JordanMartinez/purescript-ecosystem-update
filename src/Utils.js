import process from "process";
import fs from "fs";

export function mkdirImpl(path) {
  return function(opt) {
    return function (cb) {
      return function () {
        fs.mkdir(path, opt, cb);
      };
    };
  };
}

export function rmImpl(path) {
  return function(opt) {
    return function (cb) {
      return function () {
        fs.rm(path, opt, cb);
      };
    };
  };
}

export function setProcessExitCode(code) {
  return function () {
    process.exitCode = code;
  };
}

export function onSpawn(cp) {
  return function (cb) {
    return function () {
      cp.on("spawn", function () {
        cb();
      });
    };
  };
}

export function handleCallbackImpl(left, right, f) {
  return function (err, value) {
    if (err) {
      f(left(err))();
    } else {
      f(right(value))();
    }
  };
}

export const fdStatImpl = fs.fdStat;

export function replaceAll(r) {
  return (s) => (str) => str.replaceAll(r, s);
}
