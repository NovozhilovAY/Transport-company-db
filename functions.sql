-- ==============================================================================================
CREATE OR REPLACE FUNCTION public.get_distance(
	lat1 numeric,
	long1 numeric,
	lat2 numeric,
	long2 numeric)
    RETURNS numeric
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	lt1 numeric;
	lg1 numeric;
	lt2 numeric;
	lg2 numeric;
BEGIN
	lt1 = radians(lat1);
	lt2 = radians(lat2);
	lg1 = radians(long1);
	lg2 = radians(long2);
	RETURN round(CAST((2 * 6371 * asin(sqrt(power(sin((lt2-lt1)/2),2) + cos(lt1) * cos(lt2) * power((lg2-lg1)/2,2))))AS numeric),3);
END;
$BODY$;

-- ==============================================================================================

CREATE FUNCTION public.insert_car()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	INSERT INTO log (car_id, latitude, longitude, kilometrage)
	VALUES (NEW.id, NEW.latitude, NEW.longitude, 0);
	RETURN NEW;

END;
$BODY$;


-- ==============================================================================================

CREATE FUNCTION public.update_position()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	distance numeric;

BEGIN

	IF OLD.latitude = NEW.latitude AND OLD.longitude = NEW.longitude THEN
		RETURN NEW;
	END IF;
	
	distance := get_distance(OLD.latitude, OLD.longitude, NEW.latitude, NEW.longitude);

	INSERT INTO log (car_id, latitude, longitude, kilometrage)
	VALUES (NEW.id, NEW.latitude, NEW.longitude, distance);
	
	UPDATE cars SET 
		kilometrage = OLD.kilometrage + distance,
		km_before_maint = OLD.km_before_maint - distance 
		WHERE id = OLD.id; 

	RETURN NEW;
END;
$BODY$;

-- ==============================================================================================

CREATE OR REPLACE FUNCTION public.clear_log(
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN

	INSERT INTO history (car_id, h_date, kilometrage)
	SELECT car_id, CAST(log_time AS date), SUM(kilometrage) FROM log GROUP BY(car_id, CAST(log_time AS date));
	
	DELETE FROM log;
	
	INSERT INTO log (car_id, latitude, longitude, kilometrage)
	SELECT id, latitude, longitude, 0.0 FROM cars;
	RETURN;
END;
$BODY$;
-- ===============================================================================================