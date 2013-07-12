#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dotfiles_path=$DIR
target_dir=$HOME

rcfiles_dir=$dotfiles_path/rcfiles
rcfiles=$( ls $rcfiles_dir )

function do_cmd {
	cmd="$@"
	echo $cmd
	$cmd
}

function stars {
	printf %$1s |tr ' ' '*'
}

function msg {
	echo
	stars $2
	echo -ne '' $1 ''
	stars $2
	echo
}

function pkg {
	if [[ ! $(which apt-get >&-) ]]; then
		sudo apt-get install "$@" -y >&-
	else
		echo "Sorry, but you need apt-get to automatically install packages."
	fi
}

msg "This script will set up a bash environment to the author's liking" 1
msg "This script can be destructive and you shouldn't run it without knowing what you're doing" 1
echo -ne "Continue? [y/N] "
read

[[ ! $REPLY =~ [yY] ]] && exit 1

msg "Setting up symbolic links to rcfiles" 3
for rcfile in $rcfiles; do
	rcfile_path=$rcfiles_dir/$rcfile
	target_file_path=$target_dir/.$rcfile

	# Skip if the target is already a symbolic link
	if [[ ! -L $target_file_path ]]; then
		# If it's a regular file, rename it and source it in the repo's rcfile
		if [[ -f $target_file_path ]]; then
			old_file_path="$target_file_path.old"

			do_cmd "mv $target_file_path $old_file_path"
			do_cmd "source $old_file_path >> $rcfile_path"
		fi
		do_cmd "ln -sf $rcfile_path $target_file_path"
	fi
done

msg "Setting up Git" 3
pkg git
if [[ ! -e $HOME/.gitconfig ]]; then
	do_cmd "ln -sf $dotfiles_path/gitconfig $HOME/.gitconfig"
fi

# Symbolic links to directories need to be made independently
msg "Setting up Vim" 3
pkg vim

if [[ ! -d $HOME/.vim ]]; then
	msg "Linking $dotfiles_path/vim to $HOME/.vim" 5
	do_cmd ln -sf $dotfiles_path/vim $HOME/.vim
fi

msg "Acquiring Vim plugins..." 5
do_cmd git submodule init
do_cmd git submodule update
pkg exuberant-ctags

msg "Setting up RVM" 3
pkg curl wget libxslt1-dev libxml2-dev libreadline-dev libncurses5-dev libssl-dev
[[ -n $(which rvm) ]] || curl -L https://get.rvm.io | bash -s stable
do_cmd cp $dotfiles_path/global.gems $HOME/.rvm/gemsets/global.gems
rvm install ruby --default

msg "Setting up Node.js"
cd && git clone https://github.com/joyent/node.git
cd $HOME/node && ./configure && make && sudo make install

exec bash
