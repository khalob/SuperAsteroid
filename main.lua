
--***********SuperAsteroid***********
--Authors: Khalob Cognata and Yinan Li
 
--Include Corona's "physics" library
local physics = require "physics"

function main()
--Uses Corona's Physics 
physics.start()
physics.setGravity(0,0) --take away gravity

----------------Variables----------------
--Time and Level Control
local curTime = 0 
local curLevel = 1

--Timers
local timer1
local timer2 
local timer3 
local timer4
local timer5
local timer6
local timerBlink
local timerChangeEye
local timerBossAttack

--Images and their resepctive properties
local background = display.newImage("UI/background.png")
background.x = display.contentCenterX
background.y = display.contentCenterY

local player = display.newImage("Other/player.png", display.contentWidth/8, display.contentHeight/2)
player.name = "player"
physics.addBody(player, {density=1.0})

local rateOfFire = 2 --Per second
local movementSpeed = 5 --Player movement speed
local dead = false --Indicates player has been killed

local boss = display.newImage("Enemies/boss.png", 1250, 360)
boss.isVisible = false;
boss.isActive = false;
physics.addBody(boss, "static")

local bossHealth = 100
local bossAngered = false --Affects the attack speed of boss
local bossCanDie = false
local bossAttackSpeed = 6;
local eyeNum = 1 --Current non-blinking eye of boss
local count = 0 --Used to count how many times the boss blinks

--Bosses' 4 eyelids
local bossEyelid1 = display.newImage("Enemies/eyelid.png", 925, 110)
bossEyelid1.isVisible = false;
bossEyelid1.isActive = false;

local bossEyelid2 = display.newImage("Enemies/eyelid.png", 925, 280)
bossEyelid2.isVisible = false;
bossEyelid2.isActive = false;

local bossEyelid3 = display.newImage("Enemies/eyelid.png", 925, 430)
bossEyelid3.isVisible = false;
bossEyelid3.isActive = false;

local bossEyelid4 = display.newImage("Enemies/eyelid.png", 925, 590)
bossEyelid4.isVisible = false;
bossEyelid4.isActive = false;

--Bosses' 4 lasers
local laser1 = display.newImage("Other/laser.png", 425, 110)
laser1.isVisible = false;
laser1.isActive = false;
laser1.name = "laser"

local laser2 = display.newImage("Other/laser.png", 425, 280)
laser2.isVisible = false;
laser2.isActive = false;
laser2.name = "laser"

local laser3 = display.newImage("Other/laser.png", 425, 430)
laser3.isVisible = false;
laser3.isActive = false;
laser3.name = "laser"

local laser4 = display.newImage("Other/laser.png", 425, 590)
laser4.isVisible = false;
laser4.isActive = false;
laser4.name = "laser"

--Directional-Pad
local up = display.newImage("Directional Pad/up.png", display.contentWidth/1.15, display.contentHeight/1.5)
local down = display.newImage("Directional Pad/down.png", display.contentWidth/1.15, display.contentHeight/1.15)
local left = display.newImage("Directional Pad/left.png", display.contentWidth/1.25, display.contentHeight/1.3)
local right = display.newImage("Directional Pad/right.png", display.contentWidth/1.07, display.contentHeight/1.3)

local holdingUp = false
local holdingDown = false
local holdingLeft = false
local holdingRight = false

--Groups of objects
local projectiles = display.newGroup()
local objectsToDie = display.newGroup()
local enemies = display.newGroup()

--Gameover Screen Images/Buttons
local gameover = display.newImage("UI/gameover.png")
gameover.x = display.contentCenterX
gameover.y = display.contentCenterY
gameover.isVisible = false;
gameover.isActive = false;

--Playagain Button
local playagain = display.newImage("UI/playagain.png", display.contentWidth/4, display.contentHeight/1.3)
playagain.isVisible = false;
playagain.isActive = false;

--Quit Button
local quit = display.newImage("UI/quit.png", display.contentWidth/2, display.contentHeight/1.3)
quit.isVisible = false;
quit.isActive = false;

--Display Score in the Top Right
local score = 0
local scoreText = display.newText(score, 0, 0, native.systemFont, 35)
scoreText:setTextColor(255, 255, 255)
scoreText.x = 1230
scoreText.y = 45


