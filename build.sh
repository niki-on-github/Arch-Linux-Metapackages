#!/bin/bash
# Description: script to build all arch packages in ./sources directory
# Parameters: none : recommended; --docker : force docker build (default for non archlinux hosts)
# NOTE: dont use variable names that are used in PKGBUILD files, because we source this files to read the source array!

# config
root_dir=`dirname $0`
src_dir="sources"
repo_dir="packages"
repo_name="personal"

# colors
LBLUE='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# run not on Arch Linux host?
if ! grep -q "^NAME=\"Arch Linux\"" /etc/*-release || [ "$1" = "--docker" ] ; then
    echo -e "This is not an Arch Linux host, We use docker to build the packages"
    echo -e "${RED}[WARNING] Build packages inside arch linux docker is currently broken on "\$hosts" != "archlinux". Related to https://bugs.archlinux.org/task/69563 ${NC}"
    docker pull archlinux:base-devel # pull latest image required to install build dependencies inside docker
    docker run --rm -it -v $PWD:/mnt archlinux:base-devel bash /mnt/build.sh
    exit
fi

# run inside docker?
if [ -f /.dockerenv ]; then
    if [ "$EUID" -eq 0 ]; then
        echo "Setup build dependencies inside archlinux docker"
        pacman --noconfirm --needed -Sy git
        useradd builduser -m
        passwd -d builduser
        chown -R builduser: $root_dir/$src_dir
        chmod -R 775 $root_dir/$src_dir
        chown -R builduser: $root_dir/$repo_dir
        chmod -R 775 $root_dir/$repo_dir
        su builduser -c "bash $0"
        exit
    fi
fi

failed=()
for pkgsrc_dir in $(ls $root_dir/$src_dir) ; do
    [ ! -f "$root_dir/$src_dir/$pkgsrc_dir/PKGBUILD" ] && continue
    echo -e "\n${LBLUE} >> Build $src_dir/$pkgsrc_dir ${NC}"
    cd $root_dir/$src_dir/$pkgsrc_dir
    source=() # clear last source array
    source ./PKGBUILD # set source array if available in PKGBUILD
    for s in "${source[@]}" ; do
        if grep -q "::git+" <<< $s ; then
            eval "rm -rfv $(echo $s | cut -d ':' -f 1)"
        fi
    done
    makepkg -cdf
    success=$?
    cd - >/dev/null
    for pkg in $(ls $root_dir/$src_dir/$pkgsrc_dir/*pkg.tar.zst) ; do
        mv -vf "$pkg" "$root_dir/$repo_dir"
        cd "$root_dir/$repo_dir"
        repo-add $repo_name.db.tar.xz `basename $pkg`
        cd - >/dev/null
    done
    [ "$success" -ne "0" ] && failed+=( "$pkgsrc_dir" )
done

if [ "${#failed[@]}" -ne "0" ]; then
    echo -e "\n${RED}Build failed: ${failed[@]} ${NC}"
else
    echo -e "\n${GREEN}All packages were successfully build ${NC}"
fi
