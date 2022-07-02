# Scripts to check for changes in ui.h

Helper scripts for the developer.

## Usage

```sh
bash ui_diff.sh
```
## Requirement

* [delta](https://github.com/dandavison/delta)
* gcc - [remove comments from C/C++ code](https://stackoverflow.com/questions/2394017/remove-comments-from-c-c-code)

Note: These scripts were written to run on Ubuntu. Replace the default sed command with gnu-sed command when running on macOS.

```sh
brew install gnu-sed
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
```
