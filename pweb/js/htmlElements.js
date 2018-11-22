//Forms
//********************************

function createLoginFormDiv()
{
	var loginDiv = document.createElement('div');
	loginDiv.setAttribute("class", "form");
	loginDiv.setAttribute("id", "login_form");

	var loginForm = document.createElement('form');
	loginForm.setAttribute("method", "post");
	loginDiv.appendChild(loginForm);

	var usernameLabel = document.createElement('label');
	var usernameLabelText = document.createTextNode("Username:");
	usernameLabel.appendChild(usernameLabelText);
	loginForm.appendChild(usernameLabel);

	var usernameInput = document.createElement('input');
	usernameInput.setAttribute("type", "text");
	usernameInput.setAttribute("id", "username");
	usernameInput.setAttribute("name", "username");
	usernameLabel.appendChild(usernameInput);
	
	var passwordLabel = document.createElement('label');
	var passwordLabelText = document.createTextNode("Password:");
	passwordLabel.appendChild(passwordLabelText);
	loginForm.appendChild(passwordLabel);

	var passwordInput = document.createElement('input');
	passwordInput.setAttribute("type", "password");
	passwordInput.setAttribute("id", "password");
	passwordInput.setAttribute("name", "password");
	passwordLabel.appendChild(passwordInput);

	var loginButton = document.createElement('button');
	loginButton.setAttribute("type", "button");
	loginButton.setAttribute("name", "login");
	loginButton.setAttribute("onclick", "AjaxManager.prepareLogin()");
	var registerButtonText = document.createTextNode("Login");
	loginButton.appendChild(registerButtonText);
	loginForm.appendChild(loginButton);

	popup.appendChild(loginDiv);

	/*
	<div class="form" id="login_form">
		<form method="post">
			<label>Username: <input type="text" id="username" name="username"></label>
			<label>Password: <input type="password" id="password" name="password"></label>
			<button type="button" name="login" onclick="AjaxManager.prepareLogin();">Login</button>
		</form>
	</div>
	*/
}

function createRegisterFormDiv()
{
	var registerDiv = document.createElement('div');
	registerDiv.setAttribute("class", "form");
	registerDiv.setAttribute("id", "register_form");

	var registerForm = document.createElement('form');
	registerForm.setAttribute("method", "post");
	registerDiv.appendChild(registerForm);

	var usernameLabel = document.createElement('label');
	var usernameLabelText = document.createTextNode("Username:");
	usernameLabel.appendChild(usernameLabelText);
	registerForm.appendChild(usernameLabel);

	var usernameInput = document.createElement('input');
	usernameInput.setAttribute("type", "text");
	usernameInput.setAttribute("id", "username");
	usernameInput.setAttribute("name", "username");
	usernameLabel.appendChild(usernameInput);

	var passwordLabel = document.createElement('label');
	var passwordLabelText = document.createTextNode("Password:");
	passwordLabel.appendChild(passwordLabelText);
	registerForm.appendChild(passwordLabel);

	var passwordInput = document.createElement('input');
	passwordInput.setAttribute("type", "password");
	passwordInput.setAttribute("id", "password");
	passwordInput.setAttribute("name", "password");
	passwordLabel.appendChild(passwordInput);

	var confirmPasswordLabel = document.createElement('label');
	var confirmPasswordLabelText = document.createTextNode("Confirm password:");
	confirmPasswordLabel.appendChild(confirmPasswordLabelText);
	registerForm.appendChild(confirmPasswordLabel);

	var confirmPasswordInput = document.createElement('input');
	confirmPasswordInput.setAttribute("type", "password");
	confirmPasswordInput.setAttribute("id", "confirm_password");
	confirmPasswordInput.setAttribute("name", "confirm_password");
	confirmPasswordLabel.appendChild(confirmPasswordInput);

	var registerButton = document.createElement('button');
	registerButton.setAttribute("type", "button");
	registerButton.setAttribute("name", "register");
	registerButton.setAttribute("onclick", "AjaxManager.prepareRegistration()");
	var registerButtonText = document.createTextNode("Register");
	registerButton.appendChild(registerButtonText);
	registerForm.appendChild(registerButton);

	popup.appendChild(registerDiv);

	/*
	<div class="form" id="register_form">
		<form method="post">
			<label>Username: <input type="text" id="username" name="username"></label>
			<label>Password: <input type="text" id="password" name="password"></label>
			<label>Confirm password: <input type="text" id="confirm_password" name="confirm_password"></label>
			<button type="button" name="register" onclick="">Register</button>
		</form>
	</div>
	*/
}

