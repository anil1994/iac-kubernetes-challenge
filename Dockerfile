FROM alpine:3.14.2 as base
FROM base as build

LABEL Anıl Dalkılıç <adalkilic@ku.edu.tr>

RUN apk add --no-cache \
       gcc \
       python3-dev \
       musl-dev \
       mariadb-dev \
       py3-pip

RUN mkdir /installment

RUN pip install --prefix=/installment  flask mysqlclient

FROM base

RUN apk add --no-cache \
       python3 \
       py3-gunicorn \
       mariadb-connector-c

RUN mkdir /app
COPY --from=build /installment /usr
COPY app.py wsgi.py /app/
WORKDIR /app

CMD ["gunicorn", "--bind", "0.0.0.0:3000", "wsgi:application"]
