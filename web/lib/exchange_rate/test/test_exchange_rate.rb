require 'minitest/autorun'
require 'date'
require 'exchange_rate'
require 'exchange_rate/parser'
require 'exchange_rate/rate'

describe "ExchangeRate.configure" do
  before do
    ExchangeRate.configuration.reset
  end
  it "returns configuration defaults" do
    assert_equal(
      'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml',
      ExchangeRate.configuration.url_historical)
    assert_equal(
      'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml',
      ExchangeRate.configuration.url_daily
      )
    assert_equal(
      '/tmp/source.xml',
      ExchangeRate.configuration.temp_file
      )
    assert_equal(
      'db/exchange_rate.sqlite3',
      ExchangeRate.configuration.dbname
      )
  end
  it "changes configuration defaults" do
    ExchangeRate.configure do |c|
      c.url_historical = 'foo'
      c.url_daily = 'bar'
      c.temp_file = '/tmp/foo.xml'
      c.dbname = 'db/bar.sqlite3'
    end
    assert_equal('foo', ExchangeRate.configuration.url_historical)
    assert_equal('bar', ExchangeRate.configuration.url_daily)
    assert_equal('/tmp/foo.xml', ExchangeRate.configuration.temp_file)
    assert_equal('db/bar.sqlite3', ExchangeRate.configuration.dbname)
  end
  it "reset configuration defaults" do
    ExchangeRate.configure{ |c| c.url_historical = 'foo' }
    assert_equal('foo', ExchangeRate.configuration.url_historical)
    ExchangeRate.configuration.reset
    assert_equal(
      'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml',
      ExchangeRate.configuration.url_historical)
  end
end

describe "ExchangeRate.at"  do
  it "raises ArgumentError for a non-valid date" do
    e = assert_raises ArgumentError do
      ExchangeRate.at(date: 'foo')
    end
    assert_equal('Argument date is not date', e.message)
  end
  it "raises ArgumentError for a non-valid amount" do
    e = assert_raises ArgumentError do
      ExchangeRate.at(amount: 'foo')
    end
    assert_equal('Argument amount is not integer or float', e.message)
  end
  it "raises ArgumentError for a non-valid 'from' currency" do
    e = assert_raises ArgumentError do
      ExchangeRate.at(from: nil)
    end
    assert_equal('Argument from is not string', e.message)
  end
  it "raises ArgumentError for a non-valid 'to' currency" do
    e = assert_raises ArgumentError do
      ExchangeRate.at(to: nil)
    end
    assert_equal('Argumment to is not string', e.message)
  end
  it 'returns unit conversion from GBP to USD for 2017-11-10' do
    ExchangeRate.configuration.reset
    ExchangeRate.configure do |c|
      c.temp_file = './test/fixtures/daily.xml'
    end
    File.delete(ExchangeRate.configuration.dbname) if File.exist?(ExchangeRate.configuration.dbname)
    ExchangeRate::DB.clone.instance.schema_load
    ExchangeRate::Parser.parse
    assert_equal(1.319, ExchangeRate.at(date: Date.parse('2017-11-10'), from: 'GBP', to: 'USD'))
  end
end

describe "ExchangeRate.init" do
  #TODO
end
describe "ExchangeRate.update" do
  #TODO
end
describe "ExchangeRate.reset" do
  #TODO
end