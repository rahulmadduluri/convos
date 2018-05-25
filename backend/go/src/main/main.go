package main

import (
	"log"

	"api"
	"db"
	"middleware"
	"networking"

	"net/http"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/urfave/negroni"
)

func main() {
	// load env
	err := godotenv.Load()
	if err != nil {
		log.Print("Error loading .env file")
	}

	// setup DB
	db.ConfigHandler()
	// connect to MQTT broker
	networking.GenerateMQTTHandler()

	// middleware
	jwtMiddleware := middleware.JWTMiddleware()

	//  routers
	r := mux.NewRouter()  // unauth
	ar := mux.NewRouter() // auth

	// User
	ar.HandleFunc("/users", api.GetUsers).Methods("GET")
	ar.HandleFunc("/users/{uuid}", api.CreateUser).Methods("POST")
	ar.HandleFunc("/users/{uuid}", api.GetUser).Methods("GET")
	ar.HandleFunc("/users/{uuid}", api.UpdateUser).Methods("PUT")
	ar.HandleFunc("/users/{uuid}/contacts", api.GetContactsForUser).Methods("GET")
	ar.HandleFunc("/users/{uuid}/contacts", api.CreateContact).Methods("POST")
	// Group
	ar.HandleFunc("/groups", api.GetGroups).Methods("GET")
	ar.HandleFunc("/groups/{uuid}/conversations", api.GetConversationsForGroup).Methods("GET")
	ar.HandleFunc("/groups/{uuid}/members", api.GetMembersForGroup).Methods("GET")
	ar.HandleFunc("/groups/{uuid}", api.UpdateGroup).Methods("PUT")
	ar.HandleFunc("/groups", api.CreateGroup).Methods("POST")
	// Conversation
	ar.HandleFunc("/conversations/{uuid}", api.UpdateConversation).Methods("PUT")
	ar.HandleFunc("/conversations", api.CreateConversation).Methods("POST")
	ar.HandleFunc("/conversations/{uuid}/messages", api.CreateMessage).Methods("POST")
	ar.HandleFunc("/conversations/{uuid}/messages", api.GetMessages).Methods("GET")
	// Static Resources
	ar.Handle("/static/{s3_uri}",
		http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Negroni middleware handling
	an := negroni.New(negroni.HandlerFunc(jwtMiddleware.HandlerWithNext), negroni.HandlerFunc(middleware.HandlerForUUIDWithNext), negroni.Wrap(ar))
	r.PathPrefix("/").Handler(an)
	n := negroni.Classic()
	n.UseHandler(r)

	n.Run(":8000")
}
