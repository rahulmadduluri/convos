package db

import (
	"database/sql"
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
) (models.MessageObj, error) {
	// Returns message that was inserted
	var obj models.MessageObj

	nullableParentUUID := sql.NullString{}
	if parentUUID != "" {
		nullableParentUUID = sql.NullString{
			String: parentUUID,
			Valid:  true,
		}
	}

	m := map[string]interface{}{
		"messageuuid":      messageUUID,
		"messagetext":      messageText,
		"messagetimestamp": messageTimestamp,
		"senderuuid":       senderUUID,
		"parentuuid":       nullableParentUUID,
		"conversationuuid": conversationUUID,
	}

	_, err := dbh.db.NamedExec(dbh.messageQueries[_insertMessage], m)
	if err != nil {
		return obj, err
	}
	rows, err := dbh.db.NamedQuery(dbh.messageQueries[_getMessage], map[string]interface{}{
		"messageuuid": messageUUID,
	})
	if err != nil {
		return obj, err
	}
	defer rows.Close()

	for rows.Next() {
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
			continue
		}
		return obj, err
	}

	return obj, err
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
