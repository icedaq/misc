# Docker Meetup 17.02.2016

## Presentation

See [slides.pdf](slides.pdf)

## Demo

### Prerequisites

* Docker
* Kubernetes Cluster (See [here](https://github.com/pires/kubernetes-vagrant-coreos-cluster) how to run one using Vagrant/VirtualBox)

### Local Applications

In the demo I used docker to run two GUI applications inside a container. First we build the containers:

```sh
$ docker build -t tilda dockerfiles/tilda
$ docker build -t chromium dockerfiles/chromium
```

Before we can use the applications, we need to give them permissions to access our X server. The easy and stupid way to do this is ([the not stupid way](http://wiki.ros.org/docker/Tutorials/GUI)):

```sh
$ xhost +
```

Now run the containers. The run commands are stored inside the `run.sh` files:
```sh
$ dockerfiles/chromium/run.sh
$ dockerfiles/tilda/run.sh
```

To start with the next part, ssh from `tilda` into the host with the `kubectl` binary.

### Kubernetes

#### Proxy

To have a nice visualisation of what is going on, we first start the proxy for the Kubernetes API:

```sh
$ kubectl proxy --www=proxy/ --api-prefix=/api
```

To access it, open `http://127.0.0.1:8001/static` in chromium.

#### Image

The demo uses a two customized images. The sourcefiles can be found inside the folders `cassandra/image` and `client`. Make sure to build these images (using `docker build`) and make them available to your Kubernetes nodes. See [here](http://kubernetes.io/v1.0/docs/user-guide/images.html) for methods on how to do this. **Change the name of the images inside the cassandra replication controller, the `rolling-update` command and the `kubectl run` command**

#### Service & RC

Next we create our cassandra service and replication controller inside Kubernetes:

```sh
$ kubectl create -f cassandra/cassandra-service.yaml
$ kubectl create -f cassandra/cassandra-controller-custom.yaml
```

To check if everything worked, have a look at the proxy page. You should see 1 pod, 1 `cassandra-v6` replication controller and the `cassandra` service.

#### Insert data

Get the name of your pod and run `cqlsh` inside the pod:
```sh
$ kubectl get pods
$ kubectl exec -ti <PODNAME> -- cqlsh cassandra
```

Now we can insert some data. Execute these commands inside the `cqlsh`:

```sql
CREATE KEYSPACE demo WITH REPLICATION = { 'class' :
'SimpleStrategy','replication_factor' : 3 };

USE demo;

CREATE TABLE persons (
   user_id int PRIMARY KEY,
   firstname text,
   lastname text
);

INSERT INTO persons (user_id,  firstname, lastname)
      VALUES (1337, 'Pascal', 'Liniger');

SELECT * FROM persons;
quit
```

#### Client

We start accessing the data inside the database using the `golang` client (**ajust image name**):
```sh
$ kubectl run democlient --image=eu.gcr.io/meetup-1221/demo_client --restart=Never
$ kubectl logs -f democlient
```

#### Scale & Update

We now scale the replication controller and after that update it (**ajust image name**):

```sh
$ kubectl scale --replicas=3 rc cassandra-v6
$ kubectl rolling-update cassandra-v6 cassandra-v7 --image=eu.gcr.io/meetup-1221/cassandra-custom-v1 --update-period=30s
```

Check the progress of this using the proxy page.
