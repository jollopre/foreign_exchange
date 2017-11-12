require 'minitest/autorun'
require 'net/http'
require 'exchange_rate/fetch'

describe 'ExchangeRate::Fetch.get_to_file' do
	before do
		ExchangeRate.configuration.reset
		File.delete(ExchangeRate.configuration.temp_file) if File.exist?(ExchangeRate.configuration.temp_file)
	end
	it 'raises ArgumentError for a non-string url argument' do
		e = assert_raises(ArgumentError) do
			ExchangeRate::Fetch.get_to_file(url: nil)
		end
		assert_equal('Argument url is not String', e.message)
	end
	it 'file it\'s non-zero for a valid data source' do
		ExchangeRate::Fetch.get_to_file
		refute(File.zero?(ExchangeRate.configuration.temp_file))
	end
	it 'file it\'s zero size for a non-valid data source' do
		ExchangeRate::Fetch.get_to_file(url: 'foo')
		assert(File.zero?(ExchangeRate.configuration.temp_file))
	end
end