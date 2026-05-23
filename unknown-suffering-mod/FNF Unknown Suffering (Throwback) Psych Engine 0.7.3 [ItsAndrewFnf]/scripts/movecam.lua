local p1,p2,k=false,false,{songName=='grenade' and 35 or 25,songName=='grenade' and 35 or 25}
local m={{-k[1], 0},{0,k[2]},{0,-k[2]},{k[1],0}}
setVar('camMove',true)

function goodNoteHit(_,d)
if p1 and getVar('camMove') then
resetCam(d)
end
end

function opponentNoteHit(_,d)
if p2 and getVar('camMove') then
resetCam(d) 
end
end

function resetCam(d)
callMethod('moveCamera',{p1 and false or p2 and true})
callMethod('camFollow.setPosition',{getProperty('camFollow.x')+m[d+1][1],getProperty('camFollow.y')+m[d+1][2]})
end

function onMoveCamera(f)
if f=='dad' then
p1=false
p2=true
else
p1=true
p2=false
end
end