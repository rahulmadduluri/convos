# Convos DB

1. Make sure go version is 1.9.3
2. Install go dependencies from go_dependencies
3. Run create_db_script.sql to populate database

To populate database run the following:
```
mysql -u root -p convos
source {local location of db-util folder}/create_db_script.sql
```

To start server, go to backend/go/src/ & run the following:

```
go run main/main.go
```
Server is running on Port 8000


Test API calls found in api/test/ and for queries in db/test/
