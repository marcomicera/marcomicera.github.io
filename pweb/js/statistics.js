var highscoreArray = null;

function createHighscoreArray(data)
{
	highscoreArray = JSON.parse(data);
}

var personalHighscore = null;

function getPersonalHighscore(data)
{
	personalHighscore = data;
}

function Statistics()
{
	this.score = 0;

	this.scoreHtmlElement = document.createElement('div');
	this.scoreHtmlElementText = document.createTextNode(this.score);
}

Statistics.prototype.hasSucceed =	
	function()
	{
		//percentuali
		return (parseFloat(lastStickElement.style.width) - game.sticks.WIDTH <= parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - game.blocks.BLOCK0_LEFT - game.blocks.BLOCK0_WIDTH && parseFloat(lastStickElement.style.width) - game.sticks.WIDTH >= parseFloat(lastBlockElement.style.left) - game.blocks.BLOCK0_LEFT - game.blocks.BLOCK0_WIDTH) ? true : false;
	}

Statistics.prototype.initializeScore =
	function()
	{
		this.scoreHtmlElement.setAttribute('id', "score");

		updateTextSize(this.scoreHtmlElement, 25);

		//aggiunta del text-node
		this.scoreHtmlElement.appendChild(this.scoreHtmlElementText);

		document.body.appendChild(this.scoreHtmlElement);
	}

Statistics.prototype.updateScore =
	function()
	{
		++this.score;
		this.scoreHtmlElement.firstChild.nodeValue = this.score;
	}

Statistics.prototype.gameOver =
	function()
	{
		if(game.statistics.score > personalHighscore) AjaxManager.prepareSetNewHighscore();
			else AjaxManager.prepareHighscoreTable();
	}

Statistics.prototype.restart =
	function()
	{
		var i = 0;

		for(; i < game.blocks.numberOfBlocks; ++i)
			document.body.removeChild(game.blocks.array[i]);

		for(i = 0; i < game.sticks.numberOfSticks; ++i)
			document.body.removeChild(game.sticks.array[i]);

		document.body.removeChild(game.statistics.scoreHtmlElement);
		document.body.removeChild(game.player.htmlElement);
	}