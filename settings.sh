#
# NOTE: Put sensitive / local values in settings-local.sh to avoid accidentally committing them in git
#

# ID of the relevant Google Billing Account
export TF_VAR_billing_account_id="you could set this in settings-local.sh"

# Email address to send monitoring alerts to
export TF_VAR_monitoring_email_address="you could set this in settings-local.sh"

# Name of region to deploy in
export TF_VAR_region="us-west1"

# Name to be used as identifier throughout the stack
export TF_VAR_stack_name="gke-devops-example"

# List of zones to deploy in
# TODO 3 zones would be more robust but limits in the GCP free tier seem to prevent using 3
export TF_VAR_zones='["us-west1-a","us-west1-b"]'


#
# Below here should not normally be changed
#

export CLOUDSDK_COMPUTE_REGION="${TF_VAR_region}"

export region="${TF_VAR_region}"

export stack_name="${TF_VAR_stack_name}"

[[ -e settings-local.sh ]] && source settings-local.sh
