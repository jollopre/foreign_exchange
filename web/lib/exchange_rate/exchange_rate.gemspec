Gem::Specification.new do |s|
  s.name        = 'exchange_rate'
  s.version     = '0.0.0'
  s.date        = '2017-10-30'
  s.summary     = 'Exchange Rate summary'
  s.description = 'Exchange Rate gem according to European Central Bank (ECB)'
  s.authors     = ['Jose Lloret']
  s.email       = 'jollopre@gmail.com'
  s.files       = [
    'lib/exchange_rate.rb',
    'lib/exchange_rate/configuration.rb',
    'lib/exchange_rate/currency.rb',
    'lib/exchange_rate/currency_selector.rb',
    'lib/exchange_rate/db.rb',
    'lib/exchange_rate/euroxref_listener.rb',
    'lib/exchange_rate/logger.rb',
    'lib/exchange_rate/fetch.rb',
    'lib/exchange_rate/parser.rb',
    'lib/exchange_rate/rate.rb'
  ]
  s.homepage    =
    'http://rubygems.org/gems/exchange_rate'
  s.license       = 'MIT'
  s.add_runtime_dependency 'sqlite3', '1.3.13'
end