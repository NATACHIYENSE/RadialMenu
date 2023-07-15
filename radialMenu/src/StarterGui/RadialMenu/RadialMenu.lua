local uis = game:GetService('UserInputService')
local tws = game:GetService('TweenService')
local rus = game:GetService('RunService')

local sui = script.Parent
local RadialButton = require(sui:WaitForChild('RadialButton'))
local container = sui:WaitForChild('Container')
local description = container:WaitForChild('Description')
local main = container:WaitForChild('Main')
local outline = container:WaitForChild('Outline')
local mainFrame = main:WaitForChild('Frame')
local outlineFrame = outline:WaitForChild('Frame')

local RadialButton = require(sui:WaitForChild('RadialButton'))

local topbarInset: Vector2 = Vector2.new(0, 36)
local buttonPrioritySortFunc = function(a: RadialButton.RadialButton, b: RadialButton.RadialButton): boolean
	return a.Priority > b.Priority
end

type class = {
	activeMenu: RadialMenu?,
	absoluteRadius: number, --constant value. do not change.
	mouseAngle: number,
	selectedButton: RadialButton.RadialButton?,
	pivotOrigin: Vector2,
	showTween: Tween,
	hideTween: Tween,
	clickSound: Sound,
	pressSound: Sound,
	scrollDebounce: number,
	lastScroll: number,
	
	new: (args: constructor) -> RadialMenu, --create a new menu object. needs to be manually toggled.	
	setMenu: (menu: RadialMenu?) -> boolean, --display a radial menu. set to nil to hide the current menu.
	updatePivotOrigin: () -> boolean,
	updateSelectedButton: () -> boolean,
}
type constructor = {
	name: string,
	buttons: {RadialButton.RadialButton},
}
export type RadialMenu = { --object attributes
	Name: string,
	Buttons: {RadialButton.RadialButton},
	ButtonsAmount: number,
	AngleIncrement: number,
	Active: boolean,
	ScrollIncrement: number,
	
	SetScrollIncrement: (self: RadialMenu, increment: number, skipAnim: boolean?) -> boolean, --change the angle offset of the menu.
	Show: (self: RadialMenu) -> boolean,
	Hide: (self: RadialMenu) -> boolean,
	GetClosestButton: (self: RadialMenu, angle: number) -> RadialButton.RadialButton,
}

local RadialMenu = { --class attributes & constants
	activeMenu = nil,
	absoluteRadius = outlineFrame:WaitForChild('UIStroke').Thickness*.5,
	mouseAngle = 0,
	selectedButton = nil,
	pivotOrigin = Vector2.zero,
	showTween = tws:Create(container, TweenInfo.new(.25), {GroupTransparency = 0, BackgroundTransparency = .5}),
	hideTween = tws:Create(container, TweenInfo.new(.25), {GroupTransparency = 1, BackgroundTransparency = 1}),
	clickSound = script:WaitForChild('Click'),
	pressSound = script:WaitForChild('Press'),
	scrollDebounce = .2,
	lastScroll = 0,
}
RadialMenu.__index = RadialMenu

--class functions
function RadialMenu.new(args: constructor): RadialMenu
	assert(type(args) == 'table', `table expected, got {typeof(args)}`)
	
	local amount: number = #args.buttons
	local increment: number = 360/amount
	
	table.sort(args.buttons, buttonPrioritySortFunc)
	
	local new = {
		Name = args.name,
		Buttons = args.buttons,
		ButtonsAmount = amount,
		AngleIncrement = increment,
		ScrollIncrement = 0,
		Active = false,
	}
	local new: RadialMenu = setmetatable(new, RadialMenu)::any
	new:SetScrollIncrement(0, true)
	
	return new
end

function RadialMenu.setMenu(menu: RadialMenu?): boolean
	local existing: RadialMenu? = RadialMenu.activeMenu
	if existing then
		existing:Hide()
	end
	if menu then
		menu:SetScrollIncrement(0, true)
		menu:Show()	
		--container.Visible = true
		container.Active = true
		RadialMenu.showTween:Play()
	else
		RadialMenu.hideTween:Play()
		container.Active = false
		--container.Visible = false	
	end
	return true
end

function RadialMenu.updatePivotOrigin(): boolean
	local absPos: Vector2 = mainFrame.AbsolutePosition
	local absSize: Vector2 = mainFrame.AbsoluteSize
	RadialMenu.pivotOrigin = absPos + absSize*.5 + topbarInset
	
	sui.Marker.Position = UDim2.fromOffset(RadialMenu.pivotOrigin.X, RadialMenu.pivotOrigin.Y)
	return true
