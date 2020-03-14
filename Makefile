build:
	make build -C frontend
	make build -C server

run-server:
	cd server && ./boardgame-base
