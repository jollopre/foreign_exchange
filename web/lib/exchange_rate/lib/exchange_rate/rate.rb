require 'sqlite3'
require 'date'
require 'exchange_rate/db'
require 'exchange_rate/er_logger'

module ExchangeRate
	class Rate
		# Returns the rates for a given day passed
		def self.per_day(date: Date.today)
			raises ArgumentError, 'Argument date is not Date' unless date.is_a?(Date)
			begin
				return DB.instance.connection.execute(
					'SELECT *'\
					' FROM Rates'\
					' WHERE date=?', [date.to_s])
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
			return []
		end
		# Returns the value associated for a given currency name and date, otherwise nil
		def self.select_value(currency_name: nil, date: nil)
			raise ArgumentError, 'Argument is not string' unless currency_name.is_a? String
			raise ArgumentError, 'Argument is not date' unless date.is_a? Date
			begin
				DB.instance.connection.get_first_value('SELECT r.value'\
					' FROM Rates r, Currencies c'\
					' WHERE c.id=r.currency_id AND c.name=? AND r.date=?',
					[currency_name, date.to_s])
			rescue SQLite3::Exception => e
				ErLogger.instance.logger.error(e.message)
			end
		end
		# Saves a Rate object (or multiple objects) if date and currency_id do not already
		# exist in the db.
		# @param attributes can be a hash (date: nil, value: nil, currency_id: nil) or an Array
		def self.create(attrs)
			if attrs.is_a?(Array)
				attrs.each{ |a| create(a)}
			else
				raise ArgumentError, 'Argument is not date' unless attrs[:date].is_a? Date
				raise ArgumentError, 'Argument is not float' unless attrs[:value].is_a? Float
				raise ArgumentError, 'Argument is not integer'  unless attrs[:currency_id].is_a? Integer
				begin
					DB.instance.connection.execute(
						'INSERT INTO Rates (date, value, currency_id) '\
						'SELECT * FROM (SELECT ?, ?, ?) AS tmp '\
						'WHERE NOT EXISTS (SELECT 1 '\
						'FROM Rates WHERE date=? AND currency_id=? LIMIT 1)',
						[attrs[:date].to_s, attrs[:value], attrs[:currency_id],
						attrs[:date].to_s, attrs[:currency_id]])
				rescue SQLite3::Exception => e
					ErLogger.instance.logger.error(e.message)
				end
			end
		end
	end
end