local function playAgain()
	--Stop physics 
	physics.stop()
	
	--Reset and destroy previous game's variables
	player = nil
	
	gameover.isVisible = false;
	gameover.isActive = false;
	gameover = nil

	playagain.isVisible = false;
	playagain.isActive = false;
	playagain = nil
	
	quit.isVisible = false;
	quit.isActive = false;
	quit = nil
	
	curLevel = 1
	
	for i = 0, #projectiles do
		projectiles[i] = nil
	end
	
	for i = 0, #enemies do
		enemies[i] = nil
	end
	
	if laser1.isActive then
		physic.removeBody(laser1)
	end
	if laser1.isActive then
		physic.removeBody(laser2)
	end
	if laser1.isActive then
		physic.removeBody(laser3)
	end
	if laser1.isActive then
		physic.removeBody(laser4)
	end
	
	laser1.isActive = false;
	laser2.isActive = false;
	laser3.isActive = false;
	laser4.isActive = false;
	
	laser1.isVisible = false;
	laser2.isVisible = false;
	laser3.isVisible = false;
	laser4.isVisible = false;

	restart()
	return true
end

local function Quit()
	os.exit()
end

local function onCollision(self, event)
	if self.name == "bullet" and event.other.name == "enemy" then
		if event.other.name ~= nil then
			table.insert(objectsToDie, event.other) --kill the enemy
		end
		if self ~= nil then
			table.insert(objectsToDie, self) --kill the bullet
		end
		
		score = score + event.other.value
        scoreText.text = score
	elseif ((self.name == "player" and event.other.name == "enemy") or  (self.name == "player" and event.other.name == "laser" and event.other.isActive == true)) then
		table.insert(objectsToDie, player) --kill the player
		dead = true
		
		gameover.isVisible = true;
		gameover.isActive = true;
		quit.isVisible = true;
		quit.isActive = true;
		playagain.isVisible = true;
		playagain.isActive = true;
		
		for i = 1, #projectiles do
			table.insert(objectsToDie, projectiles[i].other) 
		end
		for i = 0, #enemies do
			table.insert(objectsToDie, enemies[i])
		end
	elseif self.name == "bullet" and event.other.name == "boss" then
		if self ~= nil then
			table.insert(objectsToDie, self) --kill the bullet
		end
		
		if(bossCanDie) then
			--Add to score and update text
			score = score + 5
			scoreText.text = score
			
			--Hurt Boss
			bossHealth = bossHealth - 2
		end
		
		if bossHealth <= 0 then
			if curLevel == 5 then --end of the game after last level and boss dies
				display.newImage("UI/win.png", display.contentWidth/2, display.contentHeight/2)
				timer.performWithDelay(3000, Quit)
			end
			
			if timerBossAttack ~= nil then
				timer.cancel(timerBossAttack)
			end
			if timerBlink ~= nil then
				timer.cancel(timerBlink)
			end
			if timerChangeEye ~= nil then
				timer.cancel(timerChangeEye)
			end
			
			laser1.isActive = false;
			laser2.isActive = false;
			laser3.isActive = false;
			laser4.isActive = false;

			laser1.isVisible = false;
			laser2.isVisible = false;
			laser3.isVisible = false;
			laser4.isVisible = false;
			
			curLevel = curLevel + 1
			changeLevel()
		end
	end	
end

local function fire()
	local p = display.newImage("Other/shot.png", player.x + 50, player.y)
	physics.addBody(p)
	p.name = "bullet"
	p.collision = onCollision
    p:addEventListener("collision", p)
	projectiles:insert(p)
	
	transition.to(p, { time = 1000, x = p.x+2000, y = p.y,
    onComplete = function(p)
		if (p.parent ~= nil) then --if it is not already dead, kill it
			p.parent:remove(p) 
			p = nil
		end
    end
})
end

