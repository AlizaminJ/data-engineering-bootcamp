FROM python:3.9

RUN pip install pandas sqlalchemy psycopg2 openpyxl

WORKDIR /app

COPY ingestion.py ingestion.py 

COPY assets/ assets/ 


ENTRYPOINT ["python", "ingestion.py"]

