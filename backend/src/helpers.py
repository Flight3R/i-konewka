def is_weekday_active(nof_watering_days):
    weakdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    watering_schedule = {}
    for day in weakdays:
        watering_schedule[day] = 0
    if nof_watering_days == '1':
        watering_schedule['monday'] = 1
    elif nof_watering_days == '2':
        watering_schedule['monday'] = 1
        watering_schedule['thursday'] = 1
    elif nof_watering_days == '3':
        watering_schedule['monday'] = 1
        watering_schedule['wednesday'] = 1
        watering_schedule['saturday'] = 1
    elif nof_watering_days == '7':
        for day in weakdays:
            watering_schedule[day] = 1
    else:
        watering_schedule['monday'] = 1
        watering_schedule['wednesday'] = 1
        watering_schedule['friday'] = 1
        watering_schedule['saturday'] = 1
    return watering_schedule