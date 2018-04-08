package main

import (
	"log"

	"api"
	"db"
	"middleware"
	"networking"

	"net/http"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/joho/godotenv"
	"github.com/urfave/negroni"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var hub = networking.NewHub()

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Print("Error loading .env file")
	}

	log.Println("Start application")
	db.ConfigHandler()
	go hub.Run()

	// middleware
	jwtMiddleware := middleware.JWTMiddleware()

	r := mux.NewRouter()
	ar := mux.NewRouter()

	ar.HandleFunc("/ws", websocketHandler)
	// User
	ar.HandleFunc("/users", api.GetUsers).Methods("GET")
	ar.HandleFunc("/users/{uuid}", api.UpdateUser).Methods("PUT")
	ar.HandleFunc("/users/{uuid}/contacts", api.GetContactsForUser).Methods("GET")
	ar.HandleFunc("/users/{uuid}/contacts", api.CreateContact).Methods("POST")
	// Group
	ar.HandleFunc("/groups/{uuid}/conversations", api.GetConversationsForGroup).Methods("GET")
	ar.HandleFunc("/groups/{uuid}/members", api.GetMembersForGroup).Methods("GET")
	ar.HandleFunc("/groups/{uuid}", api.UpdateGroup).Methods("PUT")
	ar.HandleFunc("/groups", api.CreateGroup).Methods("POST")
	// Conversation
	ar.HandleFunc("/conversations/{uuid}", api.UpdateConversation).Methods("PUT")
	ar.HandleFunc("/conversations", api.CreateConversation).Methods("POST")
	ar.Handle("/static/{s3_uri}",
		http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	an := negroni.New(negroni.HandlerFunc(jwtMiddleware.HandlerWithNext), negroni.Wrap(ar))
	r.PathPrefix("/").Handler(an)
	n := negroni.Classic()
	n.UseHandler(r)

	n.Run(":8000")
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
