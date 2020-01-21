---
title: "Pipeline Design with Concourse"
date: "2017-01-07"
summary: My thought process when developing a CI pipeline in Concourse.
---

![Goulash Pipeline](/goulash-pipeline.png "Goulash Pipeline in Concourse")

I recently made a CI/CD pipeline in [Concourse](https://concourse.ci) for deploying [Goulash](https://github.com/pivotalservices/goulash/). The pipeline definition can be found [here](https://github.com/pivotalservices/goulash/blob/master/ci/pipeline.yml).

Figuring out how to split up the work your pipeline needs to do in jobs and tasks in Concourse is not always obvious. The way you define jobs and tasks will determine how repeatable steps in your pipeline are, how fast jobs run, and how easily you can debug tasks.

In this post I will describe how I came to the job and task definitions in the pipeline for Goulash.

First, what does the pipeline do?

On every push of code to the master branch, the pipeline automatically:

* Installs the vendored dependencies for the code
* Runs unit tests
* Builds a release candidate binary
* Bumps the release candidate version (1.0.1-rc.1 -> 1.0.1-rc.2)
* Builds a tarball with the binary in it
* Uploads the tarball to a release candidate Google Cloud Storage bucket
* Deploys the binary in the tarball to a staging environment in Cloud Foundry

When manually triggered, the pipeline:

* Downloads the latest release candidate tarball
* Unpacks the tarball
* Finalizes the release candidate version (1.0.1-rc.2 -> 1.0.1)
* Uploads the release candidate tarball to a final release GCS bucket
* Creates a GitHub release with the final release tarball
* Deploys the binary in the tarball to the production environment in Cloud Foundry

Attributes which were important to me in developing this pipeline:

* I wanted the same exact bits to be used for running tests and building the binary.
* I wanted the same exact binary to be deployed to both the staging and production environment. *(N.B. The binary is exactly the same in this case because it has no internal versioning)*
* I wanted to be able to redeploy the binary to staging or production on demand without having to re-run other parts of the pipeline.
* I wanted it to be as fast as possible.

Additionally, from a pipeline maintenance standpoint:

* I wanted to be able to [execute](http://concourse.ci/fly-execute.html) tasks on the fly when necessary (for debugging, usually).
* I wanted tasks to be generic where possible, so they could be shared by different jobs.

Below, I'll expand a bit on some of these.

## Defining jobs

For this pipeline I diverged from how I've done things in the past with respect to running unit tests and building release artifacts.

In the past I would have made a job for running unit tests which does just that, with the thinking that the job should be focussed on doing one thing only. It shouldn't also build the binary, upload it somewhere, etc.

With this pipeline I built the jobs thinking more holistically about what each job represents.

There is a job, `create-rc`, which creates a release candidate. What does it mean to create a release candidate? It means:

1. run the tests
1. create a binary
1. create a tarball with the binary in it
1. put the tarball somewhere

This approach makes the pipeline more understandable from a higher level, as the tasks which are required to create a release candidate are contained within a single job. It also allows me to easily share exact bits between tasks. Sharing bits between jobs means putting them in a resource, which I feel is a bit heavy-handed. I don't want to have to create additional resources *purely* to share bits between jobs.

## Sharing bits between tasks

Concourse runs each task in a container. One job may have many tasks. Each task may define [outputs](http://concourse.ci/running-tasks.html#outputs) which downstream tasks in the same job may use.

My tasks that run unit tests and build the binary are independent, but share the same bits. To ensure the same bits are used, I defined three tasks:

1. install-dependencies
2. unit
3. build

The `install-dependencies` [task](https://github.com/pivotalservices/goulash/blob/master/ci/install-dependencies.yml) defines an [output](http://concourse.ci/running-tasks.html#outputs), `goulash-with-dependencies`, that both `unit` and `build` get as copy-on-write volumes. This ensures they operate on the same bits, and cannot change the bits in such a way as to affect the other task.


## Making it fast

The reason `unit` and `build` are split into two tasks is for two reasons:

1. Running unit tests is not dependent on building the binary, nor is building the binary dependent on running unit tests
2. They can be run in [aggregate](http://concourse.ci/aggregate-step.html), which makes the job faster

Whenever I define a job I look at what tasks can be run in aggregate to make the job faster. Generally, the initial `get` steps in a job can be run concurrently; they just set up resources for downstream tasks. There may be other tasks, like `unit` and `build` above, that also make sense to run concurrently.

## Making tasks generic where possible

Wherever possible, I make generic tasks so I can re-use them.

My pipeline has a task, `unpack-release`, which is shared by both `deploy-staging` and `deploy-production`. The task is simple: it takes a release tarball (which is specific to this pipeline) as an input and gives the unpacked result as an output named `unpacked-release`.

In Concourse, when you `get` a resource, the name of the resource is what is used as the directory the resource's volume is mounted to in the task container. The following `get` will result in a volume mounted as `goulash-rc` in downstream task containers:

```
    - get: goulash-rc
      ...
```

You can override this by using the [resource](http://concourse.ci/get-step.html#resource) attribute on the `get` step. When you do this, the value passed to `get:` is what is used as the directory to mount the resource specified by `resource:`.

```
    - get: release
      resource: goulash-rc
      ...
```

The generic task wants an input called "release"; it doesn't need to know that the release is actually "goulash-rc".

A later task in the same job knows about the outputs from `unpack-release`, and uses that path:

```
  - put: goulash-staging
    params:
      manifest: goulash/manifests/staging.yml
      path: unpacked-release
      ...
 ```

*N.B. You can also use [input_mapping](https://concourse.ci/task-step.html#input_mapping) to achieve a similar result. `input_mapping` differs in that in renames the resources for only a specific task rather than for all downstream tasks.*
 
Additionally, to avoid duplicating the definition of the generic task in the pipeline YAML, the definition has been split into its [own file](https://github.com/pivotalservices/goulash/blob/master/ci/unpack-release.yml) by using the [file](http://concourse.ci/task-step.html#file) attribute on the task step.

## Running tasks on the fly

To [execute](http://concourse.ci/fly-execute.html) a task on the fly, you need to separate its definition from the declaration in the pipeline YAML.

You do this by specifying the [file](http://concourse.ci/task-step.html#file) attribute in the task declaration in the pipeline that points to a [task YAML](http://concourse.ci/running-tasks.html#configuring-tasks).
