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
	_dbPath                  = "root:webster93@tcp(127.0.0.1:3306)/convos"
	_searchQueriesPath       = "db/searchQueries.sql"
	_userQueriesPath         = "db/userQueries.sql"
	_groupQueriesPath        = "db/groupQueries.sql"
	_conversationQueriesPath = "db/conversationQueries.sql"
	_tagQueriesPath          = "db/tagQueries.sql"
	_messageQueriesPath      = "db/messageQueries.sql"
)

type DbHandler interface {
	//Search
	GetGroups(userUUID string, searchText string) ([]models.GroupObj, error)
	// User
	CreateUser(userUUID string, name string, handle string, mobileNumber string, createdTimestampServer int, photoURI string) error
	GetUser(userUUID string) (models.UserObj, error)
	UpdateUser(userUUID string, name string, handle string) error
	GetUsers(searchText string, maxUsers int) ([]models.UserObj, error)
	GetContactsForUser(userUUID string, searchText string, maxContacts int) ([]models.UserObj, error)
	CreateContact(userUUID string, contactUUID string, createdTimestampServer int) error
	// Group
	IsMemberOfGroup(userUUID string, groupUUID string) (bool, error)
	GetConversationsForGroup(groupUUID string, maxConversations int) ([]models.ConversationObj, error)
	GetMembersForGroup(groupUUID string, searchText string, maxMembers int) ([]models.UserObj, error)
	UpdateGroup(groupUUID string, name string, timestampServer int, newMemberUUID string) error
	CreateGroup(name string, handle string, createdTimestampServer int, photoURI string, newMemberUUIDs []string) error
	// Conversation
	UpdateConversation(conversationUUID string, topic string, timestampServer int, tagName string) error
	CreateConversation(groupUUID string, topic string, tagNames []string, createdTimestampServer int, photoURI string) error
	// Messages
	GetLastXMessages(conversationUUID string, X int, latestTimestampServer int) ([]models.MessageObj, error)
	InsertMessage(messageUUID string, messageText string, messageTimestamp int, senderUUID string, parentUUID null.String, conversationUUID string) ([]models.UserObj, error)
	// DB
	Close()
}

type dbHandler struct {
	db                  *sqlx.DB
	searchQueries       goyesql.Queries
	userQueries         goyesql.Queries
	groupQueries        goyesql.Queries
	messageQueries      goyesql.Queries
	conversationQueries goyesql.Queries
	tagQueries          goyesql.Queries
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
	conversationQueries := goyesql.MustParseFile(_conversationQueriesPath)
	tagQueries := goyesql.MustParseFile(_tagQueriesPath)
	dbh := &dbHandler{
		db:                  db,
		searchQueries:       searchQueries,
		userQueries:         userQueries,
		groupQueries:        groupQueries,
		messageQueries:      messageQueries,
		conversationQueries: conversationQueries,
		tagQueries:          tagQueries,
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
