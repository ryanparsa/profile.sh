# Add this to your ~/.zshrc

# Function to display help
profile_help() {
  echo "Commands:"
  echo "  profile list      - List available profiles"
  echo "  profile init name - Create a new profile"
  echo "  profile name      - Load a profile"
}

# Function to list profiles
profile_list() {
  echo "Available profiles:"
  ls ~/.profiles
}

# Function to create a new profile
profile_init() {
  if [[ -z $1 ]]; then
    echo "Please provide a profile name."
    return 1
  fi
  touch ~/.profiles/$1
  echo "Profile '$1' created."
}

# Function to load a profile
profile_load() {
  if [[ -e ~/.profiles/$1 ]]; then
    source ~/.profiles/$1
    echo "Profile '$1' loaded."
  else
    echo "Profile '$1' does not exist."
  fi
}


profile_default(){
    echo default
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
    *)
      profile_load $1
      ;;
  esac
}