# NPM and PNPM Command Equivalents

## Installation and Setup

| npm                            | pnpm                         | Description                              |
| ------------------------------ | ---------------------------- | ---------------------------------------- |
| `npm install`                  | `pnpm install`               | Install all dependencies in package.json |
| `npm i <pkg>`                  | `pnpm add <pkg>`             | Install a package                        |
| `npm i <pkg> --save-dev`       | `pnpm add -D <pkg>`          | Install as dev dependency                |
| `npm i <pkg> --save-exact`     | `pnpm add -E <pkg>`          | Install exact version                    |
| `npm i <pkg> --global`         | `pnpm add -g <pkg>`          | Install globally                         |
| `npm init`                     | `pnpm init`                  | Create a package.json file               |
| `npm uninstall <pkg>`          | `pnpm remove <pkg>`          | Remove a package                         |
| `npm uninstall --global <pkg>` | `pnpm remove --global <pkg>` | Remove global package                    |

## Updating Packages

|npm|pnpm|Description|
|---|---|---|
|`npm update`|`pnpm update`|Update all packages|
|`npm update <pkg>`|`pnpm update <pkg>`|Update specific package|
|`npm outdated`|`pnpm outdated`|Check for outdated packages|

## Running Scripts

|npm|pnpm|Description|
|---|---|---|
|`npm run <script>`|`pnpm <script>`|Run a script|
|`npm start`|`pnpm start`|Run start script|
|`npm test`|`pnpm test`|Run test script|
|`npm rebuild`|`pnpm rebuild`|Rebuild packages|

## Publishing and Registry

|npm|pnpm|Description|
|---|---|---|
|`npm publish`|`pnpm publish`|Publish package|
|`npm login`|`pnpm login`|Login to registry|
|`npm logout`|`pnpm logout`|Logout from registry|
|`npm whoami`|`pnpm whoami`|Display current user|
|`npm config set registry <url>`|`pnpm config set registry <url>`|Set registry URL|

## Workspace Commands (Monorepo)

|npm|pnpm|Description|
|---|---|---|
|`npm i <pkg> -w <workspace>`|`pnpm add <pkg> --filter <workspace>`|Install in specific workspace|
|`npm run <cmd> -w <workspace>`|`pnpm <cmd> --filter <workspace>`|Run command in specific workspace|
|`npm run <cmd> -ws`|`pnpm -r <cmd>`|Run command in all workspaces|

## Cache Management

|npm|pnpm|Description|
|---|---|---|
|`npm cache clean`|`pnpm store prune`|Clean up cache|
|`npm cache verify`|`pnpm store status`|Verify cache|
|n/a|`pnpm store path`|Display store path|

## Additional pnpm-specific Commands

|npm|pnpm|Description|
|---|---|---|
|n/a|`pnpm why <pkg>`|Show why a package is installed|
|n/a|`pnpm store prune`|Remove unreferenced packages from store|
|n/a|`pnpm import`|Generate pnpm-lock.yaml from package-lock.json|
|n/a|`pnpm exec <cmd>`|Execute shell command in package context|
|`npx <cmd>`|`pnpm dlx <cmd>`|Execute a command without installing|

