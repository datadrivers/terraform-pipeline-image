default: build

init:
	pre-commit install

validate:
	pre-commit run -a

build:
	docker build . -t terraform-pipeline-image:local

release:
	cz bump --changelog
	git push
	git push --tags

.PHONY: default init validate build release
