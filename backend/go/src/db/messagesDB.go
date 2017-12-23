package db

import (
	"log"

	"models"
)

// list of queries
const (
	_insertMessage = "insertMessage"
	_lastXMessages = "lastXMessages"
)

func (dbh *dbhandler) InsertMessage(messageUUID string, messageText string, messageTimestamp int, senderUUID string, parentUUID string, conversationUUID string) error {
	// Could directly pass an object here and use NamedExec instead
	result, err := dbh.db.Exec(dbh.messageQueries[_insertMessage],
		map[string]interface{}{
			"messageuuid":      messageUUID,
			"messagetext":      messageText,
			"messagetimestamp": messageTimestamp,
			"senderuuid":       senderUUID,
			"parentuuid":       parentUUID,
			"conversationuuid": conversationUUID})
	return result, err
}

func (dbh *dbhandler) GetLastXMessages(conversationUUID string, X int, latestServerTimestamp int) ([]models.MessageObj, error) {
	var objs []models.MessageObj

	rows, err := dbh.db.Queryx(dbh.messageQueries[_lastXMessages],
		map[string]interface{}{
			"conversationuuid": conversationUUID,
			"x":                X,
			"latestservertimestamp": latestServerTimestamp})

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
