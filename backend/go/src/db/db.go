package db

import (
	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
	"github.com/nleof/goyesql"
	"log"
	"models"
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

func getConversations(user_id int) []models.Conversations {
	rows, err := db.Queryx(queries["findConversationsByUserId"], user_id)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	var objs []models.Conversations
	for rows.Next() {
		var obj models.Conversations
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
