VERSION := $(shell git describe --tags)

.PHONY: prepare_test
prepare_test:
	# docker cp conf/test_daemon_settings.yml $(shell docker-compose ps -q test_daemon):/storage/data/daemon_settings.yml
	docker-compose up --no-start test_lbrynet
	docker cp conf/daemon_settings.yml $(shell docker-compose ps -q test_lbrynet):/storage/data/daemon_settings.yml
	docker-compose start test_daemon

.PHONY: test
test:
	go test -cover ./...

.PHONY: test_circleci
test_circleci:
	scripts/wait_for_wallet.sh
	go get golang.org/x/tools/cmd/cover
	go get github.com/mattn/goveralls
	go run . db_migrate_up
	go test -covermode=count -coverprofile=coverage.out ./...
	goveralls -coverprofile=coverage.out -service=circle-ci -repotoken $(COVERALLS_TOKEN)

release:
	goreleaser --rm-dist

snapshot:
	goreleaser --snapshot --rm-dist

.PHONY: image
image:
	docker build -t lbry/lbrytv:$(VERSION) -t lbry/lbrytv:latest -f ./deployments/docker/app/Dockerfile .

.PHONY: dev_image
dev_image:
	docker build -t lbry/lbrytv:$(VERSION) -t lbry/lbrytv:latest-dev -f ./deployments/docker/app/Dockerfile .

.PHONY: publish_image
publish_image:
	docker push lbry/lbrytv

clean:
	find . -name rice-box.go | xargs rm
	rm -rf ./dist

.PHONY: server
server:
	LW_DEBUG=1 go run . serve

tag := $(shell git describe --abbrev=0 --tags)
.PHONY: retag
retag:
	@echo "Re-setting tag $(tag) to the current commit"
	git push origin :$(tag)
	git tag -d $(tag)
	git tag $(tag)

.PHONY: models
models:
	go get -u -t github.com/volatiletech/sqlboiler@v3.4.0
	go get -u -t github.com/volatiletech/sqlboiler/drivers/sqlboiler-psql@v3.4.0
	sqlboiler --add-global-variants --wipe psql --no-context
