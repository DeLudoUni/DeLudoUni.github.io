<?php

	ini_set('display_error', 1);
	ini_set('error_reporting', E_ALL);

	//print_r($_POST);

  // film prodotti in francia
  $france_movie = array (
    0 => 'Mary and Max',
    1 => 'Les dalton',
    2 => 'Il vento ci porterà via'
  );

  // film prodotti in italia
  $italy_movie = array (
    0 => 'La grande bellezza',
    1 => 'Il capitale umano',
    2 => 'Cuore'
  );

  $movies = array (
    ['ITA'] => $italy_movie,
    ['FRA'] => $france_movie
  );

?>

<!DOCTYPE html>
<html lang="IT">
	<head>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="css/uikit.min.css" />
        <script src="js/uikit.min.js"></script>
        <script src="js/uikit-icons.min.js"></script>
		<title>Esempio di PHP con paramentri POST</title>
	</head>
  <body>
    <div class="uk-container">

      <div class="uk-card uk-card-default uk-card-body">
        <?php
          if ( isset($_GET) && !empty($_GET['country'])) {
            $get_parameter = $_GET['country'];

            //Versione dinamica
            if (isset($movies[$get_parameter])) {
              $country_name = $get_parameter;
              $movielist = $movies[$get_parameter];
            } else {
              $get_parameter = 'paese sconosciuto';
              $movielist = array();
            }

            //Alternativa alla verione dinamica
            /*switch ($get_parameter) {
              case 'ITA':
                  $country_name = 'Italia';
                  $movielist = $movies['ITA'];
                break;
              case 'FRA':
                  $country_name = 'Francia';
                  $movielist = $movies['FRA'];
                break;
              default:
                  $get_parameter = 'paese sconosciuto';
                  $movielist = array();
                break;
            }*/

        ?>
          <h3 class="uk-card-title">Le pellicole prodotte in <?php print($country_name); ?> sono:</h3>
          <p>
            <?php
              if (!empty($movielist)) {
                //stampa la lista
                foreach ($movielist as $m) {
                  print('titolo: ');
                  print($m);
                  print('<br>');
                }

              } else {
                print ('nessuna pellicola corrisponde al parametro specificato');
              }
            ?>
          </p>
      </div>
      <?php
    } else {
      print ('La pagina prevede di indicare il paese d interesse per dunzionare correttamente.');
    }
       ?>

    <!--Chiusura generale della pagina-->
    </div>
  </body>
</html>
