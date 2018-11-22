//cache
var playerLeft = null;

function Player()
{
	this.htmlElement = document.createElement('div');

	//valori percentuali
	this.WIDTH = 2.8; //rispetto alla larghezza della finestra
	this.movementIncrease = 0.5;

	/* PLAYER SEMPRE QUADRATO

	La proprieta' width e' espressa in percentuale, rispetto alla larghezza della finestra.
	Per mantenere la forma quadrata del player, la proprieta' height viene costantemente
	aggiornata con il relativo valore di width in pixel, tramite la seguente relazione:

	HEIGHT = this.WIDTH * innerWidth / 100

	implementata dalla funzione fromPercentageToPixels in utility.js */

	this.finishLine = null; //linea di arrivo del player, in percentuale
	this.hasSucceed = true; //vale true se lo stick e' stato posizionato correttamente, booleano
}

Player.prototype.initialize =
	function(player)
	{
		this.htmlElement.setAttribute('class', "player");
		this.htmlElement.setAttribute('id', "player");

		this.htmlElement.style.width = this.WIDTH + "%";
		game.player.update(); //height, top, left

		document.body.appendChild(this.htmlElement);
	}

Player.prototype.update = //onresize
	function()
	{
		//per mantenere la forma quadrata del player
		game.player.htmlElement.style.height = fromPercentageToPixels(game.player.WIDTH, innerWidth);

		game.player.htmlElement.style.top = (100 - game.blocks.BLOCKS_HEIGHT - game.player.WIDTH * innerWidth / innerHeight) + "%";
		/* Senza semplificazioni, l'ultimo sottraendo e' game.player.WIDTH * innerWidth / 100 / innerHeight * 100,
		e consente di ottenere il rapporto percentuale tra l'altezza del player rispetto all'altezza della finestra.
		Quest'ultimo sottraendo e' composto da due parti:
		1) game.player.WIDTH * innerWidth / 100 e' l'altezza (e larghezza) in pixel del player;
		2) a questo valore si moltiplica 100 / innerHeight per estrarne il rapporto percentuale rispetto all'altezza della pagina.
		L'ultimo sottraendo equivale a: parseFloat(fromPixelsToPercentage(fromPercentageToPixels(game.player.WIDTH, innerWidth), innerHeight))
		innerWidth/innerHeight rappresenta il ratio della finestra */

		game.player.htmlElement.style.left = (game.player.hasSucceed) ? 
			game.blocks.BLOCK0_WIDTH + game.blocks.BLOCK0_LEFT - game.player.WIDTH - game.sticks.WIDTH + "%" 
				: 
			playerLeft + "%";
	}

Player.prototype.startMoving =
	function(hasSucceed)
	{
		this.hasSucceed = hasSucceed;
		this.finishLine = (hasSucceed) ? 
			parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - game.sticks.WIDTH - this.WIDTH
				:
			parseFloat(lastStickElement.style.left) + parseFloat(lastStickElement.style.width) - this.WIDTH;
				
		this.updateCacheValues();
		game.timer.start(game.player.move, game.timer.MOVING_PLAYER_SETINTERVAL_SPEED);
	}

Player.prototype.move =
	function()
	{
		for(var i = 0; i < game.timer.MOVING_PLAYER_LOOP_SPEED; ++i)
		{
			if(parseFloat(game.player.htmlElement.style.left) < game.player.finishLine)
			{
				playerLeft += game.player.movementIncrease;
				game.player.htmlElement.style.left = playerLeft + "%";
			}
		}

		//fine raggiunta	
		if(parseFloat(game.player.htmlElement.style.left) >= game.player.finishLine)
		{
			game.player.htmlElement.style.left = game.player.finishLine + "%";

			game.timer.pause();

			if(game.player.hasSucceed)
			{
				game.statistics.updateScore();

				//aggiunta di un nuovo blocco
				if(!DEV_MODE) game.blocks.addBlock(game.blocks.randomLeft(), game.blocks.randomWidth());
					else game.blocks.addBlock("100%", game.blocks.MAX_WIDTH + "%");

				game.timer.start(game.playground.moveScene, game.timer.MOVING_SCENE_SETINTERVAL_SPEED);
			}
				else game.statistics.gameOver();
		}
	}

Player.prototype.updateCacheValues =
	function()
	{
		playerLeft = game.blocks.BLOCK0_WIDTH + game.blocks.BLOCK0_LEFT - this.WIDTH - game.sticks.WIDTH;
	}