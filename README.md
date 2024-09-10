### Overview

In modern development environments, managing different configurations for various projects or services (like AWS, Kubernetes, and SSH) can be challenging. Each project may require different credentials, environment variables, or services, and manually switching between them can be error-prone and time-consuming.

This is where the `profile` shell script comes in. It provides a simple and efficient way to manage multiple configurations, or "profiles," and switch between them dynamically. This script is ideal for developers, sysadmins, or anyone working with cloud services, containerized environments, or multiple projects that require distinct settings.

### Key Concepts

1. **Profiles**: Profiles are custom environments that define specific settings like environment variables, credentials, or paths. You can create different profiles for each project or service.
  
2. **Environment Variables**: Variables such as AWS credentials, Kubernetes configuration, and SSH keys are stored within profiles and loaded when needed, ensuring you use the correct settings for each task.

3. **Pre-load/Post-load Scripts**: These are scripts that run automatically before and after loading a profile. They help in cleaning up any old environment variables (pre-load) and setting up the necessary environment (post-load).

4. **Synchronization with Git**: Profiles can be synced with a remote Git repository, allowing you to share configurations across devices or with your team.

### Why This Script Can Help You

1. **Dynamic Configuration Switching**: If you work with different cloud providers (like AWS), Kubernetes clusters, or need specific SSH configurations for various projects, this script allows you to easily switch between environments by loading the appropriate profile.
   
2. **Automation of Repetitive Tasks**: Instead of manually setting and unsetting environment variables or copying configuration files, the script does this automatically when you switch profiles, reducing errors and saving time.

3. **Consistency Across Projects**: By defining your environment in profiles, you ensure that each project has a consistent setup. This is particularly useful when collaborating with others, as you can share profiles through a Git repository.

### Step-by-Step Tutorial

#### 1. **Basic Setup**

1. **Create a Profiles Directory**:
   By default, the script looks for profiles in the `~/.profiles` directory. Start by creating this directory if it doesn’t exist:
   ```sh
   mkdir ~/.profiles
   ```

2. **Save the Script**:
   Save the `profile` script as `profile.sh` in your home directory.

3. **Make the Script Executable**:
   ```sh
   chmod +x ~/profile.sh
   ```

4. **Add to Shell Configuration**:
   To make the script available in your terminal, add the following to your `.bashrc` or `.zshrc`:
   ```sh
   source ~/profile.sh
   alias p=profile
   ```
   Then reload the shell:
   ```sh
   source ~/.zshrc  # or ~/.bashrc
   ```

#### 2. **Managing Profiles**

Now that your script is set up, you can create and manage profiles to switch between different environments.

##### **Creating a New Profile**

Let’s say you want to create a profile for a project called `projectA`. Use the following command:
```sh
p i projectA
```
This creates an empty profile file in `~/.profiles/projectA`. You can now edit the profile to add the environment variables and settings required for this project.

##### **Editing a Profile**

To configure `projectA`, edit the profile:
```sh
p e projectA
```
You can add project-specific environment variables, such as AWS credentials or Kubernetes configurations:
```sh
export AWS_ACCESS_KEY_ID=YOUR_AWS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET
export KUBECONFIG=~/path/to/kubeconfig.yaml
```

##### **Loading a Profile**

Once a profile is configured, you can load it:
```sh
p projectA
```
This will apply the settings from the profile to your current terminal session.

##### **Listing Available Profiles**

To see all profiles you've created, use:
```sh
p l
```

#### 3. **Advanced Usage**

##### **Pre-Load and Post-Load Scripts**

If you need to clean up old environment variables before loading a new profile or run setup tasks after loading one, you can use the `pre_load.sh` and `post_load.sh` scripts. For example:

- **`pre_load.sh`** (clears old variables):
  ```sh
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset KUBECONFIG
  ```

- **`post_load.sh`** (sets up configuration files):
  ```sh
  mkdir -p ~/.kube
  cp "$KUBECONFIG" ~/.kube/config
  kubectl config use-context default
  ```

These scripts will run automatically when switching profiles, ensuring a clean and ready-to-go environment each time.

##### **Syncing Profiles with Git**

If you work across multiple machines or with other people, you can sync your profiles using Git. Initialize a Git repository in the `~/.profiles` directory:
```sh
cd ~/.profiles
git init
git remote add origin <your-repo-url>
```

To sync profiles:
```sh
p s
```
This will fetch updates from the repository, commit any local changes, and push the latest version to the remote repository.

#### 4. **Real-World Example**

Let’s say you have two profiles, one for development (`dev`) and another for production (`prod`), each requiring different AWS and Kubernetes configurations:

1. **Development Profile (`dev`)**:
   ```sh
   export AWS_ACCESS_KEY_ID=DEV_AWS_KEY
   export AWS_SECRET_ACCESS_KEY=DEV_AWS_SECRET
   export KUBECONFIG=~/dev-kubeconfig.yaml
   ```

2. **Production Profile (`prod`)**:
   ```sh
   export AWS_ACCESS_KEY_ID=PROD_AWS_KEY
   export AWS_SECRET_ACCESS_KEY=PROD_AWS_SECRET
   export KUBECONFIG=~/prod-kubeconfig.yaml
   ```

You can easily switch between them:
```sh
p dev  # Switch to development environment
p prod # Switch to production environment
```

In this case, `pre_load.sh` might clean up old AWS and Kubernetes settings, and `post_load.sh` might configure your AWS and Kubernetes CLI tools based on the newly loaded profile.

### Conclusion

This profile management script is an invaluable tool for anyone juggling multiple environments, such as developers, sysadmins, or cloud engineers. It automates the tedious task of setting environment variables and configurations for various projects, ensuring you always have the right setup with minimal effort. Additionally, integrating with Git allows for easy profile sharing and synchronization across multiple machines.
