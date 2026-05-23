--Mario's Madness V2 Show Song Script
--THIS SCRIPT NOW WORKS ON PSYCH 0.7.X!
local canRunStepHit = true;
function onCreate()
	makeLuaText('titleText', 'Eight Feet Tall', 1000, 132, 301)
	setTextSize('titleText', 50)
	setTextColor('titleText', 'FFFFFF')
	setTextBorder('titleText', 2, '000000')
	setObjectCamera('titleText', 'other')
	setTextFont('titleText', 'vcr.ttf')
	addLuaText('titleText')
	doTweenAlpha('showTitleText', 'titleText', 0, 0.1 / playbackRate, "linear")

	makeLuaSprite('TheLine', 'LINE', 344, 368)
	makeGraphic('TheLine', 575, 3, 'FFFFFF')
	setObjectCamera('TheLine', 'other')
	setProperty('TheLine.alpha', 1)
	addLuaSprite('TheLine', true)
	doTweenAlpha('showBorder', 'TheLine', 0, 0.1 / playbackRate, "linear")


	makeLuaText('authorText', 'By CYANCAT', 1000, 132, 374)
	setTextSize('authorText', 35)
	setTextColor('authorText', 'FFFFFF')
	setTextBorder('authorText', 2, '000000')
	setTextFont('authorText', 'vcr.ttf')
	setObjectCamera('authorText', 'other')
	addLuaText('authorText')
	doTweenAlpha('showAuthorText', 'authorText', 0, 0.1 / playbackRate, "linear")

	makeLuaText('liruText', 'Cover by LiruSapphire', 1000, 132, 416)
	setTextSize('liruText', 35)
	setTextColor('liruText', 'FFFFFF')
	setTextBorder('liruText', 2, '000000')
	setTextFont('liruText', 'vcr.ttf')
	setObjectCamera('liruText', 'other')
	addLuaText('liruText')
	doTweenAlpha('showliruText', 'liruText', 0, 0.1 / playbackRate, "linear")
end

function onStepHit()
	if canRunStepHit then
		-- 曲名スクリプト
		--shows the song title/author
		if curStep == 16 then
			doTweenY('transition', 'titleText', 307, 0.3 / playbackRate, "cubeOut")
			doTweenY('transition2', 'TheLine', 370, 0.3 / playbackRate, "cubeOut")
			doTweenY('transition3', 'authorText', 378, 0.3 / playbackRate, "cubeOut")
			doTweenY('transition4', 'liruText', 420, 0.3 / playbackRate, "cubeOut")
			doTweenAlpha('showTitleText', 'titleText', 1, 0.3 / playbackRate, "linear")
			doTweenAlpha('showAuthorText', 'authorText', 1, 0.3 / playbackRate, "linear")
			doTweenAlpha('showBorder', 'TheLine', 1, 0.3 / playbackRate, "linear")
			doTweenAlpha('showliruText', 'liruText', 1, 0.3 / playbackRate, "linear")
		elseif curStep == 64 then --hides the song title/author
			doTweenAlpha('showTitleText', 'titleText', 0, 0.2 / playbackRate, "linear")
			doTweenAlpha('showAuthorText', 'authorText', 0, 0.2 / playbackRate, "linear")
			doTweenAlpha('showBorder', 'TheLine', 0, 0.2 / playbackRate, "linear")
			doTweenAlpha('showliruText', 'liruText', 0, 0.2 / playbackRate, "linear")

			canRunStepHit = false;
		end
	end
end

function onEndSong()
	canRunStepHit = false;
	-- カットシーンの開始処理
end
