require 'net/http'
require 'exchange_rate/er_logger'

module ExchangeRate
	class Fetch
		# Fetches an XML file from the URL specified and
		# stores it in a temporary file
		def self.get_to_file(url: ExchangeRate.configuration.url_daily)
			raise ArgumentError, 'Argument url is not String' unless url.is_a?(String)
			ErLogger.instance.logger.info("Fetching from #{url}")
			begin
				f = File.new(ExchangeRate.configuration.temp_file, 'w')
				Net::HTTP.get_response(URI(url)) do |response|
					if response.is_a?(Net::HTTPSuccess)
						# The body is passed to the block and read in fragments
						# since it is read from the socket
						response.read_body do |segments|
							f.write(segments)
						end
					else
						ErLogger.instance.logger.warn("Non-success response obtained from #{url}")
					end
				end
			rescue => e
				ErLogger.instance.logger.error(e.message)
			ensure
				f.close if f
			end
		end
	end
end