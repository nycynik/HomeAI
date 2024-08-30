# HomeAI
Docker compose and batch files for running local ai services

## Running local AI

simply run 

    ./bin/run-it.sh

to start the docker containers. then browse to [http://localhost:8080](http://localhost:8080)

## Terraform version

### Steps to Deploy with Terraform

Initialize Terraform:

    terraform init

Validate Configuration:

    terraform validate
    Plan the Deployment:

Plan:

    terraform plan

This will show you the actions Terraform will perform.

Apply the Configuration:

    terraform apply

Type yes to confirm the deployment and you are ready to go.




