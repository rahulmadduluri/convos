package db

import (
	"log"

	"models"
)

// list of queries
const (
	_findConversations = "findConversationsForUserWithTitle"
)

func (dbh *dbhandler) GetConversations(userUUID string, searchText string) []models.Conversation {
	titleSearch := "%" + searchText + "%"
	rows, err := dbh.db.Queryx(dbh.conversationQueries["findConversationsForUserWithTitle"], userUUID, titleSearch)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	var objs []models.Conversation
	for rows.Next() {
		var obj models.Conversation
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal(err)
		}
		objs = append(objs, obj)
	}
	err = rows.Err()
	if err != nil {
		log.Fatal(err)
	}
	return objs
}
