IMPORT $.^.Share;
IMPORT Std;

// Original data
gsecData := DATASET
    (
        '~flight::schedule_2019',   // Logical file pathname
        Share.GSECRec,              // Imported record definition
        FLAT                        // File type (FLAT = native Thor file format)
    );

// Record structure including our appended fields
AppendedRec := RECORD
    Share.GSECRec;
    UNSIGNED4       schedule_duration_in_days;
    UNSIGNED4       depart_minutes_after_midnight;
    UNSIGNED4       arrive_minutes_after_midnight;
    // TODO: Add more fields
END;

// Iterate over the original dataset, applying the transform to each record
appendedData := PROJECT
    (
        gsecData,
        TRANSFORM
            (
                AppendedRec,
                startedDate := Std.Date.FromStringToDate(LEFT.EffectiveDate, '%Y%m%d');
                stoppedDate := Std.Date.FromStringToDate(LEFT.DiscontinueDate, '%Y%m%d');
                SELF.schedule_duration_in_days := Std.Date.DaysBetween(startedDate, stoppedDate),
                // Note the substring operation, and casting of a string to an unsigned integer
                SELF.depart_minutes_after_midnight := ((UNSIGNED1)LEFT.DepartTimePassenger[1..2] * 60 + (UNSIGNED1)LEFT.DepartTimePassenger[2..4]),
                SELF.arrive_minutes_after_midnight := ((UNSIGNED1)LEFT.ArriveTimePassenger[1..2] * 60 + (UNSIGNED1)LEFT.ArriveTimePassenger[2..4]),
                // TODO: Assign values to the new fields
                SELF := LEFT
            )
    );

// The logical pathname for our new file
outPath := '~' + Share._me + '::schedule_2019_appended';

// Save the result
OUTPUT
    (
        appendedData,           // dataset to save
        {appendedData},         // record structure of data
        outPath,                // logical pathname
        COMPRESSED, OVERWRITE   // options
    );

/*******************************************************************************
 * Std.Date datatypes
 *
 *  Std.Date.Date_t - numeric date in YYYYMMDD format
 *  Std.Date.Time_t - numeric time in HHMMSS format
 *
 * Std.Date functions
 *
 *  Std.Date.FromStringToDate(STRING s, STRING format)
 *  Std.Date.FromStringToTime(STRING s, STRING format)
 *  Std.Date.Year(Date_t d)
 *  Std.Date.Month(Date_t d)
 *  Std.Date.Day(Date_t d)
 *  Std.Date.Hour(Time_t t)
 *  Std.Date.Minute(Time_t t)
 *  Std.Date.Second(Time_t t)
 *  Std.Date.DayOfWeek(Date_t d)
 *  Std.Date.DaysBetween(Date_t d1, Date_t d2)
 *  Std.Date.MonthsBetween(Date_t d1, Date_t d2)
 *  Std.Date.YearsBetween(Date_t d1, Date_t d2)
 ******************************************************************************/
