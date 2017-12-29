# dockerkube
A Docker image that runs minikube inside

This image runs minikube using the 'local' VM driver. That means all the
kubernetes processes run on the host's resources, but in a container.

In order to work properly, you need to run the image with a few parameters
so that kubernetes has access to everything it needs:

$ docker run --privileged -v /lib/modules:/lib/modules ecejjar/dockerkube

Once up, you can run helm and kubectl inside the container:

$ kubectl exec -it <container-name> kubectl get all -n kube-system

Since security hasn't been patched yet, you cannot access kubernetes from
outside the container.

