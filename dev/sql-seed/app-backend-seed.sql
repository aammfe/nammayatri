--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3 (Debian 12.3-1.pgdg100+1)
-- Dumped by pg_dump version 12.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: atlas_app; Type: SCHEMA; Schema: -; Owner: atlas
--

CREATE SCHEMA atlas_app;


ALTER SCHEMA atlas_app OWNER TO atlas;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: case; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.case (
    id character(36) NOT NULL,
    name character varying(255),
    description character varying(1024),
    short_id character varying(36) NOT NULL,
    industry character varying(1024) NOT NULL,
    type character varying(255) NOT NULL,
    exchange_type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    valid_till timestamp with time zone NOT NULL,
    provider character varying(255),
    provider_type character varying(255),
    requestor character varying(255),
    requestor_type character varying(255),
    parent_case_id character varying(255),
    from_location_id character varying(36),
    to_location_id character varying(36),
    udf1 character varying(255),
    udf2 character varying(255),
    udf3 character varying(255),
    udf4 character varying(255),
    udf5 character varying(255),
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.case OWNER TO atlas;

--
-- Name: product_instance; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.product_instance (
    id character(36) NOT NULL,
    case_id character varying(255) NOT NULL,
    product_id character varying(255) NOT NULL,
    person_id character varying(255),
    quantity bigint NOT NULL,
    price numeric(8,2) NOT NULL,
    status character varying(255) NOT NULL,
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.product_instance OWNER TO atlas;

--
-- Name: comment; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.comment (
    id character(36) NOT NULL,
    commented_on_entity_id character(36) NOT NULL,
    commented_on_entity_type character varying(255) NOT NULL,
    commented_by character(36) NOT NULL,
    commented_by_entity_type character varying(255) NOT NULL,
    value character varying(1024) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    info character varying(255)
);


ALTER TABLE atlas_app.comment OWNER TO atlas;

--
-- Name: document; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.document (
    id character(36) NOT NULL,
    file_url character varying(1024) NOT NULL,
    filename character varying(255) NOT NULL,
    format character varying(255) NOT NULL,
    size bigint NOT NULL,
    file_hash character varying(1024) NOT NULL,
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.document OWNER TO atlas;

--
-- Name: entity_document; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.entity_document (
    id character(36) NOT NULL,
    entity_id character(36) NOT NULL,
    entity_type character varying(255) NOT NULL,
    document_id character(36) NOT NULL,
    document_type character varying(255) NOT NULL,
    created_by character(36) NOT NULL,
    created_by_entity_type character varying(255) NOT NULL,
    verified boolean NOT NULL,
    verified_by character(36),
    verified_by_entity_type character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    info character varying(255)
);


ALTER TABLE atlas_app.entity_document OWNER TO atlas;

--
-- Name: entity_tag; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.entity_tag (
    id character(36) NOT NULL,
    tagged_by character(36) NOT NULL,
    tagged_by_entity_id character varying(255) NOT NULL,
    entity_id character(36) NOT NULL,
    entity_type character varying(255) NOT NULL,
    tag_id character(36) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    info character varying(255)
);


ALTER TABLE atlas_app.entity_tag OWNER TO atlas;

--
-- Name: location; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.location (
    id character(36) NOT NULL,
    location_type character varying(255),
    lat double precision,
    long double precision,
    ward character varying(255),
    district character varying(255),
    city character varying(255),
    state character varying(255),
    country character varying(255),
    pincode character varying(255),
    address character varying(255),
    bound character varying(255),
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.location OWNER TO atlas;

--
-- Name: organization; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.organization (
    id character(36) NOT NULL,
    name character varying(255),
    gstin character varying(255),
    status character varying(255),
    type character varying(255),
    verified boolean NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    location_type character varying(255),
    lat double precision,
    long double precision,
    ward character varying(255),
    district character varying(255),
    city character varying(255),
    state character varying(255),
    country character varying(255),
    pincode bigint,
    address character varying(1024),
    bound text,
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.organization OWNER TO atlas;

--
-- Name: person; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.person (
    id character(36) NOT NULL,
    first_name character varying(255),
    middle_name character varying(255),
    last_name character varying(255),
    full_name character varying(255),
    role character varying(255) NOT NULL,
    gender character varying(255) NOT NULL,
    identifier_type character varying(255),
    email character varying(255),
    mobile_number character varying(255),
    mobile_country_code character varying(255),
    identifier character varying(255),
    rating character varying(255),
    verified boolean NOT NULL,
    udf1 character varying(255),
    udf2 character varying(255),
    status character varying(255) NOT NULL,
    organization_id character varying(255),
    device_token character varying(255),
    location_id character varying(255),
    description character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.person OWNER TO atlas;

--
-- Name: product; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.product (
    id character(36) NOT NULL,
    short_id character(36),
    name character varying(255),
    description character varying(1024),
    industry character varying(1024) NOT NULL,
    type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    valid_till timestamp with time zone NOT NULL,
    price numeric(10,2) NOT NULL,
    rating character varying(255),
    review character varying(255),
    udf1 character varying(255),
    udf2 character varying(255),
    udf3 character varying(255),
    udf4 character varying(255),
    udf5 character varying(255),
    info text,
    from_location_id character varying(255),
    to_location_id character varying(255),
    assigned_to character varying(36),
    organization_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.product OWNER TO atlas;

--
-- Name: registration_token; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.registration_token (
    id character(36) NOT NULL,
    auth_medium character varying(255) NOT NULL,
    auth_type character varying(255) NOT NULL,
    auth_value_hash character varying(1024) NOT NULL,
    token character varying(1024) NOT NULL,
    verified boolean NOT NULL,
    auth_expiry bigint NOT NULL,
    token_expiry bigint NOT NULL,
    attempts bigint NOT NULL,
    entity_id character(36) NOT NULL,
    entity_type character(36) NOT NULL,
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.registration_token OWNER TO atlas;

--
-- Name: tag; Type: TABLE; Schema: atlas_app; Owner: atlas
--

CREATE TABLE atlas_app.tag (
    id character(36) NOT NULL,
    created_by character(36) NOT NULL,
    created_by_entity_type character varying(255) NOT NULL,
    tag_type character varying(255) NOT NULL,
    tag character varying(255) NOT NULL,
    info text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE atlas_app.tag OWNER TO atlas;

--
-- Data for Name: case; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.case (id, name, description, short_id, industry, type, exchange_type, status, start_time, end_time, valid_till, provider, provider_type, requestor, requestor_type, parent_case_id, from_location_id, to_location_id, udf1, udf2, udf3, udf4, udf5, info, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: product_instance; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.product_instance (id, case_id, product_id, person_id, quantity, price, status, info, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.comment (id, commented_on_entity_id, commented_on_entity_type, commented_by, commented_by_entity_type, value, created_at, updated_at, info) FROM stdin;
\.


--
-- Data for Name: document; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.document (id, file_url, filename, format, size, file_hash, info, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: entity_document; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.entity_document (id, entity_id, entity_type, document_id, document_type, created_by, created_by_entity_type, verified, verified_by, verified_by_entity_type, created_at, updated_at, info) FROM stdin;
\.


--
-- Data for Name: entity_tag; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.entity_tag (id, tagged_by, tagged_by_entity_id, entity_id, entity_type, tag_id, created_at, updated_at, info) FROM stdin;
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.location (id, location_type, lat, long, ward, district, city, state, country, pincode, address, bound, info, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.organization (id, name, gstin, status, type, verified, enabled, location_type, lat, long, ward, district, city, state, country, pincode, address, bound, info, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.person (id, first_name, middle_name, last_name, full_name, role, gender, identifier_type, email, mobile_number, mobile_country_code, identifier, rating, verified, udf1, udf2, status, organization_id, device_token, location_id, description, created_at, updated_at) FROM stdin;
ec34eede-5a3e-4a41-89d4-7290a0d7a629	\N	\N	\N	\N	ADMIN	UNKNOWN	MOBILENUMBER	\N	+919999999999	\N	+919999999999	\N	f	\N	\N	INACTIVE	\N	\N	\N	\N	2020-05-12 10:23:01+00	2020-05-12 10:23:01+00
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.product (id, short_id, name, description, industry, type, status, start_time, end_time, valid_till, price, rating, review, udf1, udf2, udf3, udf4, udf5, info, from_location_id, to_location_id, assigned_to, organization_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: registration_token; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.registration_token (id, auth_medium, auth_type, auth_value_hash, token, verified, auth_expiry, token_expiry, attempts, entity_id, entity_type, info, created_at, updated_at) FROM stdin;
772453e2-d02b-494a-a4ac-ec1ea0027e18	SMS	OTP	3249	ea37f941-427a-4085-a7d0-96240f166672	f	3	365	3	ec34eede-5a3e-4a41-89d4-7290a0d7a629	USER                                	\N	2020-05-12 10:23:01+00	2020-05-12 10:23:01+00
\.


--
-- Data for Name: tag; Type: TABLE DATA; Schema: atlas_app; Owner: atlas
--

COPY atlas_app.tag (id, created_by, created_by_entity_type, tag_type, tag, info, created_at, updated_at) FROM stdin;
\.


--
-- Name: case idx_16386_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.case
    ADD CONSTRAINT idx_16386_primary PRIMARY KEY (id);


--
-- Name: product_instance idx_16394_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.product_instance
    ADD CONSTRAINT idx_16394_primary PRIMARY KEY (id);


--
-- Name: comment idx_16402_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.comment
    ADD CONSTRAINT idx_16402_primary PRIMARY KEY (id);


--
-- Name: document idx_16410_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.document
    ADD CONSTRAINT idx_16410_primary PRIMARY KEY (id);


--
-- Name: entity_document idx_16418_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.entity_document
    ADD CONSTRAINT idx_16418_primary PRIMARY KEY (id);


--
-- Name: entity_tag idx_16426_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.entity_tag
    ADD CONSTRAINT idx_16426_primary PRIMARY KEY (id);


--
-- Name: location idx_16434_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.location
    ADD CONSTRAINT idx_16434_primary PRIMARY KEY (id);


--
-- Name: organization idx_16442_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.organization
    ADD CONSTRAINT idx_16442_primary PRIMARY KEY (id);


--
-- Name: person idx_16451_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.person
    ADD CONSTRAINT idx_16451_primary PRIMARY KEY (id);

ALTER TABLE ONLY atlas_app.person
  ADD CONSTRAINT unique_mobile_number_country_code UNIQUE (mobile_country_code, mobile_number);

ALTER TABLE ONLY atlas_app.person
  ADD CONSTRAINT unique_identifier UNIQUE (identifier);

ALTER TABLE ONLY atlas_app.person
  ADD CONSTRAINT unique_email UNIQUE (email);

--
-- Name: product idx_16459_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.product
    ADD CONSTRAINT idx_16459_primary PRIMARY KEY (id);


--
-- Name: registration_token idx_16467_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.registration_token
    ADD CONSTRAINT idx_16467_primary PRIMARY KEY (id);


--
-- Name: tag idx_16475_primary; Type: CONSTRAINT; Schema: atlas_app; Owner: atlas
--

ALTER TABLE ONLY atlas_app.tag
    ADD CONSTRAINT idx_16475_primary PRIMARY KEY (id);


--
-- Name: idx_16386_provider; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16386_provider ON atlas_app.case USING btree (provider);


--
-- Name: idx_16386_requestor; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16386_requestor ON atlas_app.case USING btree (requestor);


--
-- Name: idx_16386_short_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE UNIQUE INDEX idx_16386_short_id ON atlas_app.case USING btree (short_id);


--
-- Name: idx_16394_case_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16394_case_id ON atlas_app.product_instance USING btree (case_id);


--
-- Name: idx_16394_product_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16394_product_id ON atlas_app.product_instance USING btree (product_id);


--
-- Name: idx_16402_commented_on_entity_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16402_commented_on_entity_id ON atlas_app.comment USING btree (commented_on_entity_id);


--
-- Name: idx_16402_commented_on_entity_type; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16402_commented_on_entity_type ON atlas_app.comment USING btree (commented_on_entity_type);


--
-- Name: idx_16418_document_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16418_document_id ON atlas_app.entity_document USING btree (document_id);


--
-- Name: idx_16418_entity_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16418_entity_id ON atlas_app.entity_document USING btree (entity_id);


--
-- Name: idx_16418_entity_type; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16418_entity_type ON atlas_app.entity_document USING btree (entity_type);


--
-- Name: idx_16426_entity_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16426_entity_id ON atlas_app.entity_tag USING btree (entity_id);


--
-- Name: idx_16426_entity_type; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16426_entity_type ON atlas_app.entity_tag USING btree (entity_type);


--
-- Name: idx_16426_tag_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16426_tag_id ON atlas_app.entity_tag USING btree (tag_id);


--
-- Name: idx_16434_city; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16434_city ON atlas_app.location USING btree (city);


--
-- Name: idx_16434_state; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16434_state ON atlas_app.location USING btree (state);


--
-- Name: idx_16442_city; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16442_city ON atlas_app.organization USING btree (city);


--
-- Name: idx_16442_district; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16442_district ON atlas_app.organization USING btree (district);


--
-- Name: idx_16442_pincode; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16442_pincode ON atlas_app.organization USING btree (pincode);


--
-- Name: idx_16442_ward; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16442_ward ON atlas_app.organization USING btree (ward);


--
-- Name: idx_16459_organization_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16459_organization_id ON atlas_app.product USING btree (organization_id);


--
-- Name: idx_16467_entity_id; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16467_entity_id ON atlas_app.registration_token USING btree (entity_id);


--
-- Name: idx_16467_entity_type; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16467_entity_type ON atlas_app.registration_token USING btree (entity_type);


--
-- Name: idx_16475_tag; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16475_tag ON atlas_app.tag USING btree (tag);


--
-- Name: idx_16475_tag_type; Type: INDEX; Schema: atlas_app; Owner: atlas
--

CREATE INDEX idx_16475_tag_type ON atlas_app.tag USING btree (tag_type);


--
-- PostgreSQL database dump complete
--

