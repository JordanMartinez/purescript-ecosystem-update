const process = require("process");

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