//cache
var lastBlockElement = null;
var secondLastBlockElement = null;

function Blocks()
{
	this.array = new Array(); //array di blocchi

	this.numberOfBlocks = 0;

	this.BLOCKS_HEIGHT = 20; //altezza percentuale uguale per tutti i blocchi

	//primo blocco del gioco, valori percentuali
	this.BLOCK0_LEFT = 0;
	this.BLOCK0_WIDTH = 40;

	//valori percentuali
	this.MIN_DISTANCE = 1;
	this.MIN_WIDTH = 4;
	this.MAX_WIDTH = 20;
	this.MIN_DISTANCE_FROM_RIGHT_SIDE = 2; //evita la formazione di un blocco di cui non si vede la fine

	//la larghezza del blocco successivo dipende dalla proprieta' left del blocco stesso
	this.lastRandomLeft = null;
}

Blocks.prototype.addBlock =
	function(left, width) 
	{
		this.array[this.numberOfBlocks] = document.createElement('div');
		this.array[this.numberOfBlocks].setAttribute('class', "block");
		this.array[this.numberOfBlocks].setAttribute('id', "block_" + this.numberOfBlocks);

		this.array[this.numberOfBlocks].style.height = this.BLOCKS_HEIGHT + "%";
		this.array[this.numberOfBlocks].style.width = width;

		this.array[this.numberOfBlocks].style.top = 100 - this.BLOCKS_HEIGHT	 + "%";
		this.array[this.numberOfBlocks].style.left = left;

		++this.numberOfBlocks;

		this.updateCacheValues(); //ultimo e penultimo blocco

		document.body.appendChild(lastBlockElement);
	}

Blocks.prototype.updateCacheValues =
	function()
	{
		lastBlockElement = this.array[game.blocks.numberOfBlocks - 1];
		secondLastBlockElement = (this.numberOfBlocks > 1) ? this.array[this.numberOfBlocks - 2] : null;
	}

//per ottenere un valore random tra min e max
//Math.floor(Math.random() * (max - min + 1)) + min;

//************************************************************************************
Blocks.prototype.randomLeft =
	function()
	{
		this.lastRandomLeft =	(this.numberOfBlocks === 1) ? //se il blocco da aggiungere e' il secondo
									(Math.floor(Math.random() * (100 - this.MIN_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE - this.BLOCK0_LEFT - this.BLOCK0_WIDTH - this.MIN_DISTANCE + 1)) + this.BLOCK0_LEFT + this.BLOCK0_WIDTH + this.MIN_DISTANCE) 
											: //se il blocco da aggiungere non e' il secondo
									(Math.floor(Math.random() * (100 - this.MIN_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE + parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - this.BLOCK0_LEFT - this.BLOCK0_WIDTH - 99)) + 100);		
		return this.lastRandomLeft + "%";
	}

	//RAGIONAMENTO
	/*
	Se e' il secondo blocco da aggiungere
		max = 100 - this.MIN_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE
		min = BLOCK0_LEFT + BLOCK0_WIDTH + this.MIN_DISTANCE
	*/
		/*
		per tutti gli altri
			max = 100 - this.MIN_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE + parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - this.BLOCK0_LEFT - this.BLOCK0_WIDTH
			min = 100
		*/

//************************************************************************************





//************************************************************************************
Blocks.prototype.randomWidth =
	function()
	{
		return (this.numberOfBlocks === 1) ?
			((this.lastRandomLeft > 100 - this.MAX_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE) ? 
					(Math.floor(Math.random() * (100 - this.lastRandomLeft - this.MIN_DISTANCE_FROM_RIGHT_SIDE - this.MIN_WIDTH + 1)) + this.MIN_WIDTH + "%") 
						: 
					(Math.floor(Math.random() * (this.MAX_WIDTH - this.MIN_WIDTH + 1)) + this.MIN_WIDTH + "%")) 
				: 
			((this.lastRandomLeft > 100 + parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - this.BLOCK0_LEFT - this.BLOCK0_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE - this.MAX_WIDTH) ? 
					(Math.floor(Math.random() * (100 + parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - this.BLOCK0_LEFT - this.BLOCK0_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE - this.lastRandomLeft - this.MIN_WIDTH + 1)) + this.MIN_WIDTH + "%") 
						: 
					(Math.floor(Math.random() * (this.MAX_WIDTH - this.MIN_WIDTH + 1)) + this.MIN_WIDTH + "%"));
	}

	//RAGIONAMENTO
	/*
	Se e' il secondo blocco
		if(this.lastRandomLeft > 100 - this.MAX_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE)
			max = 100 - this.lastRandomLeft - this.MIN_DISTANCE_FROM_RIGHT_SIDE
			min = this.MIN_WIDTH
				else
					max = this.MAX_WIDTH
					min = this.MIN_WIDTH
	*/
		/*
		Se non e' il secondo blocco
		if(this.lastRandomLeft > 100 + parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - this.BLOCK0_LEFT - this.BLOCK0_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE - this.MAX_WIDTH)
			max = 100 + parseFloat(lastBlockElement.style.left) + parseFloat(lastBlockElement.style.width) - this.BLOCK0_LEFT - this.BLOCK0_WIDTH - this.MIN_DISTANCE_FROM_RIGHT_SIDE - this.lastRandomLeft
			min = this.MIN_WIDTH
				else
					max = this.MAX_WIDTH
					min = this.MIN_WIDTH
		*/
//************************************************************************************