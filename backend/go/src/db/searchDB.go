package db

import (
	"errors"
	"log"

	"models"

	"github.com/jmoiron/sqlx"
)

// list of queries
const (
	_findConversationObjs = "findConversationsForUserWithSearch"
	_findGroupsWithUUIDs  = "findGroupsWithUUIDs"
)

func (dbh *dbhandler) GetGroupObjs(userUUID string, searchText string) ([]models.GroupObj, error) {
	// Get All possible conversations
	conversationObjs, err := dbh.getConversationObjs(userUUID, searchText)
	if err != nil {
		return nil, err
	}

	// Get all groups with UUIDs found in ConversationObjs
	groupFoundMap := map[string]bool{}
	uniqueGroupUUIDs := []string{}
	for _, c := range conversationObjs {
		groupFoundMap[c.GroupUUID] = true
	}
	for k, _ := range groupFoundMap {
		uniqueGroupUUIDs = append(uniqueGroupUUIDs, k)
	}
	groups, err := dbh.getGroupsWithUUIDs(uniqueGroupUUIDs)
	if err != nil {
		return nil, err
	}

	groupObjs, err := combineGroupsAndConversations(groups, conversationObjs)
	return groupObjs, err
}

func (dbh *dbhandler) getConversationObjs(userUUID string, searchText string) ([]models.ConversationObj, error) {
	var objs []models.ConversationObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.searchQueries[_findConversationObjs],
		map[string]interface{}{
			"user_uuid":   userUUID,
			"search_text": wildcardSearch,
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

func (dbh *dbhandler) getGroupsWithUUIDs(groupUUIDs []string) ([]models.Group, error) {
	var groups []models.Group
	query, args, err := sqlx.In(dbh.searchQueries[_findGroupsWithUUIDs], groupUUIDs)
	if err != nil {
		return groups, err
	}
	query = dbh.db.Rebind(query)
	rows, err := dbh.db.Queryx(query, args...)
	if err != nil {
		return groups, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.Group
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
			continue
		}
		groups = append(groups, obj)
	}
	err = rows.Err()
	return groups, err
}

func combineGroupsAndConversations(groups []models.Group, conversationObjs []models.ConversationObj) ([]models.GroupObj, error) {
	var groupObjs []models.GroupObj
	var err error

	// map of groupUUID to conversation Objs
	groupConvoMap := map[string][]models.ConversationObj{}
	for _, c := range conversationObjs {
		groupConvoMap[c.GroupUUID] = append(groupConvoMap[c.GroupUUID], c)
	}

	for _, g := range groups {
		if groupConvoMap[g.UUID] == nil {
			err = errors.New("SearchDB: Combining Groups & Conversations failed. Could not find conversations for group UUID")
			break
		}
		obj := models.GroupObj{
			UUID:          g.UUID,
			Name:          g.Name,
			PhotoURL:      g.PhotoURL,
			Conversations: groupConvoMap[g.UUID],
		}
		groupObjs = append(groupObjs, obj)
	}

	return groupObjs, err
}
