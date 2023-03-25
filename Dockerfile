ARG BASE_IMAGE=python:3.10.10-slim-buster

FROM ${BASE_IMAGE} AS dev

# Install Poetry to $POETRY_HOME and allow all users to execute Poetry binaries
# https://python-poetry.org/docs/#introduction
ENV POETRY_HOME=/opt/poetry
ARG POETRY_VERSION=1.4.0
RUN set -x; \
    python -m venv ${POETRY_HOME} && \
    ${POETRY_HOME}/bin/pip install poetry==${POETRY_VERSION} && \
    ${POETRY_HOME}/bin/poetry --version && \
    chmod -R a+rwx ${POETRY_HOME}

ENV HOME="/tmp/home"
ENV PATH="/opt/poetry/bin:$PATH"


FROM dev AS build

WORKDIR /tmp/repro

COPY . /tmp/repro

RUN poetry add pydantic pytype

CMD ["poetry", "run", "python", "/tmp/repro/example.py"]
