package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Danny Weitekamp
	 */
	public class Enemy extends PhysItem
	{
		public var health:Number = 60
		public var count:int = 1
		public var remove:Boolean = false
		public var cage:MovieClip
		
		public function Enemy() 
		{
			this.cage = new CageHeadClip
			this.addChild(cage)
			//this.graphics.beginFill(0xFF0000)
			//this.graphics.drawCircle(0, 0, 20)
			
		}
		
		//Kill the Cage and iterate the explosion sequence
		public function Die():void {		
			if(cage != null){
				this.removeChild(cage)
				cage = null
			}
			this.vx = 0
			this.vy = 0
			this.graphics.clear()
			this.graphics.beginFill(0xFF0000)
			this.graphics.drawCircle(0, 0, count * 10)
			this.graphics.drawCircle(0, 0, (count + 1) * 10)
			if (count > 3) {
				remove = true
			}
			count++
			
			
		}
		
	}

}