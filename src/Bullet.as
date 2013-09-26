package  
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Danny Weitekamp
	 */
	public class Bullet extends PhysItem
	{
		
		
		public function Bullet() 
		{
			//Draw the bullet
			graphics.beginFill(0xFFFF00)
			graphics.drawCircle(0,0,5)
		}
		
	}

}