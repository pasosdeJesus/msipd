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
-- Name: completa_obs(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.completa_obs(obs character varying, nuevaobs character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RETURN CASE WHEN obs IS NULL THEN nuevaobs
          WHEN obs='' THEN nuevaobs
          WHEN RIGHT(obs, 1)='.' THEN obs || ' ' || nuevaobs
          ELSE obs || '. ' || nuevaobs
        END;
      END; $$;


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
      SELECT public.unaccent('public.unaccent', $1)  
      $_$;


--
-- Name: msip_edad_de_fechanac_fecharef(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_edad_de_fechanac_fecharef(anionac integer, mesnac integer, dianac integer, anioref integer, mesref integer, diaref integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
            SELECT CASE 
              WHEN anionac IS NULL THEN NULL
              WHEN anioref IS NULL THEN NULL
              WHEN anioref < anionac THEN -1
              WHEN mesnac IS NOT NULL AND mesnac > 0 
                AND mesref IS NOT NULL AND mesref > 0 
                AND mesnac >= mesref THEN
                CASE 
                  WHEN mesnac > mesref OR (dianac IS NOT NULL 
                    AND dianac > 0 AND diaref IS NOT NULL 
                    AND diaref > 0 AND dianac > diaref) THEN 
                    anioref-anionac-1
                  ELSE 
                    anioref-anionac
                END
              ELSE
                anioref-anionac
            END 
          $$;


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexesp(entrada text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
      DECLARE
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
        --raise notice 'entrada=%', entrada;
        -- devolver null si recibi un string en blanco o con espacios en blanco
        IF length(trim(entrada))= 0 then
              RETURN NULL;
        END IF;


      	-- 1: LIMPIEZA:
      		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
      		-- 'holá coñó' => 'OLA CONO'
      		entrada=translate(ltrim(trim(upper(entrada)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');

        IF array_upper(regexp_split_to_array(entrada, '[^a-zA-Z]'), 1) > 1 THEN
          RAISE NOTICE 'Esta función sólo maneja una palabra y no ''%''. Use más bien soundexespm', entrada;
      		RETURN NULL;
        END IF;

      	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
      	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
      	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
      	pri_letra =substr(entrada,1,1);
      	resto =substr(entrada,2);
      	CASE
      		when pri_letra IN ('V') then
      			sustituida='B';
      		when pri_letra IN ('Z','X') then
      			sustituida='S';
      		when pri_letra IN ('G') AND substr(entrada,2,1) IN ('E','I') then
      			sustituida='J';
      		when pri_letra IN('C') AND substr(entrada,2,1) NOT IN ('H','E','I') then
      			sustituida='K';
      		else
      			sustituida=pri_letra;

      	end case;
      	--corregir el parámetro con las consonantes sustituidas:
      	entrada=sustituida || resto;		
        --raise notice 'entrada tras cambios en primera letra %', entrada;

      	-- 3: corregir "letras compuestas" y volverlas una sola
      	entrada=REPLACE(entrada,'CH','V');
      	entrada=REPLACE(entrada,'QU','K');
      	entrada=REPLACE(entrada,'LL','J');
      	entrada=REPLACE(entrada,'CE','S');
      	entrada=REPLACE(entrada,'CI','S');
      	entrada=REPLACE(entrada,'YA','J');
      	entrada=REPLACE(entrada,'YE','J');
      	entrada=REPLACE(entrada,'YI','J');
      	entrada=REPLACE(entrada,'YO','J');
      	entrada=REPLACE(entrada,'YU','J');
      	entrada=REPLACE(entrada,'GE','J');
      	entrada=REPLACE(entrada,'GI','J');
      	entrada=REPLACE(entrada,'NY','N');
      	-- para debug:    --return entrada;
        --raise notice 'entrada tras cambiar letras compuestas %', entrada;

      	-- EMPIEZA EL CALCULO DEL SOUNDEX
      	-- 4: OBTENER PRIMERA letra
      	pri_letra=substr(entrada,1,1);

      	-- 5: retener el resto del string
      	resto=substr(entrada,2);

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


--
-- Name: soundexespm(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexespm(entrada text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
      DECLARE
        soundex text = '' ;
        partes text[];
        sep text = '';
        se text = '';
      BEGIN
        entrada=translate(ltrim(trim(upper(entrada)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');
        partes=regexp_split_to_array(entrada, '[^a-zA-Z]');

        --raise notice 'partes=%', partes;
        FOR i IN 1 .. array_upper(partes, 1) LOOP
          se = soundexesp(partes[i]);
          IF length(se) > 0 THEN
            soundex = soundex || sep || se;
            sep = ' ';
            --raise notice 'i=% . soundexesp=%', i, se;
          END IF;
        END LOOP;

      	RETURN soundex;	
      END;	
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: divipola_oficial_2019_corregido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.divipola_oficial_2019_corregido (
    coddep integer,
    departamento character varying(512) COLLATE public.es_co_utf_8,
    codmun integer,
    municipio character varying(512) COLLATE public.es_co_utf_8,
    codcp integer,
    centropoblado character varying(512) COLLATE public.es_co_utf_8,
    tipocp character varying(6)
);


--
-- Name: msip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_anexo (
    id integer NOT NULL,
    fecha date NOT NULL,
    descripcion character varying(1500) NOT NULL COLLATE public.es_co_utf_8,
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
-- Name: msip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_anexo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_anexo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_anexo_id_seq OWNED BY public.msip_anexo.id;


--
-- Name: msip_bitacora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_bitacora (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    ip character varying(100),
    usuario_id integer,
    url character varying(1023),
    params character varying(5000),
    modelo character varying(511),
    modelo_id integer,
    operacion character varying(63),
    detalle json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_bitacora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_bitacora_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_bitacora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_bitacora_id_seq OWNED BY public.msip_bitacora.id;


--
-- Name: msip_clase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_clase (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    municipio_id integer NOT NULL,
    clalocal_cod integer,
    tclase_id character varying(10) DEFAULT 'CP'::character varying NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision
);


--
-- Name: msip_clase_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_clase_histvigencia (
    id bigint NOT NULL,
    clase_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    clalocal_cod integer,
    tclase_id character varying,
    observaciones character varying(5000)
);


--
-- Name: msip_clase_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_clase_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_clase_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_clase_histvigencia_id_seq OWNED BY public.msip_clase_histvigencia.id;


--
-- Name: msip_clase_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_clase_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_clase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_clase_id_seq OWNED BY public.msip_clase.id;


--
-- Name: msip_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_departamento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer NOT NULL,
    deplocal_cod integer,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codiso character varying(6),
    catiso character varying(64),
    codreg integer,
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision
);


--
-- Name: msip_departamento_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_departamento_histvigencia (
    id bigint NOT NULL,
    departamento_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    deplocal_cod integer,
    codiso integer,
    catiso integer,
    codreg integer,
    observaciones character varying(5000)
);


--
-- Name: msip_departamento_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_departamento_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_departamento_histvigencia_id_seq OWNED BY public.msip_departamento_histvigencia.id;


--
-- Name: msip_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_departamento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_departamento_id_seq OWNED BY public.msip_departamento.id;


--
-- Name: msip_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_municipio (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    departamento_id integer NOT NULL,
    munlocal_cod integer,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codreg integer,
    ultvigenciaini date,
    ultvigenciafin date,
    tipomun character varying(32),
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision
);


--
-- Name: msip_divipola; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.msip_divipola AS
 SELECT msip_departamento.deplocal_cod AS coddep,
    msip_departamento.nombre AS departamento,
    ((msip_departamento.deplocal_cod * 1000) + msip_municipio.munlocal_cod) AS codmun,
    msip_municipio.nombre AS municipio,
    (((msip_departamento.deplocal_cod * 1000000) + (msip_municipio.munlocal_cod * 1000)) + msip_clase.clalocal_cod) AS codcp,
    msip_clase.nombre AS centropoblado,
    msip_clase.tclase_id AS tipocp,
    msip_clase.id AS sip_idcp
   FROM ((public.msip_departamento
     JOIN public.msip_municipio ON ((msip_municipio.departamento_id = msip_departamento.id)))
     JOIN public.msip_clase ON ((msip_clase.municipio_id = msip_municipio.id)))
  WHERE ((msip_departamento.pais_id = 170) AND (msip_clase.fechadeshabilitacion IS NULL))
  ORDER BY msip_departamento.nombre, msip_municipio.nombre, msip_clase.nombre;


--
-- Name: msip_estadosol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_estadosol (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_estadosol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_estadosol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_estadosol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_estadosol_id_seq OWNED BY public.msip_estadosol.id;


--
-- Name: msip_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    dominio_id integer DEFAULT 1
);


--
-- Name: msip_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etiqueta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etiqueta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_etiqueta_id_seq OWNED BY public.msip_etiqueta.id;


--
-- Name: msip_etiqueta_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta_municipio (
    etiqueta_id bigint NOT NULL,
    municipio_id bigint NOT NULL
);


--
-- Name: msip_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_fuenteprensa (
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
-- Name: msip_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_fuenteprensa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_fuenteprensa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_fuenteprensa_id_seq OWNED BY public.msip_fuenteprensa.id;


--
-- Name: msip_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_grupo_id_seq OWNED BY public.msip_grupo.id;


--
-- Name: msip_grupo_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupo_usuario (
    usuario_id integer NOT NULL,
    grupo_id integer NOT NULL
);


--
-- Name: msip_grupoper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupoper (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    anotaciones character varying(1000),
    dominio_id integer DEFAULT 1
);


--
-- Name: msip_grupoper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_grupoper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_grupoper_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_grupoper_id_seq OWNED BY public.msip_grupoper.id;


--
-- Name: msip_municipio_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_municipio_histvigencia (
    id bigint NOT NULL,
    municipio_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    munlocal_cod integer,
    observaciones character varying(5000),
    codreg integer
);


--
-- Name: msip_municipio_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_municipio_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_municipio_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_municipio_histvigencia_id_seq OWNED BY public.msip_municipio_histvigencia.id;


--
-- Name: msip_municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_municipio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_municipio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_municipio_id_seq OWNED BY public.msip_municipio.id;


--
-- Name: msip_oficina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_oficina (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    dominio_id integer DEFAULT 1
);


--
-- Name: msip_oficina_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_oficina_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_oficina_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_oficina_id_seq OWNED BY public.msip_oficina.id;


--
-- Name: msip_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial (
    id bigint NOT NULL,
    grupoper_id integer NOT NULL,
    telefono character varying(500),
    fax character varying(500),
    direccion character varying(500),
    pais_id integer,
    web character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fechadeshabilitacion date,
    tipoorg_id integer DEFAULT 2 NOT NULL
);


--
-- Name: msip_orgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_orgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_orgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_orgsocial_id_seq OWNED BY public.msip_orgsocial.id;


--
-- Name: msip_orgsocial_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial_persona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    orgsocial_id integer,
    perfilorgsocial_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    correo character varying(100),
    cargo character varying(254)
);


--
-- Name: msip_orgsocial_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_orgsocial_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_orgsocial_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_orgsocial_persona_id_seq OWNED BY public.msip_orgsocial_persona.id;


--
-- Name: msip_orgsocial_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial_sectororgsocial (
    orgsocial_id integer,
    sectororgsocial_id integer
);


--
-- Name: msip_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_pais (
    id integer NOT NULL,
    nombre character varying(200) COLLATE public.es_co_utf_8,
    nombreiso_espanol character varying(200),
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
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    nombreiso_ingles character varying(512),
    nombreiso_frances character varying(512),
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision
);


--
-- Name: msip_pais_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_pais_histvigencia (
    id bigint NOT NULL,
    pais_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    codiso integer,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codcambio character varying(4)
);


--
-- Name: msip_pais_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_pais_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_pais_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_pais_histvigencia_id_seq OWNED BY public.msip_pais_histvigencia.id;


--
-- Name: msip_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_pais_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_pais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_pais_id_seq OWNED BY public.msip_pais.id;


--
-- Name: msip_perfilorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_perfilorgsocial (
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
-- Name: msip_perfilorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_perfilorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_perfilorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_perfilorgsocial_id_seq OWNED BY public.msip_perfilorgsocial.id;


--
-- Name: msip_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_persona (
    id integer NOT NULL,
    nombres character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    apellidos character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character varying(1) NOT NULL,
    departamento_id integer,
    municipio_id integer,
    clase_id integer,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer,
    nacionalde integer,
    tdocumento_id integer
);


--
-- Name: msip_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_persona_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_persona_id_seq OWNED BY public.msip_persona.id;


--
-- Name: msip_persona_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_persona_trelacion (
    id integer NOT NULL,
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    trelacion_id character varying(2) DEFAULT 'SI'::character varying NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: msip_persona_trelacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_persona_trelacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_persona_trelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_persona_trelacion_id_seq OWNED BY public.msip_persona_trelacion.id;


--
-- Name: msip_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_sectororgsocial (
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
-- Name: msip_sectororgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_sectororgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_sectororgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_sectororgsocial_id_seq OWNED BY public.msip_sectororgsocial.id;


--
-- Name: msip_solicitud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_solicitud (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date NOT NULL,
    solicitud character varying(5000),
    estadosol_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_solicitud_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_solicitud_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_solicitud_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_solicitud_id_seq OWNED BY public.msip_solicitud.id;


--
-- Name: msip_solicitud_usuarionotificar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_solicitud_usuarionotificar (
    usuarionotificar_id integer,
    solicitud_id integer
);


--
-- Name: msip_tclase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tclase (
    id character varying(10) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: msip_tdocumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    sigla character varying(100),
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    ayuda character varying(1000)
);


--
-- Name: msip_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tdocumento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tdocumento_id_seq OWNED BY public.msip_tdocumento.id;


--
-- Name: msip_tema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tema (
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
    updated_at timestamp without time zone NOT NULL,
    btn_primario_fondo_ini character varying(127),
    btn_primario_fondo_fin character varying(127),
    btn_primario_fuente character varying(127),
    btn_peligro_fondo_ini character varying(127),
    btn_peligro_fondo_fin character varying(127),
    btn_peligro_fuente character varying(127),
    btn_accion_fondo_ini character varying(127),
    btn_accion_fondo_fin character varying(127),
    btn_accion_fuente character varying(127),
    alerta_exito_fondo character varying(127),
    alerta_exito_fuente character varying(127),
    alerta_problema_fondo character varying(127),
    alerta_problema_fuente character varying(127),
    fondo character varying(127),
    color_fuente character varying(127),
    color_flota_subitem_fuente character varying,
    color_flota_subitem_fondo character varying
);


--
-- Name: msip_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tema_id_seq OWNED BY public.msip_tema.id;


--
-- Name: msip_tipoorg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tipoorg (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_tipoorg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tipoorg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tipoorg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tipoorg_id_seq OWNED BY public.msip_tipoorg.id;


--
-- Name: msip_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_trelacion (
    id character varying(2) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    inverso character varying(2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: msip_trivalente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_trivalente (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_trivalente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_trivalente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_trivalente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_trivalente_id_seq OWNED BY public.msip_trivalente.id;


--
-- Name: msip_tsitio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tsitio (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: msip_tsitio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tsitio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tsitio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tsitio_id_seq OWNED BY public.msip_tsitio.id;


--
-- Name: msip_ubicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_ubicacion (
    id integer NOT NULL,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    clase_id integer,
    municipio_id integer,
    departamento_id integer,
    tsitio_id integer DEFAULT 1 NOT NULL,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer
);


--
-- Name: msip_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_ubicacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_ubicacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_ubicacion_id_seq OWNED BY public.msip_ubicacion.id;


--
-- Name: msip_ubicacionpre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_ubicacionpre (
    id bigint NOT NULL,
    nombre character varying(2000) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer,
    departamento_id integer,
    municipio_id integer,
    clase_id integer,
    lugar character varying(500),
    sitio character varying(500),
    tsitio_id integer,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nombre_sin_pais character varying(500)
);


--
-- Name: msip_ubicacionpre_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_ubicacionpre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_ubicacionpre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_ubicacionpre_id_seq OWNED BY public.msip_ubicacionpre.id;


--
-- Name: msip_vereda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_vereda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    municipio_id integer,
    verlocal_id integer,
    observaciones character varying(5000),
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_vereda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_vereda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_vereda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_vereda_id_seq OWNED BY public.msip_vereda.id;


--
-- Name: msipd_dominio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio (
    id bigint NOT NULL,
    dominio character varying(500) NOT NULL,
    mandato character varying(5000) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msipd_dominio_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio_grupo (
    dominio_id bigint NOT NULL,
    grupo_id bigint NOT NULL
);


--
-- Name: msipd_dominio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msipd_dominio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msipd_dominio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msipd_dominio_id_seq OWNED BY public.msipd_dominio.id;


--
-- Name: msipd_dominio_operaen_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio_operaen_departamento (
    departamento_id bigint NOT NULL,
    dominio_id bigint NOT NULL
);


--
-- Name: msipd_dominio_operaen_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio_operaen_pais (
    dominio_id bigint NOT NULL,
    pais_id bigint NOT NULL
);


--
-- Name: msipd_dominio_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio_orgsocial (
    orgsocial_id bigint NOT NULL,
    dominio_id bigint NOT NULL
);


--
-- Name: msipd_dominio_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio_persona (
    dominio_id bigint NOT NULL,
    persona_id bigint NOT NULL
);


--
-- Name: msipd_dominio_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msipd_dominio_usuario (
    dominio_id integer NOT NULL,
    usuario_id integer NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
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
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


--
-- Name: msip_anexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_anexo ALTER COLUMN id SET DEFAULT nextval('public.msip_anexo_id_seq'::regclass);


--
-- Name: msip_bitacora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora ALTER COLUMN id SET DEFAULT nextval('public.msip_bitacora_id_seq'::regclass);


--
-- Name: msip_clase id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase ALTER COLUMN id SET DEFAULT nextval('public.msip_clase_id_seq'::regclass);


--
-- Name: msip_clase_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_clase_histvigencia_id_seq'::regclass);


--
-- Name: msip_departamento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento ALTER COLUMN id SET DEFAULT nextval('public.msip_departamento_id_seq'::regclass);


--
-- Name: msip_departamento_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_departamento_histvigencia_id_seq'::regclass);


--
-- Name: msip_estadosol id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_estadosol ALTER COLUMN id SET DEFAULT nextval('public.msip_estadosol_id_seq'::regclass);


--
-- Name: msip_etiqueta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta ALTER COLUMN id SET DEFAULT nextval('public.msip_etiqueta_id_seq'::regclass);


--
-- Name: msip_fuenteprensa id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_fuenteprensa ALTER COLUMN id SET DEFAULT nextval('public.msip_fuenteprensa_id_seq'::regclass);


--
-- Name: msip_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo ALTER COLUMN id SET DEFAULT nextval('public.msip_grupo_id_seq'::regclass);


--
-- Name: msip_grupoper id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupoper ALTER COLUMN id SET DEFAULT nextval('public.msip_grupoper_id_seq'::regclass);


--
-- Name: msip_municipio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio ALTER COLUMN id SET DEFAULT nextval('public.msip_municipio_id_seq'::regclass);


--
-- Name: msip_municipio_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_municipio_histvigencia_id_seq'::regclass);


--
-- Name: msip_oficina id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina ALTER COLUMN id SET DEFAULT nextval('public.msip_oficina_id_seq'::regclass);


--
-- Name: msip_orgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_orgsocial_id_seq'::regclass);


--
-- Name: msip_orgsocial_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona ALTER COLUMN id SET DEFAULT nextval('public.msip_orgsocial_persona_id_seq'::regclass);


--
-- Name: msip_pais id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais ALTER COLUMN id SET DEFAULT nextval('public.msip_pais_id_seq'::regclass);


--
-- Name: msip_pais_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_pais_histvigencia_id_seq'::regclass);


--
-- Name: msip_perfilorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_perfilorgsocial_id_seq'::regclass);


--
-- Name: msip_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona ALTER COLUMN id SET DEFAULT nextval('public.msip_persona_id_seq'::regclass);


--
-- Name: msip_persona_trelacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion ALTER COLUMN id SET DEFAULT nextval('public.msip_persona_trelacion_id_seq'::regclass);


--
-- Name: msip_sectororgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_sectororgsocial_id_seq'::regclass);


--
-- Name: msip_solicitud id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud ALTER COLUMN id SET DEFAULT nextval('public.msip_solicitud_id_seq'::regclass);


--
-- Name: msip_tdocumento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tdocumento ALTER COLUMN id SET DEFAULT nextval('public.msip_tdocumento_id_seq'::regclass);


--
-- Name: msip_tema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tema ALTER COLUMN id SET DEFAULT nextval('public.msip_tema_id_seq'::regclass);


--
-- Name: msip_tipoorg id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorg ALTER COLUMN id SET DEFAULT nextval('public.msip_tipoorg_id_seq'::regclass);


--
-- Name: msip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.msip_trivalente_id_seq'::regclass);


--
-- Name: msip_tsitio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tsitio ALTER COLUMN id SET DEFAULT nextval('public.msip_tsitio_id_seq'::regclass);


--
-- Name: msip_ubicacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion ALTER COLUMN id SET DEFAULT nextval('public.msip_ubicacion_id_seq'::regclass);


--
-- Name: msip_ubicacionpre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre ALTER COLUMN id SET DEFAULT nextval('public.msip_ubicacionpre_id_seq'::regclass);


--
-- Name: msip_vereda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda ALTER COLUMN id SET DEFAULT nextval('public.msip_vereda_id_seq'::regclass);


--
-- Name: msipd_dominio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio ALTER COLUMN id SET DEFAULT nextval('public.msipd_dominio_id_seq'::regclass);


--
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: msip_anexo msip_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_anexo
    ADD CONSTRAINT msip_anexo_pkey PRIMARY KEY (id);


--
-- Name: msip_bitacora msip_bitacora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora
    ADD CONSTRAINT msip_bitacora_pkey PRIMARY KEY (id);


--
-- Name: msip_clase_histvigencia msip_clase_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase_histvigencia
    ADD CONSTRAINT msip_clase_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_clase msip_clase_id_municipio_id_clalocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase
    ADD CONSTRAINT msip_clase_id_municipio_id_clalocal_key UNIQUE (municipio_id, clalocal_cod);


--
-- Name: msip_clase msip_clase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase
    ADD CONSTRAINT msip_clase_pkey PRIMARY KEY (id);


--
-- Name: msip_departamento_histvigencia msip_departamento_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento_histvigencia
    ADD CONSTRAINT msip_departamento_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_departamento msip_departamento_id_pais_id_deplocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_id_pais_id_deplocal_unico UNIQUE (pais_id, deplocal_cod);


--
-- Name: msip_departamento msip_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_pkey PRIMARY KEY (id);


--
-- Name: msip_estadosol msip_estadosol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_estadosol
    ADD CONSTRAINT msip_estadosol_pkey PRIMARY KEY (id);


--
-- Name: msip_etiqueta msip_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta
    ADD CONSTRAINT msip_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: msip_fuenteprensa msip_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_fuenteprensa
    ADD CONSTRAINT msip_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: msip_grupo msip_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo
    ADD CONSTRAINT msip_grupo_pkey PRIMARY KEY (id);


--
-- Name: msip_grupoper msip_grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupoper
    ADD CONSTRAINT msip_grupoper_pkey PRIMARY KEY (id);


--
-- Name: msip_municipio_histvigencia msip_municipio_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio_histvigencia
    ADD CONSTRAINT msip_municipio_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_municipio msip_municipio_id_departamento_id_munlocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_departamento_id_munlocal_unico UNIQUE (departamento_id, munlocal_cod);


--
-- Name: msip_municipio msip_municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_pkey PRIMARY KEY (id);


--
-- Name: msip_oficina msip_oficina_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT msip_oficina_pkey PRIMARY KEY (id);


--
-- Name: msip_orgsocial_persona msip_orgsocial_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT msip_orgsocial_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_orgsocial msip_orgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT msip_orgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_pais msip_pais_codiso_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais
    ADD CONSTRAINT msip_pais_codiso_unico UNIQUE (codiso);


--
-- Name: msip_pais_histvigencia msip_pais_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais_histvigencia
    ADD CONSTRAINT msip_pais_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_pais msip_pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais
    ADD CONSTRAINT msip_pais_pkey PRIMARY KEY (id);


--
-- Name: msip_perfilorgsocial msip_perfilorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial
    ADD CONSTRAINT msip_perfilorgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_persona msip_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_pkey PRIMARY KEY (id);


--
-- Name: msip_sectororgsocial msip_sectororgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial
    ADD CONSTRAINT msip_sectororgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_solicitud msip_solicitud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT msip_solicitud_pkey PRIMARY KEY (id);


--
-- Name: msip_tdocumento msip_tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tdocumento
    ADD CONSTRAINT msip_tdocumento_pkey PRIMARY KEY (id);


--
-- Name: msip_tema msip_tema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tema
    ADD CONSTRAINT msip_tema_pkey PRIMARY KEY (id);


--
-- Name: msip_tipoorg msip_tipoorg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorg
    ADD CONSTRAINT msip_tipoorg_pkey PRIMARY KEY (id);


--
-- Name: msip_trivalente msip_trivalente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trivalente
    ADD CONSTRAINT msip_trivalente_pkey PRIMARY KEY (id);


--
-- Name: msip_tsitio msip_tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tsitio
    ADD CONSTRAINT msip_tsitio_pkey PRIMARY KEY (id);


--
-- Name: msip_ubicacion msip_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_pkey PRIMARY KEY (id);


--
-- Name: msip_ubicacionpre msip_ubicacionpre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT msip_ubicacionpre_pkey PRIMARY KEY (id);


--
-- Name: msip_vereda msip_vereda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda
    ADD CONSTRAINT msip_vereda_pkey PRIMARY KEY (id);


--
-- Name: msipd_dominio msipd_dominio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio
    ADD CONSTRAINT msipd_dominio_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: msip_tclase sip_tclase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tclase
    ADD CONSTRAINT sip_tclase_pkey PRIMARY KEY (id);


--
-- Name: msip_trelacion sip_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trelacion
    ADD CONSTRAINT sip_trelacion_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: index_msip_orgsocial_on_grupoper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_orgsocial_on_grupoper_id ON public.msip_orgsocial USING btree (grupoper_id);


--
-- Name: index_msip_orgsocial_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_orgsocial_on_pais_id ON public.msip_orgsocial USING btree (pais_id);


--
-- Name: index_msip_solicitud_usuarionotificar_on_solicitud_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_solicitud_usuarionotificar_on_solicitud_id ON public.msip_solicitud_usuarionotificar USING btree (solicitud_id);


--
-- Name: index_msip_solicitud_usuarionotificar_on_usuarionotificar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_solicitud_usuarionotificar_on_usuarionotificar_id ON public.msip_solicitud_usuarionotificar USING btree (usuarionotificar_id);


--
-- Name: index_msip_ubicacion_on_clase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_clase_id ON public.msip_ubicacion USING btree (clase_id);


--
-- Name: index_msip_ubicacion_on_departamento_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_departamento_id ON public.msip_ubicacion USING btree (departamento_id);


--
-- Name: index_msip_ubicacion_on_municipio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_municipio_id ON public.msip_ubicacion USING btree (municipio_id);


--
-- Name: index_msip_ubicacion_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_pais_id ON public.msip_ubicacion USING btree (pais_id);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_email ON public.usuario USING btree (email);


--
-- Name: msip_nombre_ubicacionpre_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_nombre_ubicacionpre_b ON public.msip_ubicacionpre USING gin (to_tsvector('spanish'::regconfig, public.f_unaccent((nombre)::text)));


--
-- Name: msip_persona_anionac_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_anionac_ind ON public.msip_persona USING btree (anionac);


--
-- Name: msip_persona_sexo_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_sexo_ind ON public.msip_persona USING btree (sexo);


--
-- Name: sip_departamento_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_departamento_id_key ON public.msip_departamento USING btree (id);


--
-- Name: sip_departamento_id_pais_id_deplocal_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_departamento_id_pais_id_deplocal_key ON public.msip_departamento USING btree (pais_id, deplocal_cod);


--
-- Name: sip_persona_trelacion_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_persona_trelacion_id_key ON public.msip_persona_trelacion USING btree (id);


--
-- Name: sip_persona_trelacion_persona1_persona2_id_trelacion_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_persona_trelacion_persona1_persona2_id_trelacion_key ON public.msip_persona_trelacion USING btree (persona1, persona2, trelacion_id);


--
-- Name: sip_persona_trelacion_persona1_persona2_id_trelacion_key1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sip_persona_trelacion_persona1_persona2_id_trelacion_key1 ON public.msip_persona_trelacion USING btree (persona1, persona2, trelacion_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: msip_clase clase_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase
    ADD CONSTRAINT clase_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_clase clase_id_tclase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase
    ADD CONSTRAINT clase_id_tclase_fkey FOREIGN KEY (tclase_id) REFERENCES public.msip_tclase(id);


--
-- Name: msip_departamento departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_oficina fk_rails_06284eb69b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT fk_rails_06284eb69b FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_municipio fk_rails_089870a38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT fk_rails_089870a38d FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_etiqueta fk_rails_08b508c1d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta
    ADD CONSTRAINT fk_rails_08b508c1d4 FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_etiqueta_municipio fk_rails_10d88626c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_10d88626c3 FOREIGN KEY (etiqueta_id) REFERENCES public.msip_etiqueta(id);


--
-- Name: msipd_dominio_grupo fk_rails_1a9738aae8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_grupo
    ADD CONSTRAINT fk_rails_1a9738aae8 FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msipd_dominio_orgsocial fk_rails_259bca386f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_orgsocial
    ADD CONSTRAINT fk_rails_259bca386f FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msipd_dominio_persona fk_rails_2d6a08d29d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_persona
    ADD CONSTRAINT fk_rails_2d6a08d29d FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_bitacora fk_rails_2db961766c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora
    ADD CONSTRAINT fk_rails_2db961766c FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msip_ubicacionpre fk_rails_2e86701dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_2e86701dfb FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_ubicacionpre fk_rails_3b59c12090; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_3b59c12090 FOREIGN KEY (clase_id) REFERENCES public.msip_clase(id);


--
-- Name: msip_grupoper fk_rails_3c81737399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupoper
    ADD CONSTRAINT fk_rails_3c81737399 FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msipd_dominio_usuario fk_rails_409b6c9cf3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_usuario
    ADD CONSTRAINT fk_rails_409b6c9cf3 FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msipd_dominio_operaen_departamento fk_rails_44dcf582d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_operaen_departamento
    ADD CONSTRAINT fk_rails_44dcf582d1 FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msipd_dominio_grupo fk_rails_45459713c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_grupo
    ADD CONSTRAINT fk_rails_45459713c7 FOREIGN KEY (grupo_id) REFERENCES public.msip_grupo(id);


--
-- Name: msip_orgsocial_persona fk_rails_4672f6cbcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT fk_rails_4672f6cbcd FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: msipd_dominio_usuario fk_rails_4f83073a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_usuario
    ADD CONSTRAINT fk_rails_4f83073a94 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msip_etiqueta_municipio fk_rails_5672729520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_5672729520 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_orgsocial fk_rails_5b21e3a2af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_5b21e3a2af FOREIGN KEY (grupoper_id) REFERENCES public.msip_grupoper(id);


--
-- Name: msip_solicitud_usuarionotificar fk_rails_6296c40917; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud_usuarionotificar
    ADD CONSTRAINT fk_rails_6296c40917 FOREIGN KEY (solicitud_id) REFERENCES public.msip_solicitud(id);


--
-- Name: msip_grupo_usuario fk_rails_734ee21e62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo_usuario
    ADD CONSTRAINT fk_rails_734ee21e62 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msip_orgsocial fk_rails_7bc2a60574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_7bc2a60574 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_orgsocial_persona fk_rails_7c335482f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT fk_rails_7c335482f6 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: msip_grupo_usuario fk_rails_8d24f7c1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo_usuario
    ADD CONSTRAINT fk_rails_8d24f7c1c0 FOREIGN KEY (grupo_id) REFERENCES public.msip_grupo(id);


--
-- Name: msip_fuenteprensa fk_rails_8fecb1ba5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_fuenteprensa
    ADD CONSTRAINT fk_rails_8fecb1ba5c FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_departamento fk_rails_92093de1a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT fk_rails_92093de1a1 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_anexo fk_rails_96bffeb735; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_anexo
    ADD CONSTRAINT fk_rails_96bffeb735 FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_orgsocial_sectororgsocial fk_rails_9f61a364e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_9f61a364e0 FOREIGN KEY (sectororgsocial_id) REFERENCES public.msip_sectororgsocial(id);


--
-- Name: msip_solicitud fk_rails_a670d661ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT fk_rails_a670d661ef FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: msipd_dominio_persona fk_rails_b1b0ce97ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_persona
    ADD CONSTRAINT fk_rails_b1b0ce97ef FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: msipd_dominio_operaen_departamento fk_rails_b49ea67f2f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_operaen_departamento
    ADD CONSTRAINT fk_rails_b49ea67f2f FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msipd_dominio_operaen_pais fk_rails_b5291ac79e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_operaen_pais
    ADD CONSTRAINT fk_rails_b5291ac79e FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_ubicacionpre fk_rails_c08a606417; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_c08a606417 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_ubicacionpre fk_rails_c8024a90df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_c8024a90df FOREIGN KEY (tsitio_id) REFERENCES public.msip_tsitio(id);


--
-- Name: usuario fk_rails_cc636858ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_cc636858ad FOREIGN KEY (tema_id) REFERENCES public.msip_tema(id);


--
-- Name: msip_perfilorgsocial fk_rails_d0182d7038; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial
    ADD CONSTRAINT fk_rails_d0182d7038 FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_solicitud_usuarionotificar fk_rails_db0f7c1dd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud_usuarionotificar
    ADD CONSTRAINT fk_rails_db0f7c1dd6 FOREIGN KEY (usuarionotificar_id) REFERENCES public.usuario(id);


--
-- Name: msip_ubicacionpre fk_rails_eba8cc9124; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_eba8cc9124 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msipd_dominio_operaen_pais fk_rails_ed1af0ae84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_operaen_pais
    ADD CONSTRAINT fk_rails_ed1af0ae84 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_orgsocial_sectororgsocial fk_rails_f032bb21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_f032bb21a6 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: msip_sectororgsocial fk_rails_f3e34439fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial
    ADD CONSTRAINT fk_rails_f3e34439fd FOREIGN KEY (dominio_id) REFERENCES public.msipd_dominio(id);


--
-- Name: msip_clase fk_rails_fb09f016e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_clase
    ADD CONSTRAINT fk_rails_fb09f016e4 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msipd_dominio_orgsocial fk_rails_fb63f7876b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msipd_dominio_orgsocial
    ADD CONSTRAINT fk_rails_fb63f7876b FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: msip_solicitud fk_rails_ffa31a0de6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT fk_rails_ffa31a0de6 FOREIGN KEY (estadosol_id) REFERENCES public.msip_estadosol(id);


--
-- Name: msip_municipio msip_municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_persona persona_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_id_clase_fkey FOREIGN KEY (clase_id) REFERENCES public.msip_clase(id);


--
-- Name: msip_persona persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_persona persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES public.msip_tdocumento(id);


--
-- Name: msip_persona_trelacion persona_trelacion_id_trelacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_id_trelacion_fkey FOREIGN KEY (trelacion_id) REFERENCES public.msip_trelacion(id);


--
-- Name: msip_persona_trelacion persona_trelacion_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona1_fkey FOREIGN KEY (persona1) REFERENCES public.msip_persona(id);


--
-- Name: msip_persona_trelacion persona_trelacion_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona2_fkey FOREIGN KEY (persona2) REFERENCES public.msip_persona(id);


--
-- Name: msip_ubicacion ubicacion_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_clase_fkey FOREIGN KEY (clase_id) REFERENCES public.msip_clase(id);


--
-- Name: msip_ubicacion ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_ubicacion ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_ubicacion ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_ubicacion ubicacion_id_tsitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_tsitio_fkey FOREIGN KEY (tsitio_id) REFERENCES public.msip_tsitio(id);


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
('20190625112649'),
('20190715083916'),
('20190715182611'),
('20190818013251'),
('20190926104116'),
('20191205200007'),
('20191205202150'),
('20191205204511'),
('20191219011910'),
('20200228235200'),
('20200319183515'),
('20200722210144'),
('20200723133542'),
('20200907165157'),
('20200907174303'),
('20200916022934'),
('20200919003430'),
('20201119125643'),
('20201124035715'),
('20201124050637'),
('20201124142002'),
('20201124145625'),
('20210401194637'),
('20210401210102'),
('20210414201956'),
('20210614120835'),
('20210614213436'),
('20210616003251'),
('20210728214424'),
('20211010164634'),
('20211024105450'),
('20211117200456'),
('20211216125250'),
('20220213031520'),
('20220214121713'),
('20220214232150'),
('20220215095957'),
('20220413123127'),
('20220417203841'),
('20220417220914'),
('20220417221010'),
('20220420143020'),
('20220420154535'),
('20220422190546'),
('20220428145059'),
('20220613224844'),
('20220713200101'),
('20220713200444'),
('20220714191500'),
('20220714191505'),
('20220714191510'),
('20220714191555'),
('20220719111148'),
('20220721170452'),
('20220721200858'),
('20220722000850'),
('20220722192214'),
('20220805181901'),
('20220822132754'),
('20221024221557'),
('20221025025402'),
('20221102144613'),
('20221102145906'),
('20221118032223'),
('20221201133152'),
('20221201143440'),
('20221201154025'),
('20221208173349'),
('20221210155527'),
('20221211141207'),
('20221211141208'),
('20221211141209'),
('20221212021533'),
('20230119111240'),
('20230301145222'),
('20230301212546'),
('20230404025025');


