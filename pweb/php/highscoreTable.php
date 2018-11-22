<?php
	require_once "./util/dbManager.php";	

	$queryText = "select username, highscore from users order by highscore desc limit 10";
	
	$rows = array();
	
	$result = $db->performQuery($queryText);
	
	//http://stackoverflow.com/questions/12272017/returning-multiple-rows-with-mysqli-and-arrays#answer-12272062
	while($row = $result->fetch_assoc()) $rows[] = $row;

	$db->closeConnection();
	echo json_encode($rows);
?>