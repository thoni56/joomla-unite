USER = thoni56
UBUNTU = jammy
PHP = 8.0

all:
	test -f unite-package*.zip
	UBUNTU=$(UBUNTU) PHP=$(PHP) envsubst '$$UBUNTU $$PHP $$USER' < Dockerfile.template > Dockerfile
	envsubst < unite.xml.template > unite.xml
	docker build -t $(USER)/joomla-unite:$(UBUNTU)-$(PHP) .
	@echo "Build done."

NAME = `ls restore/site*.jpa | awk -F\- '{ printf "%s-%s",$$2,$$3 }'`

run:
	docker run -p 80:80 -p 443:443 $(USER)/joomla-unite:$(UBUNTU)-$(PHP)
