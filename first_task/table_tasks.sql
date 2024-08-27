-- Table: public.tasks

-- DROP TABLE IF EXISTS public.tasks;

CREATE TABLE IF NOT EXISTS public.tasks
(
    title text COLLATE pg_catalog."default" NOT NULL,
    priority integer NOT NULL,
    definition text COLLATE pg_catalog."default",
    status text COLLATE pg_catalog."default" NOT NULL,
    evaluation real,
    expenses real,
    master_user character varying(50) COLLATE pg_catalog."default" NOT NULL,
    running_user character varying(50) COLLATE pg_catalog."default",
    project_name character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT project_constraint FOREIGN KEY (project_name)
        REFERENCES public.projects (project_name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT user_constraint FOREIGN KEY (master_user)
        REFERENCES public.users (login) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tasks_status_check CHECK (status = 'Новая'::text OR status = 'Переоткрыта'::text OR status = 'Выполняется'::text OR status = 'Закрыта'::text)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tasks
    OWNER to postgres;