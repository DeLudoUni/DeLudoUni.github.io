<?php 
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('lib/functions.php'); 
?>
<!DOCTYPE html>
<html>
    <head>
        <?php include_once ('lib/header.php'); ?>
        <title>
        IMDB app
        </title>
    </head>
    <body>
    <div class="uk-container uk-margin-bottom uk-margin-top">
    <h1 class="uk-article-title">Creazione di un menù dinamico - esempi con IMDB</h1>
    <?php include_once ('lib/navigation.php'); ?>

    <div class="uk-margin" uk-grid>
        <div class="uk-width-1-3">
            <div class="uk-card uk-card-primary uk-card-body uk-padding-small uk-text-left">
                <nav>
					<ul class="uk-nav uk-nav-default">
						<li><a href="dynamic_menu.php?mod=list">Film disponibili</a></li>
						<li><a href="dynamic_menu.php?mod=insert">Nuovo film</a></li>
						<li><a href="dynamic_menu.php?mod=stats">Statistiche</a></li>
					</ul>
				</nav>
            </div>
        </div>
        <div class="uk-width-2-3">
            <div class="uk-card uk-card-default uk-card-body uk-padding-small uk-text-left">
             <?php
				if (isset($_GET['mod'])) {
					switch ($_GET['mod']) {
					case 'insert':
						include_once('lib/movieform.php');	
						break;
					case 'stats':
						include_once('lib/moviestats.php');	
						break;
					case 'list':
					default:
						include_once('lib/movietable.php');	
						break;
					}
				} else {
					include_once('lib/movietable.php');		
				}
			?>       
            </div>
        </div>
    </div>
        
	</div>
    </body>
</html>