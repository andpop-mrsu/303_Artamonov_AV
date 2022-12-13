import pandas as pd
import sqlite3
import re

try:
    connect = sqlite3.connect("movies_rating.db")
    cursor = connect.cursor()
    connect.commit()
except:
    print("movies_rating.db already is exist")

sqlFile = open("db_init.sql", "w")

sqlFile.writelines(
    [
        "drop table if exists movies;\n",
        "drop table if exists ratings;\n",
        "drop table if exists tags;\n",
        "drop table if exists users;\n",
        "drop table if exists occupations;\n"

        """
create table movies
(
    id primary key,
    title  varchar(255),
    genres varchar(255),
    year date
);
        """,

        """
create table ratings
(
    id primary key,
    user_id   int,
    movie_id  int,
    rating    int,
    timestamp int
);
        """,

        """
create table tags
(
    id primary key,
    user_id int,
    movie_id int,
    tag varchar(255),
    timestamp int
);
        """,

        """
create table users
(
    id primary key,
    name varchar(255),
    email varchar(255),
    gender varchar(255),
    register_date date,
    occupation varchar(255)
);
        """
    ]
)


def generate_inserts_for_csv_files(table_name, file_name, auto_increments=False):
    lines = pd.read_csv(file_name)
    fields = lines.columns.tolist()

    sqlFile.writelines("""
insert into %(table_name)s values
""" % {
        "table_name": table_name,
    })

    for i in range(len(lines)):
        line = []
        for field in fields:
            line.append(lines[field][i])

        if auto_increments:
            line.insert(0, i + 1)

        content = []

        for elem in line:
            try:
                float(elem)
                content.append(str(elem))
            except:
                elem = elem.replace("\'", "")
                elem = elem.replace("\"", "")
                content.append("\'" + str(elem) + "\'")

        line = ",".join(content)

        insert = "\t(%(line)s)" % {
            "line": line,
        }
        sqlFile.writelines([insert])

        if i < len(lines) - 1:
            sqlFile.writelines(",\n")

    sqlFile.writelines(";\n\n")


generate_inserts_for_csv_files("ratings", "ratings.csv", auto_increments=True)
generate_inserts_for_csv_files("tags", "tags.csv", auto_increments=True)


def generate_inserts_for_txt_files(table_name, file_name):
    file = open(file_name)
    file_contents = file.readlines()

    sqlFile.writelines("""
insert into %(table_name)s values
""" % {
        "table_name": table_name
    })

    for i in range(len(file_contents)):
        file_content = file_contents[i].replace("\n", "")
        line = file_content.split("|")

        content = []
        for elem in line:
            try:
                float(elem)
                content.append(elem)
            except:
                elem = elem.replace("\'", "")
                elem = elem.replace("\"", "")
                content.append("\'" + elem + "\'")

        line = ",".join(content)

        insert = "\t(%(line)s)" % {
            "line": line
        }
        sqlFile.writelines([insert])

        if i < len(file_contents) - 1:
            sqlFile.writelines(",\n")

    sqlFile.writelines(";\n\n")


generate_inserts_for_txt_files("users", "users.txt")


def generate_inserts_for_movies():
    lines = pd.read_csv("movies.csv")
    fields = lines.columns.tolist()

    sqlFile.writelines("""
insert into movies values
""")

    for i in range(len(lines)):
        line = []
        for field in fields:
            line.append(lines[field][i])

        content = []

        for elem in line:
            try:
                float(elem)
                content.append(str(elem))
            except:
                elem = elem.replace("\'", "")
                elem = elem.replace("\"", "")
                content.append("\'" + str(elem) + "\'")

        line = ",".join(content)

        match = re.search(r"[(][0-9][0-9][0-9][0-9].[0-9][0-9][0-9][0-9][)]", content[1])
        if match is None:
            match = re.search(r"[(][0-9][0-9][0-9][0-9][)]", content[1])
        year = match[0].replace("(", "").replace(")", "") if match else None

        if year is None:
            line += ", null"
        else:
            line += ", \'" + year + "\'"

        insert = "\t(%(line)s)" % {
            "line": line,
        }
        sqlFile.writelines([insert])

        if i < len(lines) - 1:
            sqlFile.writelines(",\n")

    sqlFile.writelines(";\n\n")


generate_inserts_for_movies()
