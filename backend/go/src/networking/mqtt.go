package networking

import (
	"fmt"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"os"
)

var _mqtt *mqttHandler

//define a function for the default message handler
var f mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	fmt.Printf("TOPIC: %s\n", msg.Topic())
	fmt.Printf("MSG: %s\n", msg.Payload())
}

type MQTTHandler interface {
	SubscribeToTopic(topicName string)
	PublishToTopic(topicName string, messagePayload []byte)
	DisconnectFromTopic(topicName string)
}

type mqttHandler struct {
	client mqtt.Client
}

func GetMQTTHandler() MQTTHandler {
	return _mqtt
}

func GenerateMQTTHandler() {
	_mqtt = createMQTTHandler()
}

func createMQTTHandler() *mqttHandler {
	//create a ClientOptions struct setting the broker address, clientid, turn
	//off trace output and set the default message handler
	opts := mqtt.NewClientOptions().AddBroker("tcp://iot.eclipse.org:1883")
	// client ID linked to server instance?
	opts.SetClientID("convos-mqtt")
	opts.SetDefaultPublishHandler(f)

	//create and start a client using the above ClientOptions
	c := mqtt.NewClient(opts)
	if token := c.Connect(); token.Wait() && token.Error() != nil {
		panic(token.Error())
	}

	return &mqttHandler{
		client: c,
	}
}

// eg topic name: "groupUUID/conversationUUID/messages"
func (mqttH *mqttHandler) SubscribeToTopic(topicName string) {
	//subscribe to the topic /topicName and request messages to be delivered
	//at a maximum qos of zero, wait for the receipt to confirm the subscription
	if token := mqttH.client.Subscribe(topicName, 0, nil); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error())
		os.Exit(1)
	}
}

// eg topic name: "groupUUID/conversationUUID/messages"
func (mqttH *mqttHandler) PublishToTopic(topicName string, messagePayload []byte) {
	token := mqttH.client.Publish(topicName, 0, false, messagePayload)
	token.Wait()
}

// eg topic name: "groupUUID/conversationUUID/messages"
func (mqttH *mqttHandler) DisconnectFromTopic(topicName string) {
	if token := mqttH.client.Unsubscribe(topicName); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error())
		os.Exit(1)
	}

	mqttH.client.Disconnect(250)
}
