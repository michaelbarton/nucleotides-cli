import os, psycopg2

def reset_database():
    host, port = os.environ['POSTGRES_HOST'].split(':')
    conf = "dbname={} user={} password={} host={} port={}".format(
            os.environ['POSTGRES_NAME'],
            os.environ['POSTGRES_USER'],
            os.environ['POSTGRES_PASSWORD'],
            host.replace("//", ""),
            port)
    conn   = psycopg2.connect(conf)
    cursor = conn.cursor()
    cursor.execute("drop schema public cascade; create schema public;")
    with open("test/fixtures/benchmarks.sql", "r") as f:
        cursor.execute(f.read())
    conn.commit()
    cursor.close()
    conn.close()

