## Bootstraping K3S Cluster via Terragrunt

k3s is a highly available and certified Kubernetes distribution designed with simplicity at its core. It is packaged as a single < 40MB binary that reduces the dependencies and time to set up a production-ready cluster. With a simple command, you can have a cluster ready in under approximately 30 seconds. 

* SQLite replaces etcd as the database.
* Traefik is the default Ingress Controller.
* ServiceLB is default LoadBalancer
* Local-Path provisioner is default also as shown below.

$  kubectl get storageclass  --kubeconfig=kubeconfig
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3h9m

# Requirements for Bootstraping k3s on GCP

1- k3sup is a lightweight utility to get from zero to production-ready cluster with k3s on any local or remote VM. All you need is ssh access and the k3sup binary. 
 $ curl -sLS https://get.k3sup.dev | sh
 
2- Download gcloud cli to authenticate GCP

k3sup requires an SSH key to access to a VM instance to do its job, we need to generate an SSH key and save the configuration into an SSH config file (~/.ssh/config).

$ gcloud compute config-ssh
By default, the SSH key is generated in ~/.ssh/google_compute_engine.

3- After this operation, we need to install terragrunt and terraform like as following

  $ Terragrunt Installation:
          $ wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.16/terragrunt_linux_amd64  
          $ mv terragrunt_linux_amd64 terragrunt 
          $ chmod u+x terragrunt 
          $ sudo mv terragrunt /usr/local/bin/terragrunt 
  
  $ Terraform Installation:
          $ sudo wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip 
          $s udo unzip terraform_0.12.2_linux_amd64.zip && sudo mv terraform /usr/local/bin/terraform
          

#  Terragrunt
  
   Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state.  Our backend and provider configuration is on the root section defined terragrunt.hcl which is so clean and dry by means of terragrunt.
   
   Also, remote state is protected  on the google cloud bucket defined terragrunt.hcl on the root section.
   
   Terragrunt is also so significant to manage many environment such as prod,dev,qa,stg together so easily.

You can see our terragrunt codes and structure on my terragrunt-iac folder. I seperated master node configuration from worker and infra section.

## Helm Deploy

  Flask application depends on mysql. Because of this, We have to deploy firstly mysql. I used bitnami repo to deploy mysql chart
  
$ helm repo add bitnami https://charts.bitnami.com/bitnami --kubeconfig=kubeconfig && \
$ helm upgrade -i mysql bitnami/mysql --set auth.rootPassword="${{ secrets.MYSQL_PASSWORD }}",auth.database="flask_database",global.storageClass="local-path" --kubeconfig=kubeconfig 

I put mysql_password Github Secret section as a secret. Moreover, by default, From the installation of the k3s cluster, local-path provisioner was deployed. I added global.storageClass parameter to helm command in order that mysql know storageclass name.  After deploying mysql helm chart, mysql pvc is bound. I handle persistence issue.

  Now, we can deploy our application. Gunicorn serves at port 3000 on our flask application. 
 
$ helm upgrade -i flask-app helm-manifests/  --set MYSQL_PASSWORD="${{ secrets.MYSQL_PASSWORD }}",image.tag=${{ github.run_number }}  --kubeconfig=kubeconfig

After successful helm deployment, my k3s cluster's pods and svc information is as following,

$ kubectl get pods  --kubeconfig=kubeconfig
NAME                           READY   STATUS    RESTARTS   AGE
mysql-0                        1/1     Running   0          3h13m
svclb-flask-chart-czrng        1/1     Running   0          168m
svclb-flask-chart-bzlrf        1/1     Running   0          168m
flask-chart-57f9d5545b-nkj4s   1/1     Running   0          164m

$ kubectl get svc  --kubeconfig=kubeconfig
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP               PORT(S)          AGE
kubernetes       ClusterIP      10.43.0.1       <none>                    443/TCP          5h50m
mysql-headless   ClusterIP      None            <none>                    3306/TCP         3h13m
mysql            ClusterIP      10.43.145.42    <none>                    3306/TCP         3h13m
flask-chart      LoadBalancer   10.43.199.167   10.186.0.22,10.186.0.25   8080:30198/TCP   3h13m

$ curl -vk 10.186.0.22:8080
* About to connect() to 10.186.0.22 port 8080 (#0)
*   Trying 10.186.0.22...
* Connected to 10.186.0.22 (10.186.0.22) port 8080 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: 10.186.0.22:8080
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: gunicorn/20.0.4
< Date: Sun, 09 Jan 2022 23:11:54 GMT
< Connection: close
< Content-Type: text/html; charset=utf-8
< Content-Length: 23
<
* Closing connection 0
Hello Devops 123, 1234!
   
## CICD

 I used Github Actions used for provisining k3s cluster, building our docker application and helm chart deployment to GCP . when my code is on the github, it is so easy to integrate with CI/CD by using github action. There are many predefined github action modules. By referring these modules, I can easily integrate with CI/CD. 
 
 You can find CI/CD pipeline in the .github/workflows/main.yml
   
   When your environment has many platforms such as AWS,Google Cloud,Openshift, I suggest you should use jenkins CI/CD tool. Because, Jenkins have so many plugins that integrate with so many platforms (AWS,Azure,Openshift,GKE etc). When your environment has only AWS platform, also, you can use AWS Codebuild,Codedeploy,Codepipeline resources. Your github account can easily sync to AWS and you can easily integrate your code with  codepipeline.  
