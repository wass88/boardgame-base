package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"time"
)

type transaction struct {
	Game      string               `json:"game"`
	Pay       map[string]*payMount `json:"pay"`
	CreatedAt time.Time            `json:"created_at"`
}

type payMount struct {
	Mount  int    `json:"mount" validate:"required`
	Result string `json:"result" validate:"required`
}

type coins struct {
	Coins map[string]int `json:"coins"`
}

type coinDB struct {
	Transactions []*transaction `json:"transactions"`
	Coins        *coins         `json:"coins"`
}

func newDB() coinDB {
	t := map[string]int{}
	return coinDB{
		Transactions: []*transaction{},
		Coins:        &coins{Coins: t},
	}
}

var dbFile string = "db.json"

func initDB() {
	db := newDB()
	db.save(dbFile)
}

func loadDB(filename string) coinDB {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	var db coinDB
	if err := json.Unmarshal(bytes, &db); err != nil {
		panic(err)
	}
	return db
}

func (db *coinDB) save(filename string) error {
	bytes, err := json.Marshal(db)
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(filename, bytes, 0644)
	if err != nil {
		return err
	}
	return nil
}

func (db *coinDB) addTransaction(game string, pay map[string]*payMount) error {
	err := db.validatePay(pay)
	if err != nil {
		return err
	}
	t := transaction{Game: game, Pay: pay, CreatedAt: time.Now()}
	db.Transactions = append(db.Transactions, &t)
	for user, mount := range pay {
		db.Coins.Coins[user] += mount.Mount
	}
	return nil
}

func (db *coinDB) validatePay(t map[string]*payMount) error {
	if len(t) == 0 {
		return fmt.Errorf("Pay is empty")
	}
	sum := 0
	for user, m := range t {
		sum += m.Mount
		if _, err := db.getCoin(user); err != nil {
			return fmt.Errorf("User is missing: %s", user)
		}
	}
	if sum != 0 {
		return fmt.Errorf("Sum must be 0, but %d", sum)
	}
	return nil
}

func (db *coinDB) addUser(user string) error {
	if _, ok := db.Coins.Coins[user]; ok {
		return fmt.Errorf("Already exists User: %s", user)
	}
	initCoin := 1000
	db.Coins.Coins[user] = initCoin
	return nil
}

func (db *coinDB) getCoin(user string) (int, error) {
	coin, ok := db.Coins.Coins[user]
	if !ok {
		return -1, fmt.Errorf("Unknown User: %s", user)
	}
	return coin, nil
}
