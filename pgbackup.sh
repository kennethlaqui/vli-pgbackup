#!/bin/bash
set -e

if [ -f .env ]; then

  export $(cat .env | sed 's/#.*//g' | xargs)

  status=$?
  
  printf $"Virtual Logic Inc. Custom Script For Docker Postgres Backup & Restore\n"
  
  echo
  
  echo "----- PostgreSQL Backup -----"
  
  echo
  
  echo "Step 1: Creating Backup Roles ..."
	  
  PGPASSWORD=$POSTGRES_PASSWORD pg_dumpall -g -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER   --no-tablespaces > globals.sql
  
  if [ ${status} -eq 0 ]; then
  
	echo "pg_dumpall: done: (Backup Roles) ... 100% "
	
  fi
  
  echo
  
  echo "Step 2: Creating Database Backup ..."
  
  PGPASSWORD=$POSTGRES_PASSWORD pg_dump -f company -Fc -Z 9 -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_DB
  
  if [ ${status} -eq 0 ]; then
  
	echo "pg_dump: done: (Database Backup) ... 100% "
	
  fi
  
  echo 
  
  echo "----- Docker Postgres -----"
  
  echo
  
  read -p "Would you like to generate SQL file for Docker Postgres? " -n 1 -r
  
  echo
  
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
  
	echo "Step 1: Generating Schema ..."
	
	pg_restore -f schema.sql -Fc -s --no-tablespaces company
	
	if [ ${status} -eq 0 ]; then
  
		echo "pg_restore: done: (Schema Created) ... 100% "
	
	fi
  
  fi
  
  echo
  
  echo "Step 2: Extracting Data ..."
  
  pg_restore -f data.sql -Fc -a --no-tablespaces company
  
  if [ ${status} -eq 0 ]; then
  
	echo "pg_restore: done: (Data Extracted) ... 100% "
	
  fi
  
  echo
  
  echo "Note: Copy 3 SQL files inside your docker directory."
  
  echo
  
  echo "Done"
  
  
else
  
	echo "Could not find .env file in this directory"
	
	echo
	
	read -p "Generate new .env file? " -n 1 -r
	
	if [[ $REPLY =~ ^[Yy] ]]; then
	
		touch .env
		
		echo -e "POSTGRES_HOST=\nPOSTGRES_DB=\nPOSTGRES_PORT=\nPOSTGRES_USER=\nPOSTGRES_PASSWORD=" > .env
		
		echo -e "\n"
		
		echo "Done. Define Your Database Connection Inside .env File."
		
	fi
  
fi
