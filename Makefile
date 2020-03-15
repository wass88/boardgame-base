build:
	make build -C frontend
	make build -C server

run-server:
	cd server && ./boardgame-base

DEST := kmc:private_html/app/boardgame-coin
deploy:
	make build -C frontend
	make server-amd64 -C server
	scp server/server-amd64 ${DEST}
	scp -r server/static ${DEST}