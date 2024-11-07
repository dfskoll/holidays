import holidays
ca = holidays.country_holidays('CA', subdiv='NL')
ca.get('2024-01-01')
print("##### There should be " + str(len(list(ca.items()))))


