#!/usr/bin/env python
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
    y = holidays.country_holidays(country);
    for category in y.supported_categories:
        print("# CATEGORY %s" % (category))
        x = holidays.country_holidays(country, categories=category)
        x.get('2024-01-01')
    for subdiv in subdivisions:
        print("# SUBDIV %s" % (subdiv))
        for category in y.supported_categories:
            print("# CATEGORY %s" % (category))
            x = holidays.country_holidays(country, subdiv=subdiv, categories=category)
            x.get('2024-01-01')


