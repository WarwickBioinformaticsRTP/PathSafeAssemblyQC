# PathSafeAssemblyQC

Running the pathsafeQC pipeline requires two singularity sandbox containers to be created. Assuming singularity is installed these can be created using the commands below. Note it will take  some time (a couple of hours) to create the sandboxes and install all dependencies specified in the definition files "pathsafeQC_container1.def" and "pathsafeQC_container2.def". Both sandboxes will run Ubuntu 20.04 as the underlying OS.

```
#Build sandbox 1:
singularity build --sandbox --fakeroot --fix-perms pathsafeQC_container1 pathsafeQC_container1.def

#Build sandbox 2:
singularity build --sandbox --fakeroot --fix-perms pathsafeQC_container2 pathsafeQC_container2.def

# --sandbox = create sandbox environment i.e. a directory that can be entered, files created etc
# --fakeroot --fix-perms = overcomes lack of sudo permissions
```
