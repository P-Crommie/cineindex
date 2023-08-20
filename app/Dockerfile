FROM python:alpine3.17 as compiler

RUN mkdir /app 

RUN apk -U upgrade
RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .

RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt

COPY app.py /app/
COPY templates/ /app/templates/

FROM python:alpine3.17 as builder

COPY --from=compiler /opt/venv /opt/venv
COPY --from=compiler /app/ .
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT [ "python", "app.py" ]