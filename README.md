## Repository to demo Trivy

This repository provides several examples, showcasing Trivy. Trivy is an open source security scanner.

You can find the introduction slides to Trivy here: [intro-slides](./intro-slides)

### Resources
- GitHub repository: https://github.com/aquasecurity/trivy
- Documentation: https://aquasecurity.github.io/trivy/latest/
- Slack Channel: https://slack.aquasec.com

### Presentations
- You can find the presentation for this repository here: https://aquasecurity-my.sharepoint.com/:p:/g/personal/anais_urlichs_aquasec_com/EdDjDXQ5-tNDrLm7AHpd_lEBkWjCsMzxcaoDmYZRtljCmg?e=UUAjgq

## Prerequisites
* WSL, Linux or Mac based Operating System
* Alternatively, use https://killercoda.com/ and their Ubuntu Playground environment

## Trivy CLI

Installation options: https://aquasecurity.github.io/trivy/latest/getting-started/installation/

Below are some of the commands that can be used through the Trivy CLI.

### GIT Repository Scans
[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/vulnerability/scanning/git-repository/)

You can scan any remote 
```
trivy repo <repo-name>
trivy repo https://github.com/Cloud-Native-Security/website
```

Pass a --branch argument with a valid branch name on the remote repository provided:
```
trivy repo --branch <branch-name> <repo-name>
trivy repo --branch example https://github.com/Cloud-Native-Security/website 
```

Pass a --tag argument with a valid tag on the remote repository provided:
```
trivy repo --tag <tag-name> <repo-name>
trivy repo --tag 0.0.1 https://github.com/Cloud-Native-Security/website 
```

Scan any GH repository for vulnerabilities:
```
trivy repo --vuln-type library https://github.com/Cloud-Native-Security/website
```

### Trivy fs scanning

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/target/filesystem/)

```
git clone git@github.com:Cloud-Native-Security/website.git
trivy fs website
```

`trivy repo` will scan both configuration files and source code; `trivy fs` will scan solely your source code.


### Vulnerability Scans

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/vulnerability/scanning/)

Scan a container image for vulnerabilities:
```
trivy image anaisurlichs/cns-website:0.2.5
```

Scan a container image for vulnerabilities but ignore all vulnerabilities that do not have a fix available:
```
trivy image --ignore-unfixed anaisurlichs/cns-website:0.2.5
```

**Note**
`--ignore-unfixed` relates to the [status of the vulnerabilities.](https://aquasecurity.github.io/trivy/v0.48/docs/configuration/filtering/#by-status)

Scan a container image for vulnerabilities but filter for HIGH and CRITICAL vulnerabilities
```
trivy image --severity HIGH,CRITICAL --vuln-type os postgres:10.6
```

As part of this scan, notice that Trivy also detects exposed Secrets in your Scan Targets:
```
/etc/ssl/private/ssl-cert-snakeoil.key (secrets)

Total: 1 (HIGH: 1, CRITICAL: 0)

HIGH: AsymmetricPrivateKey (private-key)
```

#### Trivy detects Misconfiguration on the container image

```
trivy image --image-config-scanners misconfig anaisurlichs/cns-website:0.2.5
```

### Misconfiguration Scans

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/misconfiguration/scanning/)
This section assumes that you are in the `trivy-demo/` repository. Otherwise, clone the repository and move into the repository:
```
git clone git@github.com:Cloud-Native-Security/trivy-demo.git
cd trivy-demo/
```

Scan all of your infrastructure configuration for vulnerabilities:
```
ls bad_iac
```

Scan your Dockerfile for vulnerabilities and misconfigurations:
```
trivy config website/Dockerfile
```

Scan your Kubernetes manifests for vulnerabilities and misconfigurations:
```
trivy config kubernetes-manifests
```

You can use the same flags from the other Trivy scans also into misconfiguration scanning to filter results:
```
trivy config --severity HIGH kubernetes-manifests
```

Scan your Terraform for vulnerabilities and misconfigurations:
```
trivy config bad_iac/terraform
```

Scan your CloudFormation resource for security issues:
```
trivy config CloudFormation
```

### Kustomize YAML misconfiguration scanning

While you can scan a Kustomize directory directly with Trivy, the scan output will not be as accurate than if you build the Kustomize deployment first.
```
trivy config ./kustomize
```

Or build the kustomize first:
```
kustomize build ./kustomize -o test.yaml

trivy config test.yaml
```

### Scan a binary

