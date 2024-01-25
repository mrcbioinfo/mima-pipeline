---
title: What is Container Image?
description: brief introduction to image Containers
weight: 10
---

## ...in a nutshell

A Container Image is an *image* file with packaged code (software applications) along with its dependencies (e.g., specific operating system, system libraries) that can be deployed consistently as a *container* in any environment. 

Since the image is unchangeable after it is built, it allows for consistent and repeatable deployment. For example, let's say an image was built with Ubuntu as the operating system, and you deploy this image on your Windows 11 PC (host). A Ubuntu *"container"* will be created and the programs inside this container will run under the Ubuntu settings.

Different *platforms* are available for building and deploying these container images, for example, <a href="https://apptainer.org/" target="_blank;">Apptainer</a>, <a href="https://sylabs.io/docs/" target="_blank">SingularityCE</a> or <a href="https://www.docker.com/" target="_blank">Docker</a>.

For the MIMA Pipeline we use Apptainer.

{{% alert colour='tip' title="Apptainer == Singularity" %}}
We recently changed to Apptainer from Singularity, any overlooked mention of 'Singularity' in the tutorials can be changed to 'Apptainer'.
{{% /alert %}}


## Noteworthy points

### Build a Sandbox

Every time you deploy a container from an image file (*.sif extension), the platform needs to unpack the system files each time. If the container is complex and have many dependencies or programs, this can be time consuming.

You can bypass this by building a **sandbox** that unpacks the files *once* into a directory (container in a directory) and then repeatedly use that directory. This removes the need to keep unpacking each time.

```Shell
apptainer build --sandbox <container-directory> <image.sif>
```

### Containers need explicit instructions to access your files {#path-binding}

A container is deployed with the bare minimum filesystem to operate, meaning that it only has access to your home directory by default.

It does not automatically have access to other filesystems or disks. If your data is located on another drive or path, then you need to explicitly provide this information using either

**Option 1)** `-B` parameter: the binding only exists during the life of the container

```Shell
apptainer run -B /home/jsmith/studyABC:/study/data,/srv/shared/refDB:/reference/data
```
**Option 2)** `APPTAINER_BIND` environmental variable: the binding exists during your terminal session (multiple deployed containers)

```Shell
export APPTAINER_BIND="/home/jsmith/studyABC:/study/data,/srv/shared/refDB:/reference/data"
```

The path binding format is: `<host-PC>:<container>` where the:

* Left of the colon (**:**) is the [absolute path]({{< ref "need-to-know.md#use-absolute-paths" >}}) of the directory found on the host PC
* Right of the colon (**:**) is the path that the *Container* sees when it's deployed

The above example:

| <div style="width:150px">Path on Host PC (left)</div> | <div style="width:150px">Path in Container (right)</div> | Description            |
|---------------------|-------------------|------------------------|
| `/home/jsmith/studyABC`    | `/study/data`       | The `studyABC` directory on the host PC is in the home directory of user jsmith (`/home/jsmith`).<br/> Applications running in the Container can access the data from `/study/data` |
| `/srv/shared/refDB`       | `/reference/data`   | The `refDB` directory on the hostPC is in a shared located `/srv/shared`.<br/> Applications running in the Container can access this data from `/reference/data` |


{{% alert color=warning title="Shortcuts/softlinks also need binding" pre="fa-solid fa-plus" %}}
If you have shortcuts or softlinks in your home directory pointing to elsewhere, you also need to bind the original locations using the `-B` parameter or the environment variable setting.
{{% /alert %}}

