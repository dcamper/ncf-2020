EXPORT AirportRec := RECORD
    UNSIGNED4	id;
    STRING		ident;
    STRING		airport_type;
    STRING		name;
    DECIMAL9_6	latitude;           // degrees
    DECIMAL9_6	longitude;          // degrees
    INTEGER2	elevation;          // feet
    STRING		continent;
    STRING		iso_country;
    STRING		iso_region;
    STRING		municipality;
    STRING		scheduled_service;
    STRING		gps_code;
    STRING		iata_code;
    STRING		local_code;
    STRING		home_link;
    STRING		wikipedia_link;
    STRING		keywords;
END;
