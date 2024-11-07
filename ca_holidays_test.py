import holidays
for (country) in holidays.EntityLoader.get_country_codes():
    print("# COUNTRY %s" % (country))
    x = holidays.country_holidays(country)
    x.get('2024-01-01')


