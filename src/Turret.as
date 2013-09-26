package  
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Danny Weitekamp
	 */
	public class Turret extends MovieClip
	{
		//The Turret's health
		var health:Number = 100
		
		public function Turret() 
		{
			//Draw the Turret
			this.graphics.beginFill(0x0000FF)
			this.graphics.drawCircle(0, 0, 20)
			this.graphics.beginFill(0x00FF00)
			this.graphics.drawRect(-2.5, -30, 5, 20)

			
		}
		
	}

}//HI GITHUB