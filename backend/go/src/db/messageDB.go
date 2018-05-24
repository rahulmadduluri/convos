package db

import (
	"log"

	"models"
)

// list of queries
const (
	_insertMessage           = "insertMessage"
	_getMessage              = "getMessage"
	_getUsersForConversation = "getUsersForConversation"
	_lastXMessages           = "lastXMessages"
)

func (dbh *dbHandler) InsertMessage(
	messageUUID string,
	messageText string,
	messageTimestamp int,
	senderUUID string,
	parentUUID string,
	conversationUUID string,
) error {
	m := map[string]interface{}{
		"messageuuid":      messageUUID,
		"messagetext":      messageText,
		"messagetimestamp": messageTimestamp,
		"senderuuid":       senderUUID,
		"parentuuid":       parentUUID,
		"conversationuuid": conversationUUID,
	}
	_, err := dbh.db.NamedExec(dbh.messageQueries[_insertMessage], m)
	return err
}

func (dbh *dbHandler) GetLastXMessages(conversationUUID string, X int, latestTimestampServer int) ([]models.MessageObj, error) {
	var objs []models.MessageObj

	rows, err := dbh.db.NamedQuery(dbh.messageQueries[_lastXMessages],
		map[string]interface{}{
			"conversationuuid": conversationUUID,
			"x":                X,
			"latesttimestampserver": latestTimestampServer})

	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.MessageObj
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
			continue
		}
		objs = append(objs, obj)
	}
	err = rows.Err()

	return objs, err
}
