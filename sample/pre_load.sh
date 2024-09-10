# cat ~/.profiles/pre_load.sh 
# Unset common environment variables

# Unset variables related to OpenAI
unset OPENAI_API_KEY

# Unset variables related to AWS
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_DEFAULT_REGION

# Unset variables related to Kubernetes
unset KUBECONFIG
unset KUBERNETES_SERVICE_HOST
unset KUBERNETES_SERVICE_PORT

# Add any other variables you want to unset here
