#!/bin/sh

# Set default profile path if PROFILE_PATH is not set
PROFILE_PATH="${PROFILE_PATH:-$HOME/.profiles}"
PRE_LOAD_SCRIPT="${PRE_LOAD_SCRIPT:-$PROFILE_PATH/pre_load.sh}"
POST_LOAD_SCRIPT="${POST_LOAD_SCRIPT:-$PROFILE_PATH/post_load.sh}"

# Create profile directory if it doesn't exist
if [ ! -d "$PROFILE_PATH" ]; then
  echo "Profile directory not found. Creating: $PROFILE_PATH"
  mkdir -p "$PROFILE_PATH"
fi

# Create pre-load script if it doesn't exist
if [ ! -f "$PRE_LOAD_SCRIPT" ]; then
  echo "Pre-load script not found. Creating: $PRE_LOAD_SCRIPT"
  touch "$PRE_LOAD_SCRIPT"
fi

# Create post-load script if it doesn't exist
if [ ! -f "$POST_LOAD_SCRIPT" ]; then
  echo "Post-load script not found. Creating: $POST_LOAD_SCRIPT"
  touch "$POST_LOAD_SCRIPT"
fi

# Function to display help
profile_help() {
  echo "Usage: profile [COMMAND] [ARGS]"
  echo ""
  echo "Commands:"
  echo "  h, help           - Display this help message"
  echo "  l, list           - List available profiles"
  echo "  i, init <name>    - Create a new profile with the given name"
  echo "  e, edit <name>    - Edit the specified profile using the default editor"
  echo "  s, sync           - Pull and push changes to remote git repo"
  echo ""
  echo "  <name>            - Load the specified profile"
  echo ""
  echo "Environment Variables:"
  echo "  PROFILE_FORCE     - If set, forces the user to select a profile from the list"
  echo "  PROFILE_DEFAULT   - If set, loads the default profile when no profile is specified"
  echo "  PROFILE_PATH      - Specifies the path to store and load profiles (default: ~/.profiles)"
  echo "  PRE_LOAD_SCRIPT   - Specifies the path to a script to run before loading a profile"
  echo "  POST_LOAD_SCRIPT  - Specifies the path to a script to run after loading a profile"
  echo ""
  echo "Examples:"
  echo "  profile list               - List all available profiles"
  echo "  profile init myprofile     - Create a new profile 'myprofile'"
  echo "  profile edit myprofile     - Edit the profile 'myprofile'"
  echo "  profile myprofile          - Load the profile 'myprofile'"
  echo "  profile                    - Load default profile (if PROFILE_DEFAULT is set)"
  echo "  PROFILE_FORCE=1 profile    - Force the user to select a profile"
}

# Sync with git
profile_sync() {
  # Save the current directory
  local original_dir=$(pwd)

  # Ensure PROFILE_PATH is set and is a valid directory
  if [ ! -d "$PROFILE_PATH" ]; then
    echo "PROFILE_PATH ($PROFILE_PATH) is not a valid directory."
    return 1
  fi

  # Navigate to the PROFILE_PATH directory
  cd "$PROFILE_PATH" || { echo "Failed to change directory to $PROFILE_PATH"; return 1; }

  # Ensure we're in a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository. Please ensure PROFILE_PATH contains a git repository."
    cd "$original_dir"  # Return to the original directory
    return 1
  fi

  # Fetch updates from remote main branch
  echo "Fetching updates from remote repository..."
  if ! git fetch origin main; then
    echo "Failed to fetch updates from remote repository."
    cd "$original_dir"  # Return to the original directory
    return 1
  fi

  # Check for local changes
  if [ -n "$(git status --porcelain)" ]; then
    # Commit changes with datetime
    local commit_message="Sync local changes at $(date +"%Y-%m-%d %H:%M:%S")"
    echo "Adding and committing local changes..."
    if ! git add . || ! git commit -m "$commit_message"; then
      echo "Failed to add or commit changes."
      cd "$original_dir"  # Return to the original directory
      return 1
    fi
  else
    echo "No local changes to commit."
  fi

  # Pull and rebase onto the updated remote main
  echo "Pulling and rebasing onto remote main..."
  if ! git pull --rebase origin main; then
    echo "Rebase failed. Please resolve conflicts and run 'profile sync' again."
    cd "$original_dir"  # Return to the original directory
    return 1
  fi

  # Push local changes to remote repository
  echo "Pushing local changes to remote repository..."
  if ! git push origin main; then
    echo "Push failed. Please check your remote configuration and try again."
    cd "$original_dir"  # Return to the original directory
    return 1
  fi

  # Return to the original directory
  cd "$original_dir"
}
# Function to list profiles
profile_list() {
  echo "Available profiles:"
  ls -1 "$PROFILE_PATH"
}

# Function to create a new profile
profile_init() {
  profile_name="$1"

  if [ -z "$profile_name" ]; then
    echo "Please provide a profile name."
    return 1
  fi

  if [ -e "$PROFILE_PATH/$profile_name" ]; then
    echo "Profile '$profile_name' already exists."
    return 1
  fi

  touch "$PROFILE_PATH/$profile_name"
  echo "Profile '$profile_name' created."
}

# Function to load a profile
profile_load() {
  profile_name="$1"

  if [ -e "$PROFILE_PATH/$profile_name" ]; then
    # Check if pre_load script exists and source it
    if [ -f "$PRE_LOAD_SCRIPT" ]; then
      . "$PRE_LOAD_SCRIPT"
    fi
    
    # Load the profile
    . "$PROFILE_PATH/$profile_name"
    echo "Profile '$profile_name' loaded."
    
    # Check if post_load script exists and source it
    if [ -f "$POST_LOAD_SCRIPT" ]; then
      . "$POST_LOAD_SCRIPT"
    fi
  else
    echo "Profile '$profile_name' does not exist."
  fi
}

# Function to edit a profile
profile_edit() {
  profile_name="$1"

  if [ -z "$profile_name" ]; then
    echo "Please provide a profile name to edit."
    return 1
  fi

  if [ -e "$PROFILE_PATH/$profile_name" ]; then
    ${EDITOR:-vi} "$PROFILE_PATH/$profile_name"  # Use $EDITOR if set, otherwise fall back to vi
    echo "Profile '$profile_name' opened for editing."
  else
    echo "Profile '$profile_name' does not exist."
  fi
}

# Function to handle PROFILE_FORCE or load PROFILE_DEFAULT
profile_default() {
  if [ -n "$PROFILE_FORCE" ]; then
    echo "PROFILE_FORCE is set. Please choose a profile:"
    profile_list

    # Prompt user for input
    echo -n "Enter profile name: "
    read profile_name

    # Load selected profile
    profile_load "$profile_name"
    return
  fi

  if [ -n "$PROFILE_DEFAULT" ]; then
    profile_load "$PROFILE_DEFAULT"
    return
  fi
}

# Main profile function to delegate to sub-functions
profile() {
  command="$1"
  arg="$2"

  case "$command" in
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
      profile_init "$arg"
      ;;
    "e" | "edit")
      profile_edit "$arg"
      ;;
    "s" | "sync")
      profile_sync
      ;;
    *)
      profile_load "$command"
      ;;
  esac
}

profile "$@"
