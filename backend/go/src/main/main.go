package main

import (
	"log"

	"db"
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
	// db.Queryx()
	// Create a simple file server
	log.SetFlags(0 | log.Lshortfile)
	log.Println("Start application")
	go hub.Run()

	http.HandleFunc("/ws", createWebsocket)
	log.Println("call", *db.GetDbHandler().GetUsersByName("R")[0].Photo_url)

	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Println("ListenAndServe: ", err)
	} else {
		log.Println("http server started on :8000")
	}
}

// create new websocket
func createWebsocket(res http.ResponseWriter, req *http.Request) {
	// Upgrade HTTP request handler to a websocket
	ws, err := upgrader.Upgrade(res, req, nil)
	if err != nil {
		log.Println("Failed to upgrade to websocket", err)
		http.NotFound(res, req)
		return
	}

	// is uuid user UUID or not?
	client := networking.NewClient(ws)
	hub.Register(client)

	go client.RunRead(hub)
	go client.RunWrite(hub)
}
