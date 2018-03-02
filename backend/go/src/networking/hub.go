package networking

import (
	"errors"

	"encoding/json"
	"log"
	"strconv"
)

type Hub interface {
	GetClients() map[string]Client
	Register(c Client)
	Unregister(c Client)
	Run()
	Send(packet Packet, uuid string) error
	SendToUser(packet Packet, uuid string) error
}

// Hub maintains the set of active clients
// keeps track of connections/disconnections
type hub struct {
	clients    map[string]Client
	users      map[string]Client
	register   chan Client
	unregister chan Client
}

// init
func NewHub() Hub {
	return &hub{
		register:   make(chan Client),
		unregister: make(chan Client),
		clients:    make(map[string]Client),
		users:      make(map[string]Client),
	}
}

// run Hub
func (h *hub) Run() {
	// TODO: Remove (i) and place user-uuid (from header) in uuid
	i := 1
	for {
		select {
		case client := <-h.register:
			h.clients[client.GetUUID()] = client
			useruuid := "uuid-" + strconv.Itoa(i)
			h.users[useruuid] = client
			createdMsg, _ := json.Marshal("Client uuid-" + strconv.Itoa(i) + " Registered")
			packet := Packet{Data: createdMsg}
			h.Send(packet, client.GetUUID())
			i = i%2 + 1
		case client := <-h.unregister:
			if _, ok := h.clients[client.GetUUID()]; ok {
				client.Close()
				delete(h.clients, client.GetUUID())
			}
		}
	}
}

// send packet to user with given UUID
func (h *hub) SendToUser(packet Packet, uuid string) error {
	log.Println("Sending to user " + uuid)
	if recvClient, ok := h.users[uuid]; ok {
		log.Println("Sending to client " + recvClient.GetUUID())
		recvClient.Send(&packet)
		return nil
	} else {
		errText := "failed to send packet to user uuid " + uuid
		return errors.New(errText)
	}
}

// send packet to client with given UUID
func (h *hub) Send(packet Packet, uuid string) error {
	if recvClient, ok := h.clients[uuid]; ok {
		recvClient.Send(&packet)
		return nil
	} else {
		errText := "failed to send packet to client uuid " + uuid
		return errors.New(errText)
	}
}

// get clients for hub
func (h *hub) GetClients() map[string]Client {
	return h.clients
}

// register this client
func (h *hub) Register(client Client) {
	h.register <- client
}

// register this client
func (h *hub) Unregister(client Client) {
	h.unregister <- client
}
