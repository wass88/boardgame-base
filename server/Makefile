boardgame-base: *.go
	go build

build: boardgame-base

server-amd64: *.go
	GOOS=linux GOARCH=amd64 go build -o server-amd64
