# Local environment and execution policy

## Scope and configuration sources

- Use Nix to provide the runtimes, compilers, and environment tools needed for all development and execution tasks, including temporary projects, one-off scripts, data processing, file conversion, builds, tests, and code generation.
- Manage machine-wide software through `~/.nix/nix-darwin`. Development templates are registered in `~/.nix/flake.nix` and implemented under `~/.nix/nix-dev/`.
- The custom `nix-direnv` and `nix-rebuild` zsh functions are defined in `~/.nix/nix-darwin/flake-darwin.nix`.
- Do not hardcode a username or a path such as `/Users/<username>/`. Use `~` in documentation, quoted `"$HOME/..."` paths in shell commands, and existing values such as `machine.configurationDirectory` or `machine.homeDirectory` in Nix configuration. Do not use `builtins.getEnv "HOME"` to derive paths during flake evaluation.

## Inspect the environment before starting

- Read the applicable project instructions, README, dependency manifests, lock files, build configuration, and CI configuration before choosing tools or changing dependencies.
- Find the actual project or workspace root. Check that directory and its relevant ancestors for `flake.nix`, `flake.lock`, `.envrc`, `shell.nix`, and other environment definitions.
- Reuse a suitable monorepo or parent-directory environment. A subdirectory without its own flake does not necessarily need a new environment.
- Identify the required runtime, compiler, package-manager versions, native dependencies, supported platforms, and installation, build, test, and execution commands.
- When a command is missing, first check whether the correct Nix environment has been loaded. Fix environment selection before adding dependencies.

## Create and adapt project environments

- Projects without Nix configuration must be initialized through the custom `nix-direnv <target>` function. Select an existing matching target from the template registry; current language targets include `rust`, `go`, `node`, `bun`, and `python`.
- Pass the target explicitly. Do not accidentally select the default `hello` template by omitting it.
- Invoke the function in the project root through an interactive zsh, for example:

  ```sh
  zsh -ic 'nix-direnv node'
  ```

- `flake-darwin.nix` is a Nix module, not a shell script to source. If the function is unavailable, inspect the installed zsh configuration and function loading instead of bypassing it with another installer.
- For an existing non-Nix project, identify its environment first, initialize from the appropriate template, then adapt the flake and direnv configuration to that environment before installing dependencies or running project code.
- Preserve existing version constraints, package managers, dependency lock files, workspace structure, build commands, and supported platforms. Template defaults are starting points; they do not authorize runtime upgrades, package-manager migrations, or application scaffolding over an existing project.
- When adapting a toolchain, update the package declarations, environment variables, `shellHook`, and checks together so they describe the same environment.
- Reuse existing Nix configuration and add missing flake or direnv integration as needed. Preserve the dependency and build logic of an existing `shell.nix` or other Nix expression.
- Inspect and merge existing `.envrc`, `.gitignore`, and project configuration. The helper does not overwrite an existing `.envrc`; make sure it loads the intended flake and does not subsequently replace Nix-provided tools with another runtime manager.
- Resolve template file conflicts without overwriting existing project files. For a mixed-language project, adapt one coherent environment to include the required toolchains.

## Choose the appropriate execution method

- Prefer the existing project environment for project work. Use `direnv exec . <command>` when `.envrc` supplies the environment, or `direnv exec <environment-directory> <command>` when reusing an environment elsewhere.
- Use `nix develop --command <command>` when the flake's development shell is sufficient and the command does not require additional `.envrc` behavior.
- `nix-direnv` and `direnv allow` do not imply that the current non-interactive process has loaded the environment. Load it explicitly for subsequent commands.
- `nix run` executes an application or a package's main program. `nix shell --command` provides selected packages for a command. Neither automatically loads a project's development shell, its `shellHook`, or its `.envrc` settings.
- If environment loading fails, diagnose the flake, lock file, direnv state, and configuration. Do not silently continue with a different runtime from the host.

## One-off tasks and temporary projects

- One-off tasks must also use Nix-provided tools and runtimes. Reuse a suitable existing environment when available.
- Prefer `nix run <package-or-app> -- <arguments>` for a simple tool invocation, and `nix shell <packages...> --command <command>` for an interpreter, a specific executable, or a combination of tools.
- Simple one-off commands do not require a new Git repository, `flake.nix`, `flake.lock`, or `.envrc`.
- Prefer an existing locked input or an explicitly pinned revision. For example, reuse the system configuration's locked Nixpkgs without updating its lock file:

  ```sh
  nix run --inputs-from "$HOME/.nix/nix-darwin" \
    --no-update-lock-file 'nixpkgs#jq' -- --version

  nix shell --inputs-from "$HOME/.nix/nix-darwin" \
    --no-update-lock-file 'nixpkgs#python3' --command python3 script.py
  ```

- Do not update the system flake just to obtain a temporary command. A bare `nixpkgs#...` reference depends on the configured registry and is not by itself an explicit version pin.
- When a task needs a complex or reusable development environment, create a task-local environment through `nix-direnv <target>` in `.codex-env/` or an independent subdirectory under `$TMPDIR`. Keep its flake, lock file, and direnv configuration together.
- Use an independent temporary directory if a task-local environment would conflict with an unrelated repository or its ignore rules. Do not force unrelated repository changes merely to run a temporary task.
- An actual temporary project follows the project initialization rules. Do not bypass an existing project's version or dependency constraints by treating its build as a standalone command.
- Toolchain constraints still apply to one-off execution. For example, set `GOTOOLCHAIN=local` when running Go through `nix run` or `nix shell`, since these commands do not inherit the Go template's settings automatically.

