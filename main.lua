-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
WIDTH = display.contentWidth
HEIGHT = display.contentHeight

local function rectArrayMaker(numOfCopies,distance,centerX,centerY,spacePercentage)
  rectArray = {}
  local returnGroup = display.newGroup()

  for i = 1, numOfCopies, 1 do
      rectArray[i] = display.newRect(centerX,centerY,5,spacePercentage*2*math.pi*distance/numOfCopies)
      rectArray[i]:setFillColor( 1,0,0 )
      --rectArray[i].x = rectArray[i].x+ distance
      local x = distance*math.cos((i-1)*(math.pi*2/numOfCopies))
      local y = distance*math.sin((i-1)*(math.pi*2/numOfCopies))
      rectArray[i].x =  x + centerX
      rectArray[i].y =  y + centerY

   rectArray[i]:rotate((360/numOfCopies)*(i-1))--(360/numOfCopies)*i)
   returnGroup:insert(rectArray[i])

  end
  return returnGroup
end


local ear = display.newImageRect("ear.png",45,45)


local target = display.newGroup()
target.x = display.contentCenterX
target.y =  45

target:insert(ear)
targetSurround  = rectArrayMaker(10,45,target.x,target.y,.6)

target:insert(targetSurround)
targetSurround.x = 0 - target.x
targetSurround.y = 0 - target.y
--target.x = target.x +10

--local group = display.newGroup()
--group:insert( rect )

--targetSurround:setFillColor(red)



local weapon = display.newImageRect( "guitar.png", 100, 50 )
weapon.rotation = -90
weapon.x = display.contentCenterX
weapon.y = HEIGHT-45


local bullet = display.newImageRect("note.png",33,33)
bullet.x = display.contentCenterX
bullet.y = display.contentCenterY + 110


function newFrame()


        -- this is the case where the bird actually captures the target, and the target is sent back to the right
        withinRange(70,bird,targets) --then hits = hits+ 1;  end

        if (bird.y < -100) then bird.yVelocity = 4 end  -- if the ball goes to high it slows down automatically

        if (bird.y >= display.contentHeight) then bird.yVelocity = -5 end
        -- this causes the bird to bounce up if it hits the bottom



        stopAndGo(worm,2.50)
        sinuousPath(bat,3)
        cosinuousPath(nut,2)
	-- Move the bird by its current velocity, i.e. as yVelocity gradually increases on the next line of code
	bird.y = bird.y + bird.yVelocity
	-- Increase velocity a bit for gravity effect
	bird.yVelocity = bird.yVelocity + 0.3
        --rewrite the score
        missChecker(targets)
        gameEval()






end

function withinRange(range,object1,objects)

        for i = 1, #objects do

        if ( math.abs(object1.x-objects[i].x) < range and math.abs(object1.y-objects[i].y)< range )
                then  sendToTheBack(objects[i]); hits = hits+1; scoreValue = scoreValue + i*100 end -- end of if statement

        end -- end of for loop
end
