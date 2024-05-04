#!/usr/bin/env bash

# the dir this script is in
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#helper functions
function link {
    target=$1
    src=$2
    if [ -L $src ];
    then
        rm $src
    fi
    mkdir -p `dirname $src`
    echo "Creating symlink for $src"
    ln -sf $target $src
}

function downloadSubmodules {
    dir=$1
    if [ -e $dir/submodules ];
    then
        while read l;
        do
            read -a array <<< $l
            if [ ! -e $dir/${array[1]} ];
            then
                git clone ${array[0]} $dir/${array[1]}
            else
                echo "update git repo"
                #TODO
            fi
        done < $dir/submodules
    fi
}

function vim {
    echo "Linking vim"
    downloadSubmodules $cwd/vim
    link $cwd/vim/vimrc ~/.vimrc
    link $cwd/vim/vim ~/.vim
}

function conky {
    echo "enabling lean conky"
    cd $cwd/conky
    git clone git@github.com:jxai/lean-conky-config.git
    cd lean-conky-config
    echo "You will need to add the following command to autostart:"
    echo "${cwd}/conky/lean-conky-config/start-lcc.sh}"
    bash ./start-lcc.sh
}

# cannot be called git, conflicts with download submodules
function git_config {
    echo "Linking git"
    for file in $(ls $cwd/git_config);
    do
        link $cwd/git_config/$file ~/.$file
    done
}

function shell {
    echo "Linking shell"
    for file in $(ls $cwd/shell);
    do
        link $cwd/shell/$file ~/.$file
    done
}

function tmux {
    echo "Linking tmux"
    link $cwd/tmux/tmux.conf ~/.tmux.conf
}

function terminator {
    echo "Linking terminator"
    link $cwd/terminator/terminator ~/.config/terminator
}

function scripts {
    #DO NOTHING
    if [ `uname` == 'Darwin' ]
    then
        #TODO: Create bin directory if not there
        link $cwd/scripts/osx/edit ~/bin/edit
    else
        echo "Skipping scripts"
    fi
}

function run {
    eval ${1}
}

function all {
    echo "Linking all configs"
    for dir in $cwd/*/
    do
        dir=${dir%*/}
        dir=${dir##*/}
        if [ "$dir" != "~" ];
        then
            run ${dir}
        fi
    done
}



if [ "$#" -eq 0 ];
then
    echo "Usage: $0 [all | CONFIGS_TO_LINK ...]"
    exit
fi

#for var in "$@"
#do
#    run ${var}
#done
run ${1}
