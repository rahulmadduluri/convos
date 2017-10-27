package networking

import (
	"errors"

	"encoding/json"

	"github.com/satori/go.uuid"
)

type Hub interface {
	GetClients() map[uuid.UUID]Client
	Register(c Client)
	Unregister(c Client)
	Run()
	Send(packet Packet, uuid uuid.UUID) error
}

// Hub maintains the set of active clients
// keeps track of connections/disconnections
type hub struct {
	clients    map[uuid.UUID]Client
	users      map[uuid.UUID]Client
	register   chan Client
	unregister chan Client
}

// init
func NewHub() Hub {
	return &hub{
		register:   make(chan Client),
		unregister: make(chan Client),
		clients:    make(map[uuid.UUID]Client),
	}
}

// run Hub
func (h *hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.clients[client.GetUUID()] = client
			createdMsg, _ := json.Marshal("Client Registered")
			packet := Packet{Data: createdMsg}
			h.Send(packet, client.GetUUID())
		case client := <-h.unregister:
			if _, ok := h.clients[client.GetUUID()]; ok {
				client.Close()
				delete(h.clients, client.GetUUID())
			}
		}
	}
}

// send packet to client with given UUID
func (h *hub) Send(packet Packet, uuid uuid.UUID) error {
	if recvClient, ok := h.clients[uuid]; ok {
		recvClient.Send(packet)
		return nil
	} else {
		errText := "failed to send packet to uuid " + uuid.String()
		return errors.New(errText)
	}
}

// get clients for hub
func (h *hub) GetClients() map[uuid.UUID]Client {
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
