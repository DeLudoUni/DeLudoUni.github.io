-- check_person_location
-- su inserimento o modifica di un record in location, verficare che la persona non abbia già un record con il medesimo ruolo

CREATE OR REPLACE FUNCTION check_person_location()
RETURNS TRIGGER AS $$
DECLARE

  g_name person.given_name%TYPE;
  event varchar(10);

BEGIN

    PERFORM * FROM location
      WHERE person = NEW.person AND d_role = NEW.d_role;

    IF FOUND THEN
    -- risultato trovato
      SELECT given_name INTO g_name
        FROM person WHERE id = NEW.person;

      IF NEW.d_role = 'B' THEN
        event = 'nascita';
      ELSE
        event = 'decesso';
      END IF;

      RAISE INFO 'Inserimento annullato perchè esiste già un record per la persona % su evento di %', g_name, event;
      RETURN NULL;
    ELSE
    -- risultato non trovato
      RETURN NEW;
    END IF;

END;
$$ language 'plpgsql';


CREATE TRIGGER i_u_location
BEFORE INSERT OR UPDATE ON location
FOR EACH ROW
EXECUTE PROCEDURE check_person_location();

-- modifica di scale --> rating
--
--

CREATE OR REPLACE FUNCTION scale_update()
  RETURNS TRIGGER AS $$
BEGIN

    IF (OLD.scale <> NEW.scale) AND (OLD.score = NEW.score) THEN
        NEW.score = OLD.score / OLD.scale * NEW.scale;

    END IF;

    RETURN NEW;

END;
$$ language 'plpgsql';

CREATE TRIGGER u_rating
BEFORE UPDATE ON rating
FOR EACH ROW
EXECUTE PROCEDURE scale_update();

-- PERSON_STATS (VISTA MATERIALIZZATA)
-- creare una tabella con la seguente struttura person_stats(person_id, person_role, movie_number)
CREATE TABLE person_stats(
  person_id varchar(10) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE,
  person_role person_role,
  movie_number integer,
  PRIMARY KEY(person_id, person_role)
);

CREATE TRIGGER i_u_d_crew
AFTER INSERT OR UPDATE OR DELETE ON i_u_d_crew
FOR EACH ROW EXECUTE PROCEDURE set_person_stats();