We can use Trivy to scan Trivy:
```
trivy rootfs ./binary
```

### Custom Policies with Rego

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/misconfiguration/custom/)

Trivy makes it possible to scan custom policies defined in Rego.

The following file provides a custom policy that compares a Kubernetes deployment and a Kubernetes service. It then scans them to see whether they have the same selectors applied:
```
cat custom-policies/combine-yaml.rego
```

The following command will run the scan:
```
trivy conf --severity CRITICAL --policy ./custom-policies/combine-yaml.rego --namespaces user ./kubernetes-manifests
```

### Trivy Cloud | Trivy AWS
[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/cloud/aws/scanning/)

See all the options to scan your AWS services by running the following command:
```
trivy aws --help 
```

Perform an account wide scan:
```
trivy aws  
```

The cache is naturally saved for 24h. This makes scanning your resources again or looking in detail at specific services much quicker:
```
trivy aws --update-cache 
```

Alternatively, you can also specify a max-cache age:
```
trivy aws --max-cache-age 12h 
```

By default, Trivy will either connect with your configured default region or by the region in your ENV variable. However, you can also scan any other region with the 
```
trivy aws --region eu-central-1
```

Alternatively to scnaning your entire cluster or once you have scanned your entire cluster, you can also look at specific services:
```
trivy aws --region eu-central-1 --service ec2 
```

Next, you can look at a specific service by specifying the arn:
```
trivy aws --region eu-central-1 --service ec2 --arn arn:aws:ec2:eu-central-1:XXXXXXXXXXXX:vpc/vpc-00ce30b51ebebb314 
```

OR by specifying the `--format` should be json:
```
trivy aws --region eu-central-1 --format json --service ec2 
```

Jless is a great tool to view the output better:
```
trivy aws --region eu-central-1 --format json --service ec2 | jless 
```

You can also scan myltiple different services at once:
```
trivy aws --region us-east-1 --service s3 --service ec2
```

### Scan your connected Kubernetes cluster

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/target/kubernetes/)

Note: This section will change in the upcoming Trivy releases.

If you don't have access to a Kubernetes cluster, quickly spin up a [KinD cluster:](https://kind.sigs.k8s.io/)
```
kind create cluster --name trivy-demo
```

The Trivy Kubernetes command scans any connected Kubernetes cluster for vulnerabilities, misconfigurations, exposed secrets and more.

To scan your entire cluster and receive a summary report use the following command:

```
trivy k8s --report summary cluster
```

Note that this command my take some time to run, depending on your cluster size. What you could do to speed up the scanning is to only check for misconfiguration:
```
trivy k8s --report summary --scanners misconf cluster
```

Or to only check for vulnerabilities:
```
trivy k8s --report summary --scanners vuln cluster
```

To scan a specific namespace in your cluster and receive a summary report use the following command:
```
trivy k8s --namespace kube-system --report summary cluster
```

To receive a detailed report, you can use the `--report=all` flag. However, we would advice to only do that on specific namespaces or resources since you will be provided with a lot of detailed information:
```
trivy k8s --namespace kube-system --report all cluster
```

Similar to vulnerabilities, we can also filter in-cluster for specific vulnerabilty types:
```
trivy k8s --severity=CRITICAL --report all cluster
```

With the trivy K8s command, you can also scan specific workloads that are running within your cluster.

First install the workload:
```
kubectl apply -f kubernetes-manifests
```

And then scan it for security issues:
```
trivy k8s --report=summary --namespace default deploy react-application
```

### KBOM 

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/target/kubernetes/#kbom)

Generate the KBOM:
```
trivy k8s cluster --format cyclonedx --output mykbom.cdx.json
```

Scan the KBOM for security issues:
```
trivy sbom mykbom.cdx.json
```

Scan the Kubernetes Infrastructure directly for security issues:

```
trivy k8s cluster --scanners vuln  --report summary
```

## Trivy Operator

[**Documentation**](https://aquasecurity.github.io/trivy-operator/latest)

While you would use the Trivy CLI on your local machine or from within a CI/CD pipeline, the Trivy operator is installed inside your Kubernetes cluster. From there, it performs continuous scanning of your Kuberentes resources.
Have a look at the documentation for more information:

Installation options: https://aquasecurity.github.io/trivy-operator/v0.0.8/

### Scan your connected Kubernetes cluster

Once the operator is installed, you will see it running in the Trivy System namespace:
```
kubectl get all -n trivy-system
```

Now, we can install a deployment. If you do not have a deployment within your cluster, you can use our example application:
```
kubectl apply -f kubernetes-manifests 
```

Trivy will then automatically scan new deployments:
```
kubectl get vulnerabilityreports --all-namespaces -o wide
```

Inspect created ConfigAuditReports by:
```
kubectl get configauditreports --all-namespaces -o wide
```

To get detailed information on the vulnerabilities, describe the Vulnerabilityreports:
```
kubectl describe Vulnerabilityreports replicaset-react-application-79694589b9-react-application
```

## Trivy Config

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/references/customization/config-file/)

