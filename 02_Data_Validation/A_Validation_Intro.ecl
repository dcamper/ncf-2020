DataRec := RECORD
    UNSIGNED4   random_num;
END;

// Inline generated dataset
someNumbers := DATASET
    (
        100,        // Number of records to create
        TRANSFORM   // Transform to apply for each record
            (
                DataRec,
                SELF.random_num := RANDOM()
            )
    );

OUTPUT(someNumbers, NAMED('someNumbers'));

// New record definition
ExtendedRec := RECORD
    DataRec;                // Include this previous record definition
    BOOLEAN     is_even;    // New field we're adding
END;

// PROJECT iterates over a dataset and applies a transform to each record
newData := PROJECT
    (
        someNumbers, // Dataset to process; reference as 'LEFT' within transform
        TRANSFORM
            (
                ExtendedRec,
                SELF.is_even := LEFT.random_num % 2 = 0,
                SELF := LEFT
            )
    );

OUTPUT(newData, NAMED('newData'));
