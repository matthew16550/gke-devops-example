This is a work in progress demo project using [Terraform](https://www.terraform.io/) to deploy a simple Python web app on
[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/).

I hadn't used GKE before so took this opportunity to try it out.

Note the current web app only produces static content so this could all be replaced with static hosting and possibly a CDN.  That would
be so much simpler and more robust!


# Prerequisites

* Development and testing was done on macOS.  It probably works on Linux too.

* [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts) installed locally.

* [Terraform](https://www.terraform.io/downloads.html) installed locally.


# Deploying

1. Adjust `settings.sh` to your liking (possibly creating `settings-local.sh` as well).

1. Get some Google Cloud credentials.  Running `gcloud auth login` in the shell was enough for me and I haven't read more about it.
 
1. Run `bin/stack-create-or-update.sh` to create everything.  (It's idempotent so run it whenever you like)

1. It will probably fail with `'projects/PROJECT_ID' is not a Stackdriver workspace`, this is a [known bug](https://github.com/terraform-providers/terraform-provider-google/issues/2605).
   To work around it go [here](https://app.google.stackdriver.com/accounts) and manually add a workspace for the project
   then run `bin/stack-create.sh` again.

1. Open the web page linked in the TF output `console_for_hello_service` and wait until it looks like some pods are serving.
   (TODO add a CLI way to do this)

1. Run `bin/smoketest.sh` to check the app is working.


# Undeploying

Run `bin/stack-destroy.sh` to destroy everything.


# Architecture

A "regional" GKE cluster is created so the K8s masters and nodes will be deployed in several zones. Three worker nodes are deployed in each
zone, our app is deployed three times in each zone and fronted by an HTTP load balancer. In theory all that means our app should survive
most infrastructure failures provided at least one node in one zone is still working.  In practice I expect it probably will but some
outages will be caused by K8s extreme internal complexity.

The app is built into a Docker image and deployed via Terraforms Kubernetes provider so in theory it would be simple to move away from
Google Cloud.

Python dependencies are managed by [Pipenv](https://docs.pipenv.org/) as I find it the most convenient of the various Python
dependency tools.

Uptime monitoring & alerting is a work in progress and might be provided by Google Stackdriver.


# Security

I chose `python:3.7.2-alpine3.8` as the base Docker image because it is small and my home internet doesn't cope with uploading larger
images.  But that image has known security vulnerabilities.  Newer images should be released [soon](https://github.com/docker-library/python/pull/375).
The Debian based images are probably a better choice wrt security.

`Dockerfile` includes a `pipenv check` step which will fail the build on dependency vulnerabilities known to the
[Safety](https://pyup.io/safety/) project.  Beware their database is only updated once a month unless you pay for a license.  

Things I have not done but would improve security:

* Remove all unnecessary files from the deployed container (multistage builds make this easier but it's not trivial with Python).

* Use something like [snyk](https://snyk.io) to find dependency vulnerabilities via CI builds or their "Continuous monitoring".

* Use Google [Container Analysis](https://cloud.google.com/container-registry/docs/container-analysis) to find known security
  vulnerabilities.  In my brief trying it does not find the vulnerabilities in my base image that Docker Hub reports.  And I've seen it 
  take over 15 hours before analysing a new image.  So it doesn't seem too useful yet.

* Use a third party container compliance / vulnerability scanner, there seem to be many to choose from. 


# Known Issues

* The Terraform code is a bit verbose as I like to learn by linking all the pieces myself.
  Long term it's probably better to use these "verified" modules:

    * [project-factory](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/1.0.2)
    * [kubernetes-engine](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/0.4.0)

* Not yet using version numbers for the Docker image (it's effectively `latest` everywhere).

* I haven't paid attention to IAM or to network segregation.
 
* Google "Cluster Autoscaler" isn't used because when I tried it wouldn't scale above zero!  Probably I missed a vital setting.
  Once enabled it will improve the apps ability to handle large loads and improve resiliency during zone outages by automatically deploying
  nodes across the remaining zones.

* The cluster master is often auto upgraded soon after creation.  It seems to take 5 - 10 minutes during which Terraform fails with
  `Cluster "..." has status "RECONCILING" with message ""`.  It happens both when I set `min_master_version` in
  `google_container_cluster.main` to the latest version and when I let it default to a slightly older version.
  
* Every time I've tried this, a few "hello" pods never successfully start for various reasons.  Haven't dug into it.  Regardless, the
  deployment does reach desired size fairly quickly.

* Disk usage in the pods goes up 100-150k every 15 mins, I haven't let them run long enough to determine if this is actually a problem.

* Stackdriver Monitoring may take up to 25 minutes before it starts monitoring, apparently that's by design.

* Uptime alert emails aren't sent because I haven't decyphered how to use Stackdriver Alert Policies with uptime monitors.
