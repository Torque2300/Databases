-- Table: public.projects

-- DROP TABLE IF EXISTS public.projects;

CREATE TABLE IF NOT EXISTS public.projects
(
    project_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    definition text COLLATE pg_catalog."default",
    data_begin date NOT NULL,
    data_end date,
    CONSTRAINT projects_pkey PRIMARY KEY (project_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.projects
    OWNER to postgres;