#!/bin/sh

# Set default profile path if PROFILE_PATH is not set
PROFILE_PATH="${PROFILE_PATH:-$HOME/.profiles}"
PROFILE_PRE_LOAD_SCRIPT="${PROFILE_PRE_LOAD_SCRIPT:-$PROFILE_PATH/.pre.sh}"
PROFILE_POST_LOAD_SCRIPT="${PROFILE_POST_LOAD_SCRIPT:-$PROFILE_PATH/.post.sh}"
PROFILE_CLEAN_SCRIPT="${PROFILE_CLEAN_SCRIPT:-$PROFILE_PATH/.clean.sh}"
SCRIPT_PATH="${SCRIPT_PATH:-$HOME/.profile.sh}"
GIT_REMOTE="${GIT_REMOTE:-origin}"
GIT_BRANCH="${GIT_BRANCH:-main}"

# General function to check and create file if it doesn't exist
check_and_create_file() {
  file_path="$1"
  description="$2"

  if [ ! -f "$file_path" ]; then
    echo "$description not found. Creating: $file_path"
    touch "$file_path"
  fi
}

# General function to run a script if it exists
run_script() {
  script_path="$1"

  if [ -f "$script_path" ]; then
    . "$script_path"
    echo "$script_path executed."
  else
    echo "$script_path not found."
  fi
}

# Function to validate profile names
validate_profile_name() {
  case "$1" in
    *[!a-zA-Z0-9_-]*)
      echo "Invalid profile name."
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

# Function to validate if a file exists
validate_file_exists() {
  file_path="$1"
  if [ ! -f "$file_path" ]; then
    echo "File '$file_path' does not exist."
    return 1
  fi
  return 0
}

# Function to run the clean script
profile_clean() {
  run_script "$PROFILE_CLEAN_SCRIPT"
}

# Function to sync with git
profile_sync() {
  # Check if git is installed
  command -v git >/dev/null 2>&1 || { echo "git is required but not installed."; return 1; }

  # Save the current directory
  original_dir=$(pwd)

  # Ensure PROFILE_PATH is set and is a valid directory
  if [ ! -d "$PROFILE_PATH" ]; then
    echo "PROFILE_PATH ($PROFILE_PATH) is not a valid directory."
    return 1
  fi

  # Navigate to the PROFILE_PATH directory
  cd "$PROFILE_PATH" || {
    echo "Failed to change directory to $PROFILE_PATH"
    return 1
  }

  # Ensure we're in a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository. Please ensure PROFILE_PATH contains a git repository."
    cd "$original_dir" # Return to the original directory
    return 1
  fi

  # Fetch updates from remote branch
  echo "Fetching updates from remote repository..."
  if ! git fetch "$GIT_REMOTE" "$GIT_BRANCH"; then
    echo "Failed to fetch updates from remote repository."
    cd "$original_dir" # Return to the original directory
    return 1
  fi

  # Check for local changes
  if [ -n "$(git status --porcelain)" ]; then
    # Commit changes with datetime
    commit_message="Sync local changes at $(date +"%Y-%m-%d %H:%M:%S")"
    echo "Adding and committing local changes..."
    if ! git add . || ! git commit -m "$commit_message"; then
      echo "Failed to add or commit changes."
      cd "$original_dir" # Return to the original directory
      return 1
    fi
  else
    echo "No local changes to commit."
  end

  # Pull and rebase onto the updated remote branch
  echo "Pulling and rebasing onto remote $GIT_BRANCH..."
  if ! git pull --rebase "$GIT_REMOTE" "$GIT_BRANCH"; then
    echo "Rebase failed. Please resolve conflicts and run 'profile sync' again."
    cd "$original_dir" # Return to the original directory
    return 1
  fi

  # Push local changes to remote repository
  echo "Pushing local changes to remote repository..."
  if ! git push "$GIT_REMOTE" "$GIT_BRANCH"; then
    echo "Push failed. Please check your remote configuration and try again."
    cd "$original_dir" # Return to the original directory
    return 1
  fi

  # Return to the original directory
  cd "$original_dir"
}

