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
-- Name: es_co_utf_8; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.es_co_utf_8 (provider = libc, locale = 'es_CO.UTF-8');


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexesp(input text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
DECLARE
	-- Función tomada de http://wiki.postgresql.org/wiki/SoundexESP
	soundex text='';	
	-- para determinar la primera letra
	pri_letra text;
	resto text;
	sustituida text ='';
	-- para quitar adyacentes
	anterior text;
	actual text;
	corregido text;
BEGIN
       -- devolver null si recibi un string en blanco o con espacios en blanco
	IF length(trim(input))= 0 then
		RETURN NULL;
	end IF;
 
 
	-- 1: LIMPIEZA:
		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
		-- 'holá coñó' => 'OLA CONO'
		input=translate(ltrim(trim(upper(input)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');
 
		-- eliminar caracteres no alfabéticos (números, símbolos como &,%,",*,!,+, etc.
		input=regexp_replace(input, '[^a-zA-Z]', '', 'g');
 
	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
	pri_letra =substr(input,1,1);
	resto =substr(input,2);
	CASE 
		when pri_letra IN ('V') then
			sustituida='B';
		when pri_letra IN ('Z','X') then
			sustituida='S';
		when pri_letra IN ('G') AND substr(input,2,1) IN ('E','I') then
			sustituida='J';
		when pri_letra IN('C') AND substr(input,2,1) NOT IN ('H','E','I') then
			sustituida='K';
		else
			sustituida=pri_letra;
 
	end case;
	--corregir el parametro con las consonantes sustituidas:
	input=sustituida || resto;		
 
	-- 3: corregir "letras compuestas" y volverlas una sola
	input=REPLACE(input,'CH','V');
	input=REPLACE(input,'QU','K');
	input=REPLACE(input,'LL','J');
	input=REPLACE(input,'CE','S');
	input=REPLACE(input,'CI','S');
	input=REPLACE(input,'YA','J');
	input=REPLACE(input,'YE','J');
	input=REPLACE(input,'YI','J');
	input=REPLACE(input,'YO','J');
	input=REPLACE(input,'YU','J');
	input=REPLACE(input,'GE','J');
	input=REPLACE(input,'GI','J');
	input=REPLACE(input,'NY','N');
	-- para debug:    --return input;
 
	-- EMPIEZA EL CALCULO DEL SOUNDEX
	-- 4: OBTENER PRIMERA letra
	pri_letra=substr(input,1,1);
 
	-- 5: retener el resto del string
	resto=substr(input,2);
 
	--6: en el resto del string, quitar vocales y vocales fonéticas
	resto=translate(resto,'@AEIOUHWY','@');
 
	--7: convertir las letras foneticamente equivalentes a numeros  (esto hace que B sea equivalente a V, C con S y Z, etc.)
	resto=translate(resto, 'BPFVCGKSXZDTLMNRQJ', '111122222233455677');
	-- así va quedando la cosa
	soundex=pri_letra || resto;
 
	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
	anterior=substr(soundex,1,1);
	corregido=anterior;
 
	FOR i IN 2 .. length(soundex) LOOP
		actual = substr(soundex, i, 1);
		IF actual <> anterior THEN
			corregido=corregido || actual;
			anterior=actual;			
		END IF;
	END LOOP;
	-- así va la cosa
	soundex=corregido;
 
	-- 9: siempre retornar un string de 4 posiciones
	soundex=rpad(soundex,4,'0');
	soundex=substr(soundex,1,4);		
 
	-- YA ESTUVO
	RETURN soundex;	
END;	
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sip_actorsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_actorsocial (
    id bigint NOT NULL,
    grupoper_id integer NOT NULL,
    telefono character varying(500),
    fax character varying(500),
    direccion character varying(500),
    pais_id integer,
    web character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fechadeshabilitacion date
);


--
-- Name: sip_actorsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_actorsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_actorsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_actorsocial_id_seq OWNED BY public.sip_actorsocial.id;


--
-- Name: sip_actorsocial_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_actorsocial_persona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    actorsocial_id integer,
    perfilactorsocial_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_actorsocial_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_actorsocial_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_actorsocial_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_actorsocial_persona_id_seq OWNED BY public.sip_actorsocial_persona.id;


--
-- Name: sip_actorsocial_sectoractor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_actorsocial_sectoractor (
    actorsocial_id integer,
    sectoractor_id integer
);


--
-- Name: sip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_anexo (
    id integer NOT NULL,
    fecha date NOT NULL,
    descripcion character varying(1500) COLLATE public.es_co_utf_8 NOT NULL,
    archivo character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    adjunto_file_name character varying(255),
    adjunto_content_type character varying(255),
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone,
    dominio_id integer DEFAULT 1
);


--
-- Name: sip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_anexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_anexo_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_anexo_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_anexo_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_anexo_id_seq1 OWNED BY public.sip_anexo.id;


--
-- Name: sip_clase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_clase (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    id_municipio integer NOT NULL,
    id_clalocal integer,
    id_tclase character varying(10) DEFAULT 'CP'::character varying NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_clase_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_clase_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_clase_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_clase_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_clase_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_clase_id_seq1 OWNED BY public.sip_clase.id;


--
-- Name: sip_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_departamento (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    id_pais integer NOT NULL,
    id_deplocal integer,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_departamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_departamento_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_departamento_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_departamento_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_departamento_id_seq1 OWNED BY public.sip_departamento.id;


--
-- Name: sip_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_etiqueta (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    dominio_id integer DEFAULT 1
);


--
-- Name: sip_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_etiqueta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_etiqueta_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_etiqueta_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_etiqueta_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_etiqueta_id_seq1 OWNED BY public.sip_etiqueta.id;


--
-- Name: sip_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_fuenteprensa (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    dominio_id integer DEFAULT 1
);


--
-- Name: sip_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_fuenteprensa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_fuenteprensa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_fuenteprensa_id_seq OWNED BY public.sip_fuenteprensa.id;


--
-- Name: sip_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupo (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_grupo_id_seq OWNED BY public.sip_grupo.id;


--
-- Name: sip_grupo_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupo_usuario (
    usuario_id integer NOT NULL,
    sip_grupo_id integer NOT NULL
);


--
-- Name: sip_grupoper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupoper (
    id bigint NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    anotaciones character varying(1000),
    dominio_id integer DEFAULT 1
);


--
-- Name: TABLE sip_grupoper; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sip_grupoper IS 'Creado por sip en sipdes_des';


--
-- Name: sip_grupoper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_grupoper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_grupoper_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_grupoper_id_seq OWNED BY public.sip_grupoper.id;


--
-- Name: sip_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_municipio (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    id_departamento integer NOT NULL,
    id_munlocal integer,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_municipio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_municipio_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_municipio_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_municipio_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_municipio_id_seq1 OWNED BY public.sip_municipio.id;


--
-- Name: sip_oficina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_oficina (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    dominio_id integer DEFAULT 1
);


--
-- Name: sip_oficina_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_oficina_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_oficina_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_oficina_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_oficina_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_oficina_id_seq1 OWNED BY public.sip_oficina.id;


--
-- Name: sip_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_pais (
    id integer NOT NULL,
    nombre character varying(200) COLLATE public.es_co_utf_8,
    nombreiso character varying(200),
    latitud double precision,
    longitud double precision,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codiso integer,
    div1 character varying(100),
    div2 character varying(100),
    div3 character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_pais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_pais_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_pais_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_pais_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_pais_id_seq1 OWNED BY public.sip_pais.id;


--
-- Name: sip_perfilactorsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_perfilactorsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dominio_id integer DEFAULT 1
);


--
-- Name: sip_perfilactorsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_perfilactorsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_perfilactorsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_perfilactorsocial_id_seq OWNED BY public.sip_perfilactorsocial.id;


--
-- Name: sip_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_persona (
    id integer NOT NULL,
    nombres character varying(100) COLLATE public.es_co_utf_8 NOT NULL,
    apellidos character varying(100) COLLATE public.es_co_utf_8 NOT NULL,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character varying(1) NOT NULL,
    id_departamento integer,
    id_municipio integer,
    id_clase integer,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer,
    nacionalde integer,
    tdocumento_id integer
);


--
-- Name: sip_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_persona_id_seq1 OWNED BY public.sip_persona.id;


--
-- Name: sip_persona_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_persona_trelacion (
    id integer NOT NULL,
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    id_trelacion character varying(2) DEFAULT 'SI'::character varying NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sip_persona_trelacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_trelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_trelacion_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_trelacion_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_trelacion_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_persona_trelacion_id_seq1 OWNED BY public.sip_persona_trelacion.id;


--
-- Name: sip_sectoractor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_sectoractor (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dominio_id integer DEFAULT 1
);


--
-- Name: sip_sectoractor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_sectoractor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_sectoractor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_sectoractor_id_seq OWNED BY public.sip_sectoractor.id;


--
-- Name: sip_tclase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tclase (
    id character varying(10) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_tdocumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    sigla character varying(100),
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tdocumento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tdocumento_id_seq OWNED BY public.sip_tdocumento.id;


--
-- Name: sip_tema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tema (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    nav_ini character varying(8),
    nav_fin character varying(8),
    nav_fuente character varying(8),
    fondo_lista character varying(8),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tema_id_seq OWNED BY public.sip_tema.id;


--
-- Name: sip_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_trelacion (
    id character varying(2) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    inverso character varying(2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sip_trivalente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_trivalente (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_trivalente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_trivalente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_trivalente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_trivalente_id_seq OWNED BY public.sip_trivalente.id;


--
-- Name: sip_tsitio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tsitio (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_tsitio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tsitio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tsitio_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tsitio_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tsitio_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tsitio_id_seq1 OWNED BY public.sip_tsitio.id;


--
-- Name: sip_ubicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_ubicacion (
    id integer NOT NULL,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    id_clase integer,
    id_municipio integer,
    id_departamento integer,
    id_tsitio integer DEFAULT 1 NOT NULL,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer
);


--
-- Name: sip_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_ubicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_ubicacion_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_ubicacion_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_ubicacion_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_ubicacion_id_seq1 OWNED BY public.sip_ubicacion.id;


--
-- Name: sipd_actorsocial_dominio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_actorsocial_dominio (
    actorsocial_id bigint NOT NULL,
    dominio_id bigint NOT NULL
);


--
-- Name: sipd_dominio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_dominio (
    id bigint NOT NULL,
    dominio character varying(500) NOT NULL,
    mandato character varying(5000) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipd_dominio_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_dominio_grupo (
    dominio_id bigint NOT NULL,
    grupo_id bigint NOT NULL
);


--
-- Name: sipd_dominio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipd_dominio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipd_dominio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipd_dominio_id_seq OWNED BY public.sipd_dominio.id;


--
-- Name: sipd_dominio_operaen_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_dominio_operaen_departamento (
    departamento_id bigint NOT NULL,
    dominio_id bigint NOT NULL
);


--
-- Name: sipd_dominio_operaen_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_dominio_operaen_pais (
    dominio_id bigint NOT NULL,
    pais_id bigint NOT NULL
);


--
-- Name: sipd_dominio_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_dominio_persona (
    dominio_id bigint NOT NULL,
    persona_id bigint NOT NULL
);


--
-- Name: sipd_dominio_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipd_dominio_usuario (
    dominio_id integer NOT NULL,
    usuario_id integer NOT NULL
);


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id integer NOT NULL,
    nusuario character varying(15) NOT NULL,
    password character varying(64) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(50),
    rol integer DEFAULT 4,
    idioma character varying(6) DEFAULT 'es_CO'::character varying NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    failed_attempts integer,
    unlock_token character varying(64),
    locked_at timestamp without time zone,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    regionsjr_id integer,
    nombre character varying(50) COLLATE public.es_co_utf_8,
    tema_id integer
);


--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_seq1 OWNED BY public.usuario.id;


--
-- Name: sip_actorsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_actorsocial_id_seq'::regclass);


--
-- Name: sip_actorsocial_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial_persona ALTER COLUMN id SET DEFAULT nextval('public.sip_actorsocial_persona_id_seq'::regclass);


--
-- Name: sip_anexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo ALTER COLUMN id SET DEFAULT nextval('public.sip_anexo_id_seq1'::regclass);


--
-- Name: sip_clase id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase ALTER COLUMN id SET DEFAULT nextval('public.sip_clase_id_seq1'::regclass);


--
-- Name: sip_departamento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento ALTER COLUMN id SET DEFAULT nextval('public.sip_departamento_id_seq1'::regclass);


--
-- Name: sip_etiqueta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta ALTER COLUMN id SET DEFAULT nextval('public.sip_etiqueta_id_seq1'::regclass);


--
-- Name: sip_fuenteprensa id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_fuenteprensa ALTER COLUMN id SET DEFAULT nextval('public.sip_fuenteprensa_id_seq'::regclass);


--
-- Name: sip_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo ALTER COLUMN id SET DEFAULT nextval('public.sip_grupo_id_seq'::regclass);


--
-- Name: sip_grupoper id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupoper ALTER COLUMN id SET DEFAULT nextval('public.sip_grupoper_id_seq'::regclass);


--
-- Name: sip_municipio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio ALTER COLUMN id SET DEFAULT nextval('public.sip_municipio_id_seq1'::regclass);


--
-- Name: sip_oficina id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_oficina ALTER COLUMN id SET DEFAULT nextval('public.sip_oficina_id_seq1'::regclass);


--
-- Name: sip_pais id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais ALTER COLUMN id SET DEFAULT nextval('public.sip_pais_id_seq1'::regclass);


--
-- Name: sip_perfilactorsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilactorsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_perfilactorsocial_id_seq'::regclass);


--
-- Name: sip_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona ALTER COLUMN id SET DEFAULT nextval('public.sip_persona_id_seq1'::regclass);


--
-- Name: sip_persona_trelacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion ALTER COLUMN id SET DEFAULT nextval('public.sip_persona_trelacion_id_seq1'::regclass);


--
-- Name: sip_sectoractor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectoractor ALTER COLUMN id SET DEFAULT nextval('public.sip_sectoractor_id_seq'::regclass);


--
-- Name: sip_tdocumento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tdocumento ALTER COLUMN id SET DEFAULT nextval('public.sip_tdocumento_id_seq'::regclass);


--
-- Name: sip_tema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tema ALTER COLUMN id SET DEFAULT nextval('public.sip_tema_id_seq'::regclass);


--
-- Name: sip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.sip_trivalente_id_seq'::regclass);


--
-- Name: sip_tsitio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tsitio ALTER COLUMN id SET DEFAULT nextval('public.sip_tsitio_id_seq1'::regclass);


--
-- Name: sip_ubicacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion ALTER COLUMN id SET DEFAULT nextval('public.sip_ubicacion_id_seq1'::regclass);


--
-- Name: sipd_dominio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio ALTER COLUMN id SET DEFAULT nextval('public.sipd_dominio_id_seq'::regclass);


--
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq1'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sip_actorsocial_persona sip_actorsocial_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial_persona
    ADD CONSTRAINT sip_actorsocial_persona_pkey PRIMARY KEY (id);


--
-- Name: sip_actorsocial sip_actorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial
    ADD CONSTRAINT sip_actorsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_anexo sip_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo
    ADD CONSTRAINT sip_anexo_pkey PRIMARY KEY (id);


--
-- Name: sip_clase sip_clase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_pkey PRIMARY KEY (id);


--
-- Name: sip_departamento sip_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_pkey PRIMARY KEY (id);


--
-- Name: sip_etiqueta sip_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta
    ADD CONSTRAINT sip_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: sip_fuenteprensa sip_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_fuenteprensa
    ADD CONSTRAINT sip_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: sip_grupo sip_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo
    ADD CONSTRAINT sip_grupo_pkey PRIMARY KEY (id);


--
-- Name: sip_grupoper sip_grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupoper
    ADD CONSTRAINT sip_grupoper_pkey PRIMARY KEY (id);


--
-- Name: sip_municipio sip_municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_pkey PRIMARY KEY (id);


--
-- Name: sip_oficina sip_oficina_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_oficina
    ADD CONSTRAINT sip_oficina_pkey PRIMARY KEY (id);


--
-- Name: sip_pais sip_pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais
    ADD CONSTRAINT sip_pais_pkey PRIMARY KEY (id);


--
-- Name: sip_perfilactorsocial sip_perfilactorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilactorsocial
    ADD CONSTRAINT sip_perfilactorsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_persona sip_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_pkey PRIMARY KEY (id);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_pkey PRIMARY KEY (id);


--
-- Name: sip_sectoractor sip_sectoractor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectoractor
    ADD CONSTRAINT sip_sectoractor_pkey PRIMARY KEY (id);


--
-- Name: sip_tclase sip_tclase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tclase
    ADD CONSTRAINT sip_tclase_pkey PRIMARY KEY (id);


--
-- Name: sip_tdocumento sip_tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tdocumento
    ADD CONSTRAINT sip_tdocumento_pkey PRIMARY KEY (id);


--
-- Name: sip_tema sip_tema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tema
    ADD CONSTRAINT sip_tema_pkey PRIMARY KEY (id);


--
-- Name: sip_trelacion sip_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trelacion
    ADD CONSTRAINT sip_trelacion_pkey PRIMARY KEY (id);


--
-- Name: sip_trivalente sip_trivalente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente
    ADD CONSTRAINT sip_trivalente_pkey PRIMARY KEY (id);


--
-- Name: sip_tsitio sip_tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tsitio
    ADD CONSTRAINT sip_tsitio_pkey PRIMARY KEY (id);


--
-- Name: sip_ubicacion sip_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_pkey PRIMARY KEY (id);


--
-- Name: sipd_dominio sipd_dominio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio
    ADD CONSTRAINT sipd_dominio_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: index_sip_actorsocial_on_grupoper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_actorsocial_on_grupoper_id ON public.sip_actorsocial USING btree (grupoper_id);


--
-- Name: index_sip_actorsocial_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_actorsocial_on_pais_id ON public.sip_actorsocial USING btree (pais_id);


--
-- Name: index_sip_ubicacion_on_id_clase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_clase ON public.sip_ubicacion USING btree (id_clase);


--
-- Name: index_sip_ubicacion_on_id_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_departamento ON public.sip_ubicacion USING btree (id_departamento);


--
-- Name: index_sip_ubicacion_on_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_municipio ON public.sip_ubicacion USING btree (id_municipio);


--
-- Name: index_sip_ubicacion_on_id_pais; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_pais ON public.sip_ubicacion USING btree (id_pais);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_email ON public.usuario USING btree (email);


--
-- Name: sip_departamento_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_departamento_id_key ON public.sip_departamento USING btree (id);


--
-- Name: sip_departamento_id_pais_id_deplocal_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_departamento_id_pais_id_deplocal_key ON public.sip_departamento USING btree (id_pais, id_deplocal);


--
-- Name: sip_persona_trelacion_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_persona_trelacion_id_key ON public.sip_persona_trelacion USING btree (id);


--
-- Name: sip_persona_trelacion_persona1_persona2_id_trelacion_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_persona_trelacion_persona1_persona2_id_trelacion_key ON public.sip_persona_trelacion USING btree (persona1, persona2, id_trelacion);


--
-- Name: sip_persona_trelacion_persona1_persona2_id_trelacion_key1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_persona_trelacion_persona1_persona2_id_trelacion_key1 ON public.sip_persona_trelacion USING btree (persona1, persona2, id_trelacion);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: sip_clase clase_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT clase_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_clase clase_id_tclase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT clase_id_tclase_fkey FOREIGN KEY (id_tclase) REFERENCES public.sip_tclase(id);


--
-- Name: sip_departamento departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_oficina fk_rails_06284eb69b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_oficina
    ADD CONSTRAINT fk_rails_06284eb69b FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sip_municipio fk_rails_089870a38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT fk_rails_089870a38d FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_etiqueta fk_rails_08b508c1d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta
    ADD CONSTRAINT fk_rails_08b508c1d4 FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_dominio_grupo fk_rails_1a9738aae8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_grupo
    ADD CONSTRAINT fk_rails_1a9738aae8 FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_actorsocial_dominio fk_rails_259bca386f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_actorsocial_dominio
    ADD CONSTRAINT fk_rails_259bca386f FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_dominio_persona fk_rails_2d6a08d29d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_persona
    ADD CONSTRAINT fk_rails_2d6a08d29d FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sip_grupoper fk_rails_3c81737399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupoper
    ADD CONSTRAINT fk_rails_3c81737399 FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_dominio_usuario fk_rails_409b6c9cf3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_usuario
    ADD CONSTRAINT fk_rails_409b6c9cf3 FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_dominio_operaen_departamento fk_rails_44dcf582d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_operaen_departamento
    ADD CONSTRAINT fk_rails_44dcf582d1 FOREIGN KEY (departamento_id) REFERENCES public.sip_departamento(id);


--
-- Name: sipd_dominio_grupo fk_rails_45459713c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_grupo
    ADD CONSTRAINT fk_rails_45459713c7 FOREIGN KEY (grupo_id) REFERENCES public.sip_grupo(id);


--
-- Name: sip_actorsocial_persona fk_rails_4672f6cbcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial_persona
    ADD CONSTRAINT fk_rails_4672f6cbcd FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sipd_dominio_usuario fk_rails_4f83073a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_usuario
    ADD CONSTRAINT fk_rails_4f83073a94 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sip_actorsocial fk_rails_5b21e3a2af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial
    ADD CONSTRAINT fk_rails_5b21e3a2af FOREIGN KEY (grupoper_id) REFERENCES public.sip_grupoper(id);


--
-- Name: sip_grupo_usuario fk_rails_734ee21e62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo_usuario
    ADD CONSTRAINT fk_rails_734ee21e62 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sip_actorsocial fk_rails_7bc2a60574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial
    ADD CONSTRAINT fk_rails_7bc2a60574 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: sip_actorsocial_persona fk_rails_7c335482f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial_persona
    ADD CONSTRAINT fk_rails_7c335482f6 FOREIGN KEY (actorsocial_id) REFERENCES public.sip_actorsocial(id);


--
-- Name: sip_grupo_usuario fk_rails_8d24f7c1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo_usuario
    ADD CONSTRAINT fk_rails_8d24f7c1c0 FOREIGN KEY (sip_grupo_id) REFERENCES public.sip_grupo(id);


--
-- Name: sip_fuenteprensa fk_rails_8fecb1ba5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_fuenteprensa
    ADD CONSTRAINT fk_rails_8fecb1ba5c FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sip_departamento fk_rails_92093de1a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT fk_rails_92093de1a1 FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_anexo fk_rails_96bffeb735; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo
    ADD CONSTRAINT fk_rails_96bffeb735 FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sip_actorsocial_sectoractor fk_rails_9f61a364e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial_sectoractor
    ADD CONSTRAINT fk_rails_9f61a364e0 FOREIGN KEY (sectoractor_id) REFERENCES public.sip_sectoractor(id);


--
-- Name: sipd_dominio_persona fk_rails_b1b0ce97ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_persona
    ADD CONSTRAINT fk_rails_b1b0ce97ef FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sipd_dominio_operaen_departamento fk_rails_b49ea67f2f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_operaen_departamento
    ADD CONSTRAINT fk_rails_b49ea67f2f FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_dominio_operaen_pais fk_rails_b5291ac79e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_operaen_pais
    ADD CONSTRAINT fk_rails_b5291ac79e FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: usuario fk_rails_cc636858ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_cc636858ad FOREIGN KEY (tema_id) REFERENCES public.sip_tema(id);


--
-- Name: sip_perfilactorsocial fk_rails_d0182d7038; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilactorsocial
    ADD CONSTRAINT fk_rails_d0182d7038 FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sipd_dominio_operaen_pais fk_rails_ed1af0ae84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_dominio_operaen_pais
    ADD CONSTRAINT fk_rails_ed1af0ae84 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: sip_actorsocial_sectoractor fk_rails_f032bb21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_actorsocial_sectoractor
    ADD CONSTRAINT fk_rails_f032bb21a6 FOREIGN KEY (actorsocial_id) REFERENCES public.sip_actorsocial(id);


--
-- Name: sip_sectoractor fk_rails_f3e34439fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectoractor
    ADD CONSTRAINT fk_rails_f3e34439fd FOREIGN KEY (dominio_id) REFERENCES public.sipd_dominio(id);


--
-- Name: sip_clase fk_rails_fb09f016e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT fk_rails_fb09f016e4 FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sipd_actorsocial_dominio fk_rails_fb63f7876b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipd_actorsocial_dominio
    ADD CONSTRAINT fk_rails_fb63f7876b FOREIGN KEY (actorsocial_id) REFERENCES public.sip_actorsocial(id);


--
-- Name: sip_persona persona_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_id_clase_fkey FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: sip_persona persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_persona persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_persona persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES public.sip_pais(id);


--
-- Name: sip_persona persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES public.sip_tdocumento(id);


--
-- Name: sip_persona_trelacion persona_trelacion_id_trelacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_id_trelacion_fkey FOREIGN KEY (id_trelacion) REFERENCES public.sip_trelacion(id);


--
-- Name: sip_persona_trelacion persona_trelacion_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona1_fkey FOREIGN KEY (persona1) REFERENCES public.sip_persona(id);


--
-- Name: sip_persona_trelacion persona_trelacion_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona2_fkey FOREIGN KEY (persona2) REFERENCES public.sip_persona(id);


--
-- Name: sip_municipio sip_municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_ubicacion ubicacion_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_clase_fkey FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: sip_ubicacion ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_ubicacion ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_ubicacion ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_ubicacion ubicacion_id_tsitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_tsitio_fkey FOREIGN KEY (id_tsitio) REFERENCES public.sip_tsitio(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20150413160156'),
('20150413160157'),
('20150413160158'),
('20150413160159'),
('20150416074423'),
('20150503120915'),
('20150510125926'),
('20150521181918'),
('20150528100944'),
('20150707164448'),
('20150710114451'),
('20150717101243'),
('20150724003736'),
('20150803082520'),
('20150809032138'),
('20151020203421'),
('20160519195544'),
('20161108102349'),
('20170405104322'),
('20170413185012'),
('20170414035328'),
('20180320230847'),
('20180717135811'),
('20180720140443'),
('20180720171842'),
('20180724135332'),
('20180724202353'),
('20180810221619'),
('20180921120954'),
('20181011104537'),
('20181127191845'),
('20181127192803'),
('20181127194114'),
('20181128174519'),
('20181128183936'),
('20181129001248'),
('20190102140635'),
('20190102220733'),
('20190109125417'),
('20190110191802'),
('20190123100500'),
('20190215110933'),
('20190218155153'),
('20190331111015'),
('20190401175521'),
('20190612111043'),
('20190618135559'),
('20190715083916'),
('20190715182611'),
('20190818013251'),
('20190926104116');


