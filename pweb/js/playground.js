function Playground()
{
	this.movementIncrease = 1; //incremento percentuale del movimento dell'intero playground
	this.numberOfMovingThings = 5; //numero degli ultimi block e sticks che si muoveranno
}

Playground.prototype.moveScene =
	function()
	{
		for(var i = 0; i < game.timer.MOVING_SCENE_LOOP_SPEED; ++i)
		{
			//se la fine non e' raggiunta
			if(parseFloat(secondLastBlockElement.style.left) + parseFloat(secondLastBlockElement.style.width) > game.blocks.BLOCK0_LEFT + game.blocks.BLOCK0_WIDTH)
			{
				//scorrimento blocks
				for(var j = (game.blocks.numberOfBlocks<game.playground.numberOfMovingThings)?0:(game.blocks.numberOfBlocks-game.playground.numberOfMovingThings); j <= game.blocks.numberOfBlocks - 1; ++j)
					game.blocks.array[j].style.left = parseFloat(game.blocks.array[j].style.left) - game.playground.movementIncrease + "%";

				//scorrimento sticks
				for(var j = (game.sticks.numberOfSticks<game.playground.numberOfMovingThings)?0:(game.sticks.numberOfSticks-game.playground.numberOfMovingThings); j <= game.sticks.numberOfSticks - 1; ++j)
					game.sticks.array[j].style.left = parseFloat(game.sticks.array[j].style.left) - game.playground.movementIncrease + "%";

				//scorrimento player
				game.player.htmlElement.style.left = parseFloat(game.player.htmlElement.style.left) - game.playground.movementIncrease + "%";
				
			}
		}

		//fine raggiunta
		if(parseFloat(secondLastBlockElement.style.left) + parseFloat(secondLastBlockElement.style.width) <= game.blocks.BLOCK0_LEFT + game.blocks.BLOCK0_WIDTH)
		{
			game.timer.pause();
			game.sticks.addNewStick();
			game.sticks.resetFlags();
		}
	}