package db

import (
	"log"

	"models"
)

// list of queries
const (
	_findConversations = "findConversationsForUserWithTitle"
)

func (dbh *dbhandler) GetConversationObjs(userUUID string, searchText string) ([]models.ConversationObj, error) {
	var objs []models.ConversationObj

	topicSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.conversationQueries[_findConversations],
		map[string]interface{}{
			"user_uuid":   userUUID,
			"search_text": searchText,
		},
	)

	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.ConversationObj
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
