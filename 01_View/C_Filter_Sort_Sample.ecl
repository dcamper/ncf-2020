IMPORT $.^.Share;

// Dataset definition
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// New dataset with only a few fields
slimGSECData := TABLE(gsecData, {Carrier, FlightNumber, EffectiveDate, DiscontinueDate});

// Sort by effective date and flight number
sortedData := SORT(slimGSECData, EffectiveDate, FlightNumber);

// Filter down to only Delta flights starting in November 2019
filteredData := sortedData(Carrier = 'DL' AND EffectiveDate BETWEEN '20191101' AND '20191130');

OUTPUT(CHOOSEN(filteredData, 50), NAMED('sample_data'));

// Bonus: Check out the graph for optimizations

/******************************************************************************

Conceptually equal to:

    SELECT
        Carrier, FlightNumber, EffectiveDate, DiscontinueDate
    FROM
        flight_schedule_2019
    WHERE
        Carrier = "DL" AND EffectiveData >= "20191101" AND EffectiveData <= "20191130"
    ORDER BY
        EffectiveDate, FlightNumber
    LIMIT 50;

*******************************************************************************/
