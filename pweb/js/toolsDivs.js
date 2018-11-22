var toolsDiv = null;

//PreLogin
//********************************

function createPreLoginToolsDiv()
{
	toolsDiv = document.createElement('div');
	toolsDiv.setAttribute("class", "tools");

	popup.appendChild(toolsDiv);

	createRegisterLink();
}

function createRegisterLink()
{
	var registerParagraph = document.createElement('p');
	var registerParagraphText = document.createTextNode("New user? ");
	registerParagraph.appendChild(registerParagraphText);
	
	var registerLink = document.createElement('a');
	registerLink.setAttribute("id", "register_link");
	registerLink.setAttribute("href", "#");
	registerLink.setAttribute("onclick", "registerPopup();");
	var registerLinkText = document.createTextNode("Create an account!");
	registerLink.appendChild(registerLinkText);
	registerParagraph.appendChild(registerLink);

	toolsDiv.appendChild(registerParagraph);
}

//Logged
//********************************

function createLoggedToolsDiv()
{
	toolsDiv = document.createElement('div');
	toolsDiv.setAttribute("class", "tools");

	popup.appendChild(toolsDiv);

	createLogoutLink();

	document.getElementsByClassName("tools")[0].appendChild(document.createTextNode(" - "));

	createDeleteLink();
}

function createLogoutLink()
{
	var logoutLink = document.createElement('a');
	logoutLink.setAttribute("id", "logout_link");
	logoutLink.setAttribute("href", "#");
	logoutLink.setAttribute("onclick", "AjaxManager.prepareLogout();");
	var logoutLinkText = document.createTextNode("Logout");
	logoutLink.appendChild(logoutLinkText);

	toolsDiv.appendChild(logoutLink);
}

function createDeleteLink()
{
	var deleteLink = document.createElement('a');
	deleteLink.setAttribute("id", "delete_link");
	deleteLink.setAttribute("href", "#");
	deleteLink.setAttribute("onclick", "AjaxManager.prepareAccountDeletion();");
	var deleteLinkText = document.createTextNode("Delete account");
	deleteLink.appendChild(deleteLinkText);

	toolsDiv.appendChild(deleteLink);
}

//Register
//********************************

function createRegisterToolsDiv()
{
	toolsDiv = document.createElement('div');
	toolsDiv.setAttribute("class", "tools");
	toolsDiv.setAttribute("id", "register_tools");

	popup.appendChild(toolsDiv);

	createLoginLink();
}

function createLoginLink()
{
	var loginParagraph = document.createElement('p');
	var loginParagraphText = document.createTextNode("Already a user? ");
	loginParagraph.appendChild(loginParagraphText);

	var loginLink = document.createElement('a');	
	loginLink.setAttribute("id", "login_link");
	loginLink.setAttribute("href", "#");
	loginLink.setAttribute("onclick", "loginPopup();");
	var loginLinkText = document.createTextNode("Login");
	loginLink.appendChild(loginLinkText);
	loginParagraph.appendChild(loginLink);

	toolsDiv.appendChild(loginParagraph);
}

//Game over
//********************************

function createGameOverToolsDiv()
{
	toolsDiv = document.createElement('div');
	toolsDiv.setAttribute("class", "tools");
	toolsDiv.setAttribute("id", "gameover_tools");

	popup.appendChild(toolsDiv);

	createGameOverLogoutLink();

	document.getElementsByClassName("tools")[0].appendChild(document.createTextNode(" - "));

	createGameOverDeleteLink();
}

function createGameOverLogoutLink()
{
	var logoutLink = document.createElement('a');
	logoutLink.setAttribute("id", "gameover_logout_link");
	logoutLink.setAttribute("href", "./php/logout.php");
	var logoutLinkText = document.createTextNode("Logout");
	logoutLink.appendChild(logoutLinkText);

	toolsDiv.appendChild(logoutLink);
}

function createGameOverDeleteLink()
{
	var deleteLink = document.createElement('a');
	deleteLink.setAttribute("id", "gameover_delete_link");
	deleteLink.setAttribute("href", "./php/deleteAccount.php");
	var deleteLinkText = document.createTextNode("Delete account");
	deleteLink.appendChild(deleteLinkText);

	toolsDiv.appendChild(deleteLink);
}