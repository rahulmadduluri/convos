package db

import (
	"log"
	"time"

	"models"
)

const (
	_findPeopleForGroup = "findPeopleForGroup"
	_updateGroupName    = "updateGroupName"
	_updateGroupMembers = "updateGroupMembers"
)

func (dbh *dbHandler) GetPeopleForGroup(groupUUID string, searchText string, maxPeople int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_findPeopleForGroup],
		map[string]interface{}{
			"group_uuid":  groupUUID,
			"search_text": wildcardSearch,
			"max_people":  maxPeople,
		},
	)

	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.UserObj
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

func (dbh *dbHandler) UpdateGroup(groupUUID string, name string, newMemberUUID string) error {
	var err error = nil

	if name != "" {
		_, err := dbh.db.NamedQuery(
			dbh.groupQueries[_updateGroupName],
			map[string]interface{}{
				"group_uuid": groupUUID,
				"name":       name,
			},
		)
		return err
	} else if newMemberUUID != "" {
		createdTimestampServer := int(time.Now().Unix())
		_, err := dbh.db.NamedQuery(
			dbh.groupQueries[_updateGroupMembers],
			map[string]interface{}{
				"group_uuid":               groupUUID,
				"member_uuid":              newMemberUUID,
				"created_timestamp_server": createdTimestampServer,
			},
		)
		return err
	}
	log.Println(err)
	return err
}
