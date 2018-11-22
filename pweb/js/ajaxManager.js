function AjaxManager() {}

AjaxManager.getAjaxObject = 
	function()
	{
		var xmlHttp = null;
		try 
		{ 
			xmlHttp = new XMLHttpRequest(); 
		} 
			catch(e) 
			{
				try 
				{ 
					xmlHttp = new ActiveXObject("Msxml2.XMLHTTP"); //IE (recent versions)
				} 
					catch(e)
					{
						try 
						{ 
							xmlHttp = new ActiveXObject("Microsoft.XMLHTTP"); //IE (older versions)
						} 
							catch(e) 
							{
								xmlHttp = null; 
							}
					}
			}	

		return xmlHttp;
	}

AjaxManager.performAjaxRequest = 
	function(method, url, isAsync, dataToSend, responseFunction)
	{
		var xmlHttp = AjaxManager.getAjaxObject();
		if (xmlHttp === null)
		{
			window.alert("Your browser does not support AJAX!");
			return;
		}

		xmlHttp.open(method, url, isAsync); 
		xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xmlHttp.onreadystatechange = function ()
		{
			if (xmlHttp.readyState == 4)
			{
				var data = xmlHttp.responseText;	
				responseFunction(data);
			}
		}
		xmlHttp.send(dataToSend);
}

AjaxManager.isLogged =
	function()
	{
		var url = "./php/util/isLogged.php";

		//setCanPressEnterVariable in utility.js
		AjaxManager.performAjaxRequest("POST", url, true, null, setCanPressEnterVariable);
	}

AjaxManager.prepareLogin =
	function()
	{
		var url = "./php/login.php";
		var un = document.getElementById("username").value;
		var pw = document.getElementById("password").value;
		var vars = "username="+un+"&password="+pw;
		
		AjaxManager.performAjaxRequest("POST", url, true, vars, updatePopup);
	}

AjaxManager.prepareLogout =
	function()
	{
		var url = "./php/logout.php";

		AjaxManager.performAjaxRequest("POST", url, true, "noRedirect="+true, loginPopup);
	}

AjaxManager.prepareRegistration =
	function()
	{
		var url = "./php/register.php";
		var un = document.getElementById("username").value;
		var pw = document.getElementById("password").value;
		var cpw = document.getElementById("confirm_password").value;
		var vars = "username="+un+"&password="+pw+"&confirm_password="+cpw;

		AjaxManager.performAjaxRequest("POST", url, true, vars, updatePopup);
	}

AjaxManager.preparePersonalHighscore =
	function()
	{
		var url = "./php/personalHighscore.php";

		AjaxManager.performAjaxRequest("POST", url, true, null, getPersonalHighscore)
	}

AjaxManager.prepareSetNewHighscore =
	function()
	{
		var url = "./php/setNewHighscore.php";
		var vars = "score="+game.statistics.score;

		AjaxManager.performAjaxRequest("POST", url, true, vars, AjaxManager.prepareHighscoreTable);
	}

AjaxManager.prepareHighscoreTable =
	function()
	{
		var url = "./php/highscoreTable.php";

		AjaxManager.performAjaxRequest("POST", url, true, null, gameOverPopup);
	}

AjaxManager.prepareAccountDeletion =
	function()
	{
		var url = "./php/deleteAccount.php";

		AjaxManager.performAjaxRequest("POST", url, true, "noRedirect="+true, loginPopup);
	}