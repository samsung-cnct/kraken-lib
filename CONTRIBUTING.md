# Contributing
Thank you for your interest in contributing to the kraken-lib project. We welcome all kinds of contributions: ideas, code, patches, bug reports, feature requests and documentation edits. Before diving in, please review this process summary. We did our best to make it as painless as possible!

# Table of Contents

* <a href="#workflows">Workflows</a>
    * <a href="#start-with-help-wanted">Start with Help Wanted</a>
    * <a href="#requesting-new-features">Requesting New Features</a>
    * <a href="#reporting-bugs">Reporting Bugs</a>
    * <a href="#issue-labeling">Issue Labeling</a>
    * <a href="#contributing-code-and-making-changes">Contributing Code and Making Changes</a>
* <a href="#using-pull-requests">Using Pull Requests</a>
* <a href="#recommended-dev-tooling">Recommended Dev Tooling</a>    
    * <a href="#developer-workflow-with-kraken-tools">Developer Workflow with kraken-tools</a>
* <a href="#documentation">Documentation</a>    
    * <a href="#typos-and-minor-edits">Typos and minor edits</a>
    * <a href="#substantive-edits">Substantive edits</a>
* <a href="#additional-resources">Additional Resources</a>    
* <a href="#maintainer">Maintainer</a>    

