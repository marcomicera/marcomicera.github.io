var game = null;

function intro()
{
	//sfondo
	document.body.style.backgroundImage = "url(css/images/bg/bg" + Math.floor(Math.random()*12) + ".jpg)";

	//se l'utente e' gia' loggato puo' premere ENTER per iniziare il gioco
	AjaxManager.isLogged();

	welcomePopup();
}

function begin()
{
	//rimozione del footer
	document.body.removeChild(document.body.getElementsByTagName("footer")[0]);

	//aggiunta dei primi due blocchi
	game.blocks.addBlock(game.blocks.BLOCK0_LEFT + "%", game.blocks.BLOCK0_WIDTH + "%");
	if(!DEV_MODE) game.blocks.addBlock(game.blocks.randomLeft(), game.blocks.randomWidth());
		else game.blocks.addBlock(game.blocks.BLOCK0_LEFT + game.blocks.BLOCK0_WIDTH + game.blocks.MIN_DISTANCE + "%", game.blocks.MAX_WIDTH + "%");

	//aggiunta dello stick
	game.sticks.addNewStick();
	window.addEventListener('keypress', game.sticks.startIncreasingStickHeight.bind(this), false); //per iniziare la crescita dello stick
	window.addEventListener('keyup', game.sticks.stopIncreasingStickHeight.bind(this), false); //per interrompere la crescita dello stick

	//aggiunta dello score
	game.statistics.initializeScore();
	window.addEventListener('resize', function() { updateTextSize(game.statistics.scoreHtmlElement, 25) }, false);

	//aggiunta del player
	game.player.initialize();
	window.addEventListener('resize', game.player.update, false);
}

function Game()
{
	this.timer = new Timer();
	this.statistics = new Statistics();

	this.playground = new Playground();
	this.player = new Player();
	this.blocks = new Blocks();
	this.sticks = new Sticks();
}