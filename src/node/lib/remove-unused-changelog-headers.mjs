import process from "process";
import fs from "fs";

const fileName = process.argv[2];
const content = fs.readFileSync(fileName, "utf-8");
const fixed = content
  .replaceAll(/- Update project and deps to PureScript v0.15.0[^\n]+\n/mg, "")
  .replaceAll(/- Update project and dependencies to v0.15.0 PureScript[^\n]+\n/mg, "")
  .replaceAll(/- Migrate FFI to ES Modules[^\n]+\n/mg, "")
  .replaceAll(/- Migrate FFI to ES modules[^\n]+\n/mg, "")
  .replaceAll(/- Migrated FFI to ES Modules[^\n]+\n/mg, "")
  .replaceAll(/- Migrated FFI to ES modules[^\n]+\n/mg, "")
  .replaceAll(/- Drop deprecated `MonadZero` instance[^\n]+\n/mg, "")
  .replaceAll(/- Drop deprecated `math` dependency; update imports[^\n]+\n/mg, "")
  .replaceAll(/- Drop `math` dependency; update imports[^\n]+\n/mg, "")
  .replaceAll(/- Removed dependency on `purescript-math`[^\n]+\n/mg, "")
  .replaceAll(/- Drop dependency on `math`[^\n]+\n/mg, "")
  .replaceAll(/- Added `purs-tidy` formatter[^\n]+\n/mg, "")
  .replaceAll(/^Breaking changes:\n\n/mg, "")
  .replaceAll(/^New features:\n\n/mg, "")
  .replaceAll(/^Bugfixes:\n\n/mg, "")
  .replaceAll(/^Other improvements:\n\n/mg, "")
  .replaceAll(/\n\n\n/mg, "\n\n")
  .replaceAll(/^###[^\n]+\n\n\n/mg, "")
  .replaceAll(/^###[^\n]+\n\n###/mg, "###")
  .replaceAll(/^###[^\n]+\n\n###/mg, "###")
  .replaceAll(/^###[^\n]+\n\n###/mg, "###")
  .replaceAll(/\n\n\n/mg, "\n\n");

// console.log(fixed);
fs.writeFileSync(fileName, fixed);
