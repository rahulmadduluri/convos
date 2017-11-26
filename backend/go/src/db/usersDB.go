package db

import (
	"log"

	"models"
)

// list of queries
const (
	_findUsersByUsername = "findUsersByUsername"
)

func (dbh *dbhandler) GetUsers(name string) ([]models.User, error) {
	var objs []models.User

	usernameSearch := "%" + name + "%"
	rows, err := dbh.db.Queryx(dbh.userQueries[_findUsersByUsername], usernameSearch)

	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.User
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
