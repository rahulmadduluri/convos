package networking

import (
	"log"
	"time"

	"api"
	"models"

	"encoding/json"

	"github.com/gorilla/websocket"
	"github.com/satori/go.uuid"
)

const (
	_searchRequest        = "SearchRequest"
	_searchResponse       = "SearchResponse"
	_pullMessagesRequest  = "PullMessagesRequest"
	_pullMessagesResponse = "PullMessagesResponse"
	_pushMessageRequest   = "PushMessageRequest"
	_pushMessageResponse  = "PushMessageResponse"
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
	Send(packet *Packet)
	Close()
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
	}()

	for {
		_, data, err := c.socket.ReadMessage()
		if err != nil {
			log.Println("Socket ended")
			break
		}

		var packet Packet
		err = json.Unmarshal(data, &packet)
		if err != nil {
			log.Println("Couldn't unmarshall packet")
			continue
		}

		res, err := performAPI(packet.Data, packet.Type)
		if err != nil {
			log.Println(err)
			continue
		}

		c.Send(res)
	}
}

// Write loop
func (c *client) RunWrite(h Hub) {
	defer func() {
		h.Unregister(c)
	}()

	for {
		packet, ok := <-c.sendQueue
		if !ok {
			log.Println("Failed to pull message from send queue")
			break
		}

		c.socket.WriteJSON(packet)
	}
}

func (c *client) GetUUID() uuid.UUID {
	return c.uuid
}

func (c *client) GetSocket() *websocket.Conn {
	return c.socket
}

func (c *client) Send(packet *Packet) {
	c.sendQueue <- *packet
}

func (c *client) Close() {
	close(c.sendQueue)
	c.socket.Close()
}

func performAPI(data json.RawMessage, apiType string) (*Packet, error) {
	var err error
	var res models.Model

	switch apiType {
	case _searchRequest:
		var searchRequest api.SearchRequest
		err = json.Unmarshal(data, &searchRequest)
		if err != nil {
			return nil, err
		}
		res, err = api.Search(searchRequest)
		if err != nil {
			return nil, err
		}
	case _pullMessagesRequest:
		var pullMessagesRequest api.PullMessagesRequest
		err = json.Unmarshal(data, &pullMessagesRequest)
		if err != nil {
			return nil, err
		}
		res, err = api.PullMessages(pullMessagesRequest)
		if err != nil {
			return nil, err
		}
	case _pushMessageRequest:
		var pushMessageRequest api.PushMessageRequest
		err = json.Unmarshal(data, &pushMessageRequest)
		if err != nil {
			return nil, err
		}
		res, err = api.PushMessage(pushMessageRequest)
		if err != nil {
			return nil, err
		}
	}

	serverTimestamp := time.Now()
	responseData, err := json.Marshal(res)
	if err != nil {
		return nil, err
	}

	return &Packet{
		Type:            apiType,
		ServerTimestamp: &serverTimestamp,
		Data:            responseData,
	}, nil
}
