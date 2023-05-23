ALTER TABLE atlas_app.booking_cancellation_reason ADD COLUMN driver_cancellation_location_lat double precision;
ALTER TABLE atlas_app.booking_cancellation_reason ADD COLUMN driver_cancellation_location_lon double precision;
ALTER TABLE atlas_app.booking_cancellation_reason ADD COLUMN driver_dist_to_pickup bigint;

ALTER TABLE atlas_app.merchant_service_usage_config ADD COLUMN get_distances_for_cancel_ride text;
UPDATE atlas_app.merchant_service_usage_config SET get_distances_for_cancel_ride ='OSRM';
ALTER TABLE atlas_app.merchant_service_usage_config ALTER COLUMN get_distances_for_cancel_ride SET NOT NULL;
