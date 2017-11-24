package db

import (
	"log"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
	"github.com/nleof/goyesql"
	"models"
)

var _dbh = newDbHandler()

const (
	_dbPath                  = "root:webster93@tcp(127.0.0.1:3306)/convos"
	_userQueriesPath         = "db/userQueries.sql"
	_conversationQueriesPath = "db/conversationQueries.sql"
)

type DbHandler interface {
	GetConversations(userUUID string, searchText string) []models.Conversation
	GetUsers(name string) []models.User
	Close()
}

type dbhandler struct {
	db                  *sqlx.DB
	userQueries         goyesql.Queries
	conversationQueries goyesql.Queries
}

func newDbHandler() *dbhandler {
	db, err := sqlx.Open("mysql", _dbPath)
	if err != nil {
		log.Fatal(err)
	}
	err = db.Ping()
	if err != nil {
		log.Printf("No ping %v", err)
	}
	userQueries := goyesql.MustParseFile(_userQueriesPath)
	conversationQueries := goyesql.MustParseFile(_conversationQueriesPath)
	return &dbhandler{
		db:                  db,
		userQueries:         userQueries,
		conversationQueries: conversationQueries,
	}
}

func GetHandler() DbHandler {
	return _dbh
}

func (dbh *dbhandler) Close() {
	dbh.db.Close()
}
