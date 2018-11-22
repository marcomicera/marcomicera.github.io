<?php
	require_once "./util/dbManager.php";
	require_once "./util/session.php";

	$username = $_POST['username']; 
	$password = $_POST['password']; 
	$confirm_password = $_POST['confirm_password'];
	
	$errorMessage = register($username, $password, $confirm_password);
	
	if($errorMessage === null) echo 'Welcome '.$_POST['username'].', press ENTER to play!';
		else echo $errorMessage;
	
	function register($username, $password, $confirm_password)
	{	
		if($username != null && $password != null && $confirm_password != null)
		{
			if($password != $confirm_password) return 'Passwords do not match.';
			
			$hasBeenAdded = addNewUser($username, $password);
    		
			if($hasBeenAdded)
			{
    			session_start();
				
				global $db;
				$queryText = "select userId from users where username='" . $username . "'";
				$userId = $db->performQuery($queryText)->fetch_assoc()['userId'];
				$db->closeConnection();

    			setSession($username, $userId);

    			return null;
    		}
    	}
			else return 'Something is missing!';
		
		return 'Username already taken.';
	}
	
	function addNewUser($username, $password)
	{
		global $db;
		$username = $db->sqlInjectionFilter($username);
		$password = $db->sqlInjectionFilter($password);

		$queryText = "insert into users(username, password, highscore) values('" . $username . "', '" . $password . "', 0)";

		$result = $db->performQuery($queryText); //ritorna un booleano
		$db->closeConnection();
		
		return $result;
	}
?>