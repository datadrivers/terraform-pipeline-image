default: build

init:
	pre-commit install

build:
	docker build . -t terraform-pipeline-image:local

release:
	cz bump --changelog
	git push
	git push --tags

.PHONY: default init build release