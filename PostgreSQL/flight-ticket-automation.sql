PGDMP          %                z            ucakBiletSatisOtomasyonu    14.5    14.5 G    n           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            o           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            p           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            q           1262    24738    ucakBiletSatisOtomasyonu    DATABASE     ~   CREATE DATABASE "ucakBiletSatisOtomasyonu" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';
 *   DROP DATABASE "ucakBiletSatisOtomasyonu";
                postgres    false                        3079    25459    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            r           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    2            �            1255    25283    cancel_ticket(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.cancel_ticket(IN get_ticketno integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM passenger WHERE (ticketno = get_ticketno);
		DELETE FROM ticket WHERE (ticketno = get_ticketno);
	END;

$$;
 >   DROP PROCEDURE public.cancel_ticket(IN get_ticketno integer);
       public          postgres    false            �            1255    25323 8   change_loginstatus(character varying, character varying) 	   PROCEDURE       CREATE PROCEDURE public.change_loginstatus(IN get_consumerid character varying, IN get_consumerpw character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE consumer
		SET loginstatus = true
		WHERE consumerid = get_consumerid AND consumerpw = get_consumerpw;
	END;
$$;
 t   DROP PROCEDURE public.change_loginstatus(IN get_consumerid character varying, IN get_consumerpw character varying);
       public          postgres    false            �            1255    25325    change_loginstatus_deactive() 	   PROCEDURE     �   CREATE PROCEDURE public.change_loginstatus_deactive()
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE consumer
		SET loginstatus = false;
	END;
$$;
 5   DROP PROCEDURE public.change_loginstatus_deactive();
       public          postgres    false            (           1255    25530 +   create_temp_creditcardno(character varying)    FUNCTION       CREATE FUNCTION public.create_temp_creditcardno(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
   EXECUTE format('
      CREATE TABLE IF NOT EXISTS %I (
       id int NOT NULL PRIMARY KEY,
       creditcardno varchar(20)
      )', 't_' || t_name);
END
$$;
 I   DROP FUNCTION public.create_temp_creditcardno(t_name character varying);
       public          postgres    false            $           1255    25525 $   decrypting(bytea, character varying)    FUNCTION     �   CREATE FUNCTION public.decrypting(some_text bytea, secret_text character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN pgp_sym_decrypt(some_text, secret_text);
	END;
$$;
 Q   DROP FUNCTION public.decrypting(some_text bytea, secret_text character varying);
       public          postgres    false            '           1255    25527    decrypting_now() 	   PROCEDURE     �  CREATE PROCEDURE public.decrypting_now()
    LANGUAGE plpgsql
    AS $$
	DECLARE
		counter int := 0;
	BEGIN
		LOOP
			counter := counter + 1;
			UPDATE passenger
			SET creditcardno = (SELECT creditcardno FROM t_creditcardno WHERE id = counter)
			WHERE ticketno = counter;
			EXIT WHEN counter = (SELECT COUNT(*) FROM t_creditcardno);
		END LOOP;
			DROP TABLE t_creditcardno;
	END;
$$;
 (   DROP PROCEDURE public.decrypting_now();
       public          postgres    false            %           1255    25526 0   encrypting(character varying, character varying)    FUNCTION     �   CREATE FUNCTION public.encrypting(some_text character varying, secret_text character varying) RETURNS bytea
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN pgp_sym_encrypt(some_text, secret_text);
	END;
$$;
 ]   DROP FUNCTION public.encrypting(some_text character varying, secret_text character varying);
       public          postgres    false            #           1255    25516    encrypting_now() 	   PROCEDURE     e  CREATE PROCEDURE public.encrypting_now()
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		counter int := 0;
	BEGIN
		LOOP
			counter := counter + 1;
			UPDATE passenger
			SET creditcardno = encrypting(find_creditcardno(counter), 'A1$9jqE2jSU$hsX6.HS4')
			WHERE ticketno = counter;
			EXIT WHEN counter = (SELECT COUNT(*) FROM passenger);
		END LOOP;
	END;
$_$;
 (   DROP PROCEDURE public.encrypting_now();
       public          postgres    false            &           1255    25572    fill_temp_creditcardno()    FUNCTION     `  CREATE FUNCTION public.fill_temp_creditcardno() RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		counter int := 0;
	BEGIN
		LOOP
			counter := counter + 1;
			INSERT INTO t_creditcardno VALUES (counter, (SELECT creditcardno FROM passenger WHERE ticketno = counter));
			EXIT WHEN counter = (SELECT COUNT(*) FROM passenger);
		END LOOP;
	END;
$$;
 /   DROP FUNCTION public.fill_temp_creditcardno();
       public          postgres    false            "           1255    25511    find_creditcardno(integer)    FUNCTION     �   CREATE FUNCTION public.find_creditcardno(counter integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN (SELECT creditcardno FROM passenger WHERE ticketno = counter);
	END;
$$;
 9   DROP FUNCTION public.find_creditcardno(counter integer);
       public          postgres    false            �            1255    25303 6   get_consumerinfo(character varying, character varying)    FUNCTION     :  CREATE FUNCTION public.get_consumerinfo(get_consumerid character varying, get_consumerpw character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN EXISTS (
			SELECT consumerid, consumerpw
			FROM consumer
			WHERE consumerid = get_consumerid AND consumerpw = get_consumerpw
		);
	END;
$$;
 k   DROP FUNCTION public.get_consumerinfo(get_consumerid character varying, get_consumerpw character varying);
       public          postgres    false            �            1255    25300 4   get_consumerpw(character varying, character varying)    FUNCTION     f  CREATE FUNCTION public.get_consumerpw(get_consumerid character varying, get_phone character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		forget_consumerpw varchar(20);
	BEGIN
		forget_consumerpw = (SELECT consumerpw FROM consumer WHERE consumerid = get_consumerid AND phone = get_phone);
		RETURN forget_consumerpw;
	END;
$$;
 d   DROP FUNCTION public.get_consumerpw(get_consumerid character varying, get_phone character varying);
       public          postgres    false            �            1255    25340    get_loggedin_dob()    FUNCTION     �   CREATE FUNCTION public.get_loggedin_dob() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_dob varchar(20);
	BEGIN
		temp_dob := (SELECT dob FROM consumer WHERE loginstatus = true);
		RETURN temp_dob;
	END;
$$;
 )   DROP FUNCTION public.get_loggedin_dob();
       public          postgres    false            �            1255    25341    get_loggedin_id()    FUNCTION     �   CREATE FUNCTION public.get_loggedin_id() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_id varchar(20);
	BEGIN
		temp_id := (SELECT consumerid FROM consumer WHERE loginstatus = true);
		RETURN temp_id;
	END;
$$;
 (   DROP FUNCTION public.get_loggedin_id();
       public          postgres    false            �            1255    25327    get_loggedin_idcardno()    FUNCTION       CREATE FUNCTION public.get_loggedin_idcardno() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_idcardno varchar(11);
	BEGIN
		temp_idcardno := (SELECT idcardno FROM consumer WHERE loginstatus = true);
		RETURN temp_idcardno;
	END;
$$;
 .   DROP FUNCTION public.get_loggedin_idcardno();
       public          postgres    false            �            1255    25338    get_loggedin_mail()    FUNCTION     �   CREATE FUNCTION public.get_loggedin_mail() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_mail varchar(20);
	BEGIN
		temp_mail := (SELECT mail FROM consumer WHERE loginstatus = true);
		RETURN temp_mail;
	END;
$$;
 *   DROP FUNCTION public.get_loggedin_mail();
       public          postgres    false            �            1255    25337    get_loggedin_phone()    FUNCTION     �   CREATE FUNCTION public.get_loggedin_phone() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_phone varchar(20);
	BEGIN
		temp_phone := (SELECT phone FROM consumer WHERE loginstatus = true);
		RETURN temp_phone;
	END;
$$;
 +   DROP FUNCTION public.get_loggedin_phone();
       public          postgres    false            �            1255    25336    get_loggedin_pw()    FUNCTION     �   CREATE FUNCTION public.get_loggedin_pw() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_pw varchar(20);
	BEGIN
		temp_pw := (SELECT consumerpw FROM consumer WHERE loginstatus = true);
		RETURN temp_pw;
	END;
$$;
 (   DROP FUNCTION public.get_loggedin_pw();
       public          postgres    false            �            1255    25339    get_loggedin_sex()    FUNCTION     �   CREATE FUNCTION public.get_loggedin_sex() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_sex varchar(20);
	BEGIN
		temp_sex := (SELECT sex FROM consumer WHERE loginstatus = true);
		RETURN temp_sex;
	END;
$$;
 )   DROP FUNCTION public.get_loggedin_sex();
       public          postgres    false            �            1255    25235 2   get_ticketno(character varying, character varying)    FUNCTION     W  CREATE FUNCTION public.get_ticketno(get_flightno character varying, get_idcardno character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	tofind_ticketno integer;
	BEGIN
		SELECT ticketno INTO tofind_ticketno FROM ticket t
		WHERE t.flightno = get_flightno AND t.idcardno = get_idcardno;
		RETURN tofind_ticketno;
	END;
	$$;
 c   DROP FUNCTION public.get_ticketno(get_flightno character varying, get_idcardno character varying);
       public          postgres    false            !           1255    25496    hashing(character varying)    FUNCTION     �   CREATE FUNCTION public.hashing(some_text character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN crypt(some_text, gen_salt('md5'));
	END;
$$;
 ;   DROP FUNCTION public.hashing(some_text character varying);
       public          postgres    false                        1255    25497 6   is_hashing_match(character varying, character varying)    FUNCTION     �   CREATE FUNCTION public.is_hashing_match(some_text character varying, hashed character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN (hashed = crypt(some_text, hashed)) AS IsMatch;
	END;
$$;
 ^   DROP FUNCTION public.is_hashing_match(some_text character varying, hashed character varying);
       public          postgres    false            �            1255    25390    raise_planecapacity()    FUNCTION       CREATE FUNCTION public.raise_planecapacity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_ticketno int;
	BEGIN
		temp_ticketno := (SELECT COUNT(ticketno) FROM ticket);
		
		WITH subquery AS (
			SELECT t.ticketno, planecapacity, p.planeid
			FROM ticket t, flight f, plane p
			WHERE  t.ticketno = temp_ticketno AND f.flightno = t.flightno AND p.planeid = f.planeid
	)
		UPDATE plane
		SET planecapacity = subquery.planecapacity + 1
		FROM subquery 
		WHERE plane.planeid = subquery.planeid;
		RETURN OLD;
	END;
$$;
 ,   DROP FUNCTION public.raise_planecapacity();
       public          postgres    false            �            1255    25388    reduce_planecapacity()    FUNCTION       CREATE FUNCTION public.reduce_planecapacity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
		temp_ticketno int;
	BEGIN
		temp_ticketno := (SELECT COUNT(ticketno) FROM ticket);
		
		WITH subquery AS (
			SELECT t.ticketno, planecapacity, p.planeid
			FROM ticket t, flight f, plane p
			WHERE  t.ticketno = temp_ticketno AND f.flightno = t.flightno AND p.planeid = f.planeid
	)
		UPDATE plane
		SET planecapacity = subquery.planecapacity - 1
		FROM subquery 
		WHERE plane.planeid = subquery.planeid;
		RETURN null;
	END;
$$;
 -   DROP FUNCTION public.reduce_planecapacity();
       public          postgres    false            �            1255    25310 �   save_consumer(character varying, character varying, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.save_consumer(IN get_consumerid character varying, IN get_consumerpw character varying, IN get_phone character varying, IN get_mail character varying, IN get_sex character varying, IN get_dob character varying, IN get_idcardno character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO consumer (consumerid, consumerpw, phone, mail, sex, dob, idcardno)
		VALUES (get_consumerid, get_consumerpw, get_phone, get_mail, get_sex, get_dob, get_idcardno);
	END;
$$;
   DROP PROCEDURE public.save_consumer(IN get_consumerid character varying, IN get_consumerpw character varying, IN get_phone character varying, IN get_mail character varying, IN get_sex character varying, IN get_dob character varying, IN get_idcardno character varying);
       public          postgres    false            �            1255    25260 �   save_passenger(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.save_passenger(IN fname character varying, IN lname character varying, IN sex character varying, IN dob character varying, IN mail character varying, IN phonenumber character varying, IN creditcardno character varying, IN flightno character varying, IN idcardno character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO passenger VALUES ((SELECT * FROM get_ticketno(flightno, idcardno)), fname, lname, sex, dob, mail, phonenumber, creditcardno);
	END;
$$;
 0  DROP PROCEDURE public.save_passenger(IN fname character varying, IN lname character varying, IN sex character varying, IN dob character varying, IN mail character varying, IN phonenumber character varying, IN creditcardno character varying, IN flightno character varying, IN idcardno character varying);
       public          postgres    false            �            1255    25234 1   save_ticket(character varying, character varying) 	   PROCEDURE     �   CREATE PROCEDURE public.save_ticket(IN getflightno character varying, IN getidcardno character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO ticket (flightno, idcardno) VALUES (getflightno, getidcardno);
	END;
$$;
 g   DROP PROCEDURE public.save_ticket(IN getflightno character varying, IN getidcardno character varying);
       public          postgres    false            �            1255    25385    set_count_female()    FUNCTION     �   CREATE FUNCTION public.set_count_female() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE sex_table
		SET female = (SELECT COUNT(sex) FROM passenger WHERE sex = 'F')
		WHERE id = 1;
		RETURN null;
	END;
$$;
 )   DROP FUNCTION public.set_count_female();
       public          postgres    false            �            1255    25383    set_count_male()    FUNCTION     �   CREATE FUNCTION public.set_count_male() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE sex_table
		SET male = (SELECT COUNT(sex) FROM passenger WHERE sex = 'M')
		WHERE id = 1;
		RETURN null;
	END;
$$;
 '   DROP FUNCTION public.set_count_male();
       public          postgres    false            �            1255    25265 !   someone_ticket(character varying) 	   PROCEDURE     q  CREATE PROCEDURE public.someone_ticket(IN get_idcardno character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		SELECT t.idcardno, p.fname, p.lname, f.departurecity, f.destinationcity, f.departuredate, f.departuretime, f.price
		FROM passenger p, ticket t, flight f
		WHERE get_idcardno = t.idcardno AND t.flightno = f.flightno AND p.ticketno = t.ticketno;
	END;
$$;
 I   DROP PROCEDURE public.someone_ticket(IN get_idcardno character varying);
       public          postgres    false            �            1255    25343 H   update_consumer(character varying, character varying, character varying) 	   PROCEDURE     6  CREATE PROCEDURE public.update_consumer(IN get_consumerpw character varying, IN get_phone character varying, IN get_mail character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE consumer
		SET consumerpw = get_consumerpw,
			phone = get_phone,
			mail = get_mail
		WHERE loginstatus = true;
	END;
$$;
 �   DROP PROCEDURE public.update_consumer(IN get_consumerpw character varying, IN get_phone character varying, IN get_mail character varying);
       public          postgres    false            �            1259    25070    company    TABLE     ~   CREATE TABLE public.company (
    companyid character varying(10) NOT NULL,
    companyname character varying(20) NOT NULL
);
    DROP TABLE public.company;
       public         heap    postgres    false            �            1259    25098    consumer    TABLE     ~  CREATE TABLE public.consumer (
    consumerid character varying(20) NOT NULL,
    consumerpw character varying(20) NOT NULL,
    phone character varying(20) NOT NULL,
    mail character varying(20) NOT NULL,
    sex character varying(1) NOT NULL,
    dob character varying(20) NOT NULL,
    idcardno character varying(11) NOT NULL,
    loginstatus boolean DEFAULT false NOT NULL
);
    DROP TABLE public.consumer;
       public         heap    postgres    false            �            1259    25075    flight    TABLE     �  CREATE TABLE public.flight (
    flightno character varying(10) DEFAULT 0 NOT NULL,
    planeid character varying(10) NOT NULL,
    departurecity character varying(20) NOT NULL,
    destinationcity character varying(20) NOT NULL,
    departuredate date NOT NULL,
    price integer NOT NULL,
    departuretime time(4) without time zone NOT NULL,
    destinationtime time(4) without time zone NOT NULL
);
    DROP TABLE public.flight;
       public         heap    postgres    false            �            1259    25236 	   passenger    TABLE     ]  CREATE TABLE public.passenger (
    ticketno integer NOT NULL,
    fname character varying(20) NOT NULL,
    lname character varying(20) NOT NULL,
    sex character varying(1) NOT NULL,
    dob character varying(10) NOT NULL,
    mail character varying(20) NOT NULL,
    phonenumber character varying(20) NOT NULL,
    creditcardno text NOT NULL
);
    DROP TABLE public.passenger;
       public         heap    postgres    false            �            1259    25086    plane    TABLE     �   CREATE TABLE public.plane (
    planeid character varying(10) NOT NULL,
    planecapacity integer NOT NULL,
    companyid character varying(10) NOT NULL
);
    DROP TABLE public.plane;
       public         heap    postgres    false            �            1259    25358 	   sex_table    TABLE     �   CREATE TABLE public.sex_table (
    id integer DEFAULT 1 NOT NULL,
    male integer DEFAULT 0 NOT NULL,
    female integer DEFAULT 0 NOT NULL
);
    DROP TABLE public.sex_table;
       public         heap    postgres    false            �            1259    25242    ticket    TABLE     �   CREATE TABLE public.ticket (
    ticketno integer NOT NULL,
    flightno character varying(10) NOT NULL,
    idcardno character varying(11) NOT NULL
);
    DROP TABLE public.ticket;
       public         heap    postgres    false            �            1259    25279    someone_ticket    VIEW     m  CREATE VIEW public.someone_ticket AS
 SELECT t.ticketno,
    f.flightno,
    t.idcardno,
    p.fname,
    p.lname,
    f.departurecity,
    f.destinationcity,
    f.departuredate,
    f.departuretime,
    f.price
   FROM public.passenger p,
    public.ticket t,
    public.flight f
  WHERE ((t.ticketno = p.ticketno) AND ((t.flightno)::text = (f.flightno)::text));
 !   DROP VIEW public.someone_ticket;
       public          postgres    false    214    214    214    211    211    211    211    211    211    216    216    216            �            1259    25241    ticket_ticketno_seq    SEQUENCE     �   CREATE SEQUENCE public.ticket_ticketno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.ticket_ticketno_seq;
       public          postgres    false    216            s           0    0    ticket_ticketno_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.ticket_ticketno_seq OWNED BY public.ticket.ticketno;
          public          postgres    false    215            �           2604    25245    ticket ticketno    DEFAULT     r   ALTER TABLE ONLY public.ticket ALTER COLUMN ticketno SET DEFAULT nextval('public.ticket_ticketno_seq'::regclass);
 >   ALTER TABLE public.ticket ALTER COLUMN ticketno DROP DEFAULT;
       public          postgres    false    216    215    216            d          0    25070    company 
   TABLE DATA           9   COPY public.company (companyid, companyname) FROM stdin;
    public          postgres    false    210   Kr       g          0    25098    consumer 
   TABLE DATA           h   COPY public.consumer (consumerid, consumerpw, phone, mail, sex, dob, idcardno, loginstatus) FROM stdin;
    public          postgres    false    213   �r       e          0    25075    flight 
   TABLE DATA           �   COPY public.flight (flightno, planeid, departurecity, destinationcity, departuredate, price, departuretime, destinationtime) FROM stdin;
    public          postgres    false    211   $s       h          0    25236 	   passenger 
   TABLE DATA           f   COPY public.passenger (ticketno, fname, lname, sex, dob, mail, phonenumber, creditcardno) FROM stdin;
    public          postgres    false    214   Yt       f          0    25086    plane 
   TABLE DATA           B   COPY public.plane (planeid, planecapacity, companyid) FROM stdin;
    public          postgres    false    212   u       k          0    25358 	   sex_table 
   TABLE DATA           5   COPY public.sex_table (id, male, female) FROM stdin;
    public          postgres    false    218   �u       j          0    25242    ticket 
   TABLE DATA           >   COPY public.ticket (ticketno, flightno, idcardno) FROM stdin;
    public          postgres    false    216   �u       t           0    0    ticket_ticketno_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.ticket_ticketno_seq', 5, true);
          public          postgres    false    215            �           2606    25074    company company_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (companyid);
 >   ALTER TABLE ONLY public.company DROP CONSTRAINT company_pkey;
       public            postgres    false    210            �           2606    25102    consumer consumer_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.consumer
    ADD CONSTRAINT consumer_pkey PRIMARY KEY (consumerid);
 @   ALTER TABLE ONLY public.consumer DROP CONSTRAINT consumer_pkey;
       public            postgres    false    213            �           2606    25080    flight flight_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_pkey PRIMARY KEY (flightno);
 <   ALTER TABLE ONLY public.flight DROP CONSTRAINT flight_pkey;
       public            postgres    false    211            �           2606    25240    passenger passenger_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.passenger
    ADD CONSTRAINT passenger_pkey PRIMARY KEY (ticketno);
 B   ALTER TABLE ONLY public.passenger DROP CONSTRAINT passenger_pkey;
       public            postgres    false    214            �           2606    25090    plane plane_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.plane
    ADD CONSTRAINT plane_pkey PRIMARY KEY (planeid);
 :   ALTER TABLE ONLY public.plane DROP CONSTRAINT plane_pkey;
       public            postgres    false    212            �           2606    25372    sex_table sex_table_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sex_table
    ADD CONSTRAINT sex_table_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sex_table DROP CONSTRAINT sex_table_pkey;
       public            postgres    false    218            �           2606    25247    ticket ticket_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (ticketno);
 <   ALTER TABLE ONLY public.ticket DROP CONSTRAINT ticket_pkey;
       public            postgres    false    216            �           2620    25391    ticket t_raise_planecapacity    TRIGGER     �   CREATE TRIGGER t_raise_planecapacity BEFORE DELETE ON public.ticket FOR EACH ROW EXECUTE FUNCTION public.raise_planecapacity();
 5   DROP TRIGGER t_raise_planecapacity ON public.ticket;
       public          postgres    false    250    216            �           2620    25389    ticket t_reduce_planecapacity    TRIGGER     �   CREATE TRIGGER t_reduce_planecapacity AFTER INSERT ON public.ticket FOR EACH ROW EXECUTE FUNCTION public.reduce_planecapacity();
 6   DROP TRIGGER t_reduce_planecapacity ON public.ticket;
       public          postgres    false    251    216            �           2620    25386    passenger t_set_count_female    TRIGGER     |   CREATE TRIGGER t_set_count_female AFTER INSERT ON public.passenger FOR EACH ROW EXECUTE FUNCTION public.set_count_female();
 5   DROP TRIGGER t_set_count_female ON public.passenger;
       public          postgres    false    214    249            �           2620    25384    passenger t_set_count_male    TRIGGER     x   CREATE TRIGGER t_set_count_male AFTER INSERT ON public.passenger FOR EACH ROW EXECUTE FUNCTION public.set_count_male();
 3   DROP TRIGGER t_set_count_male ON public.passenger;
       public          postgres    false    214    248            �           2606    25103    flight flight_planeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_planeid_fkey FOREIGN KEY (planeid) REFERENCES public.plane(planeid) NOT VALID;
 D   ALTER TABLE ONLY public.flight DROP CONSTRAINT flight_planeid_fkey;
       public          postgres    false    211    3271    212            �           2606    25248 !   passenger passenger_ticketno_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.passenger
    ADD CONSTRAINT passenger_ticketno_fkey FOREIGN KEY (ticketno) REFERENCES public.ticket(ticketno) NOT VALID;
 K   ALTER TABLE ONLY public.passenger DROP CONSTRAINT passenger_ticketno_fkey;
       public          postgres    false    216    214    3277            �           2606    25108    plane plane_companyid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.plane
    ADD CONSTRAINT plane_companyid_fkey FOREIGN KEY (companyid) REFERENCES public.company(companyid) NOT VALID;
 D   ALTER TABLE ONLY public.plane DROP CONSTRAINT plane_companyid_fkey;
       public          postgres    false    210    212    3267            �           2606    25253    ticket ticket_flightno_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_flightno_fkey FOREIGN KEY (flightno) REFERENCES public.flight(flightno) NOT VALID;
 E   ALTER TABLE ONLY public.ticket DROP CONSTRAINT ticket_flightno_fkey;
       public          postgres    false    211    216    3269            d   p   x�s�r�t�KL��)�J-�rv��t�/J�K��Sp�,���K-�������+-�p��p��'�+x$�%*D���$���\��ZQP�Z\��rxOQ6��=... z(�      g   I   x�˯JN�����FƜF�&F�Ʀ�F !��������\N_N##]C#]SN�BS3sK�4�=... �If      e   %  x�u�KN�0���]�b'ihv.� f&HM+MG����p�A �.�����̯+j�}K3�q� �3O��t�:$p�] �Cp�� �sF��ǆ���N�JuP^�5��L��O� v4���g])�ϔ�tKY0�5-� �&8Ҡ}�>�Z�fӪ�1M��q���)K-�l�A%�o��R�q`Ů��hR�b���5�X�ʑ��+�@E�`���۷�uߦ_f�V֖ZKGy�.�r��+�<�x��GAb֙Ri�)W�OС��i�V�F>g��9�"�����[�{��R��:      h   �   x�M���0Eg�_�'�1u�tI�P������R8�%_݇;� ��\��D���*������Y�FFE��k�m������d��I����F�Z�@;B�}��������UבD�T��S=���Zàw�����=���l�I���E9�I��́�UB�A6A�      f   }   x�U��
�0���aĦq,�.
vP���������$wI1�с�R̘���Ybܢ� ,���'`��u���\���]v�tW�.j��纞�נ��R��Ґ��;j+�V�Ա|J�g@��7�      k      x�3�4�4������ �Y      j   I   x�-���@�ji��,��]��q,^8L~#��U�߂Pњh/	u�����(�l���e�|�1��     