EXPORT AirlinesRec := RECORD
    UNSIGNED4	id;
    STRING		airline;
    STRING		alias;
    STRING3 	iata_code;
    STRING3 	icao_code;
    STRING		call_sign;
    STRING		country;
    STRING1		is_active;
END;
