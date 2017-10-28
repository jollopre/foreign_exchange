require 'sqlite3'
require 'exchange_rate/db'
require 'exchange_rate/er_logger'

module ExchangeRate
	class Currency
		# Returns first currency record that matches the argument passed, otherwise nil
		def self.find_by_name(name)
			raise ArgumentError, 'Argument is not string' unless name.is_a? String
			begin
				DB.instance.connection.results_as_hash = true
				DB.instance.connection.get_first_row('SELECT * FROM Currencies WHERE name = ?', [name])
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end 
		end
		# Returns every Currency found in the Currencies table
		def self.all
			begin
				DB.instance.connection.results_as_hash = true
				return DB.instance.connection.execute('SELECT * FROM Currencies')
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
			return []
		end
		# Creates a record into Currencies table with the given name passed as argument
		def self.create(name)
			raise ArgumentError, 'Argument is not string' unless name.is_a? String
			begin
				DB.instance.connection.execute('INSERT INTO Currencies(name) VALUES (?)', [name])
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end 
		end
	end
end