# Function to list profiles
profile_list() {
  echo "Profiles:"
  echo "--------"
  for profile in "$PROFILE_PATH"/*; do
    [ -f "$profile" ] && echo "$(basename "$profile")"
  done
}

# Function to create a new profile
profile_new() {
  profile_name="$1"

  if [ -z "$profile_name" ]; then
    echo "Please provide a profile name."
    return 1
  fi

  validate_profile_name "$profile_name" || return 1

  if [ -e "$PROFILE_PATH/$profile_name" ]; then
    echo "Profile '$profile_name' already exists."
    return 1
  fi

  check_and_create_file "$PROFILE_PATH/$profile_name" "Profile '$profile_name' created."
}

# Function to load a profile
profile_load() {
  profile_name="$1"

  validate_profile_name "$profile_name" || return 1

  # Check if profile file exists
  if ! validate_file_exists "$PROFILE_PATH/$profile_name"; then
    return 1
  fi

  # Run the pre-load script
  profile_pre

  run_script "$PROFILE_PATH/$profile_name"

  # Run the post-load script
  profile_post
}

# Function to run the pre-load script
profile_pre() {
  run_script "$PROFILE_PRE_LOAD_SCRIPT"
}

# Function to update the script
profile_update() {
  # Check if curl is installed
  command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed."; return 1; }

  echo "This will overwrite $SCRIPT_PATH. Do you want to continue? (y/n)"
  read answer
  if [ "$answer" = "y" ]; then
    cp "$SCRIPT_PATH" "$SCRIPT_PATH.bak"
    curl -o "$SCRIPT_PATH" https://raw.githubusercontent.com/ryanparsa/profile.sh/main/profile.sh
    echo "Update complete. Backup saved as $SCRIPT_PATH.bak"
  else
    echo "Update canceled."
  fi
}

# Function to run the post-load script
profile_post() {
  run_script "$PROFILE_POST_LOAD_SCRIPT"
}

# Function to edit a profile
profile_edit() {
  profile_name="$1"

  if [ -z "$profile_name" ]; then
    echo "Please provide a profile name to edit."
    return 1
  fi

  validate_profile_name "$profile_name" || return 1

  if validate_file_exists "$PROFILE_PATH/$profile_name"; then
    ${EDITOR:-vi} "$PROFILE_PATH/$profile_name" # Use $EDITOR if set, otherwise fall back to vi
    echo "Profile '$profile_name' opened for editing."
  else
    echo "Cannot edit non-existent profile '$profile_name'."
  fi
}

# Function to handle PROFILE_FORCE or load PROFILE_DEFAULT
profile_default() {
  if [ -n "$PROFILE_FORCE" ]; then
    echo "PROFILE_FORCE is set. Please choose a profile:"
    profile_list

    # Prompt user for input
    printf "Enter profile name: "
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

# Create profile directory if it doesn't exist
if [ ! -d "$PROFILE_PATH" ]; then
  echo "Profile directory not found. Creating: $PROFILE_PATH"
  mkdir -p "$PROFILE_PATH"
fi

# Check and create necessary script files
check_and_create_file "$PROFILE_PRE_LOAD_SCRIPT" "Pre-load script"
check_and_create_file "$PROFILE_POST_LOAD_SCRIPT" "Post-load script"
check_and_create_file "$PROFILE_CLEAN_SCRIPT" "Clean script"

# Function to display help
profile_help() {
  cat <<EOF
Usage: profile [COMMAND] [ARGS]

Commands:
  help            Display this help message
  list            List available profiles
  new <name>      Create a new profile with the given name
  edit <name>     Edit the specified profile using the default editor
  sync            Pull and push changes to remote git repo
  pre             Run the pre-load script directly
  post            Run the post-load script directly
  clean           Run the clean script
  update          Update this script to the latest version
  <name>          Load the specified profile

Environment Variables:
  PROFILE_PATH               Path to the profiles directory (default: \$HOME/.profiles)
  PROFILE_PRE_LOAD_SCRIPT    Path to the pre-load script
  PROFILE_POST_LOAD_SCRIPT   Path to the post-load script
  PROFILE_CLEAN_SCRIPT       Path to the clean script
  PROFILE_FORCE              If set, forces the user to select a profile
  PROFILE_DEFAULT            The default profile to load if none is specified
  EDITOR                     The editor to use for editing profiles (default: vi)
  GIT_REMOTE                 The name of the git remote (default: origin)
  GIT_BRANCH                 The git branch to use (default: main)
  SCRIPT_PATH                Path to this script (default: \$HOME/.profile.sh)

Notes:
  If PROFILE_FORCE is set, the script will prompt the user to select a profile from the list.
  If PROFILE_DEFAULT is set and PROFILE_FORCE is not, the default profile will be loaded.
  If neither is set, no profile will be loaded by default.
EOF
}

# Main profile function to delegate to sub-functions
profile() {
  command="$1"
  arg="$2"

  case "$command" in
  "") profile_default ;;
  "h" | "help") profile_help ;;
  "l" | "list") profile_list ;;
  "n" | "new") profile_new "$arg" ;;
  "e" | "edit") profile_edit "$arg" ;;
  "s" | "sync") profile_sync ;;
  "pre") profile_pre ;;
  "post") profile_post ;;
  "clean") profile_clean ;;
  "update") profile_update ;;
  *) profile_load "$command" ;;
  esac
}

profile "$@"
