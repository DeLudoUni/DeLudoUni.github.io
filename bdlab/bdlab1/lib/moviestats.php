<?php //TODO: Inserire il codice per la visualizzazione delle statistiche
?>

<form action="dynamic_menu.php?mod=stats" method="POST">
  <select name="stat_choice" class="uk-select">
    <option value="movies">Numero di pellicole per genere</option>
    <option value="persons">Numero di persone per ruolo</option>

    <button type="submit" class="ul-button uk-button-primary">Mostra statistiche</button>
  </select>

</form>
