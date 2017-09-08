
# Roadmap for kraken-lib and Related Projects
As the most important piece of our tool chain, kraken-lib drives the roadmaps for other projects. If those other projects require significant effort, we will start a stub mention here so we address it during normal project planning and grooming.

This roadmap only includes large-effort issues we believe to be of strategic importance. Ad-hoc client work will usually rise directly to the top and may prompt rearranging this roadmap.  

## Work Planned ##
Below are the main features to which we have agreed, ordered by when we'll start them. Also included are some general notes for feature expectations. The notes should not be viewed as complete requirements, merely directionally correct.

1. Monitoring 
    * resource usage broken down by namespace and node(?)
    * resource usage over time
    * resource availability over time (not just constant minus previous, capacity can change)
    * general monitoring strategy
1. Clean up logging story
    * logging agents running on master nodes
    * ensure application lifecycle (app create, restart, etc.) are in system logs
    * cluster events (oo disk, oom, new node) are in system logs
    * blog post(s) on what we're doing
1. etcd management
    * for the short term, prevent any changes to the etcd resources on a running cluster
    * define how we plan to handle etcd node management
1. Bare metal/MaaS provider
1. Rules-based alerting
    * inputs are logs (including Kubernetes events) and monitoring output
1. Linting - this should either occur as pre-commit hooks or with a CI job (or both)
    * config file
    * Ansible tasks
    * go libraries
1. Save kraken-lib state to cluster (#125)
1. Multiple admins operating at once 
    * locks on storing Terraform and kraken-lib state in etcd
1. Cluster modification plan
    * a clear output of what will change during a 'dry run'
    * requires a previous state of config file that assumes config file is source of truth
1. kraken-lib full marketing plan implementation
    * blogs/presentations/customer testimonials/white paper
    * doc PRs for adding to Kubernetes docs
    * other items as they bubble up from ongoing marketing/user=definition discussions
    * public Slack channel
    * PRs to Kubernetes docs to put kraken in the right locations
    * Kubernetes demo
1. Cluster management via website
    * implement via a combination of a local GUI, running in a pod where multiple admins can operate
    * or hack on dashboard to run against kraken-lib Docker calls

##  Features Desired but Not Planned ##
Below are items we also want to do but don't deem important enough to include on the above list yet. They're not in priority order, so feel free to add new ideas anywhere in the list.

* Debugging kraken-lib documents
* Update system certs
* kraken cleanup (we have a lot of tech debt/non-standard code here)