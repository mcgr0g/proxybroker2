ARG PY_IMG_VARIANT=3.9-bullseye
ARG POETRY_VARIANT=1.3.1
# `builder-base` stage is used to build deps + create our virtual environment
FROM python:${PY_IMG_VARIANT} as base

ARG IMG_VER
ARG BUILD_DATE
ARG APP_NAME=""
ARG OWNER_NAME=""
LABEL org.opencontainers.image.authors="Ronnie McGrog" \
      org.opencontainers.image.url="https://github.com/${OWNER_NAME}/${APP_NAME}" \
      org.opencontainers.image.documentation="https://github.com/${OWNER_NAME}/${APP_NAME}/blob/master/README.md" \
      org.opencontainers.image.source="https://github.com/${OWNER_NAME}/${APP_NAME}/blob/master/Dockerfile" \
      org.opencontainers.image.title="${APP_NAME}" \
      org.opencontainers.image.description="The New (auto rotate) Proxy [Finder | Checker | Server]" \
      org.opencontainers.image.version="${IMG_VER}" \
      org.opencontainers.image.created="${BUILD_DATE}"

ENV \
    # Keeps Python from generating .pyc files in the container
    PYTHONDONTWRITEBYTECODE=1 \
    # Turns off buffering for easier container logging 
    PYTHONUNBUFFERED=1 \
    # pip
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    # poetry
    POETRY_VERSION=${POETRY_VARIANT} \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    # make poetry create the virtual environment
    POETRY_VIRTUALENVS_CREATE=true \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # paths
    PYSETUP_PATH="/opt/pysetup"  \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM base as builder

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python - 

WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

RUN poetry install --no-ansi --no-dev

COPY ./proxybroker proxybroker
EXPOSE 8888

ENTRYPOINT ["poetry", "run", "python", "-m", "proxybroker" ]
