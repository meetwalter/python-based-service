NAME=meetwalter/python-based-service
VERSION=$(shell cat VERSION)

.PHONY: image tag release

image:
	docker build -t $(NAME):$(VERSION) .

tag:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest
	git tag -d $(VERSION) 2>&1 1>/dev/null || :
	git tag $(VERSION)

release: image tag
	docker push $(NAME)
