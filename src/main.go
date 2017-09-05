package main

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"log"
)

func main() {
	// Open up our database connection.
	db, err := sql.Open("mysql", "root:pass1@tcp(127.0.0.1:3306)/tuts")

	// if there is an error opening the connection, handle it
	if err != nil {
		log.Print(err.Error())
	}
	defer db.Close()

	// Execute the query
	_, err = db.Query("SELECT id, name FROM tags")
	if err != nil {
		panic(err.Error()) // proper error handling instead of panic in your app
	}

}
