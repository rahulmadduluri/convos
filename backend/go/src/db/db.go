package db

import (
	"log"

	"models"

	"github.com/jmoiron/sqlx"
	"github.com/nleof/goyesql"
)

var db *sqlx.DB
var queries goyesql.Queries

func init() {
	var err error
	db, err = sqlx.Open("mysql",
		"root:webster93@tcp(127.0.0.1:3306)/convos")
	if err != nil {
		log.Fatal(err)
	}
	err = db.Ping()
	if err != nil {
		log.Printf("No ping %v", err)
	}
	queries = goyesql.MustParseFile("db/queries.sql")
}

func getConversations(user_id int) []models.Conversation {
	rows, err := db.Queryx(queries["findConversationsByUserId"], user_id)
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
