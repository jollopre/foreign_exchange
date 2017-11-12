# foreign_exchange
An utility to convert between available currencies for a given date. This repository provides a **Ruby library** for obtaining Foreign Exchange (FX) rates and a Ruby on Rails (RoR) **web application**.

## Exchange Rate Library

The code is allocated at web/lib/exchange_rate and it is packaged as a Ruby gem. If you want to test it, please run:

```
  cd web/lib/exchange_rate
  rake test
```

The different end-points to interact with the library are:

Method | Description
------------ | -------------
ExchangeRate.init | Fetches an XML file from a remote source specified at ExchangeRate.configuration.url_historical; parses it according to an XSD defined at [http://www.ecb.int/vocabulary/2002-08-01/eurofxref](http://www.ecb.int/vocabulary/2002-08-01/eurofxref); and persists the data pulled into a sqlite database allocated at ExchangeRate.configuration.dbname. Note, if the database is already populated, the above steps are ignored.
ExchangeRate.update | Feeds the database with new data from a remote source specified at ExchangeRate.configuration.url_daily. This method unlike ExchangeRate.init populates the database with new rates unless data for a given data/currency already exist. It becomes useful to be called within a scheduler cron on a daily basis.
ExchangeRate.reset | Destroys the database configured at ExchangeRate.configuration.dbname.
ExchangeRate.at({date, amount, from, to}) | Returns an exchange rate from currency 'from' to currency 'to' for a given date. If keyword date is missing, it defaults to Date.today. Similarly, if amount keyword is not given, it defaults to 1. The keywords from and to are expected to be strings (e.g. USD, GBP, PLN, etc).
### Configuration of the library

Should you want to change the default configuration options, below are the available variables that may be modified:

```
ExchangeRate.configure do |c|
  c.url_historical = 'foo'  # An URL to retrieve an historical (e.g. 90 days data) XML file for currencies/rates
  c.url_daily = 'bar' # An URL to retrieve a daily XML file for currencies/rates
  c.temp_file = '/tmp/foo.xml'  # A path for where the XML file will be cached for parsing/persisting
  c.dbname = 'db/bar.sqlite3' # A relative path for where the database will be allocated
end
```

## Web application

A RoR application is used to interact with the ExchangeRate library. Currently, only one controller (e.g. exchange_rates_controller.rb) is provided with the following actions:

Method | Description
------------ | -------------
exchange_rates#index | Asks the ExchangeRate library for the available Currencies and renders an HTML form located at web/app/views/exchange_rates/index.html.erb) together with a JS file. The JS file (app/assets/javascripts/exchangeRatesIndex.js) performs client-side validations and handles network responses to exchange_rates#at.
exchange_rates#at | Interacts with ExchangeRate.at through the parameters provided by the web client and returns a JSON string with a result key for a valid conversion or a detail message if any error is encountered (ArgumentError, RuntimeError, etc).

## Cron

There is set up a cronjob at the OS level that runs **ExchangeRate.update** method every day at 16:00 (UTC) and persists new data in the database for the library, if not already present there. See exchange-rate-cron and exchange-rate-cron.sh for specification details.

## How to install it

This utility runs on an isolated environment using Docker. If you have Docker installed locally, please type:
```
  docker build -t ubuntu-sqlite3-rails .
```
to build an Ubuntu OS image together with all the dependencies needed to run this code.
## How to run it

In order to run the app, please make sure that the image has been built successfully and afterwards you should be able to type:
```
  docker run --rm -it -v "$PWD/web":/usr/src/app -p 3000:3000 ubuntu-sqlite3-rails
```
which runs a container in an interactive mode that is auto-destroyed whenever is terminated. Note that a volume is mounted within the container to easy changing any code within web folder without needing to re-build the image. The web interface should be accessible through [http://localhost:3000/exchange_rates](http://localhost:3000/exchange_rates).
