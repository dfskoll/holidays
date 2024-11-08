import holidays
from holidays import utils as hutils

def get_long_country_name(code: str) -> str:
    for k, v in holidays.registry.COUNTRIES.items():
        if v[1] == code:
            return v[0]
    return code

for (country, subdivisions) in hutils.list_supported_countries().items():
    longname = get_long_country_name(country)
    subs = len(subdivisions)
    print("# COUNTRY %s %d %s" % (country, subs, longname))
    x = holidays.country_holidays(country)
    x.get('2024-01-01')
    for subdiv in subdivisions:
        print("# SUBDIV %s" % (subdiv))
        x = holidays.country_holidays(country, subdiv=subdiv)
        x.get('2024-01-01')


