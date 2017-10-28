require 'net/http'
require 'rexml/document'
require 'exchange_rate/constants'
require 'exchange_rate/euroxref_listener'
require 'exchange_rate/er_logger'

module ExchangeRate
	class PreFetcher
		def initialize(url:nil)
			raise ArgumentError, 'Argument url is not string' unless url.is_a? String
			@url = url
		end

		def fetch
			ErLogger.instance.logger.info("Fetching from #{@url}")
			begin
				f = File.new(Constants::TEMP_FILE, 'w')
				Net::HTTP.get_response(URI(@url)) do |response|
					if response.is_a?(Net::HTTPSuccess)
						# The body is passed to the block and read in fragments
						# since it is read from the socket
						response.read_body do |segments|
							f.write(segments)
						end
					else
						ErLogger.instance.logger.warn("Non-success response obtained from #{@url}")
					end
				end
			rescue => e
				ErLogger.instance.logger.error(e.message)
			ensure
				f.close if f
			end
		end

		def parse
			ErLogger.instance.logger.info("Parsing data from #{@url}")
			begin
				f = File.new(Constants::TEMP_FILE, 'r')
				Document.parse_stream(f, EuroxrefListener.new)
			rescue => e
				ErLogger.instance.logger.error(e.message)
			ensure
				f.close if f
			end
		end
	end
end