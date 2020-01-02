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

OUTPUT(CHOOSEN(slimGSECData, 50), NAMED('sample_data'));

/******************************************************************************

Conceptually equal to:

    SELECT
        Carrier, FlightNumber, EffectiveDate, DiscontinueDate
    FROM
        flight_schedule_2019
    LIMIT 50;

*******************************************************************************/
