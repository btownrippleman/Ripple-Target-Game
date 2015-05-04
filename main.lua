-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------


--initiliaztion of variables

WIDTH = display.contentWidth
HEIGHT = display.contentHeight
local bg = display.newRect( 0, 0, WIDTH*2, HEIGHT*2)
bg:setFillColor(0)
local target = display.newGroup()
local ear = display.newImageRect("ear.png",45,45)
local weapon = display.newImageRect( "guitar.png", 100, 50 )
local bullet
local firingDirection
local explosion
local bulletFired = false
local hits=0
local misses=0
local random = math.random()
local scoreText = display.newText("hits: " .. hits .. " misses: " .. misses .. " %hits :0", 180,100,"",18)


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
local function initApp()

    target.speed =4

    target.x = 0 --display.contentCenterX
    target.y =  45
    target:insert(ear)
    targetSurround  = rectArrayMaker(10,45,target.x,target.y,.6)

    target:insert(targetSurround)
    targetSurround.x = 0 - target.x
    targetSurround.y = 0 - target.y
    --target.x = target.x +10
    target.xScale = .6
    target.yScale = .6
    target.radius = 45*.6


    weapon.rotation = -90
    weapon.x = display.contentCenterX
    weapon.y = HEIGHT-45



end
local function myTouchListener(event)




   weapon.rotation = objectRotation(event, weapon)
   firingDirection = unitVector(event,weapon)
   if event.phase == "ended" and (bullet == nil or bulletFired == false or bullet.y <0 or bullet.x <0 or bullet.x > 320  )
   then bulletFire(event,weapon,25) end


end

function objectRotation(v1,v2)
    --dotProduct of v1 and (0,1) over ||v1||  return in degrees
  if v1.x > v2.x then
    return  90- (360/(2*3.14159))*math.acos((v1.y-v2.y)/(math.sqrt((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y))))
  else
    return 90+ (360/(2*3.14159))*math.acos((v1.y-v2.y)/(math.sqrt((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y))))
  end
end

function unitVector(event,weapon)
  local v = {}
  local u = {}
      v[1] = event.x - weapon.x
      v[2] = event.y - weapon.y
  local length =  math.sqrt(math.pow(v[1],2)+math.pow(v[2],2))
  u[1] = v[1]/length; u[2] = v[2]/length;
  return  u

end

local function vectorLength(event,weapon)

  return  math.sqrt(math.pow(event.x-weapon.x,2)+math.pow(event.y-weapon.y,2))

end


function bulletFire(event,weapon,speed)
    local u = unitVector(event,weapon); local length = vectorLength(event,weapon)
    bullet = display.newImageRect("note.png", 44, 44) --1.2*length*u[1], 1.2*length*u[2])
    bullet.x = weapon.x + 100*u[1]; bullet.y = weapon.y + 100*u[2] -- obullets will spawn at about 100 units from weapons base
    bullet.rotation = objectRotation(event,weapon)+90
    bullet.speed = speed
    scoreText.text = "hits: " .. hits .. " misses: " .. misses .. " %hits :0" 
    bulletFired = true

end

local function rollingMovement(target, speed, pathTravelled, targetRadius) -- used only for circular objects, default speed equals one
        --this fcn is dependent on the screen variable WIDTH
  if speed == nil then speed = 1 end


  target.rotation = target.rotation + speed*(pathTravelled/(2*math.pi*targetRadius))
  target.x = target.x +speed

end

local function restart(target)

    if target.x > display.contentWidth then target.x = 0 end

end

function placeBackBullet()

  bullet.x = -100; bullet.y = -100

end

function placeBackTarget()

  target.x = -20

end

function explosionMake()
  explosion = nil
    local x,y = target.x, target.y
  local rand = math.ceil(math.random(7))
   explosion = display.newImageRect("boom"..rand..".png",22,22,target.x,target.y);
  if explosion ~= nil then explosion.x =target.x; explosion.y = target.y end

   random = math.random()


end

function withinRange(range)


        -- if ( math.abs(object1.x-object2.x) < range and math.abs(object1.y-object2.y)< range )
         if ( math.abs(bullet.x-target.x) < range and math.abs(bullet.y-target.y)< range )

                then return true end


 end

local function newFrame() --this function corresponds to the eventListener for Runtime:addEventListener()

      rollingMovement(target, target.speed, WIDTH, target.radius)

      if target.x > WIDTH then target.x = 0; target.speed = 2+ math.random(5) end
      if bulletFired == true then
        bullet.x = bullet.x + firingDirection[1]*bullet.speed
        bullet.y = bullet.y + firingDirection[2]*bullet.speed
      end

      if bullet~=nil and bulletFired == true and (bullet.y <0 or bullet.x <0 or bullet.x > 320)
      then placeBackBullet(); misses = misses +1 end

      if bullet~=nil and bulletFired == true and withinRange(55)
      then explosionMake();    placeBackTarget(); placeBackBullet() hits = hits+1;  target.speed = 25*math.random()*math.random() end

      if explosion ~= nil and explosion.alpha > 0 then
        explosion.alpha = explosion.alpha *explosion.alpha *explosion.alpha *explosion.alpha * .995
        explosion.yScale = explosion.yScale*explosion.yScale*explosion.yScale*explosion.yScale*1.01
        explosion.xScale = explosion.xScale*explosion.xScale*explosion.xScale*explosion.xScale*1.01
      end



end



initApp()
 bg:addEventListener( "touch", myTouchListener )
Runtime:addEventListener("enterFrame", newFrame )
