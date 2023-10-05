require "sqlite3"

class DatabaseNotFoundError < StandardError
  def initialize
    super("Database not found")
  end
end

class Database
  attr_reader :database

  def initialize(logger)
    unless File.exist?("./database/database.db")
      Thread.new {
        logger.info "Создание файла базы данных..."
        FileUtils.mkdir("./database") unless Dir.exist?("./database")
        FileUtils.touch("./database/database.db")
        @database = SQLite3::Database.open("database/database.db")
        @database.execute("CREATE TABLE IF NOT EXISTS tickets(channelid INTEGER, discordid INTEGER, nickname TEXT)")
        sleep(1) # Let it think a bit
        logger.info "База данных создана"
      }
    else
      Thread.new {
        @database = SQLite3::Database.open("database/database.db")
        sleep(1) # Let it think a bit
        logger.info "База данных загружена"
      }
    end
  end

  def add_ticket(channel_id, user_id, nickname)
    raise DatabaseNotFoundError if @database.nil?
    @database.execute("INSERT INTO tickets(channelid, discordid, nickname) VALUES (?, ?, ?)", channel_id, user_id, nickname)
  end

  def get_ticket(channel_id)
    raise DatabaseNotFoundError if @database.nil?
    ticket = @database.execute("SELECT * FROM tickets WHERE channelid = ?", channel_id)
    return ticket
  end

  def delete_ticket(channel_id)
    raise DatabaseNotFoundError if @database.nil?
    @database.execute("DELETE FROM tickets WHERE channelid = ?", channel_id)
  end

  def clear_db
    raise DatabaseNotFoundError if @database.nil?
    @database.execute("TRUNCATE TABLE tickets")
  end
end
