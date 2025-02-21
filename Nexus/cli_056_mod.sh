#!/bin/sh

# -----------------------------------------------------------------------------
# 1) Ensure Rust is installed.
#    - First, check if rustc is available. If not, install Rust non-interactively
#      using the official rustup script.
# -----------------------------------------------------------------------------
rustc --version || curl https://sh.rustup.rs -sSf | sh

# -----------------------------------------------------------------------------
# 2) Define environment variables and colors for terminal output.
# -----------------------------------------------------------------------------
NEXUS_HOME="$HOME/.nexus"
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
NC='\033[0m'  # No Color

# Ensure the $NEXUS_HOME directory exists.
[ -d "$NEXUS_HOME" ] || mkdir -p "$NEXUS_HOME"

# -----------------------------------------------------------------------------
# 3) Display a message if we're interactive (NONINTERACTIVE is not set) and the
#    $NODE_ID is not a 28-character ID. This is for Testnet II info.
# -----------------------------------------------------------------------------
if [ -z "$NONINTERACTIVE" ] && [ "${#NODE_ID}" -ne "28" ]; then
    echo ""
    echo "${ORANGE}The Nexus network is currently in Testnet II. You can now earn Nexus Points.${NC}"
    echo ""
fi

# -----------------------------------------------------------------------------
# 5) Check for 'git' availability. If not found, prompt the user to install it.
# -----------------------------------------------------------------------------
git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ "$GIT_IS_AVAILABLE" != 0 ]; then
  echo "Unable to find git. Please install it and try again."
  exit 1
fi

# -----------------------------------------------------------------------------
# 6) Clone or update the network-api repository in $NEXUS_HOME.
# -----------------------------------------------------------------------------
REPO_PATH="$NEXUS_HOME/network-api"
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating."
  (
    cd "$REPO_PATH" || exit
    git stash
    git fetch --tags
  )
else
  (
    cd "$NEXUS_HOME" || exit
    git clone https://github.com/nexus-xyz/network-api
  )
fi

# -----------------------------------------------------------------------------
# 7) Check out the latest tagged commit in the repository.
# -----------------------------------------------------------------------------
(
  cd "$REPO_PATH" || exit
  git -c advice.detachedHead=false checkout "$(git rev-list --tags --max-count=1)"
)

# -----------------------------------------------------------------------------
# 8) Run the Rust CLI in a loop for automatic restart
# -----------------------------------------------------------------------------
while true; do
  (
    cd "$REPO_PATH/clients/cli" || exit
    echo "y" | cargo run -r -- start --env beta
  ) < /dev/tty
  echo "Process terminated. Restarting in 5 seconds..."
  sleep 5
done