# Workflows
Below we outline the workflows for contributing. We use GitHub to manage all contributions, so please [open an account](https://github.com/signup/free) if you don’t already have one.

## Start with Help Wanted
An easy way to start is to work on issues we’ve labeled as [“Help Wanted”](https://github.com/samsung-cnct/k2/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) because they:  
* Are easy to complete 
* Require little time and minimal context for kraken-lib 

To get started, [search Help Wanted issues](https://github.com/samsung-cnct/k2/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) and assign one to yourself, or add a comment to one so we can prevent multiple simultaneous contributors and help you out.

## Requesting New Features
Before requesting a new feature, please check open issues for any similar requests to avoid duplicates. When you don’t find any, simply [open an issue](https://github.com/samsung-cnct/k2/issues) and summarize the desired functionality of your requested feature. Provide as much detail as possible and reference related issues, if any.  And please apply the label 'Feature Request'.

## Reporting Bugs
To report a bug, [open an issue](https://github.com/samsung-cnct/k2/issues) and summarize the bug. To help us understand and fix it, please provide the following:
* Detailed steps to reproduce the bug 
* The version of kraken-lib you’re using
* The expected behavior
* The actual, incorrect behavior
* Apply the label 'Bug'

Search our [issue tracker](https://github.com/samsung-cnct/k2/issues) for existing issues (aka tickets) similar to yours. If you find one, please add your information to it as a comment.

If you want to provide a patch with your bug report, please do by sending us a pull request (PR) as described in the section below. 

## Issue Labeling ##
We use GitHub issue labels to help us organize our workflow. As such, this section is for helping the kraken development team push work through in an orderly fashion. If you choose to help out by labeling, great! If not, we will do it during our bi-weekly backlog grooming meetings.

### Required Labels ###
All issues must be labeled as one of the three following types. Ideally, the person creating the issue assigns the label at the time of creation. Otherwise, a label will be assigned in the next grooming meeting. The issue types are:
* Bug 
* Feature Request
* Research Spike

All issues must have a priority label applied as "priority-p[0-3]'. Use the following definitions when prioritizing issues: 
* **p0**: highest priority, most critical issues. p0 implies kraken-lib is broken and should have someone assigned immediately. If you believe you've hit a p0 issue, link the issue into the #kraken Slack channel (link at bottom of this page) so we can quickly triage.  
* **p1**: to be addressed in the next sprint or two. These issues will be completed regardless of larger project goals. 
* **p2**: will only be completed as part of a larger project (e.g. CI, multi-cluster support, code cleanup, etc.) and will be **triaged monthly** to reprioritize up or down. 
* **p3**: lowest priorty, will only be completed as part of a larger project and will be **triaged quarterly** to reprioritize up or close altogether.  

For all issues, commenting on why they're important to you may prompt reprioritizing upward or, so please speak up if you need something.

### Optional Labels ###
#### Projects ####
Some issues are part of larger projects or program areas, such as the creation of a new provider (e.g. BareMetal, Azure), fully supporting multiple clusters specified in a single config (multi-cluster support), CI, etc. Use a project label, as appropriate, to ensure we're working effectively by targeting a specific larger goal and heading towards completing the entire project.  

#### Help Wanted ####
Use this label for any issue not requiring much knowledge of the kraken-lib codebase and that can be completed in a few hours. These are a great place to get started.

#### Needs Design ####
This label should be applied to any issue requiring further analysis from an experienced kraken engineer and possibly a design proposal. Anyone can apply this label. We don't have a monitor for this label, so if you're interested in working in this area or have applied this label, please ping the #kraken Slack channel for support.

## Contributing Code and Making Changes
Before contributing code, please familiarize yourself with the [kraken codebase](https://github.com/samsung-cnct/k2cli) and our general guidelines below:

* Install [pre-commit](http://pre-commit.com/) to check your code against the ansible linter
* If you don’t know where to start, [browse for open issues and tasks](https://github.com/samsung-cnct/k2/issueshttps://github.com/samsung-cnct/k2/issues) or start with [Help Wanted issues](https://github.com/samsung-cnct/k2/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22), as mentioned above 
* After you find an issue, create a pull request following the PR process below
* Because we rely on CI and end-to-end tests to validate the integrity of the clusters we create, please monitor the results of CI jobs (available in the PR) to verify your code is passing
* Contribute to the kraken-lib codebase via GitHub pull requests (if any problems arise with the PR, we can discuss via GitHub comments)
* For small patches, feel free to submit PRs directly for those patches

# Using Pull Requests
Please submit all contributions as pull requests, using this process: 

1. Create a fork of the kraken-lib repo to your personal account (refrain from working in the kraken-lib master)
2. Create a topic branch from where you want to base your work
   * Usually your fork’s master branch
   * To quickly create a topic branch based on the master: 
     `git checkout -b fix/master/my_contribution master`
   * Avoid working directly on the master branch
3. Commit your changes to a topic branch in your fork
   * Check for unnecessary whitespace with `git diff --check before committing`
   * Make sure your commit messages are in the proper format
```
    Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied, the example commit message in the CONTRIBUTING
    document is not a concrete example. This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example. This patch fixes the
    problem by making the example concrete and imperative.

    Fixes: #<github issue number filed to describe the problem>
```
4. Submit a PR to the [kraken-lib repo](https://github.com/samsung-cnct/k2)
   * Address only one issue per PR 
   * For multiple issues, submit multiple PRs 
   * If your PR is related to or depends on an existing one, note the PR number(s) in your comment
   * All PRs must pass CI testing before approval
5. Once we approve your PR, we’ll merge it into the kraken-lib master

Our core team continuously reviews and monitors open PRs. We also assign reviewers to open PRs during weekly meetings. If your PR has been open for over a week with no one assigned, ping @coffeepac.

After the kraken team provides feedback, please respond within two weeks. After which, if the PR shows no activity, we may close the PR or take it over ourselves.

*See GitHub documentation for [creating pull requests](https://help.github.com/articles/creating-a-pull-request), [forking repos](https://help.github.com/articles/fork-a-repo) and [syncing forks](https://help.github.com/articles/syncing-a-fork), for more help with this process.*

# Recommended Dev Tooling 
You can access the recommended kraken-lib developer tool in the /hack directory. Called `dockerdev`, it that pulls down a [kraken-tools](https://github.com/samsung-cnct/k2-tools) image and lands the user into a Bash prompt with a number of useful host directories mounted into the container including the local kraken-lib checkout, `~/.ssh`, `~/.aws` and more depending on the config file used. 

The intent is to mitigate version issues and requirements, allowing you, the developer, to focus on coding and not worry about dependencies.

## Developer Workflow with kraken-tools
Here we document how to use kraken-tools to work with a cluster.

### Assumptions
* You’ve used either kraken-lib or kraken to generate a config file
* You’ve pulled the latest kraken-lib master branch on your machine and are working on a fork (`docker pull quay.io/samsung_cnct/kraken-tools`)
* You’re currently on the your local kraken-lib GitHub fork directory

### Steps
1. Generate latest configuration file, for example: `kraken generate`
1. Create a Docker container that points to you (and mount your kraken-lib workspace) cluster config (generated earlier):
`hack/dockerdev -c <PATH_TO_CONFIGS>/<YOUR_CONFIG>.yaml`
1. In 15 to 45 seconds, you will be in the Bash terminal of the container 
1. Bring up your cluster as you would normally when developing kraken-lib (including any flags you require):
`/bin/up.sh -c <PATH_TO_CONFIGS>/<YOUR_CONFIG>.yaml`

Now that you’ve mounted your workspace, you can make changes to kraken-lib here and access Git commands.

# Documentation

## Typos and Minor Edits
For changes of a trivial nature to comments and documentation, you don’t need to create a new issue. Just start the first line of a commit with '(doc)' instead of a ticket number.

```
    [doc] Add documentation commit example to CONTRIBUTING

    There is no example for contributing a documentation commit
    to the kraken-lib repository. This is a problem because the contributor
    is left to assume how a commit of this nature may appear.

    The first line is a real life imperative statement with '(doc)' in
    place of what would have been the ticket number in a
    non-documentation related commit. The body describes the nature of
    the new documentation or comments added.
```

## Substantive Edits 
For more substantive, content-related changes, commit your edits in your repo fork and create a PR for our team to review. 

# Additional Resources
Thanks again for your contributions! Here are some resources you might find handy:

* #kraken Slack on [k8s.slack.com](https://k8s.slack.com/)
* [kraken-lib issue tracker](https://github.com/samsung-cnct/k2/issues)
* [kraken-tools](https://github.com/samsung-cnct/k2-tools)
* [kraken codebase](https://github.com/samsung-cnct/k2cli)
* [General GitHub documentation](https://help.github.com/)
* [GitHub pull request documentation](https://help.github.com/articles/creating-a-pull-request/)

# Maintainer
This document is maintained by Patrick Christopher (@coffeepac) at Samsung SDS.

