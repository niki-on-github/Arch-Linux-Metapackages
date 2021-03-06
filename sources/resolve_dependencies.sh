# Description: resolve dependencie groups
resolve_dependencies() {
    for s in $(grep -v "^#" "$1" | cut -d ':' -f 1); do
        group_packages="$(pacman -Sqg $s)"
        if [ -z "$group_packages" ]; then
            echo "$s"
        else
            echo "$group_packages"
        fi
    done
}
