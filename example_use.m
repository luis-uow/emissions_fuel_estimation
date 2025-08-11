% Vectorized input example
d = [490, 1020, 4979];
s = [167, 180, 267];

fuel = emissions_fuel_model.compute_fuel_ask(d, s);
co2 = emissions_fuel_model.compute_co2_ask(d, s);
sox = emissions_fuel_model.compute_sox_ask(d, s);
water_vapour = emissions_fuel_model.compute_water_vapour_ask(d, s);
nox = emissions_fuel_model.compute_nox_ask(d, s);
co = emissions_fuel_model.compute_co_ask(d, s);

disp(table(d', s', fuel', co2', sox', water_vapour', nox', co', ...
   'VariableNames', {'Distance_km', 'Seats', 'Fuel_gASK', 'CO2_gASK', 'SOx_gASK', 'Water_vaour_g_ASK', 'NOx_gASK', 'CO_gASK'}));

