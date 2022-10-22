#!/bin/bash

#pip3 install pandas
python3 make_db_init.py

sqlite3 movies_rating.db < db_init.sql