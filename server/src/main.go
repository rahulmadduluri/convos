package main

import (
	"encoding/json"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var clients = make(map[*websocket.Conn]bool) // connected clients
var broadcast = make(chan Message)           // broadcast channel

// Configure the upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type ClientMessage struct {
	Type    string          `json:"type"`
	Message json.RawMessage `json:"message"`
}

// Define our message object
// type Message struct {
// 	Email    string `json:"email"`
// 	Username string `json:"username"`
// 	Message  string `json:"message"`
// }

type SearchMessage struct {
	Text string `json:"text"`
}

type ResultMessage struct {
	Text string `json:"text"`
}

type ScrollMessage struct {
}

type SendMessage struct {
	SenderUUID    string `json:"senderUUID"`
	Text          string `json:"text"` // Later add support for images, links etc
	IsThread      bool   `json:"isThread"`
	ThreadTagUUID string `json:"threadTagUUID"`
}

func main() {
	// Create a simple file server
	fs := http.FileServer(http.Dir("../public"))
	http.Handle("/", fs)

	// Configure websocket route
	http.HandleFunc("/ws", handleConnections)

	// Start listening for incoming chat messages
	go handleMessages()

	// Start the server on localhost port 8000 and log any errors
	log.Println("http server started on :8000")
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func handleConnections(w http.ResponseWriter, r *http.Request) {
	// Upgrade initial GET request to a websocket
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Fatal(err)
	}
	// Make sure we close the connection when the function returns
	defer ws.Close()

	// Register our new client
	clients[ws] = true

	for {
		var cmsg ClientMessage
		// Read in a new message as JSON and map it to a Message object
		_, p, _ := ws.ReadMessage()
		err := json.Unmarshal(p, &cmsg)
		if err != nil {
			log.Printf("error: %v", err)
			delete(clients, ws)
			break
		}
		switch cmsg.Type {
		case 'SearchMessage': {
			var msg SearchMessage
			err := json.Unmarshal(cmsg.Message, &msg)
		}
		case 'ResultMessage': {
			
		}
		case 'ScrollMessage': {
			
		}
		case 'SendMessage': {

		}
		default:
			panic("unrecognized message")
		}
		// Send the newly received message to the broadcast channel
		broadcast <- msg
	}
}


func handleMessages() {
	for {
		// Grab the next message from the broadcast channel
		msg := <-broadcast
		// Send it out to every client that is currently connected
		for client := range clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("error: %v", err)
				client.Close()
				delete(clients, client)
			}
		}
	}
}
