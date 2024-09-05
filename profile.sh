# Set default profile path if PROFILE_PATH is not set
PROFILE_PATH=${PROFILE_PATH:-~/.profiles}

# Function to display help
profile_help() {
  echo "Usage: profile [COMMAND] [ARGS]"
  echo ""
  echo "Commands:"
  echo "  h, help           - Display this help message"
  echo "  l, list           - List available profiles"
  echo "  i, init <name>    - Create a new profile with the given name"
  echo "  e, edit <name>    - Edit the specified profile using the default editor"
  echo "  <name>            - Load the specified profile"
  echo ""
  echo "Environment Variables:"
  echo "  PROFILE_FORCE     - If set, forces the user to select a profile from the list"
  echo "  PROFILE_DEFAULT   - If set, loads the default profile when no profile is specified"
  echo "  PROFILE_PATH      - Specifies the path to store and load profiles (default: ~/.profiles)"
  echo ""
  echo "Examples:"
  echo "  profile list               - List all available profiles"
  echo "  profile init myprofile     - Create a new profile 'myprofile'"
  echo "  profile edit myprofile     - Edit the profile 'myprofile'"
  echo "  profile myprofile          - Load the profile 'myprofile'"
  echo "  profile                    - Load default profile (if PROFILE_DEFAULT is set)"
  echo "  PROFILE_FORCE=1 profile    - Force the user to select a profile"
}

# Function to list profiles
profile_list() {
  echo "Available profiles:"
  ls -1 "$PROFILE_PATH"
}

# Function to create a new profile
profile_init() {
  if [[ -z $1 ]]; then
    echo "Please provide a profile name."
    return 1
  fi
  touch "$PROFILE_PATH/$1"
  echo "Profile '$1' created."
}

# Function to load a profile
profile_load() {
  if [[ -e "$PROFILE_PATH/$1" ]]; then
    source "$PROFILE_PATH/$1"
    echo "Profile '$1' loaded."
  else
    echo "Profile '$1' does not exist."
  fi
}

# Function to edit a profile
profile_edit() {
  if [[ -z $1 ]]; then
    echo "Please provide a profile name to edit."
    return 1
  fi
  if [[ -e "$PROFILE_PATH/$1" ]]; then
    ${EDITOR:-vi} "$PROFILE_PATH/$1"  # Use $EDITOR if set, otherwise fall back to vi
    echo "Profile '$1' opened for editing."
  else
    echo "Profile '$1' does not exist."
  fi
}

# Function to handle PROFILE_FORCE or load PROFILE_DEFAULT
profile_default() {
  if [[ -n $PROFILE_FORCE ]]; then
    echo "PROFILE_FORCE is set. Please choose a profile:"
    profile_list

    # Prompt user for input
    echo -n "Enter profile name: "
    read profile_name

    # Load selected profile
    profile_load "$profile_name"
    return
  fi

  if [[ -n $PROFILE_DEFAULT ]]; then
    profile_load "$PROFILE_DEFAULT"
    return
  fi
}

# Main profile function to delegate to sub-functions
profile() {
  case $1 in
    "")
      profile_default
      ;;
    "h" | "help")
      profile_help
      ;;
    "l" | "list")
      profile_list
      ;;
    "i" | "init")
      profile_init $2
      ;;
    "e" | "edit")
      profile_edit $2
      ;;
    *)
      profile_load $1
      ;;
  esac
}

profile
