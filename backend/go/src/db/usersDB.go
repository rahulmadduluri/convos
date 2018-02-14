package db

import (
	"log"

	"models"
)

// list of queries
const (
	_findPeopleForUser  = "findPeopleForUser"
	_findPeopleForGroup = "findPeopleForGroup"
)

func (dbh *dbHandler) GetPeopleForUser(userUUID string, searchText string, maxPeople int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.userQueries[_findPeopleForUser],
		map[string]interface{}{
			"user_uuid":   userUUID,
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

func (dbh *dbHandler) GetPeopleForGroup(groupUUID string, searchText string, maxPeople int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.userQueries[_findPeopleForGroup],
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
