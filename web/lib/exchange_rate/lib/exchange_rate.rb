require 'date'
require 'exchange_rate/constants'
require 'exchange_rate/pre_fetcher'
require 'exchange_rate/db'
require 'exchange_rate/rate'

module ExchangeRate
	# Initialises the ExchangeRate library by:
	# 1. Fetching the 90 days XML file from ECB
	# 2. Parsing the XML file on a event approach manner
	# 3. Persisting Currencies and Rates in their respective database table
	# Note, if the database already contains Currencies or Rates from the file provided
	# the existing DB records do not get updated
	def self.init
		DB.instance.schema_load
		if !DB.instance.any_data?
			p = PreFetcher.new(url: Constants::URL_HISTORICAL)
			p.fetch
			p.parse
		end
	end
	# Updates the ExchangeRate data by:
	# 1. Fetching the 1 day file from ECB
	# 2. Parsing the XML file on a event approach manner
	# 3. Persisting Rates in Rates table (if not exist already)
	def self.update
		DB.instance.schema_load()
		p = PreFetcher.new(url: Constants::URL_DAILY)
		p.fetch
		p.parse
	end
	# Destroys the ExchangeRate database
	def self.reset
		DB.instance.schema_destroy()
	end
	# Converts from one currency to another the amount passed for the date specified
	# Raises ArgumentError for any non-valid argument
	# Raises RuntimeError when a currency specified (e.g. from/to) does not have a rate for the date passed
	def self.at(date: Date.today, amount: 1, from: '', to: '')
		raise ArgumentError, 'Argument date is not date' unless date.is_a? Date
		raise ArgumentError, 'Argument amount is not integer or float' unless amount.is_a?(Integer) || amount.is_a?(Float)
		raise ArgumentError, 'Argument from is not string' unless from.is_a? String
		raise ArgumentError, 'Argumment to is not string' unless to.is_a? String
		from_rate = Rate.select_value(currency_name: from, date: date)
		to_rate = Rate.select_value(currency_name: to, date: date)
		raise "Could not find a rate for #{from} at #{date}" unless !from_rate.nil?
		raise "Could not find a rate for #{to} at #{date}" unless !to_rate.nil?
		return (amount/from_rate*to_rate).round(3)
	end
end