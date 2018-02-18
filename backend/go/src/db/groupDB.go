package db

import (
	"log"

	"models"
)

const (
	_findPeopleForGroup = "findPeopleForGroup"
	_updateGroup        = "updateGroup"
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

func (dbh *dbHandler) GetGroup(groupUUID string) (models.GroupObj, error) {
	var obj models.GroupObj

	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_updateGroup],
		map[string]interface{}{
			"group_uuid": groupUUID,
		},
	)

	if err != nil {
		return obj, err
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

func (dbh *dbHandler) UpdateGroup(groupUUID string, name string, memberUUID string) (string, error) {
	var objs []models.GroupObj

	// 1. if name, update group with new name
	// 2. if memberUUID, update group_users with group:user id relation
	// 3. grab

	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_updateGroup],
		map[string]interface{}{
			"group_uuid": groupUUID,
			"name":       name,
			"max_people": maxPeople,
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
