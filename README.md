<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/b14f5d11-c3a6-4465-84f5-e0a5e194f4ad" />



## AWS | Metabase
Metabase is an open-source Business Intelligence (BI) platform that lets you analyze data, run SQL queries, and build interactive dashboards without needing to develop a custom analytics application.



🎯 Architecture Overview
```
🔐 Security vulnerabilities — insecure code that attackers could exploit
🐛 Bugs — code likely to cause runtime problems
🧹 Code smells — code that is difficult to maintain or unnecessarily complex
📋 Duplicated code
🧪 Test coverage — how much code is covered by tests
📐 Code quality — maintainability and reliability
🔎 Security Hotspots — code that requires security review
```


🧱 Features
```
✔ Fully automated provisioning with Terraform
✔ High availability using multiple subnets in different Availability Zones
✔ Secure connectivity between Application and RDS
✔ Configurable environment variables for database credentials
✔ Easy to extend for other JSON data source
```



🚀 Deployment Options
```
terraform init
terraform validate
terraform plan -var-file="template.tfvars"
terraform apply -var-file="template.tfvars" -auto-approve
```

