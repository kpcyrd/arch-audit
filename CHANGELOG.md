# Changelog

## [0.2.0] - 2024-07-23

### Bug Fixes

- config: Fix missing fmt argument in error message
- alpm: Update to alpm v3
- ci: Init keyring to fix Gitlab CI pacman keyring errors

### Documentation

- changelog: Add git-cliff configuration for changelog management

### Features

- ci: Add tags job to release to crates.io via GitLab

### Miscellaneous Tasks

- doc: Channel has been moved to Libera
- lint: Do not try to lint cli help text as Rust doc
- git: Add CI directories to git ignore
- make: Add make target to release to gitlab
- clippy: Make clippy happy like a hippo
- lint: Replace cargo-audit with cargo-deny
- deps: Replace deprecated atty with console
- deps: Replace structopt with clap
- cargo: Update authors and repository location
- doc: Update old git repository references
- deps: Upgrade all dependencies
- ci: Use default block to declare common script commands

## [0.1.20] - 2021-09-02

### Bug Fixes

- completion: Fix gen completions to target
- Fix missing space in update text for testing packages
- Properly handle display status for testing packages
- Respect status field when showing vulnerabilities

### Documentation

- Fix description of -f
- Add link to security.archlinux.org
- Replace plain manpages with scdoc for better maintainability

### Features

- Add --json flag
- Add an option to disable the proxy configured in config files
- Add user agent to requests
- Export arch-audit structs as library
- Add option to sort the output by various fields
- Create more dense output by removing Package pre text
- Implement option to set data input source

### Miscellaneous Tasks

- Update dependencies
- Apply cargo fmt
- deps: Bump locked dependencies
- Bump locked dependencies to latest
- Enable clippy nursery mode and cleanup complaints
- Fix cargo fmt
- Implement error handling using anyhow
- Move enums and structs to own types module
- Remove oversupplied whitespaces
- Restructure additional files into a contrib folder
- Sort use and mod declarations
- Use a constructor function to create an Affected instance
- Use structopt instead of directly using clap
- Use strum for convenient enum/struct operations

### Security

- Activated different security features and disabled logfile

### Testing

- Add test cases with controllable local alpm state as fixture
- Flatten and remove double nested test mod

### Cargo

- Bump all dependencies and adjust alpm code usage
- Bump dependencies in lockfile
- Bump minor dependency versions

### Ci

- Add test job for make install target
- Adding cache and docs tests
- Adding more jobs for check fmt, clippy
- Run cargo audit in test stage
- Using docker official Arch Linux image

### Completion

- Use completion subcommand generated dynamically via clap

### Make

- Added for convenience with different jobs and targets
- Adjust release sed call to only replace correct version property
- Advocate installing the systemd files
- Use PREFIX for systemd system dir as its perfectly valid in /usr/local

### Opt

- Sort upgradable field reversed to show up at the top

### Systemd

- Add more hardening options to the service
- Add random delay sec to systemd timer to avoid spikes
- Do not run in quite mode, the journal should be human readable

### Toml

- Activate lto for release profile
- Add command-line-utilities categories
- Bump all dependencies

### Ui

- Separate CVEs by a comma and a space

### Version

- Release 0.1.16
- Release 0.1.17
- Release 0.1.18
- Release 0.1.19
- Release 0.1.20


