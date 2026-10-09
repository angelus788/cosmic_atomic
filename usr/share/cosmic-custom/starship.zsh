# Starship prompt for interactive zsh.
#
# Sourced from the end of /etc/zshrc (the Containerfile appends the line). It
# can't live in /etc/profile.d: Fedora's /etc/zshrc loads that directory under
# `emulate -L ksh`, where starship's zsh init fails to parse and any option it
# sets is reverted when the loader returns.
#
# Opt out per user with: export STARSHIP_DISABLE=1

[[ -o interactive ]] || return 0
[[ -n ${STARSHIP_DISABLE:-} ]] && return 0
command -v starship >/dev/null 2>&1 || return 0

eval "$(starship init zsh)"
