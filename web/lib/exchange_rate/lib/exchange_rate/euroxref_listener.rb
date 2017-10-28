require 'date'
require 'rexml/streamlistener'
include REXML
require 'exchange_rate/currency'
require 'exchange_rate/er_logger'
require 'exchange_rate/rate'

module ExchangeRate
  class EuroxrefListener
    include REXML::StreamListener

    def initialize()
      @exchange_per_day = { time: nil, rate_currency: [] }
     	@cube_cont = 0
     	@time = nil
      @currencies = nil # When set it holds a hash of currencies by name
    end
    
    def tag_start(name, attrs)
      if name == "Cube"
        if attrs.length == 1
        	@exchange_per_day[:time] = attrs["time"]
          @cube_cont += 1
        elsif attrs.length == 2
        	@exchange_per_day[:rate_currency] << {
            rate: attrs["rate"],
            currency: attrs["currency"]
          }
          @cube_cont += 1
        end
      end
    end

    def tag_end(name)
      if name == "Cube"
     	  @cube_cont -= 1
     	  if @cube_cont == 0
          persist
          @exchange_per_day = { time: nil, rate_currency: [] }
     	  end
      end
    end

    # Persists any currency in Currencies table and the rate/date associated in Rates.
    # Note that @currencies instance variable is memoized, i.e. only inserts in the database,
    # if not exists already, the currencies mentioned at the first Cube XML element.
    def persist()
      @currencies ||= @exchange_per_day[:rate_currency]
        .map{ |rc| rc[:currency] }
        .reduce({}) do |memo, name|
          if Currency.find_by_name(name).nil?
             Currency.create(name)
          end
          c = Currency.find_by_name(name)
          memo[c["name"]] = { id: c["id"], name: c["name"] }
          memo
        end
      date = Date.parse(@exchange_per_day[:time])
      ErLogger.instance.logger.info("Trying to persist rates for #{date.to_s}")
      @exchange_per_day[:rate_currency].each do |rc|
        Rate.create(date: date, value: rc[:rate].to_f, currency_id: @currencies[rc[:currency]][:id].to_i)
      end
    end
  end
end