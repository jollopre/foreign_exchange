require 'sqlite3'
require 'singleton'
require 'exchange_rate/er_logger'

module ExchangeRate
	class DB
		include Singleton
		attr_reader :connection
		
		def initialize
			@connection = nil
			connect()
		end

		# Attemps to connect to the database. If fails
		# raises SQLite3::Exception
		def connect
			@connection = SQLite3::Database.new(ExchangeRate.configuration.dbname) if @connection.nil?
		end
		# Closes database connection if it was open
		def disconnect
			@connection.close() if @connection
			@connection = nil
		end

		# Creates tables in the database if they do not exist already
		# Note, this operation does not overwrite the schema if already loaded.
		def schema_load
			begin
				@connection.execute('CREATE TABLE IF NOT EXISTS Currencies'\
					' (id INTEGER PRIMARY KEY ASC, name TEXT)');
				@connection.execute('CREATE TABLE IF NOT EXISTS Rates'\
					' (id INTEGER PRIMARY KEY ASC, date TEXT, value REAL, currency_id INTEGER)');
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
		end

		# Destroys the database
		def schema_destroy
			begin
				disconnect()
				if File.exist?(ExchangeRate.configuration.dbname)
					File.delete(ExchangeRate.configuration.dbname)
					return true 
				end
				return false
			rescue Exception => e
				ErLogger.instance.logger.error(e.message)
			end
			return false
		end
		# Checks whether or not exists data loaded. Used to intercept 
		# fetching and parsing at ExchangeRate.init if the database already has data
		def any_data?
			begin
				return @connection.get_first_value('SELECT 1 FROM Currencies LIMIT 1')
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
			return false
		end
	end
end