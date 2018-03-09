package main

import (
	"log"

	"api"
	"db"
	"networking"

	"net/http"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var hub = networking.NewHub()

func main() {
	log.SetFlags(0 | log.Lshortfile)

	log.Println("Start application")
	db.ConfigHandler()
	go hub.Run()

	r := mux.NewRouter()
	r.HandleFunc("/", homeHandler)
	r.HandleFunc("/ws", websocketHandler)
	// User
	r.HandleFunc("/users", api.GetUsers).Methods("GET")
	r.HandleFunc("/users/{uuid}/contacts", api.GetContactsForUser).Methods("GET")
	r.HandleFunc("/users/{uuid}/contacts", api.CreateContact).Methods("POST")
	// Group
	r.HandleFunc("/groups/{uuid}/members", api.GetMembersForGroup).Methods("GET")
	r.HandleFunc("/groups/{uuid}", api.UpdateGroup).Methods("PUT")
	r.HandleFunc("/groups", api.CreateGroup).Methods("POST")
	// Conversation
	r.HandleFunc("/conversations/{uuid}", api.UpdateConversation).Methods("PUT")
	r.HandleFunc("/conversations", api.CreateConversation).Methods("POST")
	r.Handle("/static/{s3_uri}",
		http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	http.Handle("/", r)

	// Start listening on port 8000
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Println("ListenAndServe: ", err)
	} else {
		log.Println("http server started on :8000")
	}
}

// Home Handler
func homeHandler(res http.ResponseWriter, req *http.Request) {
	// do nothing
	log.Println("Home accessed")
}

// Create new websocket
func websocketHandler(res http.ResponseWriter, req *http.Request) {
	// Upgrade HTTP request handler to a websocket
	ws, err := upgrader.Upgrade(res, req, nil)
	if err != nil {
		log.Println("Failed to upgrade to websocket", err)
		http.NotFound(res, req)
		return
	}

	client := networking.NewClient(ws)
	hub.Register(client)

	// Each client runs a thread for reading & a thread for writing
	go client.RunRead(hub)
	go client.RunWrite(hub)
}
