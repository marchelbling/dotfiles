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

Passwords and secrets are managed with [1password](https://1password.com/).
For example, git signing is done using [SSH key signing](https://blog.1password.com/git-commit-signing/).

## Cheatsheet

1. install `chezmoi` (via brew)
2. `chezmoi init marchelbling` (`marchelbling` will be expanded to `github.com/marchelbling/dotfiles.git`)
3. `chezmoi cd` changes current directory to this repository
4. `chezmoi apply` copies `chezmoi` current definitions to their home destinations
