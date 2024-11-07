import holidays
from holidays import utils as hutils

for (country, subdivisions) in hutils.list_supported_countries().items():
    print("# COUNTRY %s" % (country))
    x = holidays.country_holidays(country)
    x.get('2024-01-01')
    for subdiv in subdivisions:
        print("# SUBDIV %s" % (subdiv))
        x = holidays.country_holidays(country, subdiv=subdiv)
        x.get('2024-01-01')


