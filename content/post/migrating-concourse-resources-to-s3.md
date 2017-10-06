---
title: "Migrating Concourse Resources to S3"
date: "2017-10-06"
tags:
  - concourse
---

One of the great things about Concourse is the [resource](http://concourse.ci/single-page.html#resources) abstraction it gives you for defining inputs and outputs to jobs in a pipeline. This abstraction allows you to redefine a resource while leaving the job that uses the resource unmodified. For example, if I have a resource, `my-source-code`, that normally is provided via a `git` resource:

```yaml
resources:
- name: my-source-code
  type: git
  source:
    uri: git@example.com/some-owner/some-repo.git
```

I can change that resource to be provided by S3 instead by changing the resource definition:

```yaml
resources:
- name: my-source-code
  type: s3
  source:
    bucket: some-bucket
```

Assuming the contents I put in that S3 bucket are the same as I would have gotten from git, the job should continue to work without being any the wiser.

In this post I'll talk about how to take an existing pipeline and migrate its resources to S3 in an automated way.

### Overview

The general idea is to create an artifact, typically a tarball, that can be placed in S3, and which contains the same contents that you'd get from the original resource type, for each resource the pipeline requires. You can even put the `image_resource` Docker image in S3!

After that, you need to modify your pipeline to switch out the old resource definitions for new S3 resource definitions. It's also a good idea to make any necessary changes to the `get` of those resources (for example, removing params that no longer apply).

We'll want to do this all programmatically, and we'll use Concourse to do it for us.

### Making a Pipeline to Put Resources in S3

While you could manually download the existing resource, create a tarball, and put that in S3 manually, that wouldn't be a good use of your time and is prone to errors. Instead, we can have Concourse do that for us.

The job structure for each resource is simple:

1. Do a `get` of the old, non-S3 resource
1. Create a versioned tarball from the contents of the downloaded resource's directory
1. Do a `put` to the `s3` resource with the tarball

This method results in putting a tarball in S3 that has the exact same contents that were pulled down via the non-S3 resource.

An example of a pipeline that does this for multiple resource types can be seen [here](https://github.com/pivotal-cf/pcf-pipelines/blob/master/download-offline-resources/pipeline.yml).

We'll use a git resource example:

```yaml
resources:
- name: some-resource
  type: git
  source:
    uri: git@example.com/some-resource.git
```

Its associated S3 resource looks something like this:

```yaml
- name: some-resource-s3
  type: s3
  source:
    access_key_id: some-access-key-id
    secret_access_key: some-secret-access-key
    bucket: some-bucket
    regexp: "resources/some-resource-v(.*).tgz"
```

This S3 resource is not using a versioned bucket, so it has a `regexp` field in the source that uses globs that the resource will use for determining new versions. See [here](https://github.com/concourse/s3-resource#file-names) for more explanation.

The resource's `bucket` and `regexp` fields are important as you need to use the same values in the pipeline that will consume this S3 resource.

The job that creates the tarball to be placed in S3 looks like this:

```yaml
jobs:
- name: copy-some-resource-to-s3
  plan:
  - get: some-resource
    trigger: true
  - get: some-resource-version
    params: {bump: major}
  - task: create-tarball
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: busybox
      inputs:
      - name: some-resource
      - name: some-resource-version
      outputs:
      - name: some-resource-tarball
      run:
        path: bash
        args:
        - -c
        - |
          set -eu
          version=$(cat some-resource-version/version)
          echo "Creating tarball with version v${version}..."
          tar czf "resources/some-resource-v${version}.tgz" -C some-resource .
  - put: some-resource-version
    params: {bump: major}
  - put: some-resource-s3
    params:
      file: "resources/some-resource-*.tgz"
```

*Note: This job uses a `semver` resource to create a semantic version for use in the tarball's filename. Some resource types will include a file that contains a compatible version, in which case you could just copy it over.*

This job follows the structure described above:

1. Do a `get` of the git resource, `some-resource`
1. Create a tarball from the contents of the downloaded resource's directory with a version
1. Do a `put` to the s3 resource, `some-resource-s3`, with the tarball

### Modifying a Pipeline to Use Resources From S3

Once you've got a pipeline that's pulling all your resources, packaging them up as tarballs, and putting them in S3, you'll want to modify the pipeline that uses those resources to actually pull resources from the new S3 locations.

The modifications to the pipeline will be:

1. Replace non-S3 resource definitions with new S3 resource definitions
1. Remove any unnecessary params from the `get`s of those resources

The best tool for doing this is [yaml-patch](https://github.com/krishicks/yaml-patch), a tool I wrote for modifying YAML documents.

Using `yaml-patch` to replace the `git` resource described above, we'd write a yaml-patch operation file ("opfile") like the following:

```yaml
- op: replace
  path: /resources/name=some-resource
  value:
    name: some-resource
    type: s3
    source:
      access_key_id: some-readonly-access-key-id
      secret_access_key: some-readonly-secret-access-key
      bucket: some-bucket
      regexp: "resources/some-resource-v(.*).tgz"
```

In this case there aren't any params that need to be modified, but if there were, we could do so with the following:

```yaml
- op: remove
  path: /jobs/get=some-resource/params/globs
```

This operation will remove the `globs:` entry from the `params:` of every job that does a `get` of the named resource.

*Note: This may leave an empty params hash, which Concourse ignores.*

Doing this in a pipeline would look something like the following:

```yaml
resources:
- name: yaml-patch
  type: github-release
  source:
    owner: krishicks
    repository: yaml-patch
    access_token: github-access-token

- name: standard-pipeline
  type: git
  source:
    uri: git@example.com/pipeline.git

- name: offline-pipeline
  type: git
  source:
    uri: git@example.com/offline-pipeline.git

jobs:
- name: apply-patch
  plan:
  - get: yaml-patch
  - get: standard-pipeline
    trigger: true
  - task: apply-patch
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: concourse/git-resource
      inputs:
      - name: yaml-patch
        globs: [*linux*]
      - name: standard-pipeline
      outputs:
      - name: modified-pipeline
      run:
        path: bash
        args:
        - -c
        - |
          set -eu

          chmod +x yaml-patch/yaml_patch_linux

          cat > opfile <<EOF
          - op: replace
            path: /resources/name=some-resource
            value:
              name: some-resource
              type: s3
              source:
                access_key_id: some-readonly-access-key-id
                secret_access_key: some-readonly-secret-access-key
                bucket: some-bucket
                regexp: "resources/some-resource-v(.*).tgz"
          EOF

          git clone ./standard-pipeline modified-pipeline

          cat standard-pipeline/pipeline.yml | yaml-patch/yaml_patch_linux -o opfile > modified-pipeline/pipeline.yml

          cd modified-pipeline

          git config --global user.email "user@example.com"
          git config --global user.name "Some User"
          git add -A
          git commit -m "Updated pipeline""
  - put: offline-pipeline
    params:
      repository: modified-pipeline

```

*Note: Since YAML maps don't preserve order you may find elements of your pipeline YAML are re-ordered after running them through yaml-patch. To fix this, you'll want to use the `fly` command `format-pipeline`: http://concourse.ci/single-page.html#fly-format-pipeline. This is a stylistic choice; the functionality is unaffected.*

*Note: To target the `image_resource` in a pipeline, use `/jobs/type=docker-image` as the path to replace.*

At this point you'll have two pipelines, one which pulls new versions of the resource(s) as they're detected, packages them up and puts them in S3, and another that automatically generates a version of your pipeline that pulls from S3 when a new version of the standard pipeline is pushed.

### Airgapped Environments

The above pipelines are sufficient for when you have an S3-compatible blobstore that you can access both from an environment with Internet access and one that does not. But what about when you have an environment that is completely offline and requires manual transfer of artifacts? In that case you'll want to create a single artifact that contains all of the resources the pipeline requires, including the pipeline itself, that you can move between environments manually.

To achieve this you'll want to extend your pipeline that creates the offline version of the pipeline to create a new artifact (again, a tarball) that contains all of the resource tarballs plus the pipeline YAML.

A working example of this can be seen in the `create-pcf-pipelines-combined` job [here](https://github.com/pivotal-cf/pcf-pipelines/blob/master/create-offline-pinned-pipelines/pipeline.yml).

This job:

1. Pulls the latest tarball for each resource from S3
1. Creates a SHA manifest for verification on the other side
1. Creates a single tarball with all of the other tarballs inside it
1. Encrypts the single tarball

Encrypting the tarball is optional, but it's a good security measure and ensures the bits haven't been tampered with during transfer.

This single tarball then needs to be copied into a location on the destination S3-compatible blobstore, where another pipeline can unpack it and put the contents in the correct bucket and path within S3. A working example of a pipeline that unpacks such an archive can be seen [here](https://github.com/pivotal-cf/pcf-pipelines/blob/master/unpack-pcf-pipelines-combined/pipeline.yml).

This pipeline:

1. Looks for new versions of the single tarball that contains the resource tarballs
1. Decrypts the tarball
1. Unpacks the tarball
1. Does SHA sum verification
1. Puts the resource tarballs in the locations within S3 referred to by the pipeline that has been modified to use S3

### Pinning Versions

You can go a few steps further than what was described above when modifying your pipeline to pull artifacts from S3. You may want to do testing on a set of resources with particular versions, and after you've done the testing modify your pipeline to pull *only those versions*. You can do this by pinning versions within the `get` of each resource.

The way to achieve this is via adding a [version](http://concourse.ci/single-page.html#image-resource-version) field to the `get`:

```yaml
# ...snip...
get: some-resource
version:
  path: "some-resource-v1.2.0.tar"
```

*Note: The above example is specific to pinning the version of an S3 resource; different resources require different fields and values.*

You can do the above with an opfile like this:

```yaml
- op: add
  path: /jobs/get=some-resource/version
  value:
    path: "some-resource-v1.2.0.tar"
```

*Note: To pin the version of the `image_resource`, use `/jobs/type=s3/version` after having modified the pipeline to use s3 as its `image_resource` type.*

I hope the information above is helpful in you translating your pipelines to pull from S3 rather than the existing resource types in as automated a fashion as possible.
