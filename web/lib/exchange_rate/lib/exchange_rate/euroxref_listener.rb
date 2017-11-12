require 'date'
require 'rexml/streamlistener'
require 'exchange_rate/currency'
require 'exchange_rate/currency_selector'
require 'exchange_rate/er_logger'
require 'exchange_rate/rate'

module ExchangeRate
  class EuroxrefListener
    include REXML::StreamListener

    def initialize()
      @exchange_per_day = { time: nil, rate_currency: [] }
     	@cube_cont = 0
     	@time = nil
      @currency_selector = CurrencySelector.new
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
      currencies = @currency_selector.memoizify(
        @exchange_per_day[:rate_currency].map{ |rc| rc[:currency] })
      date = Date.parse(@exchange_per_day[:time])
      ErLogger.instance.logger.info("Trying to persist rates for #{date.to_s}")
      Rate.create(
        @exchange_per_day[:rate_currency].map do |rc|
          { 
            date: date,
            value: rc[:rate].to_f,
            currency_id: currencies[rc[:currency]][:id] 
          }
        end 
      )
    end
  end
end