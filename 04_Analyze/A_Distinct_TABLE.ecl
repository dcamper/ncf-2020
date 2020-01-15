IMPORT $.^.Share;

// Original GSEC data
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// Create a dataset containing only unique carrier codes
uniqueCarriers := TABLE(gsecData, {Carrier}, Carrier);

/*****************************************************************************
 *
 * The above is conceptually similar to:
 *
 *      SELECT DISTINCT(Carrer) FROM flight_schedule_2019;
 *
 *****************************************************************************/

// Pull in carrier names as in some earlier code; note the different way of extending
// the record definition of an existing dataset

// Record structure including our appended fields
CarrierInfoRec := RECORD
    RECORDOF(uniqueCarriers);
    STRING          carrier_name;
END;

// Join original data with airline dataset, appending the carrier's name
carrierCodeAndName := JOIN
    (
        uniqueCarriers,
        Share.Airlines,
        LEFT.Carrier[..2] = RIGHT.iata_code,
        TRANSFORM
            (
                CarrierInfoRec,
                SELF.carrier_name := RIGHT.airline,
                // TODO: Assign values to the new fields
                SELF := LEFT
            ),
        LEFT OUTER, LOOKUP
    );

// Sort the results by carrier name
sortedByCarrierName := SORT(carrierCodeAndName, carrier_name);

// Output the results in the workunit
OUTPUT(sortedByCarrierName, NAMED('sortedByCarrierName'), ALL);



/******************************************************************************
 * TODO
 *
 * Perform the actions as above (looking up descriptions for codes) for either:
 *
 *      DepartCountryCode (see Share.Countries)
 *      DepartStationCode (see Share.Airports)
 *
 * You can either insert your new code here (be sure to use unique attribute
 * names!) or create a new file.
 ******************************************************************************/
