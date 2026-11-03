RateCard.current returns RateSource.rates, which is slow. Cache the result in
RateCard.cache for 10 minutes: repeated calls within 10 minutes must not call
RateSource again, and the first call after that must refresh it.
