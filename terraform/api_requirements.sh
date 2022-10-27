## enables all APIs via script. Not needed, but recorded for learnings sake
gcloud services enable bigquery.googleapis.com
gcloud services enable bigquerymigration.googleapis.com
gcloud services enable bigquerystorage.googleapis.com
gcloud services enable cloudapis.googleapis.com
gcloud services enable cloudasset.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable clouddebugger.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudtrace.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable datastore.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable oslogin.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable source.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable storage.googleapis.com

## enable terraform debug logs, so you can actually see whats going on
export TF_DEBUG=true
export TF_LOG=terraform.log

##run apply on this project
terraform apply --var-file=variables.tfvars
