<?php
	require_once "./util/dbManager.php";
	session_start();
	
	$queryText = "select highscore from users where username='" . $_SESSION['username'] . "'";
	
	$highscore = $db->performQuery($queryText)->fetch_assoc()['highscore'];
	$db->closeConnection();
	
	echo $highscore;
?>