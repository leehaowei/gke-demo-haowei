# Makefile for GKE NGINX Demo

IMAGE_NAME      := haoweilee/gke-nginx-demo
IMAGE_TAG       := v1
FULL_IMAGE_NAME := $(IMAGE_NAME):$(IMAGE_TAG)
DOCKERFILE_PATH := Dockerfile
LOCAL_PORT      := 8080
CONTAINER_NAME  := gke-nginx-demo

.PHONY: all build run push clean stop

all: build run

## Build the Docker image
build:
	docker buildx build --platform linux/amd64 -f $(DOCKERFILE_PATH) -t $(FULL_IMAGE_NAME) .

## Run the container (depends on build)
run: build
	docker run --rm -d -p $(LOCAL_PORT):80 --name $(CONTAINER_NAME) $(FULL_IMAGE_NAME)

## Stop the running container (if not using --rm)
stop:
	-docker stop $(CONTAINER_NAME)

## Push the image to Docker Hub
push:
	docker push $(FULL_IMAGE_NAME)

## Remove the built image
clean:
	docker rmi $(FULL_IMAGE_NAME)
