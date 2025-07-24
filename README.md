
# ⚙️ CodePipeline with Terraform & DevSecOps using GitHub Actions and Kubernetes Sealed Secrets

This project sets up a fully automated CI/CD pipeline on AWS using **Terraform** and enhances it with **DevSecOps** practices powered by **GitHub Actions**. It provisions AWS infrastructure (CodePipeline, CodeBuild, CodeDeploy with EC2) and integrates security scans using `tfsec` and `Trivy`. Kubernetes Sealed Secrets are used to manage sensitive data securely.

---

## 🏛️ Project Architecture

> CI/CD with DevSecOps across GitHub Actions → AWS → EC2 & Kubernetes

---

## ✨ Features

- ⚙️ **End-to-End AWS CodePipeline**: Provisioned via Terraform with Source → Build → Deploy stages.
- 🚀 **CI/CD Automation**: GitHub Actions workflows for every code push.
- 🔐 **DevSecOps Integration**: `tfsec` for Terraform scanning, `Trivy` for Docker images.
- 🔑 **Secrets Management**: Kubernetes Sealed Secrets for secure K8s secrets handling.
- 🧪 **Infrastructure Testing**: Infrastructure validation using Terratest.
- ☁️ **Cloud-Native**: Leverages EC2, S3, IAM, and Kubernetes.
- 📦 **Dockerized App**: Vite + React frontend containerized and deployed.

---

## 💻 Tech Stack

| Category            | Tools / Platforms                                      |
|---------------------|--------------------------------------------------------|
| IaC                 | Terraform, Terratest                                   |
| Cloud               | AWS (CodePipeline, EC2, IAM, S3, CodeBuild, CodeDeploy)|
| DevSecOps           | tfsec, Trivy                                            |
| Secret Management   | Kubernetes Sealed Secrets (Bitnami)                    |
| CI/CD               | GitHub Actions                                         |
| Containers          | Docker, Kubernetes                                     |
| Languages           | Go (Terratest), YAML, HCL, Bash                        |

---

## ⚙️ Setup & Installation

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/anuska222/DevOps-Project.git
cd DevOps-Project
````

### 2️⃣ Configure AWS

```bash
aws configure
# Provide Access Key, Secret Key, region (ap-south-1), and default output (json)
```

### 3️⃣ Install Required Tools

* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [Go (for Terratest)](https://go.dev/dl/)
* [kubeseal CLI](https://github.com/bitnami-labs/sealed-secrets)
* Docker & kubectl

---

## 🧾 Terraform tfvars Example

Create a `terraform.tfvars` file with your project-specific values:

```hcl
project_name       = "devops-project"
bucket_name        = "devsecops-artifacts-bucket"
aws_region         = "ap-south-1"
ami_id             = "ami-xxxxxxx"
instance_type      = "t3.micro"
key_name           = "your-ec2-keypair"
github_owner       = "anuska222"
github_repo        = "DevOps-Project"
github_branch      = "main"
github_token       = "ghp_XXXX"
instance_tag_key   = "Name"
instance_tag_value = "DevSecOpsEC2"
```

> ⚠️ Never commit this file to your repo.

---

## 🔨 Terraform Execution

```bash
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```

---

## 🚀 GitHub Actions CI/CD

CI pipeline runs on each push to `main`:

### ✅ Workflow Steps

1. Validate Terraform syntax & run `tfsec`
2. Build Docker image and scan with `Trivy`
3. Encrypt secrets using `kubeseal`
4. Deploy to Kubernetes using `kubectl apply`

### Workflow File Location

```bash
.github/workflows/devsecops-pipeline.yml
```

---

## 🧪 Infrastructure Testing with Terratest

### ✅ Steps

1. Create a Go test file under `/test/terraform_pipeline_test.go`:

```go
package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestTerraformPipeline(t *testing.T) {
  t.Parallel()
  tf := &terraform.Options{
    TerraformDir: "../terraform",
  }
  defer terraform.Destroy(t, tf)
  terraform.InitAndApply(t, tf)
  pipeline := terraform.Output(t, tf, "codepipeline_name")
  assert.NotEmpty(t, pipeline)
}
```

2. Run Test

```bash
go mod init devsecops-test
go get github.com/gruntwork-io/terratest/modules/terraform
go get github.com/stretchr/testify/assert
go test ./test
```

---

## 🔐 Kubernetes Sealed Secrets

### 1. Generate Secret

```bash
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=pass123 \
  --dry-run=client -o yaml > secret.yaml
```

### 2. Encrypt with `kubeseal`

```bash
kubeseal --cert my-sealed-secrets-cert.pem -o yaml < secret.yaml > sealed-secret.yaml
```

Place it under `k8s/secrets/sealed-secret.yaml`

---

## 📁 Project Structure

```
DevOps-Project/
├── .github/workflows/
│   └── devsecops-pipeline.yml
├── terraform/
│   ├── main.tf, variables.tf, outputs.tf
├── test/
│   └── terraform_pipeline_test.go
├── k8s/
│   ├── secrets/
│   │   └── sealed-secret.yaml
│   └── manifests/
│       └── deployment.yaml
├── docker/
│   └── Dockerfile
├── examples/
│   ├── buildspec.yml, appspec.yml, scripts/
└── README.md
```

---

## 🧠 Common Errors & Fixes

| Problem                         | Fix                                                                  |
| ------------------------------- | -------------------------------------------------------------------- |
| `ImagePullBackOff` in K8s       | Ensure Docker image was pushed correctly or Kubernetes secret exists |
| `CodeDeploy HEALTH_CONSTRAINTS` | Make sure EC2 IAM role has correct S3 permissions                    |
| `Terraform Apply Failed`        | Recheck IAM role and bucket name conflicts                           |
| `tfsec` reports critical errors | Fix Terraform misconfigurations or use `ignore` annotations          |
| `Trivy` scan fails              | Fix Dockerfile vulnerabilities (or suppress with `.trivyignore`)     |

---

## 🧠 Contribution

We welcome contributions!

1. Fork the repo
2. Create a branch: `git checkout -b feature/xyz`
3. Make your changes
4. PR to `main`

---

## 📜 License

This project is licensed under the MIT License.

---

## 📧 Contact

**Author:** Anuska Pattnaik
**GitHub:** [github.com/anuska222](https://github.com/anuska222)

---

```

