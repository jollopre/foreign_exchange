module ExchangeRate
	module Constants
		URL_HISTORICAL = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
		URL_DAILY = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
		TEMP_FILE = '/tmp/source.xml'
		DBNAME = 'db/exchange_rate.sqlite3'
	end
end
