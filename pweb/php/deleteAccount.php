<?php
	require_once "./util/dbManager.php";
	session_start();
	
	$queryText = "delete from users where userId='" . $_SESSION['userId'] . "'";
	
	$db->performQuery($queryText);
	$db->closeConnection();
	
	session_destroy();
	
	if(isset($_POST['noRedirect'])) echo 'Account deleted.';
	else
	{
		header("Location: ./../index.php");
		exit;
	}
?>