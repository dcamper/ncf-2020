IMPORT $.^.Share;

// Original data
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// Define a record structure for our validated dataset
ValidatedRec := RECORD
    Share.GSECRec;                          // Include original record definition
    BOOLEAN         is_invalid_flight;      // Append these field definitions
    BOOLEAN         is_invalid_date;
    BOOLEAN         is_invalid_location;
    // TODO: Add more validation indicator fields
    BOOLEAN         is_any_invalid;
END;

// Iterate over the original dataset, applying the transform to each record
validatedData := PROJECT
    (
        gsecData,
        TRANSFORM
            (
                ValidatedRec,
                SELF.is_invalid_flight := LEFT.Carrier = '' OR LEFT.FlightNumber = 0,
                SELF.is_invalid_date := LEFT.EffectiveDate = '' OR LEFT.DiscontinueDate = '',
                SELF.is_invalid_location := LEFT.DepartStationCode = '' OR LEFT.ArriveStationCode = '',
                // TODO: Assign values to indicator fields
                SELF.is_any_invalid := SELF.is_invalid_flight
                                        OR SELF.is_invalid_date
                                        OR SELF.is_invalid_location
                                        // TODO: Include new indicator fields here
                                        ,
                SELF := LEFT
            )
    );

// Show up to 100 records of invalid data
OUTPUT(validatedData(is_any_invalid), NAMED('invalid_records'));

// The logical pathname for our new file
outPath := '~' + Share._me + '::schedule_2019_validated';

// Save the validated data
OUTPUT
    (
        validatedData,          // dataset to save
        {validatedData},        // record structure of data
        outPath,                // logical pathname
        COMPRESSED, OVERWRITE   // options
    );
