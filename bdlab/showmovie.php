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
          <h3 class="uk-card-title">Hai selezionato le seguenti preferenze:
          </h3>
          <p>
            <?php
              print ('il titolo selezionato è:');
              // $_POST è una variabile super globale
              // $:POST è un array associativo
              print ($_POST['movietitle']);
            ?>
          </p>
      </div>

    <!--Chiusura generale della pagina-->
    </div>
  </body>
</html>
