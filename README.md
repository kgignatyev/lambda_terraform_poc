Note:
    utils/build_py_lambda.sh may need to be adjusted to use PIP if desired, now is using pip3
    
terraform/main.tf   lambda_role name need to be set for one in use

Deployment:
    
    cd terraform
    terraform init
    terraform apply --auto-approve
    
         
