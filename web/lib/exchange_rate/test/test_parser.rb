require 'minitest/autorun'
require 'exchange_rate/currency'
require 'exchange_rate/rate'
require 'exchange_rate/db'
require 'exchange_rate/parser'

describe 'ExchangeRate::Parser.parse' do
  before do
    ExchangeRate.configuration.reset
    ExchangeRate.configure do |c|
      c.temp_file = './test/fixtures/daily.xml'
      c.dbname = 'db/test_exchange_rate.sqlite3'
    end
    File.delete(ExchangeRate.configuration.dbname) if File.exist?(ExchangeRate.configuration.dbname)
    ExchangeRate::DB.clone.instance.schema_load
  end
  it 'raises ArgumentError for a non-string filename argument' do
    e = assert_raises(ArgumentError) do
      ExchangeRate::Parser.parse(filename: nil)
    end
    assert_equal('Argument filename is not String', e.message)
  end
  it 'persists 31 currencies after parsing daily file' do
    ExchangeRate::Parser.parse
    assert_equal(31, ExchangeRate::Currency.all.length)
  end
  it 'persists 31 rates for 2017-11-10' do
    ExchangeRate::Parser.parse
    assert_equal(31, ExchangeRate::Rate.per_day(date:Date.new(2017, 11, 10)).length)
  end
end