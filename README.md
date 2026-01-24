## Dotfiles

This repository aims at providing a simple way to (re)set a local environment.

**Note:** [`607747a`](https://github.com/marchelbling/dotfiles/tree/607747a2402741c4e4132dd0086be2ebbdbcfa40) is the last revision relying on homemade scripts. Some of the existing configuration (e.g. screen, curl) have not been moved to the current setup.

### Configuration files

The configuration files are managed via [chezmoi](https://www.chezmoi.io).

**References:**

- [Automating the Setup of a New Mac With All Your Apps, Preferences, and Development Tools](https://www.moncefbelyamani.com/automating-the-setup-of-a-new-mac-with-all-your-apps-preferences-and-development-tools/) for a good introduction, especially regarding templates.
- [Managing dotfiles](https://dnitza.com/post/managing-dotfiles) (see the script part)

### OSX

MacOS tools are managed via [Homebrew](https://brew.sh/). We rely on the bundle feature (see [`Brewfile`](https://github.com/marchelbling/dotfiles/blob/main/Brewfile)).

**Notes:**
* that this means applications should ideally be installed using App store (`mas` CLI) or brew cask to ensure reproducibility.
* apps installed via App Store will be "frozen"
* `brew bundle dump --force` will override an existing `Brewfile` which means that we cannot really add comments in the file: we therefore want to provide documentation when adding tools using dedicated commits.


### Secrets

Passwords, secrets, SSH keys are managed with [1password](https://1password.com/).
For example, git signing is done using [SSH key signing](https://blog.1password.com/git-commit-signing/).

1password CLI needs to be installed before initializing chezmoi.


## Cheatsheet

1. `chezmoi init marchelbling` (`marchelbling` will be expanded to `github.com/marchelbling/dotfiles.git`)
2. `chezmoi cd`: changes current directory to this repository
3. `chezmoi apply`: copies `chezmoi` current definitions to their home destinations


## New machine setup

1. Install [mise](https://mise.jdx.dev/):
   ```bash
   curl https://mise.run | sh
   ```
    If an on Mac, install Homebrew:
    ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
2. Add mise to your shell (temporary, will be configured properly by chezmoi):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   eval "$(mise activate bash)"  # or zsh
   ```
3. Install chezmoi via mise:
   ```bash
   mise use -g chezmoi
   ```
4. Initialize and apply dotfiles:
   ```bash
   chezmoi init --apply marchelbling
   ```
