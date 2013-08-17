test:
	@./node_modules/.bin/mocha --compilers coffee:coffee-script -u tdd -R spec

.PHONY: test