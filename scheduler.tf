# Create an instance schedule resource policy for automatic shutdown at 6 PM
resource "google_compute_resource_policy" "daily_shutdown" {
  name        = "daily-shutdown-policy"
  region      = var.region
  description = "Automatically shuts down instances at 6 PM"

  instance_schedule_policy {
    vm_stop_schedule {
      schedule = "0 18 * * *" # 6 PM every day
    }

    time_zone = var.scheduler_time_zone
  }
}

# Create a separate policy for startup if needed (e.g., for the next morning)
resource "google_compute_resource_policy" "daily_startup" {
  count       = var.enable_auto_startup ? 1 : 0
  name        = "daily-startup-policy"
  region      = var.region
  description = "Automatically starts instances at 8 AM on weekdays"

  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 8 * * 1-5" # 8 AM Monday-Friday
    }

    time_zone = var.scheduler_time_zone
  }
}

# Service account permissions needed for scheduling to work
# This allows the compute service account to start/stop instances
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "instance_scheduler_role" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}
