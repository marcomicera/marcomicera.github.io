//keyboard keys
var SPACE_KEY = "32";
var ENTER_KEY = "13";

var DEV_MODE = false; //se uguale a true, il gioco diventa estremamente facile

function setCanPressEnterVariable(data)
{
	canPressEnter = data;
}

//ridimensiona il testo di un elemento rispetto all'altezza della finestra
function updateTextSize(element, size)
{
	element.style.fontSize = innerHeight * size / 100 + "px";
}

function fadeIn(element, initialOpacity, finalOpacity, speed)
{
	var op = initialOpacity;
	element.style.opacity = op;
    
	var timer = setInterval(function()
							{
								op += 0.01;

								if(op >= finalOpacity)
								{
									op = finalOpacity;
									clearInterval(timer);
								}

								element.style.opacity = op;

							}, speed);
}

function fromPixelsToPercentage(size, reference)
{
	return parseFloat(size) * 100 / reference + "%";
}

function fromPercentageToPixels(size, reference)
{
	return parseFloat(size) * reference / 100 + "px";
}