local function locationGiver()
	local r = math.random(5)  -- 1 through 3
	local x
	local y
	local ox
	local oy
	if r == 1 then
		x = 1300
		y = math.random(200, 520)
		ox = -20
		oy = 720 - y
	elseif r == 2 then
		x = math.random(1000, 1280)
		y = -20
		ox = 1280 - x
		oy = 750
	elseif r == 3 then
		x = math.random(1000, 1280)
		y= 750
		ox = 1280 - x
		oy = -20
	elseif r == 4 then
		x = math.random(300, 800)
		y = -20
		ox = -x
		oy = 750
	elseif r == 5 then
		x = math.random(300, 800)
		y= 750
		ox = -x
		oy = -20
	end
	return x, y, ox, oy
end

local function spawnEnemiesV1()
	local x, y, ox, oy = locationGiver()
	local enemy = display.newImage("Enemies/enemy1.png", x, y)
	enemy.name = "enemy"
	enemy.value = 1
	physics.addBody(enemy, "kinematic", {bounce = 0})
	enemy.collision = onCollision
	enemy:addEventListener("collision", enemy)
	enemies:insert(enemy)
	
	transition.to(enemy, { time = 8000, x = ox, y = oy,
    onComplete = function(enemy)
		if (enemy.parent ~= nil) then --if it is not already dead, kill it
			enemy.parent:remove(enemy) 
			enemy = nil
		end
    end
	})
end

local function spawnEnemiesV2()
	local x, y, ox, oy = locationGiver()
	local enemy = display.newImage("Enemies/enemy2.png", x, y)
	enemy.name = "enemy"
	enemy.value = 2
	physics.addBody(enemy, "kinematic", {bounce = 0})
	enemy.collision = onCollision
	enemy:addEventListener("collision", enemy)
	enemies:insert(enemy)
	
	transition.to(enemy, { time = 2000, x = ox, y = oy,
    onComplete = function(enemy)
		if (enemy.parent ~= nil) then --if it is not already dead, kill it
			enemy.parent:remove(enemy) 
			enemy = nil
		end
    end
	})
end

local function spawnEnemiesV3()
	local x, y, ox, oy = locationGiver()
	local enemy = display.newImage("Enemies/enemy3.png", x, y)
	enemy.name = "enemy"
	enemy.value = 10
	physics.addBody(enemy, "kinematic", {bounce = 0})
	enemy.collision = onCollision
	enemy:addEventListener("collision", enemy)
	enemies:insert(enemy)
	
	transition.to(enemy, { time = 4000, x = ox, y = oy,
    onComplete = function(enemy)
		if (enemy.parent ~= nil) then --if it is not already dead, kill it
			enemy.parent:remove(enemy) 
			enemy = nil
		end
    end
	})
end

local function blinkEye()
	if(eyeNum ~= 1) then
		bossEyelid1.isVisible = not bossEyelid1.isVisible;
		bossEyelid1.isActive = not bossEyelid1.isActive;
	end
	if (eyeNum ~= 2) then
		bossEyelid2.isVisible = not bossEyelid2.isVisible;
		bossEyelid2.isActive = not bossEyelid2.isActive;
	end
	if (eyeNum ~= 3) then
		bossEyelid3.isVisible = not bossEyelid3.isVisible;
		bossEyelid3.isActive = not bossEyelid3.isActive;
	end
	if (eyeNum ~= 4) then
		bossEyelid4.isVisible = not bossEyelid4.isVisible;
		bossEyelid4.isActive = not bossEyelid4.isActive;
	end
	count = count + 1
	if count >= 4 then
		count = 0
		if(timerBlink ~= nil) then
			timer.cancel(timerBlink)
		end
	end
end

local function activateLasers()
	if(eyeNum ~= 1) then
		laser1.isVisible = not laser1.isVisible;
		laser1.isActive = not laser1.isActive;
		if laser1.isActive then
			physics.addBody(laser1, "kinematic")
		else
			physics.removeBody(laser1)
		end
	end
	if (eyeNum ~= 2) then
		laser2.isVisible = not laser2.isVisible;
		laser2.isActive = not laser2.isActive;
	if laser2.isActive then
		physics.addBody(laser2, "kinematic")
	else
		physics.removeBody(laser2)
	end
		end
	if (eyeNum ~= 3) then
		laser3.isVisible = not laser3.isVisible;
		laser3.isActive = not laser3.isActive;
	if laser3.isActive then
		physics.addBody(laser3, "kinematic")
	else
		physics.removeBody(laser3)
	end
		end
	if (eyeNum ~= 4) then
		laser4.isVisible = not laser4.isVisible;
		laser4.isActive = not laser4.isActive;
		if laser4.isActive then
			physics.addBody(laser4, "kinematic")
		else
			physics.removeBody(laser4)
		end
	end
