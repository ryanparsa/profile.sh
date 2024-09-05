# Profile Manager

**Profile Manager** is a simple script for managing multiple shell profiles. It allows you to switch between different configurations quickly and easily, making it ideal for managing environments with varying settings or credentials.

## Why Use Profile Manager?

Managing multiple profiles can be tedious, especially when switching between different environments such as work and personal projects. **Profile Manager** streamlines this process by allowing you to:

- **Create and Manage Profiles**: Set up and edit different profiles for various needs.
- **Switch Profiles Easily**: Load the desired profile with a single command.
- **Force Profile Selection**: Ensure a profile is chosen when `PROFILE_FORCE` is set.

## Installation and Setup

### 1. Install the Script

You can download and install the script directly using the following command:

```bash
curl -o ~/.profile.sh https://raw.githubusercontent.com/ryanparsa/profile.sh/main/profile.sh
```

### 2. Update Your Shell Configuration

Add the following lines to your `~/.bashrc` or `~/.zshrc` file:

```bash
# Source the profile script
source ~/.profile.sh

# Alias for the profile function
alias p='profile'

# If set, forces the user to select a profile from the list.
#export PROFILE_FORCE=1

# If set, loads the default profile when no profile is specified.
#export PROFILE_DEFAULT=proj1

```

### 3. Reload Your Shell Configuration:

```bash
source ~/.zshrc  # For Zsh users
# or
source ~/.bashrc  # For Bash users
```

## Usage

The `profile` function allows you to manage profiles using the following commands:

### Commands

- **Help**: Display help message.
    ```bash
    p h
    # or
    p help
    ```

- **List**: List all available profiles.
    ```bash
    p l
    # or
    p list
    ```

- **Create New Profile**: Create a new profile with the given name.
    ```bash
    p i myprofile
    # or
    p init myprofile
    ```

- **Edit Profile**: Edit the specified profile using the default editor.
    ```bash
    p e myprofile
    # or
    p edit myprofile
    ```

- **Load Profile**: Load the specified profile.
    ```bash
    p myprofile
    ```

- **Default Profile**: Load the default profile if no profile is specified and `PROFILE_DEFAULT` is set.
    ```bash
    p
    ```

- **Force Profile Selection**: Forces the user to select a profile from the list if `PROFILE_FORCE` is set.
    ```bash
    PROFILE_FORCE=1 p
    ```

### Environment Variables

- **`PROFILE_FORCE`**: If set, forces the user to select a profile from the list.
- **`PROFILE_DEFAULT`**: If set, loads the default profile when no profile is specified.
- **`PROFILE_PATH`**: Specifies the path to store and load profiles (default: `~/.profiles`).

## Example Usage

Suppose you have two profiles: one for university and another for the office. Each profile uses different environment variables:

1. **Create Profiles**:
    ```bash
    p i university
    p i office
    ```

2. **Set Up Profiles**:

    - **University Profile (`university`)**:
      ```bash
      echo 'export OPENAI_API_KEY="your_university_key"' > ~/.profiles/university
      echo 'export AWS_PROFILE="university_profile"' >> ~/.profiles/university
      ```

    - **Office Profile (`office`)**:
      ```bash
      echo 'export OPENAI_API_KEY="your_office_key"' > ~/.profiles/office
      echo 'export AWS_PROFILE="office_profile"' >> ~/.profiles/office
      ```

3. **Switch Profiles**:

    - To switch to the university profile:
      ```bash
      p university
      ```

    - To switch to the office profile:
      ```bash
      p office
      ```

4. **Force Profile Selection**:

    - To force profile selection:
      ```bash
      PROFILE_FORCE=1 p
      ```

5. **Edit Profiles**:

    - To edit the university profile:
      ```bash
      p e university
      ```

    - To edit the office profile:
      ```bash
      p e office
      ```

## Contributing

Feel free to open issues or submit pull requests to improve the tool.
