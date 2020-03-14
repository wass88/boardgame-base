package main

import (
	"net/http"

	"github.com/labstack/echo"
)

type transactionAPI struct {
	DB     *coinDB
	DBFile string
}

func loadTransactionAPI(filename string) transactionAPI {
	db := loadDB(filename)
	return transactionAPI{DB: &db, DBFile: filename}
}

func (api *transactionAPI) save() {
	api.DB.save(api.DBFile)
}

type transactionReq struct {
	Game string               `json:"game" validate:"required"`
	Pay  map[string]*payMount `json:"pay"  validate:"required"`
}

func (api *transactionAPI) newTransaction(c echo.Context) error {
	req := new(transactionReq)
	if err := c.Bind(req); err != nil {
		return err
	}
	if err := api.DB.addTransaction(req.Game, req.Pay); err != nil {
		return err
	}
	api.save()
	return nil
}

func (api *transactionAPI) getCoins(c echo.Context) error {
	c.JSON(http.StatusOK, api.DB.Coins)
	return nil
}

func (api *transactionAPI) getTransactions(c echo.Context) error {
	c.JSON(http.StatusOK, api.DB.Transactions)
	return nil
}

type userReq struct {
	User string `json:"user" validate:"required"`
}

func (api *transactionAPI) newUser(c echo.Context) error {
	req := new(userReq)
	if err := c.Bind(req); err != nil {
		return err
	}
	if err := c.Validate(req); err != nil {
		return err
	}
	if err := api.DB.addUser(req.User); err != nil {
		return err
	}
	api.save()
	return nil
}
