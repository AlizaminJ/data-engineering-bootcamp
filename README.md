# data-engineering-bootcamp
 A bootcamp with the support of DataTalks.Club

- data can be found on https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page , 2021-jan "yellow taxi trips":
```
https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.parquet
```

# Running in docker
## network
- first create a network
```
docker network create pg-network
```

## db
- run postgres, only named volumes work, see https://stackoverflow.com/a/63495668/13019344
```
# named volume
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="demo" \
    -v POSTGRES_DATA:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:13
```    

## pgAdmin
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

## if cli for Postgres instead of pgAdmin

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

## ingestion 

### running locally
```
URL='https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.parquet'

python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5432 \
  --db=demo \
  --table_name=yellow_taxi_trips \
  --url=${URL}
```

### running in docker

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
    --db=demo \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```

# Docker compose
```
docker-compose up
docker-compose down
```


# useful commands
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