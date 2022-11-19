#!/usr/bin/env bash
up() {
  echo "Starting Airbyte..."
  cd airbyte
  docker-compose down -v
  docker-compose up -d
  cd ..

  echo "Starting Airflow..."
  cd airflow
  docker-compose down -v    
  docker-compose up airflow-init
  docker-compose up -d
  cd ..

  echo "Starting Metabase..."
  cd metabase
  docker-compose down -v
  docker-compose up -d
  cd ..
 
  echo "Access Airbyte at http://localhost:8000 and set up the connections."
  
  echo "Access Airflow at http://localhost:8080 to kick off your Airbyte sync DAG."  

  echo "Access Metabase at http://localhost:3000 and set up a connection with Snowflake."

}

config() {
  docker network create modern-data-stack
  docker network connect modern-data-stack airbyte-proxy
  docker network connect modern-data-stack airbyte-worker  
  docker network connect modern-data-stack airflow-airflow-worker-1
  docker network connect modern-data-stack airflow-airflow-webserver-1
  docker network connect modern-data-stack metabase
  
  cd airflow
  docker-compose run airflow-webserver airflow connections add 'airbyte_example' --conn-uri 'airbyte://airbyte-proxy:8000'
  cd ..
  
  echo "Config Updated..."
}


down() {
  echo "Stopping Airbyte..."
  cd airbyte
  docker-compose down
  cd ..
  echo "Stopping Airflow..."
  cd airflow
  docker-compose down
  cd ..
  echo "Stopping Metabase..."
  cd metabase
  docker-compose down
  cd ..
}

case $1 in
  up)
    up
    ;;
  config)
    config
    ;;
  down)
    down
    ;;
  *)
    echo "Usage: $0 {up|config|down}"
    ;;
esac