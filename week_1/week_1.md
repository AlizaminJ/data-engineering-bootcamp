# Week 1

# DOCKER & POSTGRES
<br>

Data can be found on https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page , 2021-jan "yellow taxi trips":
```
https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.parquet
```

## running in docker
### network
- first create a network
```
docker network create pg-network
```

### db
- run postgres, only named volumes work, see https://stackoverflow.com/a/63495668/13019344
```
# named volume
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v POSTGRES_DATA:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:13
```    

### pgAdmin
- run pgAdmin which comes with GUI in docker instead of pgcli, check the connection 
```
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -v PGADMIN_DATA:/var/lib/pgadmin \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4
```

- configure server in pgAdmin, "pg-database" is your host!

### if cli for Postgres instead of pgAdmin

- Installing pgcli
```
pip install pgcli
```
- If you have problems installing pgcli with the command above, try this:
```
conda install -c conda-forge pgcli
pip install -U mycli
```
- Using pgcli to connect to postgres
```
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

### ingestion 

#### running locally
```
URL='https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.parquet'

python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5432 \
  --db=ny_taxi \
  --table_name=yellow_taxi_trips \
  --url=${URL}
```

#### running in docker

- build the image
```
docker build -t taxi_ingest:v001 .
```

- run the image
```
URL='https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.parquet'

docker run -it \
    --network=pg-network \
    taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```

## docker compose
```
docker-compose up
docker-compose down
```


## useful commands
```
jupyter nbconvert --to script notebook.ipynb
```

```
head -n 100  all_data.csv > crop.csv
wc -l  crop.csv
```

```
docker run -it --entrypoint=bash python:3.9
docker exec -it <mycontainer> bash
docker run -it MY_CONTAINER:1.0
docker  build -t MY_IMAGE:1.0 .
```

<br>
<hr>
<br>

# GCP & TERRAFORM

Pre-Requisites
- Terraform client installation: https://www.terraform.io/downloads
- Cloud Provider account: https://console.cloud.google.com/


## Google CLoud Platform

- <a href="https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_1_basics_n_setup/1_terraform_gcp/2_gcp_overview.md">Setup</a>

- GCP Services
<img src="https://static.packt-cdn.com/products/9781788837675/graphics/assets/23d1d5bf-3655-464e-964c-96be3a490893.png">

- use the following in WSL for initialization instead of "gcloud auth application-default login"
```
gcloud init --console-only
```

## Terraform
<a href="https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/week_1_basics_n_setup/1_terraform_gcp"> Setup</a>

### Concepts

#### Introduction

1. What is [Terraform](https://www.terraform.io)?
   * open-source tool by [HashiCorp](https://www.hashicorp.com), used for provisioning infrastructure resources
   * supports DevOps best practices for change management
   * Managing configuration files in source control to maintain an ideal provisioning state 
     for testing and production environments
2. What is IaC?
   * Infrastructure-as-Code
   * build, change, and manage your infrastructure in a safe, consistent, and repeatable way 
     by defining resource configurations that you can version, reuse, and share.
3. Some advantages
   * Infrastructure lifecycle management
   * Version control commits
   * Very useful for stack-based deployments, and with cloud providers such as AWS, GCP, Azure, K8S…
   * State-based approach to track resource changes throughout deployments


#### Files

* `main.tf`
* `variables.tf`
* Optional: `resources.tf`, `output.tf`
* `.tfstate`

#### Declarations
* `terraform`: configure basic Terraform settings to provision your infrastructure
   * `required_version`: minimum Terraform version to apply to your configuration
   * `backend`: stores Terraform's "state" snapshots, to map real-world resources to your configuration.
      * `local`: stores state file locally as `terraform.tfstate`
   * `required_providers`: specifies the providers required by the current module
* `provider`:
   * adds a set of resource types and/or data sources that Terraform can manage
   * The Terraform Registry is the main directory of publicly available providers from most major infrastructure platforms.
* `resource`
  * blocks to define components of your infrastructure
  * Project modules/resources: google_storage_bucket, google_bigquery_dataset, google_bigquery_table
* `variable` & `locals`
  * runtime arguments and constants


#### Execution steps
1. `terraform init`: 
    * Initializes & configures the backend, installs plugins/providers, & checks out an existing configuration from a version control 
2. `terraform plan`:
    * Matches/previews local changes against a remote state, and proposes an Execution Plan.
3. `terraform apply`: 
    * Asks for approval to the proposed plan, and applies changes to cloud
4. `terraform destroy`
    * Removes your stack from the Cloud

## Execution
```
# Refresh service-account's auth-token for this session
gcloud auth application-default login

# Initialize state file (.tfstate)
terraform init

# Check changes to new infra plan
terraform plan -var="project=<your-gcp-project-id>"

# Create new infra
terraform apply -var="project=<your-gcp-project-id>"

# Delete infra after your work, to avoid costs on any running services
terraform destroy
```
<br>
<hr>
<br>