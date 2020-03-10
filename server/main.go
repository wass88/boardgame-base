package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net/http"

	"github.com/labstack/echo"
)

func hello(c echo.Context) error {
	return c.JSON(http.StatusOK, nil)
}

func server(api *transactionAPI) {
	e := echo.New()
	initEcho(e)
	e.GET("/api/coins", api.getCoins)
	e.GET("/api/transactions", api.getTransactions)
	e.POST("/api/transactions", api.newTransaction)
	e.POST("/api/user", api.newUser)
	e.File("/", "static/index.html")
	e.Static("/", "static")
	data, _ := json.MarshalIndent(e.Routes(), "", "  ")
	fmt.Printf("%s", data)
	fmt.Printf("Ready")
	e.Logger.Fatal(e.Start(":18080"))
}
func main() {
	flag.Parse()
	cmd := flag.Arg(0)
	if cmd == "" || cmd == "server" {
		api := loadTransactionAPI(dbFile)
		server(&api)
	} else if cmd == "init" {
		initDB()
	} else {
		panic("Unknown command")
	}
}
