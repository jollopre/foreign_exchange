require 'singleton'
require 'logger'

module ExchangeRate
	class ErLogger
		include Singleton
		attr_reader :logger
		
		def initialize
			@logger = Logger.new(STDOUT)
			@logger.level = Logger::INFO
			@logger.datetime_format = '%Y-%m-%d %H:%M:%S'
		end
	end
end