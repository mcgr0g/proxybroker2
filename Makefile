# VERSIONS ---------------------------------------------------------------------
IMG_VER=2.0.0-alpha5
PY_IMG_VARIANT=3.8-bullseye
POETRY_VARIANT=1.3.1
APP_NAME=proxybkoker2
OWNER_NAME=mcgr0g
IMG_NAME=$(OWNER_NAME)/$(APP_NAME)
BUILD_DATE:=$(shell date '+%Y-%m-%d')

BFLAGS=docker buildx build \
		--build-arg IMG_VER=$(IMG_VER) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg PY_IMG_VARIANT=$(PY_IMG_VARIANT) \
		--build-arg POETRY_VARIANT=$(POETRY_VARIANT) \
		-t $(IMG_NAME):$(IMG_VER)


TFLAGS=docker tag $(IMG_NAME):$(IMG_VER) $(IMG_NAME):latest
BUILD_FAST=$(BFLAGS) . && $(TFLAGS)
BUILD_FULL=$(BFLAGS) --no-cache .

# IMAGE -----------------------------------------------------------------------

build:
	$(BUILD_FAST)
	
build-full:
	$(BUILD_FULL)

push:
	docker push $(IMG_NAME) --all-tags

# CONTAINER -------------------------------------------------------------------

example:
	docker run --rm --name $(APP_NAME) \
	$(IMG_NAME):$(IMG_VER) \
	--log INFO find --types HTTPS --lvl High --countries US UK DE FR NL --strict -l 10

serve:
	docker run --rm --name $(APP_NAME) \
	$(IMG_NAME):$(IMG_VER) \
	--log INFO serve --host 127.0.0.1 --port 8888 --types HTTPS --lvl High --countries UK DE FR NL --min-queue 5