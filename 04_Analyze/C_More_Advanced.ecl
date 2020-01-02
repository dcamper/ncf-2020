IMPORT $.^.Share;

// Original GSEC data
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// Reduce dataset to only those fields we need and count how many trips each carrier
// has scheduled; note how we handle departure/arrival cities
flightsBetweenAirports := TABLE
    (
        gsecData,
        {
            STRING3     city_code_1 := MIN(DepartCityCode, ArriveCityCode),
            STRING3     city_code_2 := MAX(DepartCityCode, ArriveCityCode),
            STRING3     carrier_code := Carrier,
            UNSIGNED4   num_trips := SUM(GROUP, IsOpMon + IsOpTue + IsOpWed + IsOpThu + IsOpFri + IsOpSat + IsOpSun)
        },
        MIN(DepartCityCode, ArriveCityCode), MAX(DepartCityCode, ArriveCityCode), Carrier
    );

// Purely for reporting purposes:  Show how many city pairs we're dealing with
uniqueCityPairs := TABLE(flightsBetweenAirports, {city_code_1, city_code_2}, city_code_1, city_code_2);
OUTPUT(COUNT(uniqueCityPairs), NAMED('num_city_pairs'));

// Append name of first city
cityName1 := JOIN
    (
        flightsBetweenAirports,
        Share.Cities,
        LEFT.city_code_1 = RIGHT.city_code,
        TRANSFORM
            (
                {
                    RECORDOF(LEFT),
                    UTF8    city_name_1
                },
                SELF.city_name_1 := RIGHT.city_name,
                SELF := LEFT
            )
    );

// Append name of second city
cityName2 := JOIN
    (
        cityName1,
        Share.Cities,
        LEFT.city_code_2 = RIGHT.city_code,
        TRANSFORM
            (
                {
                    RECORDOF(LEFT),
                    UTF8    city_name_2
                },
                SELF.city_name_2 := RIGHT.city_name,
                SELF := LEFT
            )
    );

// Append airline name
carrierName := JOIN
    (
        cityName2,
        Share.Airlines,
        LEFT.carrier_code = RIGHT.iata_code,
        TRANSFORM
            (
                {
                    RECORDOF(LEFT),
                    STRING  carrier_name
                },
                SELF.carrier_name := RIGHT.airline,
                SELF := LEFT
            )
    );

// Group the data around city pairs
sortForGroup := SORT(carrierName, city_code_1, city_code_2);
groupedData := GROUP(sortForGroup, city_code_1, city_code_2);

// When applied against grouped data, TOPN operates on each virtual subset of data independently
mostFlights := TOPN(groupedData, 1, -num_trips);

// Show the first 1000 records
OUTPUT(CHOOSEN(mostFlights, 1000), NAMED('most_flight_sample'));
