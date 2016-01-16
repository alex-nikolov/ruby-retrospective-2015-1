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

def compare_prices(price_one, currency_one, price_two, currency_two)
  price_one_in_bgn = convert_to_bgn(price_one, currency_one)
  price_two_in_bgn = convert_to_bgn(price_two, currency_two)
  price_one_in_bgn <=> price_two_in_bgn
end