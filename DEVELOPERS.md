# Developer documentation

This document summarizes information relevant to K2 committers and contributors.  It includes information about
the development processes and policies as well as the tools we use to facilitate those.

---

Table of Contents

* <a href="#welcome">Welcome!</a>
* <a href="#workflow-and-policies">Workflows</a>
    * <a href="#report-bug">Report a bug</a>
    * <a href="#request-feature">Request a new feature</a>
    * <a href="#contribute-code">Contribute code</a>
        * <a href="#recommended-dev-tooling">Recommended Dev Tooling</a>
    * <a href="#contribute-documentation">Contribute documentation</a>
    * <a href="#pull-requests">Pull requests</a>
        * <a href="#create-pull-request">Create a pull request</a>
        * <a href="#approve-pull-request">Approve a pull request</a>
        * <a href="#merge-pull-request">Merge a pull request or patch</a>
* <a href="#questions">Questions?</a>

---

<a name="welcome"></a>

# Welcome!

If you are reading this document then you are interested in contributing to the K2 project -- many thanks for that!
All contributions are welcome: ideas, documentation, code, patches, bug reports, feature requests, etc.  And you do not
need to be a programmer to speak up.


# Workflows

This section explains how to perform common activities such as reporting a bug or merging a pull request.


<a name="report-bug"></a>

## Report a bug

To report a bug you should [open an issue](https://github.com/samsung-cnct/k2/issues) in our issue tracker that
summarizes the bug.  If you have not used github before you will need to register an account (free), log in, and 
then click on the "New Issue" button.

In order to help us understand and fix the bug it would be great if you could provide us with:

1. The steps to reproduce the bug.  This includes information about e.g. the K2 version you were using.
2. The expected behavior.
3. The actual, incorrect behavior.

Feel free to search the issue tracker for existing issues (aka tickets) that already describe the problem;  if there is
such a ticket please add your information as a comment.

**If you want to provide a patch along with your bug report:**
That is great!  In this case please send us a pull request as described in section _Create a pull request_ below.
You can also opt to attach a patch file to the issue ticket, but we prefer pull requests because they are easier to work
with.


<a name="request-feature"></a>

## Request a new feature

To request a new feature you should [open an issue](https://github.com/samsung-cnct/k2/issues) in github
and summarize the desired functionality. If you have not used github before you will need to register an account (free), 
log in, and then click on the "New Issue" button.

<a name="contribute-code"></a>

## Contribute code

Before you set out to contribute code we recommend that you familiarize yourself with the K2 codebase.

_If you are interested in contributing code to K2 but do not know where to begin:_
In this case you should
[browse our issue tracker for open issues and tasks](https://github.com/samsung-cnct/k2/issues).
You may want to start with beginner-friendly, easier issues
([help wanted](https://github.com/samsung-cnct/k2/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22)
because they require learning about only an isolated portion of the codebase and are a relatively small amount of work.

Please install [pre-commit](http://pre-commit.com/) to check your code against the ansible linter.

Contributions to the K2 codebase should be sent as GitHub pull requests.  See section _Create a pull request_ below
for details.  If there is any problem with the pull request we can iterate on it using the commenting features of
GitHub.

* For _small patches_, feel free to submit pull requests directly for those patches.
* For _larger code contributions_, please use the following process. The idea behind this process is to prevent any
  wasted work and catch design issues early on.

    1. [Open an issue](https://github.com/samsung-cnct/k2/issues) on github if a similar issue does not
       exist already.  If a similar issue does exist, then you may consider participating in the work on the existing
       issue.
    2. Comment on the issue with your plan for implementing the issue.  Explain what pieces of the codebase you are
       going to touch and how everything is going to fit together.
    3. K2 committers will iterate with you on the design to make sure you are on the right track.
    4. Implement your issue, create a pull request (see below), and iterate from there.


### Recommended Dev Tooling 
The recommended K2 Developer Tool can be accessed in the `/hack` directory and is called `dockerdev`, a tool that pulls down a  [k2-tools](https://github.com/samsung-cnct/k2-tools) image. 
The container will provide you with a console that contains the correct environment for developing and running k2. The intent is to mitigate version issues and 
requirements, allowing you the Developer to focus on coding and not worry on dependencies.

#### Developer Workflow with K2-Tools
Here we document how a developer would use k2-tools to work with a cluster.

##### Assumptions
* You have used either K2 or k2cli to generate a config file.
* You have pulled the latest k2 master branch on your machine, and are working on a fork. 

```
docker pull quay.io/samsung_cnct/k2-tools
```

* You are currently on the your local k2 github fork directory

##### Steps
* Generate latest configuration file, for example:

```
k2cli generate
```

* Next we should create a docker container that points to you (and mount your k2 workspace) cluster config (generated earlier)

```
hack/dockerdev -c <PATH_TO_CONFIGS>/<YOUR_CONFIG>.yaml
```

* After some time, you will be in the bash terminal of the container, bring up your cluster
as you would normally when developing k2 (including any flags you require).:

```
/bin/up.sh -c <PATH_TO_CONFIGS>/<YOUR_CONFIG>.yaml
```

At this point since you have mounted your workspace, you should be able to make changes to k2 here and even access git commands.

### Testing

All pull requests must pass integration testing.

<a name="contribute-documentation"></a>

## Contribute documentation

Documentation contributions are very welcome!

You can contribute documentation by pull request, as same as code contribution.
Main directory is ```Documentation/```.

<a name="pull-requests"></a>

## Pull requests


<a name="create-pull-request"></a>

### Create a pull request

Pull requests should be done against the read-only git repository at
[https://github.com/samsung-cnct/k2](https://github.com/samsung-cnct/k2).

Pull requests must only address one issue. For multiple issues, submit multiple pull requests. If a pull request depends on another
pull request, add a comment explaining that.

Take a look at [Creating a pull request](https://help.github.com/articles/creating-a-pull-request).  In a nutshell you
need to:

1. [Fork](https://help.github.com/articles/fork-a-repo) the K2 GitHub repository at
   [https://github.com/samsung-cnct/k2/](https://github.com/samsung-cnct/k2/) to your personal GitHub
   account.  See [Fork a repo](https://help.github.com/articles/fork-a-repo) for detailed instructions.
2. Commit any changes to your fork.
3. Send a [pull request](https://help.github.com/articles/creating-a-pull-request) to the K2 GitHub repository
   that you forked in step 1.  If your pull request is related to an existing K2 issue -- for instance, because
   you reported a bug report earlier -- then mention that your pull request `fixes #123` in the description.

You may want to read [Syncing a fork](https://help.github.com/articles/syncing-a-fork) for instructions on how to keep
your fork up to date with the latest changes of the upstream (official) `K2` repository.


<a name="approve-pull-request"></a>

### Approve a pull request

A pull request must pass CI testing and be reviewed by a core committer with a LGTM. If changes are requested, those must be addressed.

<a name="merge-pull-request"></a>

### Merge a pull request or patch

_This section applies to committers only._

**Important: A pull request must first be properly approved before you are allowed to merge it.**

To pull in a merge request you should generally follow the command line instructions sent out by GitHub.

Squash pull requests when merging.

<a name="questions"></a>

# Questions?

If you have any questions after reading this document, then please reach out to us.

And of course we also welcome any contributions to improve the information in this document!
<a name="workflow"></a>

