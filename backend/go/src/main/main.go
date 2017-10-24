package main

import (
	"fmt"

	// "db"
	// "models"
	"networking"

	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var hub = networking.NewHub()

func main() {
	// database := db.GetDB()
	// defer database.Close()
	// db.Queryx()
	// Create a simple file server

	fmt.Println("Start application")
	go hub.Run()

	http.HandleFunc("/ws", createWebsocket)

	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		fmt.Println("ListenAndServe: ", err)
	} else {
		fmt.Println("http server started on :8000")
	}
}

// create new websocket
func createWebsocket(res http.ResponseWriter, req *http.Request) {
	// Upgrade HTTP request handler to a websocket
	ws, err := upgrader.Upgrade(res, req, nil)
	if err != nil {
		http.NotFound(res, req)
		return
	}

	// is uuid user UUID or not?
	client := networking.NewClient(ws)
	hub.Register(client)

	go client.RunRead(hub)
	go client.RunWrite(hub)
}
