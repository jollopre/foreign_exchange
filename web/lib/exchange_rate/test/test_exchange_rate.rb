require 'minitest/autorun'
require 'date'
require 'exchange_rate'

describe "ExchangeRate.reset" do
  it "returns true when database exists and its destroyed" do
    ExchangeRate.update()
    assert(ExchangeRate.reset())
  end
  it "returns false when database does not exists" do
    ExchangeRate.reset()
    refute(ExchangeRate.reset())
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
end