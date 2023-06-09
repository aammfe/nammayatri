INSERT INTO atlas_person_location.driver_location (driver_id, lat, lon, point, created_at, coordinates_calculated_at, merchant_id) VALUES
	('favorit-suv-000000000000000000000000', 10.0739, 76.2733, '0101000020E6100000CC7F48BF7D1153404B598638D6252440', '2022-04-12 15:15:42.279179+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('favorit-sedan-0000000000000000000000', 10.0741, 76.2733, '0101000020E6100000CC7F48BF7D1153406744696FF0252440', '2022-04-12 15:15:42.280142+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('favorit-hatchback-000000000000000000', 10.0739, 76.2733, '0101000020E6100000CC7F48BF7D1153404B598638D6252440', '2022-04-12 15:15:42.27825+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('favorit-auto1-0000000000000000000000', 10.0739, 76.2733, '0101000020E6100000CC7F48BF7D1153403B598638D6252440', '2022-04-12 15:15:42.27825+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('favorit-auto2-0000000000000000000000', 10.0739, 76.2733, '0101000020E6100000CC7F48BF7D1153402B598638D6252440', '2022-04-12 15:15:42.27825+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-furthest_driver-00000000000000000', 13.005432, 77.59336, '0101000020E61000004BB0389CF965534029B4ACFBC7022A40', '2022-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-closest-driver-000000000000000000', 13.005432, 77.59336, '0101000020E6100000A471A8DF8566534023D74D29AFFD2940', '2022-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-driver-with-old-location-00000000', 13.005432, 77.59336, '0101000020E6100000A471A8DF8566534023D74D29AFFD2940', '2020-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-other-driver-00000000000000000000', 13.005432, 77.59336, '0101000020E61000008C2FDAE38566534065C6DB4AAFFD2940', '2022-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-suv-driver-0000000000000000000000', 13.005432, 77.59336, '0101000020E61000004BB0389CF9655340043DD4B6611C2A40', '2022-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-sedan-driver-00000000000000000000', 13.005432, 77.59336, '0101000020E61000004BB0389CF965534091D442C9E41C2A40', '2022-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit'),
	('ND-hatchback-driver-0000000000000000', 13.005432, 77.59336, '0101000020E61000004BB0389CF96553401E6CB1DB671D2A40', '2022-04-12 15:15:42.27627+00', now(), 'favorit0-0000-0000-0000-00000favorit');


ALTER TABLE atlas_person_location.driver_location ALTER COLUMN coordinates_calculated_at DROP DEFAULT;
ALTER TABLE atlas_person_location.driver_location ADD COLUMN updated_at timestamp with time zone NOT NULL DEFAULT now();
