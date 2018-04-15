package db

import (
	"log"

	"models"
)

const (
	_getUser             = "getUser"
	_findUsers           = "findUsers"
	_findContactsForUser = "findContactsForUser"
	_updateContacts      = "updateContacts"
	_updateUserName      = "updateUserName"
	_updateUserHandle    = "updateUserHandle"
)

func (dbh *dbHandler) GetUser(mobileNumber string) (models.UserObj, error) {
	var obj models.UserObj

	rows, err := dbh.db.NamedQuery(
		dbh.userQueries[_getUser],
		map[string]interface{}{
			"mobile_number": mobileNumber,
		},
	)
	if err != nil {
		return obj, err
	}
	defer rows.Close()

	for rows.Next() {
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
		}
		return obj, err
	}
	return obj, err
}

func (dbh *dbHandler) UpdateUser(userUUID string, name string, handle string) error {
	if name != "" {
		_, err := dbh.db.NamedQuery(
			dbh.userQueries[_updateUserName],
			map[string]interface{}{
				"user_uuid": userUUID,
				"name":      name,
			},
		)
		return err
	} else if handle != "" {
		_, err := dbh.db.NamedQuery(
			dbh.userQueries[_updateUserHandle],
			map[string]interface{}{
				"user_uuid": userUUID,
				"handle":    handle,
			},
		)
		return err
	}
	return nil
}

func (dbh *dbHandler) GetUsers(searchText string, maxUsers int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.userQueries[_findUsers],
		map[string]interface{}{
			"search_text": wildcardSearch,
			"max_users":   maxUsers,
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

func (dbh *dbHandler) CreateContact(userUUID string, contactUUID string, createdTimestampServer int) error {
	_, err := dbh.db.NamedQuery(
		dbh.userQueries[_updateContacts],
		map[string]interface{}{
			"user_uuid":                userUUID,
			"contact_uuid":             contactUUID,
			"created_timestamp_server": createdTimestampServer,
		},
	)
	return err
}
