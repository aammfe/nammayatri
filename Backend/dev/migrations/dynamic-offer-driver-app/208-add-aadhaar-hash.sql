ALTER TABLE atlas_driver_offer_bpp.aadhaar_verification ADD COLUMN aadhaar_number_hash Text;
ALTER TABLE atlas_driver_offer_bpp.aadhaar_verification ADD COLUMN is_verified Boolean default true;
