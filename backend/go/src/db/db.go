package db

import (
	"log"

	_ "github.com/go-sql-driver/mysql"
	"github.com/guregu/null"
	"github.com/jmoiron/sqlx"
	"github.com/nleof/goyesql"
	"models"
)

var _dbh *dbHandler

const (
	_dbPath             = "root:webster93@tcp(127.0.0.1:3306)/convos"
	_searchQueriesPath  = "db/searchQueries.sql"
	_userQueriesPath    = "db/userQueries.sql"
	_groupQueriesPath   = "db/groupQueries.sql"
	_messageQueriesPath = "db/messageQueries.sql"
)

type DbHandler interface {
	//Search
	GetGroups(userUUID string, searchText string) ([]models.GroupObj, error)
	// User
	GetPeopleForUser(userUUID string, searchText string, maxPeople int) ([]models.UserObj, error)
	// Group
	GetPeopleForGroup(groupUUID string, searchText string, maxPeople int) ([]models.UserObj, error)
	UpdateGroup(groupUUID string, name string, newMemberUUID string) error
	// Messages
	GetLastXMessages(conversationUUID string, X int, latestTimestampServer int) ([]models.MessageObj, error)
	InsertMessage(messageUUID string, messageText string, messageTimestamp int, senderUUID string, parentUUID null.String, conversationUUID string) ([]models.UserObj, error)
	// DB
	Close()
}

type dbHandler struct {
	db             *sqlx.DB
	searchQueries  goyesql.Queries
	userQueries    goyesql.Queries
	groupQueries   goyesql.Queries
	messageQueries goyesql.Queries
}

func newDbHandler() *dbHandler {
	db, err := sqlx.Open("mysql", _dbPath)
	if err != nil {
		log.Fatal(err)
	}
	err = db.Ping()
	if err != nil {
		log.Printf("No ping %v", err)
	}
	searchQueries := goyesql.MustParseFile(_searchQueriesPath)
	userQueries := goyesql.MustParseFile(_userQueriesPath)
	groupQueries := goyesql.MustParseFile(_groupQueriesPath)
	messageQueries := goyesql.MustParseFile(_messageQueriesPath)
	dbh := &dbHandler{
		db:             db,
		searchQueries:  searchQueries,
		userQueries:    userQueries,
		groupQueries:   groupQueries,
		messageQueries: messageQueries,
	}
	return dbh
}

func GetHandler() DbHandler {
	return _dbh
}

func ConfigHandler() {
	_dbh = newDbHandler()
}

func (dbh *dbHandler) Close() {
	dbh.db.Close()
}
