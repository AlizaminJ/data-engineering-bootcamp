select 
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    concat(zpu."Borough", ' / ', zpu."Zone") as "pickup_loc",
    concat(zdo."Borough", ' / ', zdo."Zone") as "dropoff_loc"
from yellow_taxi_trips t,
    zones zpu,
    zones zdo
where 
    t."PULocationID"=zpu."LocationID" AND
    t."DOLocationID"=zdo."LocationID"
limit 100;


select 
    cast(tpep_dropoff_datetime as date) as "day",
    count(1)
from yellow_taxi_trips t
group by
    cast(tpep_dropoff_datetime as date) 
    order by "day" asc