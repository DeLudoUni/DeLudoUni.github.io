<?php
$genres = Array(
	'1375666' => 'Sci-Fi', 
	'0816692' => 'Drama', 
	'0816692' => 'Adventure', 
	'1345836' => 'Thriller', 
	'0770828' => 'Action'
	);

$movies_usa = Array(
	'2017' => 'Dunkirk', 
	'2012' => 'Django Unchained'
	);
$movies_ita = Array(
	'2013' => 'La grande bellezza',
 	'2011' => 'Habemus Papam'
 	);
$movies_fra = Array(
	'2013' => 'Il capitale umano',
	'2011' => 'This Must Be the Place'
	);

$movie_production = Array(
	'USA' => $movies_usa,
	'ITA' => $movies_ita, 
	'FRA' => $movies_fra
	);

/*
returns the array of existing movie genres
*/
function get_movie_genres(){
global $genres;

return $genres;

}

/*
returns the array of existing movies
*/
function get_all_movies(){
global $movie_production;

return $movie_production;

}

/*
returns the genre name given a genre id
*/
function get_genre_name($genre_id){
global $genres;

$genre_name = null;

if (isset($genres[$genre_id]))
	$genre_name = $genres[$genre_id];

return $genre_name;

}

/*
returns the movies produced in a given country 
*/
function get_movie_country($country){
global $movie_production;

$movie_country = null;

if (isset($movie_production[$country]))
	$movie_country = $movie_production[$country];

return $movie_country;

}

?>