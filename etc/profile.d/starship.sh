# Starship prompt for interactive bash. The other shells are handled elsewhere:
#   zsh:  /usr/share/cosmic-custom/starship.zsh, hooked in at the end of /etc/zshrc
#   fish: /etc/fish/conf.d/starship.fish
# Fedora's /etc/zshrc loads this directory under `emulate -L ksh`, where
# starship's zsh init fails to parse, so zsh must not be initialised from here.
# Opt out per user with: export STARSHIP_DISABLE=1

case $- in
    *i*) ;;
    *) return 0 ;;
esac

[ -n "${STARSHIP_DISABLE:-}" ] && return 0
command -v starship >/dev/null 2>&1 || return 0

# bash only: zsh sources this file under ksh emulation (see above) and must skip it.
[ -n "${BASH_VERSION:-}" ] || return 0

eval "$(starship init bash)"
