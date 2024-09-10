# cat ~/.profiles/post_load.sh 

# Create the .kube directory and copy the KUBECONFIG file
mkdir -p ~/.kube
cp "$KUBECONFIG" ~/.kube/config
kubectl config use-context default


# Create the .aws directory and configuration files
mkdir -p ~/.aws

cat > ~/.aws/config <<EOL
[default]
region = ${AWS_DEFAULT_REGION}
output = ${AWS_DEFAULT_OUTPUT}
EOL

cat > ~/.aws/credentials <<EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL

# Set the path to your SSH directory
SSH_DIR="$HOME/.ssh"

# Ensure the SSH directory exists
mkdir -p "$SSH_DIR"

# Create SSH files from environment variables
echo "$SSH_ID_ED25519_CONTENT" > "$SSH_DIR/id_ed25519"
echo "$SSH_ID_ED25519_PUB_CONTENT" > "$SSH_DIR/id_ed25519.pub"
echo "$SSH_ID_RSA_CONTENT" > "$SSH_DIR/id_rsa"
echo "$SSH_ID_RSA_PUB_CONTENT" > "$SSH_DIR/id_rsa.pub"
echo "$SSH_KNOWN_HOSTS_CONTENT" > "$SSH_DIR/known_hosts"

# Create SSH config file
echo "$SSH_CONFIG_FILE_CONTENT" > "$SSH_DIR/config"

# Set correct permissions for SSH files
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/id_ed25519" "$SSH_DIR/id_rsa"
chmod 644 "$SSH_DIR/id_ed25519.pub" "$SSH_DIR/id_rsa.pub"
chmod 644 "$SSH_DIR/known_hosts" "$SSH_DIR/config"
