var popup = null, footer = null, response = null;

var closeHandler = close.bind(this);
var resizableTextHandler = null; //per il titolo
var resizableTextHandler2 = null; //per eventuale sottotitolo

var canPressEnter = 0; //per iniziare il gioco

function welcomePopup()
{
	//inizializzazione variabili globali
	popup = document.body.childNodes[1];
	footer = document.body.getElementsByTagName("footer")[0];

	//aggiunta del logo di grandezza variabile
	var logo = document.getElementById("logo");
	var logoFontSize = 15;
	updateTextSize(logo, logoFontSize);
	resizableTextHandler = function() { updateTextSize(logo, logoFontSize); }
	window.addEventListener('resize', resizableTextHandler, false);

	//fadeIn
	fadeIn(popup, 0.01, 1, 10);
	fadeIn(footer, 0.01, 1, 10);

	//addEventListner per il tasto INVIO
	window.addEventListener('keypress', closeHandler, false);
}

function loginPopup(data)
{
	canPressEnter = 0;

	//eliminazione di vari elementi
	if(document.getElementsByClassName("response")[0] != null) popup.removeChild(document.getElementsByClassName("response")[0])
	if(document.getElementsByClassName("form")[0] != null) popup.removeChild(document.getElementsByClassName("form")[0]);
	popup.removeChild(document.getElementsByClassName("tools")[0]);

	//form di login
	createLoginFormDiv();

	//register link
	createPreLoginToolsDiv();

	//data e' null quando si proviene da una pagina di registrazione
	if(data != null) createResponseMessage(data);
}

function updatePopup(data)
{
	//eliminazione messaggi di risposta
	if(document.getElementsByClassName("response")[0] != null) popup.removeChild(document.getElementsByClassName("response")[0])

	//se il login e' avvenuto con successo
	if(data[0] == 'W')
	{
		popup.removeChild(document.getElementsByClassName("form")[0]);
		popup.removeChild(document.getElementsByClassName("tools")[0]);
		canPressEnter = 1;
	}

	createResponseMessage(data);

	if(data[0] == 'W') createLoggedToolsDiv();
}

function registerPopup()
{
	if(document.getElementsByClassName("response")[0] != null) popup.removeChild(document.getElementsByClassName("response")[0])
	popup.removeChild(document.getElementsByClassName("form")[0]);
	popup.removeChild(document.getElementsByClassName("tools")[0]);

	createRegisterFormDiv();

	createRegisterToolsDiv();
}

function gameOverPopup(data)
{
	var highscoreArray = JSON.parse(data);

	//creazione popup
	popup = document.createElement('div');
	popup.setAttribute('class', "popup");
	popup.setAttribute('id', "game_over_popup");
	document.body.appendChild(popup);

	//scritta "Game Over!"
	var gameOverText = document.createElement('h2');
	gameOverText.setAttribute("class", "resizable_text");
	gameOverText.setAttribute("id", "game_over_text");
	var gameOverTextNode = document.createTextNode("Game Over!");
	gameOverText.appendChild(gameOverTextNode);
	var gameOverFontSize = 8;
	updateTextSize(gameOverText, gameOverFontSize);
	resizableTextHandler = function() { updateTextSize(gameOverText, gameOverFontSize); }
	window.addEventListener('resize', resizableTextHandler, false);

	//scritta "Your/New highscore"
	var yourHighscoreText = document.createElement('h4');
	yourHighscoreText.setAttribute("class", "resizable_text");
	var yourHighscoreTextNode = null;
	if(game.statistics.score > personalHighscore)
	{
		yourHighscoreTextNode = document.createTextNode("New highscore: " + game.statistics.score);
		yourHighscoreText.setAttribute("id", "new_highscore_text");
	}
		else
		{
			yourHighscoreTextNode = document.createTextNode("Your highscore: " + personalHighscore);
			yourHighscoreText.setAttribute("id", "your_highscore_text");
		}
	yourHighscoreText.appendChild(yourHighscoreTextNode);
	var yourHighscoreFontSize = 4;
	updateTextSize(yourHighscoreText, yourHighscoreFontSize);
	resizableTextHandler2 = function() { updateTextSize(yourHighscoreText, yourHighscoreFontSize); }
	window.addEventListener('resize', resizableTextHandler2, false);

	popup.appendChild(gameOverText);
	popup.appendChild(yourHighscoreText);

	createHighscoreTable(highscoreArray);

	createResponseMessage("Press ENTER to play again!");

	//logout link, delete account link
	createGameOverToolsDiv();
	
	createFooter();

	fadeIn(popup, 0.01, 1, 10);
	fadeIn(footer, 0.01, 1, 10);

	window.addEventListener('keypress', closeHandler, false);
}

function createResponseMessage(data)
{
	//nuovo messaggio di riposta
	response = document.createElement('p');
	response.setAttribute("class", "response");
	response.setAttribute("id", data[0]+data[1]);

	//text-node del messaggio di risposta
	var responseText = document.createTextNode(data);
	response.appendChild(responseText);
	popup.appendChild(response);
}

function close(event)
{
	event = (!event) ? window.event : event; //evento undefined su I.E.
	var key = (event.which != null) ? event.which : event.keyCode; //event.which su Firefox

	if(key == ENTER_KEY && canPressEnter)
	{
		//removeEventListener
		window.removeEventListener('keypress', closeHandler, false);
		window.removeEventListener('resize', resizableTextHandler, false);
		if(resizableTextHandler2 != null) window.removeEventListener('resize', resizableTextHandler2, false);

		//rimozione elementi
		document.body.removeChild(popup); //rimozione del popup
		if(game != null) game.statistics.restart(); //rimozione degli elementi di gioco

		//creazione di un nuovo gioco
		game = new Game();
		AjaxManager.preparePersonalHighscore(); //recupero dell'highscore personale
		begin(); //preparazione del campo da gioco

		fadeIn(document.body, 0.01, 1, 4);
	}
}