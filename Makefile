PATH:=./node_modules/.bin/:$(PATH)

all: init build test start

clean:
	rm -rf lib/*

init:
	npm install

build: clean init
	coffee -cm -o lib src

dev: watch
	NODE_ENV=development DEBUG=soymilk,soymilk:* nodemon

watch: end-watch
	coffee -cmw -o lib src					& echo $$! > .watch_pid

end-watch:
	if [ -e .watch_pid ]; then kill `cat .watch_pid`; rm .watch_pid;	else	echo no .watch_pid file; fi

start:
	npm start

test:
	npm test

docs:
	# Not implemented :p
	# ./node_modules/.bin/groc "src/*.coffee?(.md)" "src/**/*.coffee?(.md)" readme.md

clean-docs:
	rm -rf doc/*
