classdef emissions_fuel_model
    methods (Static)
        function fuel_ask = compute_fuel_ask(distance_km, available_seats, force)
            if nargin < 3, force = false; end

            [distance_km, available_seats] = emissions_fuel_model.broadcast_inputs(distance_km, available_seats);
            emissions_fuel_model.validate_inputs(distance_km, available_seats, force);

            use_eq3 = emissions_fuel_model.should_use_eq3(distance_km, available_seats, force);

            fuel_ask = zeros(size(distance_km));
            % Equation 3 (Large aircraft)
            idx3 = use_eq3;
            fuel_ask(idx3) = ...
                0.7361 + 6651 ./ distance_km(idx3) + 5.989e-4 .* distance_km(idx3) + ...
                6.152e-2 .* available_seats(idx3) - 1.014e-6 .* distance_km(idx3) .* available_seats(idx3);

            % Equation 2 (Small aircraft)
            idx2 = ~use_eq3;
            fuel_ask(idx2) = ...
                34.67 + 6608 ./ distance_km(idx2) - 1.196e-3 .* distance_km(idx2) - ...
                0.1354 .* available_seats(idx2) + 1.338e-5 .* distance_km(idx2) .* available_seats(idx2);

            fuel_ask = round(fuel_ask, 2);
        end

        function co2_ask = compute_co2_ask(distance_km, available_seats, force)
            if nargin < 3, force = false; end
            fuel_ask = emissions_fuel_model.compute_fuel_ask(distance_km, available_seats, force);
            co2_ask = round(fuel_ask * 3.16, 2);
        end

        function nox_ask = compute_nox_ask(distance_km, available_seats, force)
            if nargin < 3, force = false; end

            [distance_km, available_seats] = emissions_fuel_model.broadcast_inputs(distance_km, available_seats);
            emissions_fuel_model.validate_inputs(distance_km, available_seats, force);

            use_eq5 = emissions_fuel_model.should_use_eq3(distance_km, available_seats, force);

            nox_ask = zeros(size(distance_km));
            % Equation 5 (Large aircraft)
            idx5 = use_eq5;
            nox_ask(idx5) = ...
                -1.427 + 152.1 ./ distance_km(idx5) + 143.5 ./ available_seats(idx5) + ...
                3.625e-6 .* distance_km(idx5) + 4.18e-3 .* available_seats(idx5);

            % Equation 4 (Small aircraft)
            idx4 = ~use_eq5;
            nox_ask(idx4) = ...
                0.1512 + 63.34 ./ distance_km(idx4) + 0.2954 ./ available_seats(idx4) + ...
                2.214e-6 .* distance_km(idx4) + 6.217e-4 .* available_seats(idx4);

            nox_ask = round(nox_ask, 2);
        end

        function co_ask = compute_co_ask(distance_km, available_seats, force)
            if nargin < 3, force = false; end

            [distance_km, available_seats] = emissions_fuel_model.broadcast_inputs(distance_km, available_seats);
            emissions_fuel_model.validate_inputs(distance_km, available_seats, force);

            use_eq7 = emissions_fuel_model.should_use_eq3(distance_km, available_seats, force);

            co_ask = zeros(size(distance_km));
            % Equation 7 (Large aircraft)
            idx7 = use_eq7;
            co_ask(idx7) = ...
                -0.5736 + 65.11 ./ distance_km(idx7) + 51.85 ./ available_seats(idx7) + ...
                2.489e-5 .* distance_km(idx7) + 1.411e-3 .* available_seats(idx7) - ...
                8.39e-8 .* distance_km(idx7) .* available_seats(idx7);

            % Equation 6 (Small aircraft)
            idx6 = ~use_eq7;
            co_ask(idx6) = ...
                0.08338 + 96.54 ./ distance_km(idx6) + 2.184 ./ available_seats(idx6) + ...
                2.433e-6 .* distance_km(idx6) - 8.602e-4 .* available_seats(idx6) - ...
                6.053e-8 .* distance_km(idx6) .* available_seats(idx6);

            co_ask = round(co_ask, 2);
        end
    end

    methods (Static, Access = private)
        function validate_inputs(distance_km, available_seats, force)
            if force, return; end
            if any(available_seats < 50 | available_seats > 365)
                error('Seats available out of range (50 - 365)');
            end
            if any(distance_km < 100 | distance_km > 12000)
                error('Distance out of range (100 - 12,000 km)');
            end
            if any(distance_km > 5000 & available_seats < 172)
                error('Flights over 5,000 km require at least 172 seats');
            end
            if any(available_seats >= 172 & distance_km < 200)
                error('Flights under 200 km are invalid for aircraft with 172+ seats');
            end
        end

        function use_large = should_use_eq3(distance_km, available_seats, force)
            if force
                use_large = (available_seats >= 172) | ...
                            (abs(available_seats - 172) < abs(available_seats - 50));
            else
                use_large = (available_seats >= 172 & available_seats <= 365) & ...
                            (distance_km >= 200 & distance_km <= 12000);
            end
        end

        function [dist_out, seats_out] = broadcast_inputs(distance_km, available_seats)
            % Ensure inputs are same size or broadcastable
            if isscalar(distance_km), distance_km = repmat(distance_km, size(available_seats)); end
            if isscalar(available_seats), available_seats = repmat(available_seats, size(distance_km)); end

            if ~isequal(size(distance_km), size(available_seats))
                error('Input dimensions must agree or be broadcastable.');
            end
            dist_out = distance_km;
            seats_out = available_seats;
        end
    end
end
