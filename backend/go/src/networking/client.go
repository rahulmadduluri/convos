package networking

import (
	"encoding/json"
	"log"
	"time"

	"api"

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
	tempUUID, _ := uuid.NewV4()
	return &client{
		uuid:      tempUUID.String(),
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
			log.Println("ERROR: failed to read message from socket -- Socket ended")
			break
		}

		var packet Packet
		err = json.Unmarshal(data, &packet)
		if err != nil {
			log.Println("ERROR: Couldn't unmarshall packet -- Socket ended")
			continue
		}

		err = c.performAPI(packet.Data, APIType(packet.Type), h)
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
			log.Println("ERROR: Failed to pull message from send queue")
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

func (c *client) performAPI(data json.RawMessage, apiType APIType, h Hub) error {
	res, err := routeAPI(data, apiType)
	if err != nil {
		return err
	}

	// just need to handle the case of PushMessagesResponse
	// send to each user specified by response object
	if APIType(res.Type) == _pushMessageResponse {
		var pmr api.PushMessageResponse
		err = json.Unmarshal(res.Data, &pmr)
		if err != nil {
			return err
		}
		for _, user := range pmr.ReceiverUUIDs {
			err = h.SendToUser(*res, user)
			if err != nil {
				return err
			}
		}
	} else {
		c.Send(res)
	}
	return nil
}
