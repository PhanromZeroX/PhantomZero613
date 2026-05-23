function onCreatePost()
callMethod("comboGroup.setPosition", {1150,750})
setProperty('timeBar.visible',true)
setProperty('timeBar.bg.visible',false)
setProperty('timeTxt.visible',true)
setTextFont('timeTxt','MilkyNice.ttf')
setProperty('timeBar.y',downscroll and 0 or 700)
setTextSize('timeTxt',20)
setProperty('timeTxt.y',downscroll and 20 or 670)
scaleObject('timeBar',3,1,false)
setTextBorder('timeTxt')

makeLuaText('s','Unknown Suffering',0,50,downscroll and 15 or 680)
setTextFont('s','MilkyNice.ttf')
setTextSize(s,18)
setTextBorder('s')
addLuaText('s')

for i,t in pairs{'Sick','Good','Bad','Shit'} do
makeLuaText(t..'Txt',t..': 0',0,screenWidth-120,(downscroll and 40 or 540)+i*25)
setTextSize(t..'Txt',18)
setTextFont(t..'Txt','MilkyNice.ttf')
setTextBorder(t..'Txt')
addLuaText(t..'Txt')
end
end

function onSongStart()
setVar('xdsiw',getProperty('songLength'))
setProperty('songLength',158000)
end

function onUpdatePost()
setTextString('timeTxt',formatTime(getSongPosition() - noteOffset) ..' - '..formatTime(getProperty("songLength")))
end

function formatTime(ms)
s = math.floor(ms/1000);
return string.format('%01d:%02d', (s/60)%60, s%60)
end

local s,g,b,sh=0,0,0,0

function goodNoteHit(i)
local r=getProperty('notes.members['..i..'].rating')
if r=='sick'then
s=s+1
setTextString('SickTxt','Sick: '..s)
elseif r=='good'then
g=g+1
setTextString('GoodTxt','Good: '..g)
elseif r=='bad'then
b=b+1
setTextString('BadTxt','Bad: '..b)
elseif r=='shit'then
sh=sh+1
setTextString('ShitTxt','Shit: '..sh)
end
end