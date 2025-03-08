FROM python:2.7-alipine 

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install -r requirements.txt 

COPY main.py .

EXPOSE 8000

CMD python3 -m flask run --host=0.0.0.0 --port=8000 


# docker build -t <>/repo1:1.0
 