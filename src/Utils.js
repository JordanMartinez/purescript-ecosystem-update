const process = require("process");

exports.setProcessExitCode = function (code) {
  return function () {
    process.exitCode = code;
  };
};
