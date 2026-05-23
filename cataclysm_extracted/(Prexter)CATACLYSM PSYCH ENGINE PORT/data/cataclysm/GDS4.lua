offsetI = {'0', '0'}-- idle
offsetL = {'38', '2'}-- left	
offsetD = {'9', '-32'}-- down
offsetU = {'0', '20'}-- up
offsetR = {'-30', '9'}-- right
offsetA = {'6', '30'}
local idle = 'ANGELFIELD IDLE'
local left = 'ANGELFIELD RIGHT'
local down = 'ANGELFIELD DOWN'
local up = 'ANGELFIELD UP'
local right = 'ANGELFIELD LEFT'
local anim = 'ANGELFIELD APARITION'
local Character_tag = 'AGS4'
local Character_Image_Name = 'characters/ANGELFIELD'
local FrameI = 24--for Idle
local FrameL = 24--for Left
local FrameD = 24--for Dow
local FrameU = 24--for Up
local FrameR = 24--for Righ
local FrameA = 12--for anim
local valiste = true
local loopI = false--or true
local above = true--or true
local flip = false-- do you want to flipX the character or not
local xS = 1--this is for the X
local yS = 1--this is for the Y
local note = 'No Animation'--this is for the character to play there animations
function onCreate()
makeAnimatedLuaSprite(Character_tag, Character_Image_Name, 70, 410);
local fuck_this = true
	addAnimationByPrefix(Character_tag, 'IDLE', idle, FrameI, loopI);
	addAnimationByPrefix(Character_tag, 'LEFT', left, FrameL, false);
	addAnimationByPrefix(Character_tag, 'DOWN', down, FrameD, false);
	addAnimationByPrefix(Character_tag, 'UP', up, FrameU, false);
	addAnimationByPrefix(Character_tag, 'RIGHT', right, FrameR, false);
	addAnimationByPrefix(Character_tag, 'appear', anim, FrameA, false);
setProperty(Character_tag.. '.flipX', flip)
objectPlayAnimation (Character_tag, 'IDLE', false)
	scaleObject(Character_tag, xS, yS);
	addLuaSprite(Character_tag, above);
	end
local singing = {"LEFT", "DOWN", "UP", "RIGHT"}
function opponentNoteHit(id, direction, noteType, isSustainNote)
if noteType == note then
runTimer('idle back', 0.5)
fuck_this = false
objectPlayAnimation(Character_tag, singing[direction + 1], false);
if isSustainNote then
objectPlayAnimation(Character_tag, singing[direction + 1], true);
end
if direction == 0 then
	setProperty(Character_tag.. '.offset.x', offsetL[1]);
	setProperty(Character_tag.. '.offset.y', offsetL[2]);
elseif direction == 1 then
	setProperty(Character_tag.. '.offset.x', offsetD[1]);
	setProperty(Character_tag.. '.offset.y', offsetD[2]);
elseif direction == 2 then
	setProperty(Character_tag.. '.offset.x', offsetU[1]);
	setProperty(Character_tag.. '.offset.y', offsetU[2]);
elseif direction == 3 then
	setProperty(Character_tag.. '.offset.x', offsetR[1]);
	setProperty(Character_tag.. '.offset.y', offsetR[2]);
		end
end
end
function goodNoteHit(id, direction, noteType, isSustainNote)
if noteType == note then
runTimer('idle back', 0.5)
fuck_this = false
objectPlayAnimation(Character_tag, singing[direction + 1], false);
if isSustainNote then
objectPlayAnimation(Character_tag, singing[direction + 1], true);
end
if direction == 0 then
	setProperty(Character_tag.. '.offset.x', offsetL[1]);
	setProperty(Character_tag.. '.offset.y', offsetL[2]);
elseif direction == 1 then
	setProperty(Character_tag.. '.offset.x', offsetD[1]);
	setProperty(Character_tag.. '.offset.y', offsetD[2]);
elseif direction == 2 then
	setProperty(Character_tag.. '.offset.x', offsetU[1]);
	setProperty(Character_tag.. '.offset.y', offsetU[2]);
elseif direction == 3 then
	setProperty(Character_tag.. '.offset.x', offsetR[1]);
	setProperty(Character_tag.. '.offset.y', offsetR[2]);
		end
end
end
-- this is for the character to do there animation on Countdown with the actual characters
function onCountdownTick(counter)
if loopI == false then
	if counter %2 == 0 and fuck_this == true then
			objectPlayAnimation(Character_tag, 'IDLE');
			setProperty(Character_tag.. '.offset.x', offsetI[1]);
			setProperty(Character_tag.. '.offset.y', offsetI[2]);
		end
end
end
-- this is for the character to do there animation on beat
function onBeatHit()
if loopI == false then
	if curBeat % 2 == 0 and fuck_this == true then
		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
	end
fuck_this = true
end
end
function onTimerCompleted(tag)
if tag == 'play' then
loopI = false
		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
end
if tag == 'idle back' then

		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
end
end
function onUpdate()
    if getProperty(Character_tag .. '.animation.curAnim.finished') and getProperty(Character_tag .. '.animation.curAnim.name') == 'appear' then
        objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
 fuck_this = true
     end    
end
function onStepHit()
    if curStep == 4880 then
 fuck_this = false
objectPlayAnimation(Character_tag, 'appear');
setProperty(Character_tag.. '.alpha', 1);
setProperty(Character_tag.. '.offset.x', offsetA[1]);
		setProperty(Character_tag.. '.offset.y', offsetA[2]);
  end
  end