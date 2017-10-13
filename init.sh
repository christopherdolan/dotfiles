#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dotfiles_path=$DIR
rc_target_dir=$HOME

rcfiles_dir=$dotfiles_path/rcfiles
rcfiles=$( ls $rcfiles_dir )

echo "This script will set up an Ubuntu-based bash environment to the author's liking"
echo -ne "Continue? [y/N] "
read

[[ ! $REPLY =~ [yY] ]] && exit 1

sudo apt install -yqq \
	byobu \
	curl \
	exuberant-ctags \
	git \
	libxslt1-dev \
	libxml2-dev \
	libreadline-dev \
	libncurses5-dev \
	libssl-dev \
	vim \
	wget

if [[ ! $(which node) ]]; then
	# Adding the nodejs apt repo
	curl -sL 'https://deb.nodesource.com/setup_6.x' | sudo -E bash -
	sudo apt install -y nodejs
fi

# Common node packages
sudo npm install -g nodemon mocha express 2>/dev/null

# RVM
if [[ ! $(which rvm) ]]; then
	gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -L https://get.rvm.io | bash -s stable --ruby=default
fi
cp -v $dotfiles_path/global.gems $HOME/.rvm/gemsets/global.gems

# Byobu presets
cp $dotfiles_path/windows.express_dev $HOME/.byobu

# Link all the rcfiles to their new home
for rcfile in $rcfiles; do
	rcfile_path=$rcfiles_dir/$rcfile
	target_file_path=$rc_target_dir/.$rcfile

	# Skip if the target is already a symbolic link
	if [[ ! -L $target_file_path ]]; then
		# If it's a regular file, rename it and source it in the repo's rcfile
		if [[ -f $target_file_path ]]; then
			old_file_path="$target_file_path.old"

			mv -v $target_file_path $old_file_path
			source $old_file_path >> $rcfile_path
		fi
		ln -sfv $rcfile_path $target_file_path
	fi
done

ln -sfv $dotfiles_path/gitconfig $HOME/.gitconfig

# VIm
if [[ ! -d $HOME/.vim ]]; then
	ln -sfv $dotfiles_path/vim $HOME/.vim
fi

git submodule init
git submodule update

echo "You should reload your shell"
