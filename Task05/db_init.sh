#!/bin/bash

sqlite3 movies_rating.db < db_init.sql

sqlite3 movies_rating.db "alter table new_movies rename to movies;"
sqlite3 movies_rating.db "alter table new_genres rename to genres;"
sqlite3 movies_rating.db "alter table new_moviesGenres rename to moviesGenres;"
sqlite3 movies_rating.db "alter table new_occupation rename to occupation;"
sqlite3 movies_rating.db "alter table new_genders rename to genders;"
sqlite3 movies_rating.db "alter table new_users rename to users;"
sqlite3 movies_rating.db "alter table new_tags rename to tags;"
sqlite3 movies_rating.db "alter table new_usersTags rename to usersTags;"
sqlite3 movies_rating.db "alter table new_ratings rename to ratings;"

sqlite3 movies_rating.db < data_add.sql

