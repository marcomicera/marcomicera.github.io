//cache
var lastStickElement = null;
var stickHeight = null;
var stickTop = null;

function Sticks()
{
	this.array = new Array();

	this.WIDTH = 0.5; //con lo stick verticale, in percentuale

	this.heightCanIncrease = 1; //bool
	this.heightIncrease = 0.5; //percentuale

	//angoli in gradi
	this.rotationAngle = 0;
	this.rotationIncrease = 0.75;

	this.numberOfSticks = 0;

	//permette di chiamare la setInterval una sola volta dopo la pressione della barra spaziatrice
	this.isFirstKeyPressEvent = 1;
}

Sticks.prototype.addNewStick =
	function()
	{
		this.array[this.numberOfSticks] = document.createElement('div');
		this.array[this.numberOfSticks].setAttribute('class', "stick");
		this.array[this.numberOfSticks].setAttribute('id', "stick_" + this.numberOfSticks);

		this.array[this.numberOfSticks].style.height = "0%";
		this.array[this.numberOfSticks].style.width = this.WIDTH + "%";

		this.array[this.numberOfSticks].style.top = 100 - game.blocks.BLOCKS_HEIGHT + "%";
		this.array[this.numberOfSticks].style.left = parseFloat(secondLastBlockElement.style.width) + parseFloat(secondLastBlockElement.style.left) - this.WIDTH + "%";

		++this.numberOfSticks;

		lastStickElement = this.array[game.sticks.numberOfSticks - 1]; //cache

		document.body.appendChild(lastStickElement);	
	}

Sticks.prototype.startIncreasingStickHeight = //keydown
	function(event)
	{
		if(game.sticks.heightCanIncrease)
		{
			event = (!event) ? window.event : event; //evento undefined su I.E.
			var pressedKey = (event.which != null) ? event.which : event.keyCode; //event.which su Firefox

			if(pressedKey == SPACE_KEY && game.sticks.isFirstKeyPressEvent)
			{
				game.sticks.isFirstKeyPressEvent = 0;
				game.sticks.updateCacheValues();
				game.timer.start(game.sticks.increaseStickHeight, game.timer.INCREASING_STICK_HEIGHT_SETINTERVAL_SPEED);
			}
		}
	}

Sticks.prototype.increaseStickHeight =
	function()
	{
		for(var i = 0; i < game.timer.INCREASING_STICK_HEIGHT_LOOP_SPEED; ++i)
		{
			stickHeight += game.sticks.heightIncrease;
			lastStickElement.style.height = stickHeight + "%";

			stickTop -= game.sticks.heightIncrease;
			lastStickElement.style.top = stickTop + "%";
		}
	}

Sticks.prototype.stopIncreasingStickHeight = //keyup
	function(event)
	{
		event = (!event) ? window.event : event; //evento undefined su I.E.
		var upKey = (event.which != null) ? event.which : event.keyCode; //event.which su Firefox

		if(upKey == SPACE_KEY && game.sticks.heightCanIncrease)
		{
			game.timer.pause();
			game.sticks.heightCanIncrease = 0;
			game.timer.start(game.sticks.rotateStick, game.timer.STICK_ROTATION_SETINTERVAL_SPEED);
		}
	}

Sticks.prototype.rotateStick =
	function()
	{
		for(var i = 0; i < game.timer.STICK_ROTATION_LOOP_SPEED; ++i)
		{
			if(game.sticks.rotationAngle < 90)
			{
				game.sticks.rotationAngle += game.sticks.rotationIncrease;
				//http://www.w3.org/TR/css3-transforms/#funcdef-rotate
				lastStickElement.style.transform = "rotate(" + game.sticks.rotationAngle + "deg)";
			}
		}

		if(game.sticks.rotationAngle >= 90)
		{
			lastStickElement.style.transform = "rotate(90deg)";
			game.sticks.swapStickProperties();
		}
	}

Sticks.prototype.swapStickProperties =
	function()
	{
		game.timer.pause();
		this.isFirstKeyPressEvent = 1;

		lastStickElement.style.transform = "rotate(0deg)";

		lastStickElement.style.top = 100 - game.blocks.BLOCKS_HEIGHT + "%";

		var newHeight = fromPercentageToPixels(lastStickElement.style.height, innerHeight);
		var newWidth = fromPercentageToPixels(lastStickElement.style.width, innerWidth);

		//scambio tra proprieta' width e height (Chrome tronca valori razionali di pixel)
		lastStickElement.style.width = fromPixelsToPercentage(newHeight, innerWidth);
		lastStickElement.style.height = fromPixelsToPercentage(newWidth, innerHeight);

		game.player.startMoving(game.statistics.hasSucceed());
	}

Sticks.prototype.resetFlags =
	function()
	{
		this.heightCanIncrease = 1;
		this.rotationAngle = 0;
	}

Sticks.prototype.updateCacheValues =
	function()
	{
		stickHeight = 0; //%
		stickTop = 100 - game.blocks.BLOCKS_HEIGHT; //%
	}