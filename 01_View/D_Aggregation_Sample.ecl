IMPORT $.^.Share;

// Dataset definition
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// Only records for flights outbound from Atlanta starting in November 2019
dataSubset := gsecData(DepartStationCode = 'ATL' AND EffectiveDate BETWEEN '20191101' AND '20191130');

// Count them by day of week
carrierCounts := TABLE
    (
        dataSubset,
        {
            Carrier,
            UNSIGNED2   num_monday := SUM(GROUP, IsOpMon),
            UNSIGNED2   num_tuesday := SUM(GROUP, IsOpTue),
            UNSIGNED2   num_wednesday := SUM(GROUP, IsOpWed),
            UNSIGNED2   num_thursday := SUM(GROUP, IsOpThu),
            UNSIGNED2   num_friday := SUM(GROUP, IsOpFri),
            UNSIGNED2   num_saturday := SUM(GROUP, IsOpSat),
            UNSIGNED2   num_sunday := SUM(GROUP, IsOpSun),
            UNSIGNED4   total := SUM(GROUP, IsOpMon + IsOpTue + IsOpWed + IsOpThu + IsOpFri + IsOpSat + IsOpSun)
        },
        Carrier
    );

// Sort the results by total outbound count, descending
sortedResults := SORT(carrierCounts, -total);

OUTPUT(sortedResults, NAMED('outbound_day_of_week'));

/******************************************************************************

Conceptually equal to:

    SELECT
        Carrier,
        SUM(IsOpMon) AS num_monday,
        SUM(IsOpTue) AS num_tuesday,
        SUM(IsOpWed) AS num_wednesday,
        SUM(IsOpThu) AS num_thursday,
        SUM(IsOpFri) AS num_friday,
        SUM(IsOpSat) AS num_saturday,
        SUM(IsOpSun) AS num_sunday,
        SUM(IsOpMon + IsOpTue + IsOpWed + IsOpThu + IsOpFri + IsOpSat) AS total
    FROM
        flight_schedule_2019
    WHERE
        DepartStationCode = "ATL" AND EffectiveData >= "20191101" AND EffectiveData <= "20191130"
    GROUP BY
        Carrier
    ORDER BY
        total DESC;

*******************************************************************************/
