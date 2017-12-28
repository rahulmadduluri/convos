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
	GetUUID() string
	GetSocket() *websocket.Conn
	RunRead(h Hub)
	RunWrite(h Hub)
	Send(packet *Packet)
	Close()
}

type client struct {
	uuid      string
	socket    *websocket.Conn
	sendQueue chan Packet
}

// init
func NewClient(ws *websocket.Conn) Client {
	return &client{
		uuid:      uuid.NewV4().String(),
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

		err = c.performAPI(packet.Data, packet.Type, h)
		if err != nil {
			log.Println(err)
			continue
		}
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

func (c *client) GetUUID() string {
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

//

func (c *client) performAPI(data json.RawMessage, apiType string, h Hub) error {
	var err error
	var res models.Model
	var resAPI string
	var receiveruuids []string

	// handle request
	switch apiType {
	case _searchRequest:
		var searchRequest api.SearchRequest
		err = json.Unmarshal(data, &searchRequest)
		if err != nil {
			return err
		}
		res, err = api.Search(searchRequest)
		resAPI = _searchResponse
		if err != nil {
			return err
		}
	case _pullMessagesRequest:
		var pullMessagesRequest api.PullMessagesRequest
		err = json.Unmarshal(data, &pullMessagesRequest)
		if err != nil {
			return err
		}
		res, err = api.PullMessages(pullMessagesRequest)
		resAPI = _pullMessagesResponse
		if err != nil {
			return err
		}
	case _pushMessageRequest:
		var pushMessageRequest api.PushMessageRequest
		err = json.Unmarshal(data, &pushMessageRequest)
		if err != nil {
			return err
		}
		res, receiveruuids, err = api.PushMessage(pushMessageRequest)
		resAPI = _pushMessageResponse
		if err != nil {
			return err
		}
	}

	serverTimestamp := time.Now()
	responseData, err := json.Marshal(res)
	if err != nil {
		return err
	}

	result := &Packet{
		Type:            resAPI,
		ServerTimestamp: &serverTimestamp,
		Data:            responseData,
	}

	// just need to handle the case of PushMessagesRequest.
	// The response contains the user uuid's to send to, so just calling h.send(res, uuid) on each on them should be enough.
	if apiType == _pushMessageRequest {
		for _, receiveruuid := range receiveruuids {
			err = h.SendToUser(*result, receiveruuid)
			if err != nil {
				log.Println(err)
			}
		}
	} else {
		c.Send(result)
	}
	return nil
}
