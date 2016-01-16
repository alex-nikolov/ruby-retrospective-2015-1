def convert_to_bgn(price, currency)
  price_in_bgn = case currency
                   when :usd then price * 1.7408
                   when :eur then price * 1.9557
                   when :gbp then price * 2.6415
                   else price
                 end
  price_in_bgn.round(2)
end

def compare_prices(price_one, currency_one, price_two, currency_two)
  price_one_in_bgn = convert_to_bgn(price_one, currency_one)
  price_two_in_bgn = convert_to_bgn(price_two, currency_two)
  price_one_in_bgn <=> price_two_in_bgn
end