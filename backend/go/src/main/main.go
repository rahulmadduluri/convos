package main

import (
	"db"
	"encoding/json"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

type ServerMessage struct {
	Username string `json:"username"`
	Receiver string `json:"receiver"`
	Message  string `json:"message"`
}

type ClientMessage struct {
	Type string          `json:"type"`
	Data json.RawMessage `json:"data"`
}

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

type JoinMessage struct {
	Username string `json:"username"`
}

type Message struct {
	Username string `json:"username"`
	Receiver string `json:"receiver"`
	Message  string `json:"message"`
}

var clients = make(map[*websocket.Conn]bool)     // connected clients
var receivers = make(map[string]*websocket.Conn) // map from username to clients
var broadcast = make(chan ServerMessage)         // broadcast channel

// Configure the upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func main() {
	// database := db.GetDB()
	// defer database.Close()
	db.Query()
	// Create a simple file server
	fs := http.FileServer(http.Dir("../../public"))
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

// Have a message queue, that is read and braodcasts to channels of receivers.
// Else, its just normal response to connection, no broadcasting
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
		case "JoinMessage":
			{
				var msg JoinMessage
				json.Unmarshal(cmsg.Data, &msg)
				receivers[msg.Username] = ws
				log.Printf("Joined: %v", msg.Username)
				// get all new messages in background? yeah. send a timestamp of this update, so that client can send it back and we only query from that point onwards.
				// messages have uid created on client,
				//db.
			}
		case "SearchMessage":
			{
				var msg SearchMessage
				json.Unmarshal(cmsg.Data, &msg)
				// do corresponding search in SQL, get result and send to client
			}
		case "ResultMessage":
			{
				// do corresponding search in SQL, get result and send to client

			}
		case "ScrollMessage":
			{
				// do corresponding search in SQL, get result and send to client

			}
		case "SendMessage":
			{
				// add to SQL database, send ack to client, put in broadcast que to send to clients
				var msg SendMessage
				json.Unmarshal(cmsg.Data, &msg)
			}
		case "Message":
			{
				// add to SQL database, send ack to client
				// handle thread gets info that D was updated, so updates view accordingly
				// easiest version is for every message, send the db update to receivers with the receiver UUID
				var msg Message
				json.Unmarshal(cmsg.Data, &msg)
				var smsg ServerMessage = ServerMessage{msg.Username, msg.Receiver, msg.Message}
				broadcast <- smsg
			}
		default:
			panic("unrecognized message")
		}
	}
}

func handleMessages() {
	for {
		// Grab the next message from the broadcast channel
		msg := <-broadcast
		// Send it out to relevant receivers
		for _, recepient := range []string{msg.Receiver, msg.Username} {
			receiver, ok := receivers[recepient]
			if ok {
				err := receiver.WriteJSON(msg)
				if err != nil {
					log.Printf("error: %v", err)
					receiver.Close()
					delete(clients, receiver)
				}
			} else {
				log.Printf("Key not present. Error: %v", ok)
			}
		}
	}
}
