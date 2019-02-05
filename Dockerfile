FROM python:3.7.2-alpine3.8

RUN pip install pipenv \
    && rm -rf /root/.cache

RUN addgroup -g 1000 appuser && \
    adduser -D -G appuser -h /app -s /sbin/nologin -u 1000 appuser

USER appuser

WORKDIR /app

COPY Pipfile Pipfile.lock ./

RUN pipenv install --deploy \
    && rm -rf .cache

COPY app ./

RUN pipenv check \
    && rm -rf .cache

CMD pipenv run python server.py

EXPOSE 5002
