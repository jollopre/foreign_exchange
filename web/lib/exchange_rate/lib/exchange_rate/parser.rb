require 'rexml/document'
require 'exchange_rate/euroxref_listener'
require 'exchange_rate/er_logger'

module ExchangeRate
	class Parser
		# Parses an XML filename specified through a custom stream listener
		# for euroxref
		def self.parse(filename: ExchangeRate.configuration.temp_file)
			raise ArgumentError, 'Argument filename is not String' unless filename.is_a?(String)
			ErLogger.instance.logger.info("Parsing data from file #{filename}")
			begin
				f = File.new(filename, 'r')
				REXML::Document.parse_stream(f, EuroxrefListener.new)
			rescue => e
				ErLogger.instance.logger.error(e.message)
			ensure
				f.close if f
			end
		end
	end
end