function Timer()
{
	this.INCREASING_STICK_HEIGHT_SETINTERVAL_SPEED = 10;
	this.INCREASING_STICK_HEIGHT_LOOP_SPEED = 2;

	this.STICK_ROTATION_SETINTERVAL_SPEED = 4;
	this.STICK_ROTATION_LOOP_SPEED = 3;

	this.MOVING_PLAYER_SETINTERVAL_SPEED = 4;
	this.MOVING_PLAYER_LOOP_SPEED = 2;

	this.MOVING_SCENE_SETINTERVAL_SPEED = 4;
	this.MOVING_SCENE_LOOP_SPEED = 1;

	//SETINTERVALL_SPEED: numero di millisecondi passati come argomento a setInterval()
	//LOOP_SPEED: numero di cicli eseguiti nell'istruzione chiamata da setInterval()

	this.clock = null;
}

Timer.prototype.start =
	function(clockFunction, frequency)
	{
		if(this.clock == null && frequency > 0) this.clock = setInterval(clockFunction, frequency);
	}

Timer.prototype.pause =
	function()
	{
		clearInterval(this.clock);
		this.clock = null;
	}