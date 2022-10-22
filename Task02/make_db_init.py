import pandas as pd
import sqlite3

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

        """
create table movies
(
    id primary key,
    title  varchar(255),
    genres varchar(255)
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
                content.append("\t" + str(elem))
            except:
                elem = elem.replace("\'", "")
                elem = elem.replace("\"", "")
                content.append("\t\'" + str(elem) + "\'")

        line = ",\n".join(content)

        insert = """
insert into %(table_name)s values (
%(line)s
);
                """ % {
            "line": line,
            "table_name": table_name
        }
        sqlFile.writelines([insert])


generate_inserts_for_csv_files("movies", "movies.csv")
generate_inserts_for_csv_files("ratings", "ratings.csv", auto_increments=True)
generate_inserts_for_csv_files("tags", "tags.csv", auto_increments=True)


def generate_inserts_for_txt_files(table_name, file_name):
    file = open(file_name)
    file_contents = file.readlines()

    for file_content in file_contents:
        file_content = file_content.replace("\n", "")
        line = file_content.split("|")

        content = []
        for elem in line:
            try:
                float(elem)
                content.append("\t" + elem)
            except:
                elem = elem.replace("\'", "")
                elem = elem.replace("\"", "")
                content.append("\t\'" + elem + "\'")


        line = ",\n".join(content)

        insert = """
insert into %(table_name)s values (
%(line)s
);
                """ % {
            "line": line,
            "table_name": table_name
        }
        sqlFile.writelines([insert])


generate_inserts_for_txt_files("users", "users.txt")

# movies = pd.read_csv("movies.csv")


# ratings = pd.read_csv("ratings.csv")
# users = pd.read_csv("tags.csv")
#
# users = open("users.txt")