The Trivy Config allows us to define the configurations for our security scans in a YAML manifest. An example is provided in this repository within [./trivy-config.yaml](./trivy-config.yaml)

You can then use the config manifest in your security scans such as your image vulnerability scans:

```
trivy image --config ./trivy-config/default.yaml node:14
```

## Trivy SBOM & Attestation

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/sbom/)

For more information watch the following tutorials:

1. [Generate SBOMs with Trivy & Scan SBOMs for vulnerabilities](https://youtu.be/Kibk6qq7ZCs)
2. [Creating an SBOM Attestation with Trivy and Cosign from Sigstore](https://youtu.be/nF15vzo5Gts)

Trivy can generate SBOMs in the following three formats SPDX, SPDX-json, and CycloneDX.

Command structure:
```
trivy image --format <spdx,spdx-json,cyclonedx> -o <sbom.spdx,sbom.spdx.json,sbom.json> <IMAGE> 
```

Example:
```
trivy image --format spdx -o sbom.spdx anaisurlichs/cns-website:0.0.6 
```

An attestation can be generated with Cosign and in-toto. For this, first generate a key-pair with Cosign:
```
cosign generate-key-pair
```

Creater the attestation fo the SBOM with your private-key with the following structure:
```
cosign attest --key /path/to/cosign.key --type spdx --predicate sbom.spdx <IMAGE>
```

Example:
```
cosign attest --key ./cosign.key --type spdx --predicate sbom.spdx anaisurlichs/cns-website:0.0.6 
```

Verify the attestation with your public key:
```
cosign verify-attestation --key /path/to/cosign.pub --type spdx <IMAGE> 
```

Following the example again:
```
cosign verify-attestation --key cosign.pub --type spdx anaisurlichs/cns-website:0.0.6
```

## Ignore Values

Works:
```
trivy fs --security-checks config --ignore-policy ./policies/ignore/ignore.rego ./bad_iac
```

Does not work
```
trivy config --ignore-policy ./policies/ignore/ignore.rego ./bad_iac
```

## Terraform Plan and Scan Plan File
[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/kubernetes/cli/scanning/)

```bash
cd bad_iac/terraform
```

```bash
terraform init

terraform plan --out tfplan.binary

terraform show -json tfplan.binary > tfplan.json
```

```bash
trivy config ./tfplan.json
```

## Trivy SBOM and VEX

Generate the SBOM

```
trivy image --format cyclonedx --output debian11.sbom.cdx debian:11
```

Create a VEX based on the SBOM generated in step 1

Provide the VEX when scanning the CycloneDX SBOM

```
trivy sbom --vex vex/trivy.vex.cdx debian11.sbom.cdx
```

## Trivy License Scanning

[**Documentation**](https://aquasecurity.github.io/trivy/latest/docs/scanner/license/)

Scan the licenses used in a container image:
```
trivy image --scanners license --severity UNKNOWN,HIGH,CRITICAL alpine:3.15
```

Full license scanning:
```
trivy image --scanners license --severity UNKNOWN,HIGH,CRITICAL --license-full grafana/grafana
```

### Ignore specific licenses

Ignore a specific license through the CLI:
```
trivy image --scanners license --ignored-licenses MPL-2.0,MIT --severity HIGH grafana/grafana:latest
```

Or through the trivy.yaml manifest:
```
trivy image --scanners license --config trivy-config/license.yaml grafana/grafana:latest
```

### Filter licenses

Some fancy jq command:
```
trivy fs . --scanners license --license-full --format json | jq '[.Results[] | .Licenses//empty | .[]] | group_by(.Name) | .[] |{"license":.[1].Name, "findings":map(if .PkgName=="" then .FilePath else .PkgName end)}'
```

## Install the Trivy Operator in Client Server Mode

Tutorial: LINK 

helm install trivy-operator ./deploy/helm \
     --namespace trivy-system \
     --create-namespace \
     --values ./trivy-operator-values/client-server-mode.yaml