# kubernetes-dse
Deploy DataStax Enterprise (DSE) cluster on a Kubernetes cluster

This project provides a set of sample Kubernetes yamls to provision DataStax Enterprise in a Kubernetes cluster environment on various cloud platforms for experimental only. It uses "default" namespace in Kubernetes and sample cloud provider's storage class definition. You would modify the yamls according to your own deployment requirements such as namespace, storage device type, cloud provider zone, etc.

#### Prerequisites:
* Tools including wget, kubectl have already been installed on your machine to execute our yamls.
* Kubernetes server's version is 1.8.x or higher. 

#### 1. Create required configmaps for DataStax Enterprise Statefulset and DataStax Enterprise OpsCenter Statefulset
```
$ git clone https://github.com/DSPN/kubernetes-dse

$ cd kubernetes-dse

$ kubectl create configmap dse-config --from-file=common/dse/conf-dir/resources/cassandra/conf --from-file=common/dse/conf-dir/resources/dse/conf

$ kubectl create configmap opsc-config --from-file=common/opscenter/conf-dir/agent/conf --from-file=common/opscenter/conf-dir/conf --from-file=common/opscenter/conf-dir/conf/event-plugins

Sample opscenter.key and opscenter.pem are provided in the ssl folder for self-signed OPSC auth access.
$ kubectl create configmap opsc-ssl-config --from-file=common/opscenter/conf-dir/conf/ssl
```

#### 2. Create your own OpsCenter admin's password using K8 secret
You can update the [opsc-secrets.yaml file's admin_password's value](https://github.com/DSPN/kubernetes-dse/blob/dev-201808/common/secrets/opsc-secrets.yaml#L7) with your own base64 encoded password. Use this command **$ echo -n '\<your own password\>' | base64** to generate your base64 encoded password.
```
$ kubectl apply -f common/secrets/opsc-secrets.yaml 
```

#### 3. Choose one of the following four deployment options.

##### 3.1 Running DSE + OpsCenter locally on a laptop/notebook
*This yamls set uses emptyDir as DataStax Enterprise data store.*
```
$ kubectl apply -f local/dse-suite.yaml
```

##### 3.2 Running DSE + OpsCenter on Azure Container Service (AKS) [sample]
*This yamls set uses kubernetes.io/azure-disk provisioner along with Premium_LRS storage type on Azure*
```
$ kubectl apply -f aks/dse-suite.yaml
```

##### 3.3 Running DSE + OpsCenter on Amazon Elastic Container Service (EKS) in us-west-2a [sample]
*This yamls set uses kubernetes.io/aws-ebs provisioner along with ext4 filesystem type and IOPS per GB rate 10 in us-west-2a.  You will need to modify the StorageClass definition if you plan to deploy in different AWS zone.* 
```
$ kubectl apply -f eks/dse-suite.yaml
```

##### 3.4 Running DSE + OpsCenter on Google Kubernetes Engine (GKE) [sample]
*This yamls set uses kubernetes.io/gce-pd provisioner along with pd-ssd persistent disk type*
```
$ kubectl apply -f gke/dse-suite.yaml
```

#### 4. Access the DataStax Enterprise OpsCenter managing the newly created DSE cluster

You can run the following command to monitor the status of your deployment.
```
$ kubectl get all
```
Then run the following command to view if the status of **dse-cluster-init-job** has successfully completed.  It generally takes about 10 minutes to spin up a 3-node DSE cluster.
```
$ kubectl get job dse-cluster-init-job
```
Once complete, you can access the DataStax Enterprise OpsCenter web console to view the newly created DSE cluster by pointing your browser at https://<svc/opscenter-ext-lb's EXTERNAL-IP>:8443 with Username: admin and Password: **datastax1!** (if you use the default OpsCenter admin's password K8 secret)

#### 5. Tear down the DSE deployment
```
$ kubectl delete -f <your cloud platform choice>/dse-suite.yaml (the same yaml file you used in step three above)
$ kubectl delete pvc -l app=dse (to remove the dynamically provisioned persistent volumes for DSE)
$ kubectl delete pvc -l app=opscenter (to remove the dynamically provisioned persistent volumes for OpsCenter)
```