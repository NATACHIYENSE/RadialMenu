--driver code

local sui = script.Parent
local RadialButton = require(sui:WaitForChild('RadialButton'))
local RadialMenu = require(sui:WaitForChild('RadialMenu'))

local func = function()print('clicked')end

local menu1: RadialMenu.RadialMenu = RadialMenu.new{
	name = 'test',
	buttons = {
		RadialButton.new{
			label = 'hi',
			pressed = func,
			description = [[HELLO!!!!]],
		},
		RadialButton.new{
			label = 'hi again',
			pressed = func,
			description = [[yes how have you beannnnn]],
		},
		RadialButton.new{
			label = 'get real',
			pressed = func,
			description = [[he is so ong for this 😭😭]],
		},
	},
}

local menu2: RadialMenu.RadialMenu = RadialMenu.new{
	name = 'test again',
	buttons = {
		RadialButton.new{
			label = 'your mom',
			pressed = func,
			description = [[fr bro]],
		},
		RadialButton.new{
			label = 'obtain realism',
			pressed = func,
			description = [[my reaction to that information]],
		},
		RadialButton.new{
			label = 'at the function',
			pressed = func,
			description = [[me when the him when uhh me him the when you their they them umm him her]],
		},
		RadialButton.new{
			label = 'insane',
			pressed = func,
			description = [[that's crazy bro]],
		},
		RadialButton.new{
			label = '😭😭😭😭😭',
			pressed = func,
			description = [[The Industrial Revolution and its consequences have been a disaster for the human race. They have greatly increased the life-expectancy of those of us who live in “advanced” countries, but they have destabilized society, have made life unfulfilling, have subjected human beings to indignities, have led to widespread psychological suffering (in the Third World to physical suffering as well) and have inflicted severe damage on the natural world. The continued development of technology will worsen the situation. It will certainly subject human beings to greater indignities and inflict greater damage on the natural world, it will probably lead to greater social disruption and psychological suffering, and it may lead to increased physical suffering even in “advanced” countries.]],
		},
	},
}

local menu3: RadialMenu.RadialMenu = RadialMenu.new{
	name = 'test again',
	buttons = {
		RadialButton.new{
			label = 'your mom',
			pressed = func,
			description = [[fr bro]],
		},
		RadialButton.new{
			label = 'obtain realism',
			pressed = func,
			description = [[my reaction to that information]],
		},
		RadialButton.new{
			label = 'at the function',
			pressed = func,
			description = [[me when the him when uhh me him the when you their they them umm him her]],
		},
		RadialButton.new{
			label = 'insane',
			pressed = func,
			description = [[that's crazy bro]],
		},
		RadialButton.new{
			label = '😭😭😭😭😭',
			pressed = func,
			description = [[The Industrial Revolution and its consequences have been a disaster for the human race. They have greatly increased the life-expectancy of those of us who live in “advanced” countries, but they have destabilized society, have made life unfulfilling, have subjected human beings to indignities, have led to widespread psychological suffering (in the Third World to physical suffering as well) and have inflicted severe damage on the natural world. The continued development of technology will worsen the situation. It will certainly subject human beings to greater indignities and inflict greater damage on the natural world, it will probably lead to greater social disruption and psychological suffering, and it may lead to increased physical suffering even in “advanced” countries.]],
		},
		RadialButton.new{
			label = 'your mom',
			pressed = func,
			description = [[fr bro]],
		},
	},
}

local uis = game:GetService('UserInputService')
uis.InputBegan:Connect(function(k, gp)
	if gp then return end
	if k.KeyCode == Enum.KeyCode.X then
		RadialMenu.setMenu(menu1)
	elseif k.KeyCode == Enum.KeyCode.C then
		RadialMenu.setMenu(menu2)
	elseif k.KeyCode == Enum.KeyCode.V then
		RadialMenu.setMenu(menu3)
	end
end)

uis.InputEnded:Connect(function(k, gp)
	if gp then return end
	if k.KeyCode == Enum.KeyCode.X or k.KeyCode == Enum.KeyCode.C then
		RadialMenu.setMenu()
	end
end)