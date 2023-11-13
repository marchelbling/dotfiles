#!/bin/bash

# install all homebrew formulas from Brewfile
brew bundle install

# setup golang binaries
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest

# setup python packages
python3 -m pip install --upgrade debugpy
