CREATE DATABASE "Transport company db"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
    
    
CREATE TABLE public.cars
(
    id integer NOT NULL DEFAULT nextval('cars_id_seq'::regclass),
    brand character varying COLLATE pg_catalog."default" NOT NULL,
    model character varying COLLATE pg_catalog."default" NOT NULL,
    year numeric(4,0) NOT NULL,
    kilometrage numeric(11,3) NOT NULL,
    license_plate character varying COLLATE pg_catalog."default" NOT NULL,
    maintenance_freq numeric(5,0) NOT NULL,
    km_before_maint numeric(8,3) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    driver_id integer,
    CONSTRAINT cars_pkey PRIMARY KEY (id),
    CONSTRAINT cars_driver_id_key UNIQUE (driver_id),
    CONSTRAINT cars_license_plate_key UNIQUE (license_plate),
    CONSTRAINT cars_driver_id_fkey FOREIGN KEY (driver_id)
        REFERENCES public.drivers (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
        NOT VALID
)

CREATE TABLE public.drivers
(
    id integer NOT NULL DEFAULT nextval('drivers_id_seq'::regclass),
    last_name character varying COLLATE pg_catalog."default" NOT NULL,
    first_name character varying COLLATE pg_catalog."default" NOT NULL,
    middle_name character varying COLLATE pg_catalog."default" NOT NULL,
    driving_license character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT drivers_pkey PRIMARY KEY (id),
    CONSTRAINT drivers_driving_license_key UNIQUE (driving_license)
)

CREATE TABLE public.history
(
    id integer NOT NULL DEFAULT nextval('history_id_seq'::regclass),
    car_id integer NOT NULL,
    h_date date NOT NULL,
    kilometrage numeric(7,3) NOT NULL,
    CONSTRAINT history_pkey PRIMARY KEY (id),
    CONSTRAINT history_car_id_fkey FOREIGN KEY (car_id)
        REFERENCES public.cars (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
)

CREATE TABLE public.log
(
    id integer NOT NULL DEFAULT nextval('log_id_seq'::regclass),
    car_id integer NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    log_time timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT log_pkey PRIMARY KEY (id),
    CONSTRAINT log_car_id_fkey FOREIGN KEY (car_id)
        REFERENCES public.cars (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
)

CREATE TABLE public.roles
(
    id integer NOT NULL DEFAULT nextval('roles_id_seq'::regclass),
    name character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT roles_pkey PRIMARY KEY (id),
    CONSTRAINT roles_name_key UNIQUE (name)
)

CREATE TABLE public.user_roles
(
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    CONSTRAINT user_roles_user_id_role_id_key UNIQUE (user_id, role_id),
    CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES public.roles (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

CREATE TABLE public.users
(
    id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
    login character varying COLLATE pg_catalog."default" NOT NULL,
    password character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_login_key UNIQUE (login)
)