//Footer
//********************************

function createFooter()
{
	footer = document.createElement('footer');
	var footerParagraph = document.createElement('p');
	footer.appendChild(footerParagraph);

	var howtoplayLink = document.createElement('a');
	howtoplayLink.setAttribute("href", "./html/howtoplay.html");
	var howtoplayLinkText = document.createTextNode("How to play");
	howtoplayLink.appendChild(howtoplayLinkText);
	footerParagraph.appendChild(howtoplayLink);
	footerParagraph.appendChild(document.createTextNode(" - "));

	var termsLink = document.createElement('a');
	termsLink.setAttribute("href", "./html/terms.html");
	var termsLinkText = document.createTextNode("Terms of Service");
	termsLink.appendChild(termsLinkText);
	footerParagraph.appendChild(termsLink);
	footerParagraph.appendChild(document.createTextNode(" - "));

	var privacyLink = document.createElement('a');
	privacyLink.setAttribute("href", "./html/privacy.html");
	var privacyLinkText = document.createTextNode("Privacy");
	privacyLink.appendChild(privacyLinkText);
	footerParagraph.appendChild(privacyLink);

	document.body.appendChild(footer);
}

//Highscore table
//********************************

function createHighscoreTable(highscoreArray)
{
	var highscoreTable = document.createElement('table');
	var highscoreTableCaption = document.createElement('caption');
	var highscoreTableCaptionText = document.createTextNode("Highscore table");
	highscoreTableCaption.appendChild(highscoreTableCaptionText);
	highscoreTable.appendChild(highscoreTableCaption);

	var highscoreTableHead = document.createElement('thead');
	highscoreTable.appendChild(highscoreTableHead);

	var highscoreTableHeadRow = document.createElement('tr');
	highscoreTableHead.appendChild(highscoreTableHeadRow);

	var highscoreTableHeadUserRow = document.createElement('th');
	var highscoreTableHeadUserRowText = document.createTextNode("User");
	highscoreTableHeadUserRow.appendChild(highscoreTableHeadUserRowText);
	highscoreTableHeadRow.appendChild(highscoreTableHeadUserRow);

	var highscoreTableHeadScoreRow = document.createElement('th');
	var highscoreTableHeadScoreRowText = document.createTextNode("Score");
	highscoreTableHeadScoreRow.appendChild(highscoreTableHeadScoreRowText);
	highscoreTableHeadRow.appendChild(highscoreTableHeadScoreRow);
	
	var highscoreTableBody = document.createElement('tbody');
	highscoreTable.appendChild(highscoreTableBody);

	var highscoreTableBodyRow = null;
	var highscoreTableBodyRowUsernameData = null;
	var highscoreTableBodyRowUsernameDataText = null;
	var highscoreTableBodyRowScoreData = null;
	var highscoreTableBodyRowScoreDataText= null;

	for(var i = 0; i < 10; ++i)
	{
		highscoreTableBodyRow = document.createElement('tr');
		highscoreTableBody.appendChild(highscoreTableBodyRow);

		highscoreTableBodyRowUsernameData = document.createElement('td');
		highscoreTableBodyRowUsernameDataText = document.createTextNode(highscoreArray[i]["username"]);
		highscoreTableBodyRowUsernameData.appendChild(highscoreTableBodyRowUsernameDataText);

		highscoreTableBodyRowScoreData = document.createElement('td');
		highscoreTableBodyRowScoreDataText = document.createTextNode(highscoreArray[i]["highscore"]);
		highscoreTableBodyRowScoreData.appendChild(highscoreTableBodyRowScoreDataText);

		highscoreTableBodyRow.appendChild(highscoreTableBodyRowUsernameData);
		highscoreTableBodyRow.appendChild(highscoreTableBodyRowScoreData);
	}
		
	popup.appendChild(highscoreTable);
}