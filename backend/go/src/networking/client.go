package networking

import (
	"time"

	"api"

	"encoding/json"

	"github.com/gorilla/websocket"
	"github.com/satori/go.uuid"
)

type Packet struct {
	Type            string
	ServerTimestamp *time.Time
	Data            json.RawMessage
}

// Client is an interface that allows interaction w/ client socket
type Client interface {
	GetUUID() uuid.UUID
	GetSocket() *websocket.Conn
	RunRead(h Hub)
	RunWrite(h Hub)
	Send(packet Packet)
	CloseSendQueue()
}

type client struct {
	uuid      uuid.UUID
	socket    *websocket.Conn
	sendQueue chan Packet
}

// init
func NewClient(ws *websocket.Conn) Client {
	return &client{
		uuid:      uuid.NewV4(),
		socket:    ws,
		sendQueue: make(chan Packet),
	}
}

// Read loop
func (c *client) RunRead(h Hub) {
	defer func() {
		h.Unregister(c)
		c.socket.Close()
	}()

	for {
		_, data, err := c.socket.ReadMessage()
		if err != nil {
			h.Unregister(c)
			c.socket.Close()
			break
		}
		var packet Packet
		err = json.Unmarshal(data, &packet)
		if err != nil {
			h.Unregister(c)
			c.socket.Close()
			break
		}
		var serverTimestamp time.Time
		serverTimestamp = time.Now()
		packet.ServerTimestamp = &serverTimestamp

		//store packet data

		switch packet.Type {
		case "SearchRequest":
			var searchRequest api.SearchRequest
			err = json.Unmarshal(packet.Data, &searchRequest)
			api.RecvSearchRequest(searchRequest)
		case "SearchResponse":
			var searchResponse api.SearchResponse
			err = json.Unmarshal(packet.Data, &searchResponse)
			api.RecvSearchResponse(searchResponse)
		case "PullMessagesRequest":
		case "PullMessagesResponse":
		case "PushMessageRequest":
		case "PushMessageResponse":
		}
		if err != nil {
			h.Unregister(c)
			c.socket.Close()
			break
		}
	}
}

// Write loop
func (c *client) RunWrite(h Hub) {
	defer func() {
		c.socket.Close()
	}()

	for {
		select {
		case packet, ok := <-c.sendQueue:
			if !ok {
				c.socket.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			c.socket.WriteJSON(packet)
		}
	}
}

func (c *client) GetUUID() uuid.UUID {
	return c.uuid
}

func (c *client) GetSocket() *websocket.Conn {
	return c.socket
}

func (c *client) Send(packet Packet) {
	c.sendQueue <- packet
}

func (c *client) CloseSendQueue() {
	close(c.sendQueue)
}
