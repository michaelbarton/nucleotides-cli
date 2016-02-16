PARAMS = {
  user:      "POSTGRES_USER",
  password:  "POSTGRES_PASSWORD",
  host:      "POSTGRES_HOST",
  dbname:    "POSTGRES_NAME"
}

def db
  return @conn if @conn

  params = Hash[PARAMS.map do |k,v|
    [k, ENV[v]]
  end]
  params[:port] = params[:host].split(':').last
  params[:host] = params[:host].split(':').first.gsub("//","")

  @conn ||= PG.connect(params)
  @conn.exec("set client_min_messages = warning")
  @conn
end

def execute_sql_file(path)
  fail("Fixture does not exist - #{path}") unless File.exists? path
  db.exec(File.read(path))
end

def execute_sql_fixture(fixture_name)
  execute_sql_file("test/fixtures/#{fixture_name}.sql")
end

def drop_all_tables
  db.exec("drop schema public cascade;")
  db.exec("create schema public;")
end

def create_benchmarks
  execute_sql_fixture("benchmarks")
end
