
# Roadmap for kraken-lib and related projects
kraken-lib (K2) is the most important piece of our tool chain and we let it drive the roadmaps for the other projects. If those other projects require significant effort we will start a stub mention here so we address it during normal project planning and grooming.

This roadmap only includes large effort issues that we believe are of strategic importance.  Ad-hoc client work will usually rise directly to the top and may cause this roadmap to be re-arranged.  

## Work Planned ##
These are the large features we have agreed to and the order we will start them.  There are also some general notes for what we expect out of each feature.  The notes should not be viewed as complete requirements, merely directionally correct.

1. monitoring 
    * resource usage broken down by namespace and node(?)
    * resource usage over time
    * resource availability over time (not just constant minus previous, capacity can change)
    * general monitoring strategy
1. clean up logging story
    * logging agents running on master nodes
    * ensure that application life cycle (app create, restart, etc) are in system logs
    * cluster events (oo disk, oom, new node) are in system logs
    * blog post on what we're doing
1. etcd management
    * for the short term, prevent any changes to the etcd resources on a running cluster
    * define how we plan to handle etcd node management
1. bare metal/MaaS provider
1. rules based alerting
    * inputs are logs (including kubernetes events) and monitoring output
1. linting - this should either be done as pre-commit hooks or with a CI job (or both)
    * config file
    * ansible tasks
    * go libraries
1. save kraken-lib state to cluster (#125)
1. multiple admins operating at once 
    * locks on storing terraform & kraken-lib state in etcd
1. cluster modification plan
    * ie a clear output of what will change during a 'dryrun'
    * this will require a previous state of config file. that assumes config file is source of truth
1. kraken-lib full marketing plan implementation
    * blogs/presentations/customer testimonials/white paper
    * doc PRs for adding to kubernetes docs
    * other items as they bubble up from ongoing marketing/user definition discussions.
    * public slack channel
    * PRs to kubernetes docs to put Kraken into the right locations
    * kubernetes demo
1. cluster management via website
    * implement via a combination of a local GUI, running in a pod where multiple admins can operate
    * or hack on dashboard to run against kraken-lib docker calls

##  Features desired but not planned ##
These are things we think we should do but do not believe they are important enough to warrant putting on the above list yet.  There is no priority order here so feel free to add new ideas anywhere in the list.

* debugging kraken-lib documents
* update system certs
* k2cli cleanup (we have a lot of tech debt/non standard code here)