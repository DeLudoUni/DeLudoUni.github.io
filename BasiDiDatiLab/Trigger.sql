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

CREATE OR REPLACE FUNCTION set_person_stats()
        RETURNS TRIGGER AS $$
DECLARE
    persons varchar(10) ARRAY[2];
    a_person crew.person%TYPE;
    a_crew crew%ROWTYPE;
    actor_count integer;
    director_count integer;
    producer_count integer;
    writer_count integer;

BEGIN

    -- capire che evento è stato fatto
    IF TG_OP = 'INSERT' THEN
      persons[1] = NEW.person;
    END IF;
    IF TG_OP = 'DELETE' THEN
      persons[1] = OLD.person;
    END IF;
    IF TG_OP = 'UPDATE' THEN
        persons[1] = OLD.person;
        IF OLD.person <> NEW.person THEN
            persons[2] = NEW.person;
        END IF;
    END IF;

    -- riconteggia il contenuto di person_stats per a_person
    -- inzioalizzo dei contatori
    FOREACH a_person = ARRAY persons

    actor_count = 0;
    director_count = 0;
    producer_count = 0;
    writer_count = 0;
    FOR a_crew IN SELECT * FROM crew
      WHERE person = a_person
    LOOP
        CASE
            WHEN a_crew.p_role = 'actor' THEN
                actor_count = actor_count + 1;
            WHEN a_crew.p_rle = 'director' THEN
                director_count = director_count + 1;
            WHEN a_crew.p_role = 'producer' THEN
                producer_count = producer_count + 1;
            WHEN a_crew.p_role = 'writer' THEN
                writer_count = writer_count + 1;
        END CASE;
    END LOOP;

    -- aggiornare la vista Materializzata
    DELETE FROM person_stat WHERE person_id = a_person;
    INSERT INTO person_stat(person_id, person_role. movie_number) VALUES (a_person, 'actor', actor_count);
    INSERT INTO person_stat(person_id, person_role. movie_number) VALUES (a_person, 'director', director_count);
    INSERT INTO person_stat(person_id, person_role. movie_number) VALUES (a_person, 'producer', producer_count);
    INSERT INTO person_stat(person_id, person_role. movie_number) VALUES (a_person, 'writer', writer_count);

    END LOOP;
    RETURN NULL;
END;
$$ language 'plpgsql';

CREATE TRIGGER i_u_d_crew
AFTER INSERT OR UPDATE OR DELETE ON crew
FOR EACH ROW EXECUTE PROCEDURE set_person_stats();

-- CREARE UNA TABELLA DI LOG CHE MEMORIZZA GLI EVENTI DI UPDATE SULLA TABELLA movie
CREATE TABLE update_log (
  id serial,
  op_ts timestamp DEFAULT current_timestamp,
  op_description varchar,
  affected_table varchar
);

CREATE OR REPLACE FUNCTION insert_update_log()
      RETURNS TRIGGER AS $$
DECLARE
    a_description update_log.op_description%TYPE;
BEGIN
    a_description = 'update on table movie on record with if = '|| NEW.id;
    INSERT INTO update_log(op_description, affected_table) VALUES (a_description, 'movie');
    RETURN NULL;
END;
$$ language 'plpgsql';

CREATE TRIGGER u_movie AFTER
UPDATE ON movie FOR EACH ROW
EXECUTE PROCEDURE insert_update_log();
