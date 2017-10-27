To delete old databse, run
mysql -u root -p 
DROP DATABASE convos;
CREATE DATABASE convos;

To run script, run
mysql -u root -p convos < create_db_script.sql