package db

import (
	"github.com/guregu/null"
	"log"
	"models"
)

// list of queries
const (
	_insertMessage           = "insertMessage"
	_getUsersForConversation = "getUsersForConversation"
	_lastXMessages           = "lastXMessages"
)

func (dbh *dbhandler) InsertMessage(messageUUID string, messageText string, messageTimestamp int, senderUUID string, parentUUID null.String, conversationUUID string) ([]models.UserObj, error) {
	// Returns users who need to be informed about message
	var objs []models.UserObj

	m := map[string]interface{}{
		"messageuuid":      messageUUID,
		"messagetext":      messageText,
		"messagetimestamp": messageTimestamp,
		"senderuuid":       senderUUID,
		"parentuuid":       parentUUID,
		"conversationuuid": conversationUUID,
	}

	_, err := dbh.db.NamedExec(dbh.messageQueries[_insertMessage], m)
	if err != nil {
		return objs, err
	}
	rows, err := dbh.db.NamedQuery(dbh.messageQueries[_getUsersForConversation], m)
	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.UserObj
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

func (dbh *dbhandler) GetLastXMessages(conversationUUID string, X int, latestTimestampServer int) ([]models.MessageObj, error) {
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
