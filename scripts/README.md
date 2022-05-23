Scripts to check for changes in ui.h

```sh
bash ui_diff.sh
```

Note: These scripts were written to run on Ubuntu. Replace the default sed command with gnu-sed command when running on macOS.

```sh
brew install gnu-sed
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
```
