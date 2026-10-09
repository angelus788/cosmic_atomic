# Starship prompt for interactive fish (bash/zsh: /etc/profile.d/starship.sh)
# Opt out per user with: set -Ux STARSHIP_DISABLE 1

if status is-interactive; and not set -q STARSHIP_DISABLE; and command -q starship
    starship init fish | source
end