end

local function changeEye()
	eyeNum = math.random(4) --between 1 through 4
end


local function bossAttack()
	--Blink 4 times
	timerBlink = timer.performWithDelay((bossAttackSpeed*1000)/15, blinkEye,0)
	
	--shoot lasers--
	--turn on lasers
	timer.performWithDelay((bossAttackSpeed*1000)/2, activateLasers)
	--turn off lasers
	timer.performWithDelay(((bossAttackSpeed*1000)/2) + 500, activateLasers)
	--Change eye 1 millisecond after turning off the lasers
	timer.performWithDelay(((bossAttackSpeed*1000)/2) + 501, changeEye)

	-- change attack speed based on boss hp
	if(bossHealth<75 and bossHealth >50) then
		if(bossAngered == false) then
			timer.cancel(timer6)
			bossAttackSpeed = 5;
			timer6 = timer.performWithDelay(4000, bossAttack, 0)
			bossAngered = true
		end
	elseif(bossHealth<50 and bossHealth >25) then
		if(bossAngered == false) then
			timer.cancel(timer6)
			bossAttackSpeed = 4;
			timer6 = timer.performWithDelay(3000, bossAttack, 0)
			bossAngered = true
		end
	elseif(bossHealth<25 and bossHealth >0) then
		if(bossAngered == false) then
			timer.cancel(timer6)
			bossAttackSpeed = 2;
			timer6 = timer.performWithDelay(2000, bossAttack, 0)
			bossAngered = true
		end
	end
end

local function moveUp()
	if holdingUp then
		if (dead == false) then
			if player.y > 30 then
				player.y  = player.y - movementSpeed;
			end
		end
	end
end

local function moveDown()
	if holdingDown then
		if (dead == false) then
			if player.y < 690 then
				player.y  = player.y + movementSpeed;
			end
		end
	end
end

local function moveLeft()
	if holdingLeft then
		if (dead == false) then
			if player.x > 50 then
				player.x  = player.x - movementSpeed;
			end
		end
	end
end

local function moveRight()
	if holdingRight then
		if (dead == false) then
			if player.x < 1230 then
				player.x  = player.x + movementSpeed;
			end
		end
	end
end
	
local function touchUp(event)
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        Runtime:addEventListener( "enterFrame", moveUp)
        holdingUp = true
    elseif event.target.isFocus then
		if event.phase == "ended" then
            holdingUp = false
            Runtime:removeEventListener( "enterFrame", moveUp )
            display.getCurrentStage():setFocus( nil )
            event.target.isFocus = false
        end
    end
    return true
end

local function touchDown(event)
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        Runtime:addEventListener( "enterFrame", moveDown)
        holdingDown = true
    elseif event.target.isFocus then
		if event.phase == "ended" then
            holdingDown = false
            Runtime:removeEventListener( "enterFrame", moveDown )
            display.getCurrentStage():setFocus( nil )
            event.target.isFocus = false
        end
    end
    return true
end

local function touchLeft(event)
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        Runtime:addEventListener( "enterFrame", moveLeft)
        holdingLeft = true
    elseif event.target.isFocus then
		if event.phase == "ended" then
            holdingLeft = false
            Runtime:removeEventListener( "enterFrame", moveLeft )
            display.getCurrentStage():setFocus( nil )
            event.target.isFocus = false
        end
    end
    return true
end

local function touchRight(event)
    if event.phase == "began" then
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        Runtime:addEventListener( "enterFrame", moveRight)
        holdingRight = true
    elseif event.target.isFocus then
		if event.phase == "ended" then
            holdingRight = false
            Runtime:removeEventListener( "enterFrame", moveRight )
            display.getCurrentStage():setFocus( nil )
            event.target.isFocus = false
        end
    end
    return true
end

local function makeBossKillable()
	bossCanDie = true
