class ExchangeRatesController < ApplicationController
  def index
    currencies = ExchangeRate::Currency.all.map{ |c| c["name"] }
    render('index', locals: { from: currencies, to: currencies })
  end
  def at
    begin
    	converted = ExchangeRate.at(
    		date: Date.parse(params[:date]),
    		amount: params[:amount].to_i,
    		from: params[:from],
    		to: params[:to])
      render(json: { result: converted }, status: :ok)
    rescue ArgumentError => e # If user sends wrong args types
      render(json: { detail: e.message }, status: :bad_request )
    rescue RuntimeError => e # If there is not rate for from/to currency at date specified
      render(json: { detail: e.message }, status: :not_found )
    end
  end
end
