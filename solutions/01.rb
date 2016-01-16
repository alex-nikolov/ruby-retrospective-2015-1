EXCHANGE_RATE = {
  bgn: 1,
  usd: 1.7408,
  eur: 1.9557,
  gbp: 2.6415,
}

def convert_to_bgn(price, currency)
  price_in_bgn = price * EXCHANGE_RATE[currency]
  price_in_bgn.round(2)
end

def compare_prices(first_price, first_currency, second_price, second_currency)
  first_price_in_bgn = convert_to_bgn(first_price, first_currency)
  second_price_in_bgn = convert_to_bgn(second_price, second_currency)

  first_price_in_bgn <=> second_price_in_bgn
end