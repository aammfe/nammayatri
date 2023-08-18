insert into atlas_bpp_dashboard.access_matrix (id, role_id, api_entity, user_access_type, created_at, updated_at, user_action_type) (select uuid_generate_v4() as id,id as role_id,'DRIVERS' as api_entity, 'USER_NO_ACCESS' as user_access_type, now() as created_at, now() as updated_at, 'BOOKING_WITH_VEHICLE_NUMBER_AND_PHONE' as user_action_type from atlas_bpp_dashboard.role) on conflict do nothing;

insert into atlas_bpp_dashboard.access_matrix (id, role_id, api_entity, user_access_type, created_at, updated_at, user_action_type) (select uuid_generate_v4() as id,id as role_id,'ISSUE' as api_entity, 'USER_NO_ACCESS' as user_access_type, now() as created_at, now() as updated_at, 'TICKET_STATUS_CALL_BACK' as user_action_type from atlas_bpp_dashboard.role) on conflict do nothing;

insert into atlas_bpp_dashboard.access_matrix (id, role_id, api_entity, user_access_type, created_at, updated_at, user_action_type) (select uuid_generate_v4() as id,id as role_id,'RIDES' as api_entity, 'USER_NO_ACCESS' as user_access_type, now() as created_at, now() as updated_at, 'TICKET_RIDE_LIST_API' as user_action_type from atlas_bpp_dashboard.role) on conflict do nothing;

