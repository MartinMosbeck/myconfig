# My dotfiles, configs, tools

## Download & Install
* git clone --recursive https://github.com/MartinMosbeck/myconfig.git .myconfig
* Set symlinks to files/folders starting with . in .myconfig to your $HOME folder

## Update
* Run update.sh

## Notes
* Vim plugins are handled as submodules with pathogen, to add a plugin do "git
  submodule add `<url>`" in .vim/bundle
* OhMyZSH plugins are handled with antigen.
* Local git config can be stored in .myconfig/local/.gitconfig
* Local zsh config can be stored in .myconfig/local/.zshrc
