SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;
COMMENT ON DATABASE postgres IS 'default administrative connection database';
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
SET search_path = public, pg_catalog;
CREATE TYPE task_type AS ENUM (
    'produce',
    'evaluate'
);
ALTER TYPE task_type OWNER TO postgres;
CREATE FUNCTION benchmark_instance_external_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	NEW.external_id := md5(NEW.benchmark_type_id || '-' || NEW.input_data_file_id || '-' || NEW.product_image_instance_task_id);
	RETURN NEW;
END;$$;
ALTER FUNCTION public.benchmark_instance_external_id() OWNER TO postgres;
CREATE FUNCTION create_metadata_table(metadata_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
EXECUTE format('
  CREATE TABLE IF NOT EXISTS %I (
    id		serial		PRIMARY KEY,
    created_at	timestamp	DEFAULT current_timestamp,
    name	text		UNIQUE NOT NULL,
    description	text		NOT NULL,
    active	bool		NOT NULL DEFAULT true
  );', metadata_name || '_type');
END
$$;
ALTER FUNCTION public.create_metadata_table(metadata_name character varying) OWNER TO postgres;
CREATE FUNCTION populate_benchmark_instance() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO benchmark_instance(
	benchmark_type_id,
	input_data_file_id,
	product_image_instance_id,
	product_image_instance_task_id,
	file_instance_id)
SELECT
benchmark_type.id      AS benchmark_type_id,
input_data_file.id     AS data_file_id,
image_instance.id      AS image_instance_id,
image_instance_task.id AS image_instance_task_id,
file_instance.id       AS file_instance_id
FROM benchmark_type
LEFT JOIN benchmark_data      ON benchmark_data.benchmark_type_id = benchmark_type.id
LEFT JOIN input_data_file_set ON input_data_file_set.id = benchmark_data.input_data_file_set_id
LEFT JOIN input_data_file     ON input_data_file.input_data_file_set_id = input_data_file_set.id
LEFT JOIN file_instance       ON file_instance.id = input_data_file.file_instance_id
LEFT JOIN image_type          ON benchmark_type.product_image_type_id = image_type.id
INNER JOIN image_instance     ON image_type.id = image_instance.image_type_id
LEFT JOIN image_instance_task ON image_instance.id = image_instance_task.image_instance_id
WHERE NOT EXISTS(
	SELECT external_id FROM benchmark_instance WHERE benchmark_instance.external_id = external_id
);
END; $$;
ALTER FUNCTION public.populate_benchmark_instance() OWNER TO postgres;
CREATE FUNCTION populate_task() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO task (benchmark_instance_id, image_instance_task_id, task_type)
	SELECT
	benchmark_instance.id   AS benchmark_instance_id,
	image_instance_task.id  AS image_instance_task_id,
	'evaluate'::task_type   AS task_type
	FROM benchmark_instance
	LEFT JOIN benchmark_type      ON benchmark_type.id = benchmark_instance.benchmark_type_id
	LEFT JOIN image_instance      ON benchmark_type.evaluation_image_type_id = image_instance.image_type_id
	LEFT JOIN image_instance_task ON image_instance.id = image_instance_task.image_instance_id
UNION
	SELECT
	benchmark_instance.id	                          AS benchmark_instance_id,
	benchmark_instance.product_image_instance_task_id AS image_instance_task_id,
	'produce'::task_type                              AS task_type
	FROM benchmark_instance
EXCEPT
	SELECT
	benchmark_instance_id,
	image_instance_task_id,
	task_type
	FROM task
ORDER BY benchmark_instance_id, image_instance_task_id, task_type ASC;
END; $$;
ALTER FUNCTION public.populate_task() OWNER TO postgres;
SET default_tablespace = '';
SET default_with_oids = false;
CREATE TABLE benchmark_data (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    input_data_file_set_id integer NOT NULL,
    benchmark_type_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE benchmark_data OWNER TO postgres;
CREATE SEQUENCE benchmark_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE benchmark_data_id_seq OWNER TO postgres;
ALTER SEQUENCE benchmark_data_id_seq OWNED BY benchmark_data.id;
CREATE TABLE benchmark_instance (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    external_id text NOT NULL,
    benchmark_type_id integer NOT NULL,
    input_data_file_id integer NOT NULL,
    product_image_instance_id integer NOT NULL,
    product_image_instance_task_id integer NOT NULL,
    file_instance_id integer NOT NULL
);
ALTER TABLE benchmark_instance OWNER TO postgres;
CREATE SEQUENCE benchmark_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE benchmark_instance_id_seq OWNER TO postgres;
ALTER SEQUENCE benchmark_instance_id_seq OWNED BY benchmark_instance.id;
CREATE TABLE benchmark_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    product_image_type_id integer NOT NULL,
    evaluation_image_type_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE benchmark_type OWNER TO postgres;
CREATE SEQUENCE benchmark_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE benchmark_type_id_seq OWNER TO postgres;
ALTER SEQUENCE benchmark_type_id_seq OWNED BY benchmark_type.id;
CREATE TABLE event (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    task_id integer NOT NULL,
    success boolean NOT NULL
);
ALTER TABLE event OWNER TO postgres;
CREATE TABLE event_file_instance (
    id integer NOT NULL,
    event_id integer NOT NULL,
    file_instance_id integer NOT NULL
);
ALTER TABLE event_file_instance OWNER TO postgres;
CREATE SEQUENCE event_file_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE event_file_instance_id_seq OWNER TO postgres;
ALTER SEQUENCE event_file_instance_id_seq OWNED BY event_file_instance.id;
CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE event_id_seq OWNER TO postgres;
ALTER SEQUENCE event_id_seq OWNED BY event.id;
CREATE TABLE file_instance (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    file_type_id integer NOT NULL,
    sha256 text NOT NULL,
    url text NOT NULL
);
ALTER TABLE file_instance OWNER TO postgres;
CREATE SEQUENCE file_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE file_instance_id_seq OWNER TO postgres;
ALTER SEQUENCE file_instance_id_seq OWNED BY file_instance.id;
CREATE TABLE file_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE file_type OWNER TO postgres;
CREATE SEQUENCE file_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE file_type_id_seq OWNER TO postgres;
ALTER SEQUENCE file_type_id_seq OWNED BY file_type.id;
CREATE TABLE image_instance (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    image_type_id integer NOT NULL,
    name text NOT NULL,
    sha256 text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE image_instance OWNER TO postgres;
CREATE SEQUENCE image_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE image_instance_id_seq OWNER TO postgres;
ALTER SEQUENCE image_instance_id_seq OWNED BY image_instance.id;
CREATE TABLE image_instance_task (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    image_instance_id integer NOT NULL,
    task text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE image_instance_task OWNER TO postgres;
CREATE SEQUENCE image_instance_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE image_instance_task_id_seq OWNER TO postgres;
ALTER SEQUENCE image_instance_task_id_seq OWNED BY image_instance_task.id;
CREATE TABLE image_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE image_type OWNER TO postgres;
CREATE SEQUENCE image_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE image_type_id_seq OWNER TO postgres;
ALTER SEQUENCE image_type_id_seq OWNED BY image_type.id;
CREATE TABLE input_data_file (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    input_data_file_set_id integer NOT NULL,
    file_instance_id integer NOT NULL
);
ALTER TABLE input_data_file OWNER TO postgres;
CREATE SEQUENCE input_data_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE input_data_file_id_seq OWNER TO postgres;
ALTER SEQUENCE input_data_file_id_seq OWNED BY input_data_file.id;
CREATE TABLE input_data_file_set (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    input_data_source_id integer NOT NULL,
    platform_type_id integer NOT NULL,
    product_type_id integer NOT NULL,
    protocol_type_id integer NOT NULL,
    run_mode_type_id integer NOT NULL
);
ALTER TABLE input_data_file_set OWNER TO postgres;
CREATE SEQUENCE input_data_file_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE input_data_file_set_id_seq OWNER TO postgres;
ALTER SEQUENCE input_data_file_set_id_seq OWNED BY input_data_file_set.id;
CREATE TABLE input_data_source (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    source_type_id integer NOT NULL
);
ALTER TABLE input_data_source OWNER TO postgres;
CREATE SEQUENCE input_data_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE input_data_source_id_seq OWNER TO postgres;
ALTER SEQUENCE input_data_source_id_seq OWNED BY input_data_source.id;
CREATE TABLE input_data_source_reference_file (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    input_data_source_id integer NOT NULL,
    file_instance_id integer NOT NULL
);
ALTER TABLE input_data_source_reference_file OWNER TO postgres;
CREATE SEQUENCE input_data_source_reference_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE input_data_source_reference_file_id_seq OWNER TO postgres;
ALTER SEQUENCE input_data_source_reference_file_id_seq OWNED BY input_data_source_reference_file.id;
CREATE TABLE metric_instance (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    metric_type_id integer NOT NULL,
    event_id integer NOT NULL,
    value double precision NOT NULL
);
ALTER TABLE metric_instance OWNER TO postgres;
CREATE SEQUENCE metric_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE metric_instance_id_seq OWNER TO postgres;
ALTER SEQUENCE metric_instance_id_seq OWNED BY metric_instance.id;
CREATE TABLE metric_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE metric_type OWNER TO postgres;
CREATE SEQUENCE metric_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE metric_type_id_seq OWNER TO postgres;
ALTER SEQUENCE metric_type_id_seq OWNED BY metric_type.id;
CREATE TABLE platform_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE platform_type OWNER TO postgres;
CREATE SEQUENCE platform_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE platform_type_id_seq OWNER TO postgres;
ALTER SEQUENCE platform_type_id_seq OWNED BY platform_type.id;
CREATE TABLE product_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE product_type OWNER TO postgres;
CREATE SEQUENCE product_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE product_type_id_seq OWNER TO postgres;
ALTER SEQUENCE product_type_id_seq OWNED BY product_type.id;
CREATE TABLE protocol_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE protocol_type OWNER TO postgres;
CREATE SEQUENCE protocol_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE protocol_type_id_seq OWNER TO postgres;
ALTER SEQUENCE protocol_type_id_seq OWNED BY protocol_type.id;
CREATE TABLE run_mode_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE run_mode_type OWNER TO postgres;
CREATE SEQUENCE run_mode_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE run_mode_type_id_seq OWNER TO postgres;
ALTER SEQUENCE run_mode_type_id_seq OWNED BY run_mode_type.id;
CREATE TABLE source_type (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    name text NOT NULL,
    description text NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE source_type OWNER TO postgres;
CREATE SEQUENCE source_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE source_type_id_seq OWNER TO postgres;
ALTER SEQUENCE source_type_id_seq OWNED BY source_type.id;
CREATE TABLE task (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    benchmark_instance_id integer NOT NULL,
    image_instance_task_id integer NOT NULL,
    task_type task_type NOT NULL
);
ALTER TABLE task OWNER TO postgres;
CREATE VIEW task_expanded_fields AS
 WITH successful_event AS (
         SELECT DISTINCT ON (event.task_id) event.task_id
           FROM event
          WHERE (event.success = true)
        )
 SELECT task.id,
    task.benchmark_instance_id,
    benchmark_instance.external_id,
    task.task_type,
    image_instance.name AS image_name,
    image_instance_task.task AS image_task,
    image_instance.sha256 AS image_sha256,
    image_type.name AS image_type,
    (successful_event.task_id IS NOT NULL) AS complete
   FROM (((((task
     LEFT JOIN image_instance_task ON ((image_instance_task.id = task.image_instance_task_id)))
     LEFT JOIN image_instance ON ((image_instance.id = image_instance_task.image_instance_id)))
     LEFT JOIN image_type ON ((image_type.id = image_instance.image_type_id)))
     LEFT JOIN benchmark_instance ON ((benchmark_instance.id = task.benchmark_instance_id)))
     LEFT JOIN successful_event ON ((successful_event.task_id = task.id)));
ALTER TABLE task_expanded_fields OWNER TO postgres;
CREATE SEQUENCE task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE task_id_seq OWNER TO postgres;
ALTER SEQUENCE task_id_seq OWNED BY task.id;
ALTER TABLE ONLY benchmark_data ALTER COLUMN id SET DEFAULT nextval('benchmark_data_id_seq'::regclass);
ALTER TABLE ONLY benchmark_instance ALTER COLUMN id SET DEFAULT nextval('benchmark_instance_id_seq'::regclass);
ALTER TABLE ONLY benchmark_type ALTER COLUMN id SET DEFAULT nextval('benchmark_type_id_seq'::regclass);
ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);
ALTER TABLE ONLY event_file_instance ALTER COLUMN id SET DEFAULT nextval('event_file_instance_id_seq'::regclass);
ALTER TABLE ONLY file_instance ALTER COLUMN id SET DEFAULT nextval('file_instance_id_seq'::regclass);
ALTER TABLE ONLY file_type ALTER COLUMN id SET DEFAULT nextval('file_type_id_seq'::regclass);
ALTER TABLE ONLY image_instance ALTER COLUMN id SET DEFAULT nextval('image_instance_id_seq'::regclass);
ALTER TABLE ONLY image_instance_task ALTER COLUMN id SET DEFAULT nextval('image_instance_task_id_seq'::regclass);
ALTER TABLE ONLY image_type ALTER COLUMN id SET DEFAULT nextval('image_type_id_seq'::regclass);
ALTER TABLE ONLY input_data_file ALTER COLUMN id SET DEFAULT nextval('input_data_file_id_seq'::regclass);
ALTER TABLE ONLY input_data_file_set ALTER COLUMN id SET DEFAULT nextval('input_data_file_set_id_seq'::regclass);
ALTER TABLE ONLY input_data_source ALTER COLUMN id SET DEFAULT nextval('input_data_source_id_seq'::regclass);
ALTER TABLE ONLY input_data_source_reference_file ALTER COLUMN id SET DEFAULT nextval('input_data_source_reference_file_id_seq'::regclass);
ALTER TABLE ONLY metric_instance ALTER COLUMN id SET DEFAULT nextval('metric_instance_id_seq'::regclass);
ALTER TABLE ONLY metric_type ALTER COLUMN id SET DEFAULT nextval('metric_type_id_seq'::regclass);
ALTER TABLE ONLY platform_type ALTER COLUMN id SET DEFAULT nextval('platform_type_id_seq'::regclass);
ALTER TABLE ONLY product_type ALTER COLUMN id SET DEFAULT nextval('product_type_id_seq'::regclass);
ALTER TABLE ONLY protocol_type ALTER COLUMN id SET DEFAULT nextval('protocol_type_id_seq'::regclass);
ALTER TABLE ONLY run_mode_type ALTER COLUMN id SET DEFAULT nextval('run_mode_type_id_seq'::regclass);
ALTER TABLE ONLY source_type ALTER COLUMN id SET DEFAULT nextval('source_type_id_seq'::regclass);
ALTER TABLE ONLY task ALTER COLUMN id SET DEFAULT nextval('task_id_seq'::regclass);
INSERT INTO benchmark_data VALUES (1, '2016-02-16 19:25:19.771188', 1, 1, true);
INSERT INTO benchmark_data VALUES (2, '2016-02-16 19:25:19.771188', 1, 2, true);
SELECT pg_catalog.setval('benchmark_data_id_seq', 2, true);
INSERT INTO benchmark_instance VALUES (1, '2016-02-16 19:25:19.773218', '453e406dcee4d18174d4ff623f52dcd8', 1, 2, 2, 3, 3);
INSERT INTO benchmark_instance VALUES (2, '2016-02-16 19:25:19.773218', 'e61730e6717b1787cf09d44914ffb920', 1, 2, 1, 2, 3);
INSERT INTO benchmark_instance VALUES (3, '2016-02-16 19:25:19.773218', '6151f5ab282d90e4cee404433b271dda', 1, 2, 1, 1, 3);
INSERT INTO benchmark_instance VALUES (4, '2016-02-16 19:25:19.773218', '98c1d2a9d58ce748c08cf65dd3354676', 1, 1, 2, 3, 2);
INSERT INTO benchmark_instance VALUES (5, '2016-02-16 19:25:19.773218', '4f57d0ecf9622a0bd8a6e3f79c71a09d', 1, 1, 1, 2, 2);
INSERT INTO benchmark_instance VALUES (6, '2016-02-16 19:25:19.773218', '2f221a18eb86380369570b2ed147d8b4', 1, 1, 1, 1, 2);
SELECT pg_catalog.setval('benchmark_instance_id_seq', 6, true);
INSERT INTO benchmark_type VALUES (1, '2016-02-16 19:25:19.771188', 'illumina_isolate_reference_assembly', 'desc', 1, 3, true);
INSERT INTO benchmark_type VALUES (2, '2016-02-16 19:25:19.771188', 'short_read_preprocessing_reference_evaluation', 'desc', 2, 4, true);
SELECT pg_catalog.setval('benchmark_type_id_seq', 2, true);
SELECT pg_catalog.setval('event_file_instance_id_seq', 1, false);
SELECT pg_catalog.setval('event_id_seq', 1, false);
INSERT INTO file_instance VALUES (1, '2016-02-16 19:25:19.764867', 3, 'd421a4', 's3://ref');
INSERT INTO file_instance VALUES (2, '2016-02-16 19:25:19.768323', 2, '7673a', 's3://reads');
INSERT INTO file_instance VALUES (3, '2016-02-16 19:25:19.768323', 2, '24b5b01b08482053d7d13acd514e359fb0b726f1e8ae36aa194b6ddc07335298', 's3://nucleotides-testing/short-read-assembler/dummy.reads.fq.gz');
SELECT pg_catalog.setval('file_instance_id_seq', 3, true);
INSERT INTO file_type VALUES (1, '2016-02-16 19:25:19.761868', 'log', 'Free form text output from benchmarking tools', true);
INSERT INTO file_type VALUES (2, '2016-02-16 19:25:19.761868', 'short_read_fastq', 'Short read sequences in FASTQ format', true);
INSERT INTO file_type VALUES (3, '2016-02-16 19:25:19.761868', 'reference_fasta', 'Reference sequence in FASTA format', true);
INSERT INTO file_type VALUES (4, '2016-02-16 19:25:19.761868', 'contig_fasta', 'contigs', true);
SELECT pg_catalog.setval('file_type_id_seq', 4, true);
INSERT INTO image_instance VALUES (1, '2016-02-16 19:25:19.769647', 1, 'bioboxes/velvet', 'digest_1', true);
INSERT INTO image_instance VALUES (2, '2016-02-16 19:25:19.769647', 1, 'bioboxes/ray', 'digest_2', true);
INSERT INTO image_instance VALUES (3, '2016-02-16 19:25:19.769647', 3, 'bioboxes/quast', 'digest_4', true);
SELECT pg_catalog.setval('image_instance_id_seq', 3, true);
INSERT INTO image_instance_task VALUES (1, '2016-02-16 19:25:19.769647', 1, 'default', true);
INSERT INTO image_instance_task VALUES (2, '2016-02-16 19:25:19.769647', 1, 'careful', true);
INSERT INTO image_instance_task VALUES (3, '2016-02-16 19:25:19.769647', 2, 'default', true);
INSERT INTO image_instance_task VALUES (4, '2016-02-16 19:25:19.769647', 3, 'default', true);
SELECT pg_catalog.setval('image_instance_task_id_seq', 4, true);
INSERT INTO image_type VALUES (1, '2016-02-16 19:25:19.761868', 'short_read_assembler', 'desc', true);
INSERT INTO image_type VALUES (2, '2016-02-16 19:25:19.761868', 'short_read_preprocessor', 'desc', true);
INSERT INTO image_type VALUES (3, '2016-02-16 19:25:19.761868', 'reference_assembly_evaluation', 'desc', true);
INSERT INTO image_type VALUES (4, '2016-02-16 19:25:19.761868', 'short_read_preprocessing_reference_evaluation', 'desc', true);
SELECT pg_catalog.setval('image_type_id_seq', 4, true);
INSERT INTO input_data_file VALUES (1, '2016-02-16 19:25:19.768323', true, 1, 2);
INSERT INTO input_data_file VALUES (2, '2016-02-16 19:25:19.768323', true, 1, 3);
SELECT pg_catalog.setval('input_data_file_id_seq', 2, true);
INSERT INTO input_data_file_set VALUES (1, '2016-02-16 19:25:19.766949', true, 'jgi_isolate_microbe_2x150_1', 'desc', 2, 1, 1, 1, 1);
SELECT pg_catalog.setval('input_data_file_set_id_seq', 1, true);
INSERT INTO input_data_source VALUES (1, '2016-02-16 19:25:19.764867', 'kansas_farm_soil', 'desc', true, 1);
INSERT INTO input_data_source VALUES (2, '2016-02-16 19:25:19.764867', 'ecoli_k12', 'desc', true, 2);
SELECT pg_catalog.setval('input_data_source_id_seq', 2, true);
INSERT INTO input_data_source_reference_file VALUES (1, '2016-02-16 19:25:19.764867', true, 2, 1);
SELECT pg_catalog.setval('input_data_source_reference_file_id_seq', 1, true);
SELECT pg_catalog.setval('metric_instance_id_seq', 1, false);
INSERT INTO metric_type VALUES (1, '2016-02-16 19:25:19.761868', 'ng50', 'desc', true);
INSERT INTO metric_type VALUES (2, '2016-02-16 19:25:19.761868', 'lg50', 'desc', true);
SELECT pg_catalog.setval('metric_type_id_seq', 2, true);
INSERT INTO platform_type VALUES (1, '2016-02-16 19:25:19.761868', 'illumina', 'Illumina sequencing platform', true);
SELECT pg_catalog.setval('platform_type_id_seq', 1, true);
INSERT INTO product_type VALUES (1, '2016-02-16 19:25:19.761868', 'random', 'DNA extraction followed by random DNA sequencing', true);
SELECT pg_catalog.setval('product_type_id_seq', 1, true);
INSERT INTO protocol_type VALUES (1, '2016-02-16 19:25:19.761868', 'nextera', 'Illumina nextera protocol', true);
SELECT pg_catalog.setval('protocol_type_id_seq', 1, true);
INSERT INTO run_mode_type VALUES (1, '2016-02-16 19:25:19.761868', '2x150_270', 'An insert size of 270bp sequenced with 2x150bp reads', true);
SELECT pg_catalog.setval('run_mode_type_id_seq', 1, true);
INSERT INTO source_type VALUES (1, '2016-02-16 19:25:19.761868', 'metagenome', 'A mixture of multiple genomes', true);
INSERT INTO source_type VALUES (2, '2016-02-16 19:25:19.761868', 'microbe', 'A single isolated microbe', true);
SELECT pg_catalog.setval('source_type_id_seq', 2, true);
INSERT INTO task VALUES (1, '2016-02-16 19:25:19.773218', 1, 3, 'produce');
INSERT INTO task VALUES (2, '2016-02-16 19:25:19.773218', 1, 4, 'evaluate');
INSERT INTO task VALUES (3, '2016-02-16 19:25:19.773218', 2, 2, 'produce');
INSERT INTO task VALUES (4, '2016-02-16 19:25:19.773218', 2, 4, 'evaluate');
INSERT INTO task VALUES (5, '2016-02-16 19:25:19.773218', 3, 1, 'produce');
INSERT INTO task VALUES (6, '2016-02-16 19:25:19.773218', 3, 4, 'evaluate');
INSERT INTO task VALUES (7, '2016-02-16 19:25:19.773218', 4, 3, 'produce');
INSERT INTO task VALUES (8, '2016-02-16 19:25:19.773218', 4, 4, 'evaluate');
INSERT INTO task VALUES (9, '2016-02-16 19:25:19.773218', 5, 2, 'produce');
INSERT INTO task VALUES (10, '2016-02-16 19:25:19.773218', 5, 4, 'evaluate');
INSERT INTO task VALUES (11, '2016-02-16 19:25:19.773218', 6, 1, 'produce');
INSERT INTO task VALUES (12, '2016-02-16 19:25:19.773218', 6, 4, 'evaluate');
SELECT pg_catalog.setval('task_id_seq', 12, true);
ALTER TABLE ONLY benchmark_data
    ADD CONSTRAINT benchmark_data_idx UNIQUE (input_data_file_set_id, benchmark_type_id);
ALTER TABLE ONLY benchmark_data
    ADD CONSTRAINT benchmark_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_external_id_key UNIQUE (external_id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_idx UNIQUE (benchmark_type_id, input_data_file_id, product_image_instance_task_id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY benchmark_type
    ADD CONSTRAINT benchmark_type_name_key UNIQUE (name);
ALTER TABLE ONLY benchmark_type
    ADD CONSTRAINT benchmark_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY event_file_instance
    ADD CONSTRAINT event_file_idx UNIQUE (event_id, file_instance_id);
ALTER TABLE ONLY event_file_instance
    ADD CONSTRAINT event_file_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);
ALTER TABLE ONLY file_instance
    ADD CONSTRAINT file_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY file_instance
    ADD CONSTRAINT file_instance_sha256_key UNIQUE (sha256);
ALTER TABLE ONLY file_type
    ADD CONSTRAINT file_type_name_key UNIQUE (name);
ALTER TABLE ONLY file_type
    ADD CONSTRAINT file_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY image_instance
    ADD CONSTRAINT image_instance_idx UNIQUE (image_type_id, name, sha256);
ALTER TABLE ONLY image_instance
    ADD CONSTRAINT image_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY image_instance_task
    ADD CONSTRAINT image_instance_task_idx UNIQUE (image_instance_id, task);
ALTER TABLE ONLY image_instance_task
    ADD CONSTRAINT image_instance_task_pkey PRIMARY KEY (id);
ALTER TABLE ONLY image_type
    ADD CONSTRAINT image_type_name_key UNIQUE (name);
ALTER TABLE ONLY image_type
    ADD CONSTRAINT image_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY input_data_file
    ADD CONSTRAINT input_data_file_pkey PRIMARY KEY (id);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_name_key UNIQUE (name);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_pkey PRIMARY KEY (id);
ALTER TABLE ONLY input_data_source
    ADD CONSTRAINT input_data_source_name_key UNIQUE (name);
ALTER TABLE ONLY input_data_source
    ADD CONSTRAINT input_data_source_pkey PRIMARY KEY (id);
ALTER TABLE ONLY input_data_source_reference_file
    ADD CONSTRAINT input_data_source_reference_file_pkey PRIMARY KEY (id);
ALTER TABLE ONLY metric_instance
    ADD CONSTRAINT metric_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY metric_instance
    ADD CONSTRAINT metric_to_event UNIQUE (metric_type_id, event_id);
ALTER TABLE ONLY metric_type
    ADD CONSTRAINT metric_type_name_key UNIQUE (name);
ALTER TABLE ONLY metric_type
    ADD CONSTRAINT metric_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY platform_type
    ADD CONSTRAINT platform_type_name_key UNIQUE (name);
ALTER TABLE ONLY platform_type
    ADD CONSTRAINT platform_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY product_type
    ADD CONSTRAINT product_type_name_key UNIQUE (name);
ALTER TABLE ONLY product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY protocol_type
    ADD CONSTRAINT protocol_type_name_key UNIQUE (name);
ALTER TABLE ONLY protocol_type
    ADD CONSTRAINT protocol_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY run_mode_type
    ADD CONSTRAINT run_mode_type_name_key UNIQUE (name);
ALTER TABLE ONLY run_mode_type
    ADD CONSTRAINT run_mode_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY source_type
    ADD CONSTRAINT source_type_name_key UNIQUE (name);
ALTER TABLE ONLY source_type
    ADD CONSTRAINT source_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY task
    ADD CONSTRAINT task_idx UNIQUE (benchmark_instance_id, image_instance_task_id, task_type);
ALTER TABLE ONLY task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);
ALTER TABLE ONLY input_data_file
    ADD CONSTRAINT unique_file_per_file_set_idx UNIQUE (input_data_file_set_id, file_instance_id);
ALTER TABLE ONLY input_data_source_reference_file
    ADD CONSTRAINT unique_reference_files_per_source_idx UNIQUE (input_data_source_id, file_instance_id);
CREATE INDEX event_status ON event USING btree (success);
CREATE INDEX task_type_idx ON task USING btree (task_type);
CREATE TRIGGER benchmark_instance_insert BEFORE INSERT OR UPDATE ON benchmark_instance FOR EACH ROW EXECUTE PROCEDURE benchmark_instance_external_id();
ALTER TABLE ONLY benchmark_data
    ADD CONSTRAINT benchmark_data_benchmark_type_id_fkey FOREIGN KEY (benchmark_type_id) REFERENCES benchmark_type(id);
ALTER TABLE ONLY benchmark_data
    ADD CONSTRAINT benchmark_data_input_data_file_set_id_fkey FOREIGN KEY (input_data_file_set_id) REFERENCES input_data_file_set(id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_benchmark_type_id_fkey FOREIGN KEY (benchmark_type_id) REFERENCES benchmark_type(id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_file_instance_id_fkey FOREIGN KEY (file_instance_id) REFERENCES file_instance(id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_input_data_file_id_fkey FOREIGN KEY (input_data_file_id) REFERENCES input_data_file(id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_product_image_instance_id_fkey FOREIGN KEY (product_image_instance_id) REFERENCES image_instance(id);
ALTER TABLE ONLY benchmark_instance
    ADD CONSTRAINT benchmark_instance_product_image_instance_task_id_fkey FOREIGN KEY (product_image_instance_task_id) REFERENCES image_instance_task(id);
ALTER TABLE ONLY benchmark_type
    ADD CONSTRAINT benchmark_type_evaluation_image_type_id_fkey FOREIGN KEY (evaluation_image_type_id) REFERENCES image_type(id);
ALTER TABLE ONLY benchmark_type
    ADD CONSTRAINT benchmark_type_product_image_type_id_fkey FOREIGN KEY (product_image_type_id) REFERENCES image_type(id);
ALTER TABLE ONLY event_file_instance
    ADD CONSTRAINT event_file_instance_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(id);
ALTER TABLE ONLY event_file_instance
    ADD CONSTRAINT event_file_instance_file_instance_id_fkey FOREIGN KEY (file_instance_id) REFERENCES file_instance(id);
ALTER TABLE ONLY event
    ADD CONSTRAINT event_task_id_fkey FOREIGN KEY (task_id) REFERENCES task(id);
ALTER TABLE ONLY file_instance
    ADD CONSTRAINT file_instance_file_type_id_fkey FOREIGN KEY (file_type_id) REFERENCES file_type(id);
ALTER TABLE ONLY image_instance
    ADD CONSTRAINT image_instance_image_type_id_fkey FOREIGN KEY (image_type_id) REFERENCES image_type(id);
ALTER TABLE ONLY image_instance_task
    ADD CONSTRAINT image_instance_task_image_instance_id_fkey FOREIGN KEY (image_instance_id) REFERENCES image_instance(id);
ALTER TABLE ONLY input_data_file
    ADD CONSTRAINT input_data_file_file_instance_id_fkey FOREIGN KEY (file_instance_id) REFERENCES file_instance(id);
ALTER TABLE ONLY input_data_file
    ADD CONSTRAINT input_data_file_input_data_file_set_id_fkey FOREIGN KEY (input_data_file_set_id) REFERENCES input_data_source(id);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_input_data_source_id_fkey FOREIGN KEY (input_data_source_id) REFERENCES input_data_source(id);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_platform_type_id_fkey FOREIGN KEY (platform_type_id) REFERENCES platform_type(id);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_product_type_id_fkey FOREIGN KEY (product_type_id) REFERENCES product_type(id);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_protocol_type_id_fkey FOREIGN KEY (protocol_type_id) REFERENCES protocol_type(id);
ALTER TABLE ONLY input_data_file_set
    ADD CONSTRAINT input_data_file_set_run_mode_type_id_fkey FOREIGN KEY (run_mode_type_id) REFERENCES run_mode_type(id);
ALTER TABLE ONLY input_data_source_reference_file
    ADD CONSTRAINT input_data_source_reference_file_file_instance_id_fkey FOREIGN KEY (file_instance_id) REFERENCES file_instance(id);
ALTER TABLE ONLY input_data_source_reference_file
    ADD CONSTRAINT input_data_source_reference_file_input_data_source_id_fkey FOREIGN KEY (input_data_source_id) REFERENCES input_data_source(id);
ALTER TABLE ONLY input_data_source
    ADD CONSTRAINT input_data_source_source_type_id_fkey FOREIGN KEY (source_type_id) REFERENCES source_type(id);
ALTER TABLE ONLY metric_instance
    ADD CONSTRAINT metric_instance_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(id);
ALTER TABLE ONLY metric_instance
    ADD CONSTRAINT metric_instance_metric_type_id_fkey FOREIGN KEY (metric_type_id) REFERENCES metric_type(id);
ALTER TABLE ONLY task
    ADD CONSTRAINT task_benchmark_instance_id_fkey FOREIGN KEY (benchmark_instance_id) REFERENCES benchmark_instance(id);
ALTER TABLE ONLY task
    ADD CONSTRAINT task_image_instance_task_id_fkey FOREIGN KEY (image_instance_task_id) REFERENCES image_instance_task(id);