end

 function changeLevel()
		if(timer2 ~= nil) then
			timer.cancel(timer2)
		end
		if(timer3 ~= nil) then
			timer.cancel(timer3)
		end
		if(timer4 ~= nil) then
			timer.cancel(timer4)
		end
		
		if(curLevel < 4) then
			if(curLevel >= 1) then
				timer2 = timer.performWithDelay(500, spawnEnemiesV1, 0)
			end
			if(curLevel >= 2) then
				timer3 = timer.performWithDelay(500, spawnEnemiesV2, 0)
			end
			if(curLevel >= 3) then
				timer4 = timer.performWithDelay(250, spawnEnemiesV3, 0)
			end
		elseif(curLevel == 4) then  --Spawn boss at level 4
			boss.isVisible = true;
			boss.isActive = true;
			boss.name = "boss"
			boss.collision = OnCollision
			boss:addEventListener("collision", boss)
			bossAttackSpeed = 6;
			timer6 = timer.performWithDelay(5000, bossAttack, 0)
			timer.performWithDelay(4999, makeBossKillable)
			curTime = -900
		elseif(curLevel == 5) then --Heal boss and spawn version 1 enemies at level 5 (Final Level)
			curTime = 0
			bossHealth = 100
			timer2 = timer.performWithDelay(500, spawnEnemiesV1, 0)
		end
end

local function addToTimer()
	curTime = curTime +1;
	if (curTime % 30 == 0 and curTime <= 90 and curTime>0) then
		if not(curLevel >= 4) then
			curLevel = curLevel + 1
			changeLevel()
		end
	end
end

local function removeLoop()
	if (#objectsToDie > 0) then
		for i = 1, #objectsToDie do
			if (objectsToDie[i] ~= nil and objectsToDie[i].parent ~= nil and objectsToDie[i] ~= nil) then
				if objectsToDie[i].name == "player" then
						if(timer1 ~= nil) then
							timer.cancel(timer1)
						end
						if(timer2 ~= nil) then
							timer.cancel(timer2)
						end
						if(timer3 ~= nil) then
							timer.cancel(timer3)
						end
						if(timer4 ~= nil) then
							timer.cancel(timer4)
						end
						if(timer5 ~= nil) then
							timer.cancel(timer5)
						end
						if(timer6 ~= nil) then
							timer.cancel(timer6)
						end
						up:removeEventListener( "touch", touchUp)
						display.getCurrentStage():setFocus( nil )
						up.isFocus = false
						down:removeEventListener( "touch", touchDown)
						display.getCurrentStage():setFocus( nil )
						down.isFocus = false
						left:removeEventListener( "touch", touchLeft)
						display.getCurrentStage():setFocus( nil )
						left.isFocus = false
						right:removeEventListener( "touch", touchRight)
						display.getCurrentStage():setFocus( nil )
						right.isFocus = false
						Runtime:removeEventListener("enterFrame", removeLoop)
					end
				objectsToDie[i].parent:remove(objectsToDie[i])
				objectsToDie[i] = nil
			end
        end
	end
end

changeLevel() --Start level one

--Realtime timers
timer1 = timer.performWithDelay(1000/rateOfFire, fire, 0) --Shoot everysecond/shots per a second
timer5 = timer.performWithDelay(1000, addToTimer, 0) --Add to our curTime every second

--------------Listeners and Collision--------------

--Player collision
player.collision = onCollision
player:addEventListener("collision", player)

--Gameover Button listeners
playagain:addEventListener("tap", playAgain)
quit:addEventListener("tap", Quit)

--Laser collision
laser1.collision = onCollision
laser2.collision = onCollision
laser3.collision = onCollision
laser4.collision = onCollision
laser1:addEventListener("collision", laser1)
laser2:addEventListener("collision", laser2)
laser3:addEventListener("collision", laser3)
laser4:addEventListener("collision", laser4)

--Directional-Pad Listeners
up:addEventListener("touch", touchUp)
down:addEventListener("touch", touchDown)
left:addEventListener("touch", touchLeft)
right:addEventListener("touch", touchRight)
Runtime:addEventListener("enterFrame", removeLoop)
end

main() --Run main

function restart()
  main()
end