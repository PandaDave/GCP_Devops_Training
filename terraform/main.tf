//
resource "google_storage_bucket" "pluto_bucket" {
  project  = var.project_id
  name     = "${var.project_id}-bucket"
  location = var.region
  versioning {
    enabled = false
  }
}

resource "google_bigquery_dataset" "bq_dataset" {
  project                     = var.project_id
  dataset_id                  = "activities"
  friendly_name               = "activities"
  description                 = "Moonbank activities dataset"
  location                    = "US"
  default_table_expiration_ms = 3600000
}

resource "google_bigquery_table" "bq_table" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.bq_dataset.dataset_id
  table_id            = "resources"
  depends_on          = [google_bigquery_dataset.bq_dataset]
  schema              = <<EOF
[
  {
    "name": "messages",
    "type": "STRING"
  }
]
EOF
  deletion_protection = false
}

resource "google_pubsub_topic" "pubsub_topic" {
  project                    = var.project_id
  name                       = "activities"
  message_retention_duration = "86600s"
}

resource "google_pubsub_subscription" "pubsub_sub" {
  project              = var.project_id
  name                 = "activites-catchall"
  topic                = google_pubsub_topic.pubsub_topic.name
  ack_deadline_seconds = 20
  depends_on           = [google_pubsub_topic.pubsub_topic]
}

resource "google_storage_bucket_object" "cloudfunction" {
  name    = var.function_zip
  bucket  = var.infra_bucket
  source  = "./${var.function_zip}"
}

resource "google_cloudfunctions_function" "function" {
  project             = var.project_id
  name                = var.function_name
  description         = "Capture activities from pubsub and push into BQ"
  runtime             = "python39"
  available_memory_mb = 128
  source_repository {
    url = "https://source.developers.google.com/projects/mb-devops-user7/repos/GCP_Devops_Training/moveable-aliases/main/paths/cloudfunction"
  }
  timeout = 60
  event_trigger {
    resource   = google_pubsub_topic.pubsub_topic.name
    event_type = "google.pubsub.topic.publish"
  }
  depends_on = [google_pubsub_topic.pubsub_topic]
}

resource "google_cloud_asset_project_feed" "project_feed" {
  for_each     = var.project_children
  project      = each.value.name
  feed_id      = "asset-feed"
  content_type = "RESOURCE"
  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.pubsub_topic.id
    }
  }

  asset_types = [
    "compute.googleapis.com/Autoscaler",
    "compute.googleapis.com/Address",
    "compute.googleapis.com/GlobalAddress",
    "compute.googleapis.com/BackendBucket",
    "compute.googleapis.com/BackendService",
    "compute.googleapis.com/Commitment",
    "compute.googleapis.com/Disk",
    "compute.googleapis.com/ExternalVpnGateway",
    "compute.googleapis.com/Firewall",
    "compute.googleapis.com/FirewallPolicy",
    "compute.googleapis.com/ForwardingRule",
    "compute.googleapis.com/GlobalForwardingRule",
    "compute.googleapis.com/HealthCheck",
    "compute.googleapis.com/HttpHealthCheck",
    "compute.googleapis.com/HttpsHealthCheck",
    "compute.googleapis.com/Image",
    "compute.googleapis.com/Instance",
    "compute.googleapis.com/InstanceGroup",
    "compute.googleapis.com/InstanceGroupManager",
    "compute.googleapis.com/InstanceTemplate",
    "compute.googleapis.com/Interconnect",
    "compute.googleapis.com/InterconnectAttachment",
    "compute.googleapis.com/License",
    "compute.googleapis.com/Network",
    "compute.googleapis.com/NetworkEndpointGroup",
    //"compute.googleapis.com/NodeGrop",
    "compute.googleapis.com/NodeTemplate",
    "compute.googleapis.com/PacketMirroring",
    "compute.googleapis.com/Project",
    "compute.googleapis.com/RegionBackendService",
    "compute.googleapis.com/RegionDisk",
    "compute.googleapis.com/Reservation",
    "compute.googleapis.com/ResourcePolicy",
    "compute.googleapis.com/Route",
    "compute.googleapis.com/Router",
    "compute.googleapis.com/SecurityPolicy",
    "compute.googleapis.com/ServiceAttachment",
    "compute.googleapis.com/Snapshot",
    "compute.googleapis.com/SslCertificate",
    "compute.googleapis.com/SslPolicy",
    "compute.googleapis.com/Subnetwork",
    "compute.googleapis.com/TargetHttpProxy",
    "compute.googleapis.com/TargetHttpsProxy",
    "compute.googleapis.com/TargetInstance",
    "compute.googleapis.com/TargetPool",
    "compute.googleapis.com/TargetTcpProxy",
    "compute.googleapis.com/TargetSslProxy",
    "compute.googleapis.com/TargetVpnGateway",
    "compute.googleapis.com/UrlMap",
    "compute.googleapis.com/VpnGateway",
    "compute.googleapis.com/VpnTunnel"
  ]
  depends_on = [
    google_pubsub_topic.pubsub_topic,
    google_pubsub_topic_iam_member.member
  ]
}

//grant service accent publisher access to core project
resource "google_pubsub_topic_iam_member" "member" {
  for_each = var.project_children                //my child array of projects
  project  = var.project_id                      //my core project ID
  topic    = google_pubsub_topic.pubsub_topic.id //my generated pubsub topic
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:service-${each.value.project_number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
}
