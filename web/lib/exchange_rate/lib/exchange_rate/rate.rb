require 'sqlite3'
require 'date'
require 'exchange_rate/db'
require 'exchange_rate/er_logger'

module ExchangeRate
	class Rate
		# Returns the value associated for a given currency name and date, otherwise nil
		def self.select_value(currency_name: nil, date: nil)
			raise ArgumentError, 'Argument is not string' unless currency_name.is_a? String
			raise ArgumentError, 'Argument is not date' unless date.is_a? Date
			begin
				DB.instance.connection.type_translation = true
				DB.instance.connection.get_first_value('SELECT r.value'\
					' FROM Rates r, Currencies c'\
					' WHERE c.id=r.currency_id AND c.name=? AND r.date=?',
					[currency_name, date.to_s])
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
		end
		# Creates a Rate record in the database if not exist already an entry for
		# currency_id and date specified
		def self.create(date: nil, value: nil, currency_id: nil)
			raise ArgumentError, 'Argument is not date' unless date.is_a? Date
			raise ArgumentError, 'Argument is not float' unless value.is_a? Float
			raise ArgumentError, 'Argument is not integer'  unless currency_id.is_a? Integer
			begin
				r = DB.instance.connection.get_first_value('SELECT 1'\
					' FROM Rates r'\
					' WHERE r.date=? AND currency_id=?',
					[date.to_s, currency_id])
				if r.nil?
					DB.instance.connection.execute('INSERT INTO Rates(date, value, currency_id)'\
						' VALUES (?, ?, ?)', [date.to_s, value, currency_id])
				end
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
		end
	end
end