package db

import (
	"log"

	_ "github.com/go-sql-driver/mysql"
	"github.com/guregu/null"
	"github.com/jmoiron/sqlx"
	"github.com/nleof/goyesql"
	"models"
)

var _dbh = newDbHandler()

const (
	_dbPath                  = "root:webster93@tcp(127.0.0.1:3306)/convos"
	_userQueriesPath         = "db/userQueries.sql"
	_conversationQueriesPath = "db/conversationQueries.sql"
	_messageQueriesPath      = "db/messageQueries.sql"
)

type DbHandler interface {
	GetConversationObjs(userUUID string, searchText string) ([]models.ConversationObj, error)
	GetUsers(name string) ([]models.User, error)
	GetLastXMessages(conversationUUID string, X int, latestServerTimestamp int) ([]models.MessageObj, error)
	InsertMessage(messageUUID string, messageText string, messageTimestamp int, senderUUID string, parentUUID null.String, conversationUUID string) ([]models.UserObj, error)
	Close()
}

type dbhandler struct {
	db                  *sqlx.DB
	userQueries         goyesql.Queries
	conversationQueries goyesql.Queries
	messageQueries      goyesql.Queries
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
	messageQueries := goyesql.MustParseFile(_messageQueriesPath)
	return &dbhandler{
		db:                  db,
		userQueries:         userQueries,
		conversationQueries: conversationQueries,
		messageQueries:      messageQueries,
	}
}

func GetHandler() DbHandler {
	return _dbh
}

func (dbh *dbhandler) Close() {
	dbh.db.Close()
}
