# There can only be a single job definition per file.
# Create a job with ID and Name 'example'
job "core" {
	# Run the job in the global region, which is the default.
	# region = "global"

	# Specify the datacenters within the region this job can run in.
	datacenters = ["dc1"]

	# Service type jobs optimize for long-lived services. This is
	# the default but we can change to batch for short-lived tasks.
	# type = "service"

	# Priority controls our access to resources and scheduling priority.
	# This can be 1 to 100, inclusively, and defaults to 50.
	# priority = 50

	# Restrict our job to only linux. We can specify multiple
	# constraints as needed.
	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}

	# Configure the job to do rolling updates
	update {
		# Stagger updates every 10 seconds
		stagger = "10s"

		# Update a single task at a time
		max_parallel = 1
	}

	# Create a 'core' group. Each task in the group will be
	# scheduled onto the same machine.
	group "core" {
		# Control the number of instances of this groups.
		# Defaults to 1
		count = 1

		# Configure the restart policy for the task group. If not provided, a
		# default is used based on the job type.
		restart {
			# The number of attempts to run the job within the specified interval.
			attempts = 10
			interval = "5m"
			
			# A delay between a task failing and a restart occurring.
			delay = "25s"

			# Mode controls what happens when a task has restarted "attempts"
			# times within the interval. "delay" mode delays the next restart
			# till the next interval. "fail" mode does not restart the task if
			# "attempts" has been hit within the interval.
			mode = "fail"
		}

		# Define a task to run
		task "core" {
			# Use Docker to run the task.
			driver = "docker"

			# Configure Docker driver with the image
			config {
				image = "crokita/discovery-core:master"

				port_map {
					tcp = 12345
					hmi = 8087
				}
			}

			service {
				name = "${TASKGROUP}"
				tags = ["global", "cache", "${NOMAD_PORT_tcp}"]
				port = "hmi"
				check {
					name = "alive"
					type = "script"
					interval = "2s"
					timeout = "1s"
					command = "/bin/bash health.sh"
				}
			}

			env {
				DOCKER_IP = "${NOMAD_IP_hmi}"
			}

			# We must specify the resources required for
			# this task to ensure it runs on a machine with
			# enough capacity.
			resources {
				cpu = 500 # 500 Mhz
				memory = 256 # 256MB
				network {
					mbits = 10
					port "tcp" {}
					port "hmi" {}
				}
			}

		}
	}
}