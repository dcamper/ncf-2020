IMPORT $.^.Share;

// Original GSEC data
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// Record structure including our appended fields
AppendedRec := RECORD
    STRING          carrier_name;
    Share.GSECRec;
END;

// Join original data with airline dataset, appending the carrier's name
appendedData := JOIN
    (
        gsecData,
        Share.Airlines,
        LEFT.Carrier[..2] = RIGHT.iata_code,
        TRANSFORM
            (
                AppendedRec,
                SELF.carrier_name := RIGHT.airline,
                // TODO: Assign values to the new fields
                SELF := LEFT
            ),
        LEFT OUTER, LOOKUP
    );

// TODO: Given GSEC's departure and arrival country codes, append
// the names of those countries (both departure and arrival);
// country data can be found in Share.Countries.ecl

// The logical pathname for our new file
outPath := '~' + Share._me + '::schedule_2019_with_carrier_names';

// Save the result
OUTPUT
    (
        appendedData,           // dataset to save
        {appendedData},         // record structure of data
        outPath,                // logical pathname
        COMPRESSED, OVERWRITE   // options
    );
