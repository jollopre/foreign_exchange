module ExchangeRate
	class Configuration
		attr_accessor :url_historical
		attr_accessor :url_daily
		attr_accessor :temp_file
		attr_accessor :dbname
		def initialize
			reset
		end
		def reset
			@url_historical = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
			@url_daily = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
			@temp_file = '/tmp/source.xml'
			@dbname = 'db/exchange_rate.sqlite3'
			self
		end
	end
end