package db

import (
	"log"

	"models"
)

// list of queries
const (
	_findUsersByUsername = "findUsersByUsername"
)

func (dbh *dbhandler) GetUsers(name string) []models.User {
	rows, err := dbh.db.Queryx(dbh.userQueries[_findUsersByUsername], "%"+name+"%")
	if err != nil {
		log.Fatal("query error", err)
	}
	defer rows.Close()
	var objs []models.User
	for rows.Next() {
		var obj models.User
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error", err)
		}
		objs = append(objs, obj)
	}
	err = rows.Err()
	if err != nil {
		log.Fatal(err)
	}
	return objs
}