## Dependency ownership and installation boundaries

- Project flakes provide runtimes, compilers, package managers, native build tools, and linked libraries. Application dependencies belong in the project's existing language manifests and dependency-management workflow.
- Add missing dependencies to the appropriate declaration. Preserve existing lock files and limit updates to what the task requires.
- Do not independently alter global or user-level development environments with `npm install -g`, `pip install --user`, installation into system Python, `brew install`, `nix profile install`, runtime bootstrap scripts, or standalone runtime managers.
- Nix downloads, builds, and store caching used by `nix run`, `nix shell`, or project environments are expected. Normal project dependency downloads and caches are also allowed within the established dependency workflow.
- If machine-wide software is needed, change the appropriate declaration in `~/.nix/nix-darwin`.
- Do not use `nix-rebuild` as a routine project-environment repair command. It also updates system inputs, removes old generations, and runs garbage collection. Use a scoped build or activation command when applying a specific configuration change.

## Language-specific conventions

### Rust

- Initialize Rust projects with `nix-direnv rust`.
- Manage the Rust toolchain, components, and cross-compilation targets in the project flake. Keep crate dependencies in `Cargo.toml`, `Cargo.lock`, and the existing workspace configuration.
- Do not install or update a separate rustup-managed toolchain to bypass Nix.
- Add native tools and linked libraries to the flake only when the project needs them.

### Node.js and Bun

- Select `nix-direnv node` or `nix-direnv bun` according to the project's actual runtime. Preserve its package manager, version requirements, and lock file.
- Provide Node.js, Bun, and the required package manager through Nix. Keep TypeScript, linters, frameworks, and application packages in project dependencies, and run them through project scripts or the package manager's local execution facilities.
- Do not migrate between npm, Yarn, pnpm, and Bun to match template defaults.
- Update a Nix-managed runtime through its Nix declaration and, when necessary, the relevant locked input. Do not use `bun upgrade` or a separate runtime installer.

### Python

- Initialize Python projects with `nix-direnv python`. Preserve their existing dependency manager and version constraints; the template does not require migrating an existing project to uv.
- Manage the Python interpreter, native build tools, and linked libraries through Nix. Existing project virtual environments may be used when they are based on the Nix-provided interpreter.
- When using uv, point it at the Nix-provided interpreter, disable automatic Python downloads, and retain the template's relevant interpreter-selection settings. Apply equivalent settings explicitly during one-off uv commands that do not load the template environment.
- Do not use `uv python install` or another tool to install a competing interpreter. Preserve existing project version requirements, including version metadata such as `.python-version`, and keep them aligned with the Nix-selected interpreter.

### Go

- Initialize Go projects with `nix-direnv go`. Simple one-off Go commands may use `nix run` or `nix shell` under the one-off task rules.
- Select a compatible Nix Go package using `go.mod`, `go.work`, CI, and the existing environment. Preserve the project's constraints and workspace structure: a `go` directive specifies a minimum Go version, while a `toolchain` directive suggests a toolchain; neither should automatically be treated as an exact compiler pin.
- Keep `GOTOOLCHAIN=local`. If the compiler is too old, first select a suitable Go package in the flake, then update the relevant input and lock file only if necessary. Do not use `GOTOOLCHAIN=auto`, persistent `go env -w` changes, or a separate Go download to bypass Nix.
- Manage Go, `gopls`, and general development tools through Nix. Keep module requirements and checksums in `go.mod`, `go.sum`, and the existing Go workspace configuration. Preserve project-declared Go tool dependencies and run them within the Nix environment.
- Do not use `go install` to place development tools in user-level bin directories. Add tools to the appropriate Nix or existing project declaration.
- For cgo, declare the required compiler, build tools, and linked libraries in the flake. Preserve the project's cgo settings instead of disabling cgo to hide missing dependencies.

## Validation and Git state

- The `nix-direnv` helper stages generated environment files. If it creates a new Git repository and Git identity is configured, it can also create the initial commit; it does not automatically commit in an existing repository.
- After initialization and adaptation, inspect both staged and unstaged changes so the final configuration reflects the actual project rather than unadapted template defaults.
- Preserve unrelated user changes and the existing index. Do not clear the staging area or overwrite unrelated files.
- Ensure new environment files are visible to flake evaluation. Keep project environment definitions and their relevant lock files under version control; simple one-off commands do not require additional project files.
- Verify the selected toolchain versions, environment loading, and relevant project builds and tests. Passing a template's smoke check does not establish that the project itself works.

## Maintaining these instructions

- The shared source is `~/.nix/nix-darwin/dotfiles/agents/AGENTS.md`.
- Home Manager manages the global entry points for Codex and Claude Code as links to this source.
- Edit the repository source when changing these instructions. Preserve the managed entry-point links rather than replacing them during an atomic save.
- Track instruction changes with Git. After the links have been deployed, content edits do not require `darwin-rebuild switch`; new sessions read the updated source. Nix generation rollback does not restore earlier contents of this mutable source.
