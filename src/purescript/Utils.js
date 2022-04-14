const process = require("process");
const fs = require("fs");

exports.mkdirImpl = function(path) {
  return function(opt) {
    return function (cb) {
      fs.mkdir(path, opt, cb);
    };
  };
};

exports.setProcessExitCode = function (code) {
  return function () {
    process.exitCode = code;
  };
};

exports.onSpawn = function onSpawn(cp) {
  return function (cb) {
    return function () {
      cp.on("spawn", function () {
        cb();
      });
    };
  };
};

exports.handleCallbackImpl = function (left, right, f) {
  return function (err, value) {
    if (err) {
      f(left(err))();
    } else {
      f(right(value))();
    }
  };
};

exports.fdStatImpl = fs.fdStat;
