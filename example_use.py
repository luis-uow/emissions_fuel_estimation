from pprint import pprint
from emissions_fuel_model import (
    compute_fuel_ask,
    compute_co2_ask,
    compute_nox_ask,
    compute_co_ask,
)

# Sample aircraft test cases
test_cases = [
    {"distance_km": 300, "available_seats": 70},   # Small regional
    {"distance_km": 2500, "available_seats": 150}, # Narrow-body, medium-haul
    {"distance_km": 9000, "available_seats": 300}, # Wide-body, long-haul
    {"distance_km": 150, "available_seats": 180, "force": True},  # Forcing validation override
    {"distance_km": 6000, "available_seats": 130, "force": True}, # Forcing long-range for small plane
	{"distance_km": 200, "available_seats": 72},
	{"distance_km": 490, "available_seats": 172},
	{"distance_km": 1020, "available_seats": 172},
	{"distance_km": 1984, "available_seats": 172},
	{"distance_km": 4979, "available_seats": 200},
	{"distance_km": 4979, "available_seats": 290},
	{"distance_km": 8022, "available_seats": 290}
]


print("=== Aircraft Emissions per ASK ===")
for case in test_cases:
    distance = case["distance_km"]
    seats = case["available_seats"]
    force = case.get("force", False)

    try:
        emissions = {
            "Distance (km)": distance,
            "Seats": seats,
            "Force Mode": force,
            "Fuel (g/ASK)": compute_fuel_ask(distance, seats, force),
            "CO2 (g/ASK)": compute_co2_ask(distance, seats, force),
            "NOx (g/ASK)": compute_nox_ask(distance, seats, force),
            "CO (g/ASK)": compute_co_ask(distance, seats, force),
        }
        pprint(emissions)
        print("-" * 50)
    except ValueError as e:
        print(f"Error for case {case}: {e}")
        print("-" * 50)


# Optional: Vector-style output for plotting or bulk use
print("\n=== Emissions by Distance (Fixed Aircraft) ===")
fixed_seats = 180
distances = list(range(200, 11000, 1000))

for d in distances:
    try:
        print(f"{d} km | Fuel: {compute_fuel_ask(d, fixed_seats):5.2f} | CO₂: {compute_co2_ask(d, fixed_seats):5.2f} | NOₓ: {compute_nox_ask(d, fixed_seats):5.2f} | CO: {compute_co_ask(d, fixed_seats):5.2f}")
    except Exception as e:
        print(f"{d} km | Error: {e}")