end

function RadialMenu.updateSelectedButton(): boolean
	local menu: RadialMenu? = RadialMenu.activeMenu
	if menu then
		local prevSelected: RadialButton.RadialButton? = RadialMenu.selectedButton
		local newSelected: RadialButton.RadialButton = menu:GetClosestButton(RadialMenu.mouseAngle)
		
		if newSelected == prevSelected then
			return true
		end
		if prevSelected then
			prevSelected:Unselect()
		end
		newSelected:Select()
		RadialMenu.selectedButton = newSelected
		description.Text = newSelected.Description
		RadialMenu.clickSound:Play()
		return true
	end
	return false
end

--object methods

function RadialMenu.SetScrollIncrement(self: RadialMenu, increment: number, skipAnim: boolean?): boolean
	for i, v in self.Buttons do
		local angle: number = self.AngleIncrement*(i-1 + increment) % 360
		v:SetPosition(angle, RadialMenu.absoluteRadius, skipAnim)
	end	
	self.ScrollIncrement = increment
	return true
end

function RadialMenu.Show(self: RadialMenu): boolean
	if self.Active or RadialMenu.activeMenu then
		return false
	end
	
	--print(`showing {self.Name}`)
	for _, v in self.Buttons do
		v.Element.Parent = mainFrame
		v.Outline.Parent = outlineFrame
	end
	
	RadialMenu.activeMenu = self
	self.Active = true
	return true
end

function RadialMenu.Hide(self: RadialMenu): boolean
	if self.Active == false or RadialMenu.activeMenu ~= self then
		return false
	end
	
	--print(`hiding {self.Name}`)
	for _, v in self.Buttons do
		v.Element.Parent = nil
		v.Outline.Parent = nil
		if v == RadialMenu.selectedButton then
			v:Unselect()
			RadialMenu.selectedButton = nil
		end
	end
	
	RadialMenu.activeMenu = nil
	self.Active = false
	return true
end

function RadialMenu.GetClosestButton(self: RadialMenu, angle: number): RadialButton.RadialButton
	local closest: number = math.huge
	local candidate: RadialButton.RadialButton = self.Buttons[1]
	
	for _, v in self.Buttons do
		local phi: number = math.abs(v.WorldAngle - angle) % 360
		local delta: number = if phi > 180 then 360 - phi else phi
		if delta < closest then
			closest = delta
			candidate = v
		end
	end
	
	return candidate
end

RadialMenu.updatePivotOrigin()
RadialMenu.setMenu()
mainFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(RadialMenu.updatePivotOrigin)
mainFrame:GetPropertyChangedSignal('AbsoluteSize'):Connect(RadialMenu.updatePivotOrigin)

container.MouseWheelForward:Connect(function()
	local menu: RadialMenu? = RadialMenu.activeMenu
	if menu then
		local timeNow: number = os.clock()
		if timeNow - RadialMenu.lastScroll > RadialMenu.scrollDebounce then
			RadialMenu.lastScroll = timeNow
			menu:SetScrollIncrement(menu.ScrollIncrement + 1)
		end
	end	
end)

container.MouseWheelBackward:Connect(function()
	local menu: RadialMenu? = RadialMenu.activeMenu
	if menu then
		local timeNow: number = os.clock()
		if timeNow - RadialMenu.lastScroll > RadialMenu.scrollDebounce then
			RadialMenu.lastScroll = timeNow
			menu:SetScrollIncrement(menu.ScrollIncrement - 1)
		end
	end	
end)

uis.InputBegan:Connect(function(k)
	if k.UserInputType == Enum.UserInputType.MouseButton1 then
		local selected: RadialButton.RadialButton? = RadialMenu.selectedButton
		if selected then
			selected.Pressed()
		end
	end
end)

---[[
rus.RenderStepped:Connect(function()
	local menu: RadialMenu? = RadialMenu.activeMenu
	if menu then
		local mPos: Vector2 = uis:GetMouseLocation()
		local disp: Vector2 = mPos - RadialMenu.pivotOrigin
		local angle: number = (math.deg(math.atan2(disp.Y, disp.X)) + 360) % 360
		--print(angle)
		RadialMenu.mouseAngle = angle
		RadialMenu.updateSelectedButton()
	end		
end)
--]]

return (RadialMenu::any)::class