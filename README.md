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
ExchangeRate.init(url) | url data source specified, otherwise will default to ExchangeRate.Constants.URL_HISTORICAL. The steps carried out after invoking this method are: Fetching the XML file from the data source; Parsing it according to the Schema Definition from [http://www.ecb.int/vocabulary/2002-08-01/eurofxref](http://www.ecb.int/vocabulary/2002-08-01/eurofxref); Persisting locally on a sqlite database allocated at ExchangeRate.Constants.DBNAME. Note this method follows the steps mentioned before unless the sqlite database does not exist or it has no data persisted.
ExchangeRate.update(url) | url data source specified, otherwise will default to ExchangeRate.Constants.URL_HISTORICAL. This method always perform the steps of fetching, parsing and an attempt to persist data locally and becomes useful for feeding the database with new data on a regular basis (e.g. using scheduler cron).
ExchangeRate.reset | Destroys the database and permits methods like ExchangeRate.init to be fully executed again.
ExchangeRate.at({date, amount, from, to}) | Performs an exchange from currency 'from' to currency 'to'. Four non-positional parameters can be passed: date (as Date, defaults to today), amount (as Integer or Float, defaults to 1), from (as String representing the currency name, defaults to empty string) and to (as String representing the currency name, defaults to empty string). Two exception can be raised: ArgumentError or RuntimeError.

## Web application

A RoR application has been chosen to interact with the ExchangeRate library. Currently, only one controller (e.g. exchange_rates_controller.rb) is provided with the following actions:

Method | Description
------------ | -------------
exchange_rates#index | Queries the ExchangeRate library to retrieve the available Currencies and renders a HTML form located at web/app/views/exchange_rates/index.html.erb) together with a JS file. The JS file is allocated at (app/assets/javascripts/exchangeRatesIndex.js) and performs client validations together with an adequate handling of network requests to exchange_rates#at.
exchange_rates#at | Interacts with ExchangeRate.at by passing the parameters provided through the web client and returns a JSON output with result key for a valid conversion or detail message if any error is encountered (ArgumentError, RuntimeError).

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
