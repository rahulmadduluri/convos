package db

import (
	"log"

	"models"
)

const (
	_findContactsForUser = "findContactsForUser"
)

func (dbh *dbHandler) GetContactsForUser(userUUID string, searchText string, maxContacts int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.userQueries[_findContactsForUser],
		map[string]interface{}{
			"user_uuid":    userUUID,
			"search_text":  wildcardSearch,
			"max_contacts": maxContacts,
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
