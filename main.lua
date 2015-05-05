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
local rect
local weapon = display.newImageRect( "guitar.png", 100, 50 )
--local bullet
local explosion
local targetHit
local shotFired = false
local hits=0
local misses=0
local scoreText = display.newText("hits:0 misses:0 %hits :0", 160,150,"",18)

local function rectArrayMaker(numOfCopies,distance,centerX,centerY,spacePercentage) --- this makes an array of rects centered around target
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

function targetMake() -- this is called every time a target is destroyed either by a bullet or going off screen
  shotFired = false
  local rect = display.newRect(0,0,45,45) -- I initially used this code for a rotating ear, but I used a rect instead
  rect:setFillColor(0,0,1) -- make the rect color blue
  target = display.newGroup()  -- ear = display.newImageRect("ear.png",45,45)
  target.x = 0 --display.contentCenterX
  target.y =  math.random(HEIGHT)
  target:insert(rect)
  local targetSurround  = rectArrayMaker(10,45,target.x,target.y,.6) -- this a subgroup of target
  target:insert(targetSurround)
  targetSurround.x = 0 - target.x
  targetSurround.y = 0 - target.y
  target.xScale = .6
  target.yScale = .6
  target.radius = 45*.6
  local transitionTime = 1000
  if hits~= 0 and misses~= 0 then transitionTime = 500 +math.random()*1000*(misses+hits)/hits
  else transitionTime = 1500 end
  transition.to(target, {time = transitionTime , rotation =360*(WIDTH/(2*math.pi*45)), alpha = 1, x = WIDTH,  onComplete =  destroyTarget })
 end

local function initApp() -- app initialization, a lot of the code repeated in targetMake()


    weapon.rotation = -90
    weapon.x = display.contentCenterX
    weapon.y = HEIGHT-45

    targetMake()


end
local  function myTouchListener(event) -- called at every tap, makes sure weapon, i.e. guitar is propery pointed and that
    weapon.rotation = objectRotation(event, weapon)
    if event.phase == "ended" and bullet == nil then
    bullet =  bulletFire(event,weapon) end

end

function objectRotation(v1,v2) --  function used in rotating the guitar
    --dotProduct of v1 and (0,1) over ||v1||  return in degrees
  if v1.x > v2.x then
    return  90- (360/(2*3.14159))*math.acos((v1.y-v2.y)/(math.sqrt((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y))))
  else
    return 90+ (360/(2*3.14159))*math.acos((v1.y-v2.y)/(math.sqrt((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y))))
  end
end


   --designed to get unit vetor values if necessary.
function unitVector(event,obj)   -- this just give me the direction of the vector from the tap to the weapon, i.e. guitar
  local v = {}
  local u = {}
      v[1] = event.x - obj.x
      v[2] = event.y - obj.y
  local length =  math.sqrt(math.pow(v[1],2)+math.pow(v[2],2))
  u[1] = v[1]/length; u[2] = v[2]/length;
  return  u
end

local function vectorLength(event,weapon)-- returns distance between vectors

  return  math.sqrt(math.pow(event.x-weapon.x,2)+math.pow(event.y-weapon.y,2))

end



function destroyExplosion() --  would have used a generic destroyObject(obj) construction for all these but the onComplete listener
  explosion:removeSelf(); explosion = nil -- in transition.to(explosion, {...}) didn't like it
end

function destroyTarget()
  if shotFired == false then misses = misses +1 end
  target:removeSelf(); target = nil;
end

function destroyBullet() -- same goes for what is said above, but I try to call the destroy function only appropriate times
  if targetHit == false then misses = misses +1 end
   if bullet~= nil then bullet:removeSelf(); bullet = nil;  end
end

function bulletFire(event,weapon) -- called by myTouchListener from the tappings on the background.
    shotFired = true;
    targetHit = false -- if this value does not change during the life the bullet, it will register as a miss.
    local u = unitVector(event,weapon); local length = vectorLength(event,weapon)
    local localbullet = display.newImageRect("note.png", 44, 44) --1.2*length*u[1], 1.2*length*u[2])
    localbullet.x = weapon.x + 100*u[1]; localbullet.y = weapon.y + 100*u[2] -- bullets will spawn at about 100 units from weapons base
    localbullet.rotation = objectRotation(event,weapon)+90
    transition.to(localbullet, {time = 150, alpha = 1,x = event.x,y = event.y,  onComplete = destroyBullet })

    return localbullet -- returns a value as req'd in the module
end

function explosionMake(x,y)  -- used easing.outExpo, increased the fastest, i.e. being an exponential function.
  local rand = math.ceil(math.random(7))
  local explosion = display.newImageRect("boom"..rand..".png",22,22);
  explosion.x = x;
  explosion.y = y;
  local explSize = 15
  if hits ~= 0 or misses ~= 0 then explSize = math.random() *30*hits/(hits+misses) end
  transition.to(explosion,{ time=1000, xScale=explSize, yScale = explSize, alpha = 0, transition=easing.outExpo })

end

local function scoreTextRenew() --  call this at every frame of newFrame to make sure the text is in the Front.
    if misses ~= 0 or hits ~= 0 then scoreText.text = "hits: " .. hits .. " misses: " .. misses .. " %hits :"..math.round(100*hits/(hits+misses)) end
      scoreText:toFront()
end





local function withinRange(range, obj1, obj2) -- used to find if objs are in range return a false or true


         if ( math.abs(obj1.x-obj2.x) < range and math.abs(obj1.y-obj2.y)< range )
            then return true
         else
            return false
         end
 end

local function newFrame() --this function corresponds to the eventListener for Runtime:addEventListener()

        scoreTextRenew(); -- call this to make sure that it's in front. I would normally put it somewhere else
                        -- but for not it's computationally negligible
       if target == nil then targetMake() end

       if bullet ~= nil and target ~= nil then
          if withinRange(55,bullet,target)
          then
            targetHit = true;
            hits = hits+1;
            explosionMake(target.x,target.y);
            transition.cancel(target,bullet,explosion);
            destroyBullet();
            destroyTarget();

           end
       end





end



initApp() -- intialize vars at very end except for listeners.
bg:addEventListener( "touch", myTouchListener )
Runtime:addEventListener("enterFrame", newFrame )
