CREATE OR REPLACE FUNCTION get_movie_top_rating(varchar(200))
RETURNS numeric AS $$
DECLARE
/*Variabili se presenti*/
    --max_score numeric;
    max_score rating.score%TYPE; /* Permette alla funzione di prendere il tipo di rating.score*/

BEGIN
/*Corpo della funzione*/
    SELECT max(score) INTO max_score
    FROM movie INNER JOIN rating ON movie.id = rating.movie
    WHERE trim(lower(official_title)) = trim(lower($1));

    RETURN max_score;
END;
$$ language 'plpgsql';

-- esempio: trovare la valutazione massima per il film inception
/*SELECT max(score)
FROM movie INNER JOIN rating ON movie.id = rating.movie
WHERE lower(official_title) = lower('Inception');*/

SELECT * FROM get_movie_top_rating('inception');

-- Implemento la stessa funzione, ma in modo migliore
-- Input: il titolo di un film
-- la valutazione massima ricevuta da ciascun film con il titolo specificato

CREATE OR REPLACE FUNCTION get_movie_top_rating_revised
    (movie_title varchar(200))
    RETURNS SETOF numeric AS $$
DECLARE

    max_score rating.score%TYPE;

BEGIN

    FOR max_score IN
        SELECT max(score)
          FROM movie INNER JOIN rating ON movie.id = rating.movie
          WHERE trim(lower(official_title)) = trim(lower(movie_title))
          GROUP BY movie.id
    LOOP
      RETURN NEXT max_score;
    END LOOP;

    RETURN;

END;
$$ language 'plpgsql';

-- Produrre una nuova funzione che restituisce anche il campo id del fil, corrispondente
-- input: titolo del film.
-- output: <movie_id, top_rating> per ogni pellicola specificata

-- ho bisgono di creare un nuovo tipo che contenga l'output
CREATE TYPE movie_top_rating AS (movie_id varchar(10),
top_rating numeric);

DROP FUNCTION get_movie_top_rating_revised(varchar(200));

CREATE OR REPLACE FUNCTION get_movie_top_rating_revised
    (movie_title varchar(200))
    RETURNS SETOF movie_top_rating AS $$
DECLARE

    max_score movie_top_rating;

BEGIN

    FOR max_score IN
        SELECT movie.id, max(score)
          FROM movie INNER JOIN rating ON movie.id = rating.movie
          WHERE trim(lower(official_title)) = trim(lower(movie_title))
          GROUP BY movie.id
    LOOP
      RETURN NEXT max_score;
    END LOOP;

    RETURN;

END;
$$ language 'plpgsql';

-- get_movie_genre
-- dato il titolo di una pellicola, restituire tutti i generi cinematografici assocaiti
--input: titolo di un film
--output: la lista <movie, genre dei generi per il seelzionato film

DROP FUNCTION get_movie_genre(varchar(200));

CREATE OR REPLACE FUNCTION get_movie_genre
    (movie_title varchar(200))
    RETURNS SETOF genre AS $$
DECLARE

    a_genre genre%ROWTYPE;

BEGIN

    FOR a_genre IN
        SELECT genre.*
          FROM movie INNER JOIN genre ON movie.id = genre.movie
          WHERE trim(lower(official_title)) = trim(lower(movie_title))
    LOOP
      RETURN NEXT a_genre;
    END LOOP;

    RETURN;

END;
$$ language 'plpgsql';

--stessa funzione con cursore

CREATE OR REPLACE FUNCTION get_movie_genre_cursor
    (varchar(200)) RETURNS SETOF genre AS $$
DECLARE

    a_genre genre%ROWTYPE;
    movie_genres CURSOR FOR SELECT genre.*
      FROM movie INNER JOIN genre ON movie.id = genre.movie
      WHERE trim(lower(official_title)) = trim(lower($1));

BEGIN

    OPEN movie_genres; /*Apertura del cursore*/

    LOOP
        FETCH movie_genres INTO a_genre;
        EXIT WHEN NOT FOUND; /*Permette di uscire dal loop quando la queery ha finito*/

        RETURN NEXT a_genre;

    END LOOP;
    CLOSE movie_genres; /*Chiusura del cursore*/
    RETURN;

END;
$$ language 'plpgsql';

-- get_movie_card
-- dato il codice di un film, restituisce un testo che descriva titolo,
--anno, durata e una lista di paesi in cui il film è stato distribuito.
--Per ogni paese mostrare l'anno e il titolo adottato.
--input: codice id di un film
--output: una descrizione testuale del film

CREATE OR REPLACE FUNCTION get_movie_card(varchar(10))
    RETURNS text AS $$
DECLARE

    card text;
    m movie%ROWTYPE;

    c released.country%TYPE;
    r released.released%TYPE;
    t released.title%TYPE;

BEGIN
    card = '';

    SELECT * FROM movie INTO m
      WHERE trim(lower(id)) = trim(lower($1));

    IF FOUND THEN
      card= m.official_title || ' - durata: '||
          m.length || ' minuti - anno di realizzazione: ' ||
          m.year || E'\n';

          FOR c,r,t IN SELECT country, released, title FROM released
            WHERE movie = m.id
          LOOP
              card = card || 'distribuito in ' || c;
              IF r IS NOT NULL THEN
                  card = card || ' in data ' || to_char(r, 'DD/MM/YYYY');
              END IF;
              IF t IS NOT NULL THEN
                  card = card || ' con titolo ' || t ;
              END IF;
              card = card || E'\n';
          END LOOP;

    ELSE
      RAISE INFO 'La pellicola richiesta non esiste nel db.';
    END IF;

    RETURN card;

END;
$$ language 'plpgsql';

SELECT * FROM get_movie_card('1375666');
