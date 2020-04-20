CREATE TABLE IF NOT EXISTS corbon_intensities(
    year_start timestamp,
    from_time timestamp,
    to_time timestamp,
    forecast int,
    actual int,
    intensity_index text,
  PRIMARY KEY(year_start, from_time, to_time))
  WITH CLUSTERING ORDER BY(from_time ASC);

-- SOURCE './priv/1587396609_create_corbon_intensities.cql'