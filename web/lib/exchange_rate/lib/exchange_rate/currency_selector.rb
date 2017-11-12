module ExchangeRate
	class CurrencySelector
		def initialize
			@currencies = nil
		end

		# Memoizes a hash of Currency object given an Array of currency names.
		# The hash keys represent the currency name whereas the hash values represent Currency objects
		# Note, this method attempts to persist currency names if the don't exist in the db yet
		# Note, once the instance variable @currencies is set, it never gets re-assigned again
		def memoizify(currency_names = [])
			raise ArgumentError 'Array is expected for currency_names' unless currency_names.is_a?(Array)

			@currencies||= currency_names.reduce({}) do |memo, name|
 				Currency.create(name) if Currency.find_by_name(name).nil?
 				c = Currency.find_by_name(name)
 				memo[c['name']] = { id: c['id'], name: c['name'] } if !c.nil?
 				memo
 			end

		end
	end
end