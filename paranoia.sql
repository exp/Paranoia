--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.first_names DROP CONSTRAINT first_names_fkey_countries;
ALTER TABLE ONLY public.first_names DROP CONSTRAINT first_names_pkey;
ALTER TABLE ONLY public.first_names DROP CONSTRAINT first_name_unique_name;
ALTER TABLE ONLY public.countries DROP CONSTRAINT countries_unique_name;
ALTER TABLE ONLY public.countries DROP CONSTRAINT countries_pkey;
ALTER TABLE public.first_names ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.countries ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.first_names_id_seq;
DROP TABLE public.first_names;
DROP SEQUENCE public.countries_id_seq;
DROP TABLE public.countries;
DROP EXTENSION plpgsql;
DROP EXTENSION plperl;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plperl; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plperl WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plperl; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plperl IS 'PL/Perl procedural language';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name text NOT NULL,
    population bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.countries OWNER TO paul;

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.countries_id_seq OWNER TO paul;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: first_names; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE first_names (
    id integer NOT NULL,
    country integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.first_names OWNER TO paul;

--
-- Name: first_names_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE first_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.first_names_id_seq OWNER TO paul;

--
-- Name: first_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE first_names_id_seq OWNED BY first_names.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY first_names ALTER COLUMN id SET DEFAULT nextval('first_names_id_seq'::regclass);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: countries_unique_name; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_unique_name UNIQUE (name);


--
-- Name: first_name_unique_name; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY first_names
    ADD CONSTRAINT first_name_unique_name UNIQUE (country, name);


--
-- Name: first_names_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY first_names
    ADD CONSTRAINT first_names_pkey PRIMARY KEY (id);


--
-- Name: first_names_fkey_countries; Type: FK CONSTRAINT; Schema: public; Owner: paul
--

ALTER TABLE ONLY first_names
    ADD CONSTRAINT first_names_fkey_countries FOREIGN KEY (country) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

