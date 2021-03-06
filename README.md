# Arch-Packages

My Arch Linux metapackages. A meta-package is a term for a specific type of package that actually contains no applications or files itself, but rather serves as an umbrella that encompasses a number of packages underneath it. This simplifies the installation of multiple packages by installing them all automatically when the meta-package is installed. It also serves to make the list of explicitly installed packages smaller.

## Adding Dependencies

You cannot specify a package group in metapackages. All packages must be listed separately. By using my `resolve_dependencies.sh` script, package groups are automatically resolved and simplify the administration of the packages.

## Build Packages

```bash
bash build.sh
```

## Deploy Repository

```
docker-compose up -d
```

## Add self hosted repository to pacman

Add to `/etc/pacman.conf`:

```
[REPOSITORY_NAME]
SigLevel = Optional TrustAll
Server = http://SERVER_DNS_NAME:SERVER_PORT/
```

e.g.

```
[personal]
SigLevel = Optional TrustAll
Server = http://10.0.0.70:8010/
```

## Usage 

Setup personal arch linux with specified package groups. Example:
```bash
pacman -Sy desktop-pc
```

## References

- [Managing Arch Linux with Meta Packages](https://disconnected.systems/blog/archlinux-meta-packages/#what-are-meta-packages)
- [Creating Packages](https://wiki.archlinux.org/index.php/Creating_packages)
- [Replicate your system with self-hosted Arch Linux metapackages](https://ownyourbits.com/2019/07/21/replicate-your-system-with-self-hosted-arch-linux-metapackages/)
- [Arch Metapackage Guide](https://github.com/stoicaviator/arch_metapackage_guide)
