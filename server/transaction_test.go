package main

import (
	"testing"
)

func TestNewUser(t *testing.T) {
	db := newDB()
	if len(db.Coins.Coins) != 0 {
		t.Fatalf("new DB must empty")
	}
	if err := db.addUser("wass"); err != nil {
		t.Fatal(err)
	}
	coin, err := db.getCoin("wass")
	if err != nil {
		t.Fatal(err)
	}
	if coin != 0 {
		t.Fatalf("Not 0 coin of new User; %#+v", db.Coins.Coins)
	}
}

func TestAddTransaction(t *testing.T) {
	db := newDB()
	db.addUser("A")
	db.addUser("B")
	a := payMount{-10, "#1"}
	b := payMount{+10, "#2"}
	if err := db.addTransaction("YES", map[string]*payMount{"A":&a, "B":&b}) ; err != nil {
		t.Fatal(err)
	}
	coinA, err := db.getCoin("A")
	if err != nil {
		t.Fatal(err)
	}
	if coinA != -10 {
		t.Fatalf("coin of A must be -10, not %d", coinA)
	}
	coinB, err := db.getCoin("B")
	if err != nil {
		t.Fatal(err)
	}
	if coinB != 10 {
		t.Fatalf("coin of B must be 10, not %d", coinB)
	}
}

func TestErrTransaction(t *testing.T) {
	db := newDB()
	db.addUser("A")
	db.addUser("B")
	db.addUser("C")
	p1 := &payMount{1, "#1"}
	m1 := &payMount{-1, "#2"}
	m2 := &payMount{-2, "#2"}
	if err := db.validatePay(map[string]*payMount{}); err == nil {
		t.Fatal("Empty transaction is invalid")
	}
	if err := db.validatePay(map[string]*payMount{"D":p1,"A":m1}); err == nil {
		t.Fatal("Unknown user is invalid")
	}
	if err := db.validatePay(map[string]*payMount{"A":p1}); err == nil {
		t.Fatal("Sum must be 0")
	}
	if err := db.validatePay(map[string]*payMount{"A":p1, "B":m2}); err == nil {
		t.Fatal("Sum must be 0")
	}
	if err := db.validatePay(map[string]*payMount{"A":p1, "B":m1}); err != nil {
		t.Fatal("ok if Sum is 0, but", err)
	}
	if err := db.validatePay(map[string]*payMount{"A":p1, "B":p1, "C":m2}); err != nil {
		t.Fatal("ok if Sum is 0, but", err)
	}
}
