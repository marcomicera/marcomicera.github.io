<?php
	require_once "./util/dbManager.php";
	require_once "./util/session.php";

	$username = $_POST['username'];
	$password = $_POST['password'];
	
	$errorMessage = login($username, $password);
	
	if($errorMessage === null) echo 'Welcome '.$_POST['username'].', press ENTER to play!';
		else echo $errorMessage;

	function login($username, $password)	
	{		
		if($username != null && $password != null)
		{
			$userId = authenticate($username, $password);
    		if($userId > 0)
			{
    			session_start();
    			setSession($username, $userId);
				
    			return null;
    		}
    	}
			else return 'Missing username and/or password.';
    	
    	return 'Username and/or password not valid.';
	}
	
	function authenticate($username, $password)
	{   
		global $db;
		$username = $db->sqlInjectionFilter($username);
		$password = $db->sqlInjectionFilter($password);

		$queryText = "select userId from users where username='" . $username . "' AND password='" . $password . "'";

		$result = $db->performQuery($queryText);

		$numRow = mysqli_num_rows($result);
		if($numRow != 1) return -1;

		$userId = $result->fetch_assoc()['userId'];
		$db->closeConnection();

		return $userId;
	}
?>