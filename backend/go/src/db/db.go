package db

import (
	"log"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
	"github.com/nleof/goyesql"
	"models"
)

var _dbh = newDbHandler()

type DbHandler interface {
	GetConversations(user_id int) []models.Conversation
	GetUsersByName(name string) []models.User
	Close()
}

type dbhandler struct {
	db      *sqlx.DB
	queries goyesql.Queries
}

func newDbHandler() *dbhandler {
	db, err := sqlx.Open("mysql",
		"root:webster93@tcp(127.0.0.1:3306)/convos")
	if err != nil {
		log.Fatal(err)
	}
	err = db.Ping()
	if err != nil {
		log.Printf("No ping %v", err)
	}
	queries := goyesql.MustParseFile("db/queries.sql")
	return &dbhandler{
		db:      db,
		queries: queries,
	}
}

func GetDbHandler() DbHandler {
	return _dbh
}

func (dbh *dbhandler) Close() {
	dbh.db.Close()
}

func (dbh *dbhandler) GetConversations(user_id int) []models.Conversation {
	rows, err := dbh.db.Queryx(dbh.queries["findConversationsByUserId"], user_id)
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

func (dbh *dbhandler) GetUsersByName(name string) []models.User {
	rows, err := dbh.db.Queryx(dbh.queries["findUsersByName"], name+"%")
	if err != nil {
		log.Fatal("query error", err)
	}
	defer rows.Close()
	var objs []models.User
	for rows.Next() {
		var obj models.User
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error", err)
		}
		objs = append(objs, obj)
	}
	err = rows.Err()
	if err != nil {
		log.Fatal(err)
	}
	return objs
}
