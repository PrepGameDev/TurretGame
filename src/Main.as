package 
{
	//Import stuff
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent
	import flash.text.TextField;
	import flash.display.StageDisplayState;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Danny Weitekamp
	 */
	public class Main extends Sprite 
	{
		/////////////////////////////////
		//// Public Variables /////////
		////////////////////////////
		
		//The Turret
		public var turret:Turret = new Turret
		//The Center of the screen
		public var centerX:Number
		public var centerY:Number		
		//A list of all items that need to enter the integration loop
		public var physItems:Vector.<PhysItem> = new Vector.<PhysItem>
		public var physItemsL:int = 0 
		//A list of all the bullets
		public var bullets:Vector.<Bullet> = new Vector.<Bullet>
		public var bulletsL:int = 0
		//A list of all the enemies
		public var enemies:Vector.<Enemy> = new Vector.<Enemy>
		public var enemiesL:int = 0
		//True if the mouse is down
		public var mouseIsDown:Boolean = false
		//The health bar
		public var healthBar:Sprite = new Sprite		
		//Text Fields
		public var scoreText:TextField = new TextField
		public var hightScoreText:TextField = new TextField
		public var gameOverText:TextField = new TextField
		//Scores
		public var score:int = 0
		public var highScore:int = 0
		//Counters to measure how many frames have passed
			//1 frame = (1/30) seconds; because were running at 30 fps
		public var counter:int = 0
		public var enemyCounter:int = 0
		public var bulletCounter:int = 0
		//How often Enemies pop up (in frames)
			//defaults at every 3 seconds and slowly decreases
		public var enemyFreq = 90
		
		public var fullScreen:Boolean = true
		
		
		
		//Counts down the time between the game ending and starting again
			//if its -1 then the game is running; When it hits 0 the game restarts
		public var gameOverCount:int = -1
		
		
		//////////////////////
		////Functions/////////
		//////////////////
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			//start the program in Full Screan
			stage.displayState = StageDisplayState.FULL_SCREEN
			
		}
		
		//Add stuff to stage; give it a postion; set up events
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		
			centerX = stage.stageWidth/2
			centerY = stage.stageHeight/2
			turret.x = centerX
			turret.y = centerY
			stage.addChild(turret)
			
			addEventListener(Event.ENTER_FRAME, loop)
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown)
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown)
			//stage.addEventListener( flash.events.FullScreenEvent.FULL_SCREEN , noticeDisplayState );
			
			healthBar.graphics.beginFill(0xFF0000)
			healthBar.graphics.drawRect(5, 5, 200, 25)
			stage.addChild(healthBar)
			
			var barFrame:Sprite = new Sprite
			barFrame.graphics.lineStyle(3, 0, 1)
			barFrame.graphics.drawRect(5, 5, 200, 25)
			stage.addChild(barFrame)
			
			scoreText.x = stage.stageWidth - 275
			scoreText.y = 0
			stage.addChild(scoreText)
			scoreText.scaleX = 3
			scoreText.scaleY = 3
			scoreText.mouseEnabled = false
			
			hightScoreText.x = stage.stageWidth - 275
			hightScoreText.y = 30
			stage.addChild(hightScoreText)
			hightScoreText.scaleX = 3
			hightScoreText.scaleY = 3
			hightScoreText.mouseEnabled = false
			
			
		}
			
		
		public function loop(e:Event = null):void {
			
			if (turret.health > 0) {
				//Make the turret follow the mouse
				var vecRX:Number = mouseX - centerX
				var vecRY:Number = mouseY - centerY
				
				var rot:Number = Math.atan2(vecRY, vecRX)
				rot *= 180 / Math.PI
				rot += 90
				
				turret.rotation = rot
				
				
				//Allow the player to shoot at 6 bullets per second if mouse is held down
				if (mouseIsDown && Number(bulletCounter)/5 == int(bulletCounter/5)){
					shoot()
				}
			}
			
			
			//Integrate every object with a velocity (enemies/bullets)
			for (var i:int = 0; i < physItemsL; i++) {
				var item:PhysItem = physItems[i]
				item.x += item.vx
				item.y += item.vy
			}
			
			//Brute force test each bullet against each enemy
			for (var i:int = 0; i < bulletsL; i++) {
				var bullet:Bullet = bullets[i]
				for (var j:int = 0; j < enemiesL; j++) {
					var enemy:Enemy = enemies[j]
					//If it hits damage the enemy and remove the bullet
					if (enemy.hitTestObject(bullet)) {
						enemy.health -= 20
						removeBullet(bullet)
					}
				}
				//Get rid of the bullet if it gets far enough away
				if (bullet.x * bullet.x + bullet.y * bullet.y > 1200000) {					
					removeBullet(bullet)
				}
				
			}
			//Loop through enemies
			for (var i:int = 0; i < enemiesL; i++) {
				var enemy:Enemy = enemies[i]
				//Decide if it should be dead
				if (enemy.health < 0) {
					if (enemy.count == 1) {
						score += 20
						enemy.Die()
					}
				//Otherwise test if it hits the turret
				//If it does kill it and make the turret take damage
				}else {
					if (enemy.hitTestObject(turret)) {
						if (enemy.count == 1) {
							turret.health -= 20
							enemy.Die()
						}
						
						
					}
				}
				//Test if the enemey is dead
				//If so run Die() so that the explosion animation can finish
				if (enemy.count > 1) {
					enemy.Die()
				}
				//If the animation is done remove the enemy
				if (enemy.remove) {
					stage.removeChild(enemy)
					enemies.splice(enemies.indexOf(enemy), 1)
					enemiesL--
					physItems.splice(physItems.indexOf(enemy), 1)
					physItemsL--
				}
			}
			
			
			//Iterate all counters 
			counter++
			enemyCounter++
			bulletCounter++
			
			//Reduce enemyFreq making the enemies come faster
			if (counter >= 150) {
				counter = 0
				enemyFreq -= 10
			}
			
			//Test if it is time to make an enemy come
			//If so make one at a random angle and send it at the turret
			if (enemyCounter >= enemyFreq) {
				enemyCounter = 0
				var enemy:Enemy = new Enemy;
				var ro:Number = Math.random() * 2 * Math.PI
				var vecX:Number = Math.cos(ro)
				var vecY:Number = Math.sin(ro)
				enemy.x = vecX * 600 + centerX
				enemy.y = vecY * 600 + centerY
				enemy.vx = -vecX * 5
				enemy.vy = -vecY * 5
				stage.addChild(enemy)
				
				physItems[physItemsL++] = enemy
				enemies[enemiesL++] = enemy
			}
			//Update the text fields
			scoreText.text = 		"Score:			" + String(score)
			hightScoreText.text = 	"HighScore:	" + String(highScore)
			
			//Update the Health bar
			var dimX:Number = 200*(turret.health / 100)
			if(dimX < 0) dimX = 0
			healthBar.graphics.clear()
			healthBar.graphics.beginFill(0xFF0000)
			healthBar.graphics.drawRect(5, 5, dimX, 25)
			
			
		
			//See if the score is higher than the highScore
			if(score > highScore) highScore = score
			
			//See if the turret is dead
			//If so start the game over sequence
			if (turret.health <= 0) {
				if (gameOverCount == -1) {
					gameOverCount = 150
					gameOverText.text = "GAME OVER" + "\n" + "	   	" + String(int(gameOverCount/30))
					gameOverText.scaleX = 5
					gameOverText.scaleY = 5
					gameOverText.x = stage.stageWidth/2 - gameOverText.width/2.5
					gameOverText.y = stage.stageHeight / 2 - gameOverText.height / 2
					gameOverText.mouseEnabled = false
					stage.addChild(gameOverText)
					
				}
				gameOverText.text = "GAME OVER" + "\n" + "	   	"+ String(int(gameOverCount/30))
				gameOverCount--
				if(gameOverCount == 0){
					reset()
				}
			}
		}
		
		//Handle the shooting/mouse presses
		public function mouseDown(e:MouseEvent = null):void {
			mouseIsDown = true
			shoot()
			
		}
		public function mouseUp(e:MouseEvent = null):void {
			mouseIsDown = false
			
		}
		
		//Remove bullets from the stage and from respective lists
		public function removeBullet(bullet:Bullet) {
			stage.removeChild(bullet)
			bullets.splice(bullets.indexOf(bullet), 1)
			bulletsL--
			physItems.splice(physItems.indexOf(bullet), 1)
			physItemsL--
		}
		
		//Fires 1 bullet
		public function shoot():void {
			//The vector from the center of the screen to the mouse
			var VX:Number = mouseX - centerX
			var VY:Number = mouseY - centerY			
			//Normalize the vector (make the magnitude 1)
			var dist:Number = VX * VX + VY * VY
			dist = Math.sqrt(dist)
			VX /= dist
			VY /= dist
			
			//Make a new bullet 
			//Make it's velocity and position relative the the direction of
			//the mouse
			var b:Bullet = new Bullet
			b.x = centerX + VX * 10
			b.y = centerY + VY * 10
			b.vx = 10 *VX
			b.vy = 10 * VY
			stage.addChild(b)
			physItems[physItemsL++] = b
			bullets[bulletsL++] = b
		}
		
		//Resets the game back to its start conditions
		public function reset():void {
			stage.removeChild(gameOverText)
			score = 0
			enemyFreq = 90
			for (var i:int = 0; i < bulletsL; i++) {
				var bullet:Bullet = bullets[i];
				stage.removeChild(bullet)
			}
			for (var j:int = 0; j < enemiesL; j++) {
				var enemy:Enemy = enemies[j]
				stage.removeChild(enemy)
			}
			
			bullets = new Vector.<Bullet>
			bulletsL = 0
			enemies = new Vector.<Enemy>
			enemiesL = 0
			physItems = new Vector.<PhysItem>
			physItemsL = 0 
			
			turret.health = 100
		}
		
		//Handler for the key press event
		public function keyDown(e:KeyboardEvent = null) {			
			if (e.keyCode == 32 || e.keyCode == Keyboard.ESCAPE) {
				//Toggles full screen if space is pressed
				if(fullScreen){
					stage.displayState = StageDisplayState.NORMAL
					fullScreen = false
				}else {
					stage.displayState = StageDisplayState.FULL_SCREEN
					fullScreen = true
				}
			}
		}
		
		
	}
	
}