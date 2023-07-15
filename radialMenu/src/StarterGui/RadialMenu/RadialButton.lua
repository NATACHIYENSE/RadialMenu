local tws = game:GetService('TweenService')
local rus = game:GetService('RunService')

local bOutline = script:WaitForChild('ButtonOutline')
local bElement = script:WaitForChild('ButtonElement')

type class = {
	unselectedStrokeTweenPt: {},
	selectedStrokeTweenPt: {},
	selectionTweenInfo: TweenInfo,
	animRotSpeed: number,
	
	new: (args: constructor) -> RadialButton,
}
type constructor = { --arguments for constructing a new object
	image: string?,
	size: UDim2?,
	label: string?,
	description: string?,
	priority: number?,
	pressed: () -> (),
}
export type RadialButton = {
	Element: buttonElement,
	Outline: buttonOutline,
	Description: string,
	Priority: number,
	Pressed: () -> (),
	Connection: RBXScriptConnection,
	TweenableAngle: CFrameValue,
	WorldAngle: number,
	
	SetPosition: (self: RadialButton, angle: number, radiusOffset: number, skipAnim: boolean?) -> (),
	Delete: (self: RadialButton) -> (),
	Select: (self: RadialButton) -> (),
	Unselect: (self: RadialButton) -> (),
}

export type buttonOutline = typeof(bOutline)
export type buttonElement = typeof(bElement)

local RadialButton = {
	unselectedStrokeTweenPt = {Color = bOutline.UIStroke.Color, Thickness = bOutline.UIStroke.Thickness},
	selectedStrokeTweenPt = {Color = Color3.fromRGB(255, 255, 255), Thickness = 32},
	selectionTweenInfo = TweenInfo.new(.2, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
	animRotSpeed = 360,
}
RadialButton.__index = RadialButton

function RadialButton.new(args: constructor): RadialButton
	assert(type(args) == 'table', `table expected, got {typeof(args)}`)
	
	local newOutline: buttonOutline = bOutline:Clone()
	local newElement: buttonElement = bElement:Clone()
	
	local icon = newElement.Icon
	icon.Image = args.image or ''
	icon.Size = args.size or icon.Size
	
	local label = newElement.Label
	label.Text = args.label or ''
	
	local new = {
		Element = newElement,
		Outline = newOutline,
		Description = args.description or '',
		Priority = args.priority or 0,
		Pressed = args.pressed,
		Connection = newElement.MouseButton1Click:Connect(args.pressed),
		TweenableAngle = newElement.TweenableAngle,
		WorldAngle = 0,	
	}
	return setmetatable(new, RadialButton)::any
end

function RadialButton.SetPosition(self: RadialButton, angle: number, radiusOffset: number, skipAnim: boolean?)
	local prevAngle: number = self.WorldAngle
	self.WorldAngle = angle	
	local angleRad: number = math.rad(angle)

	if skipAnim then
		self.TweenableAngle.Value = CFrame.Angles(0, angleRad, 0)
		local x, y: number = math.cos(angleRad), math.sin(angleRad)
		local x01, y01: number = (x+1)*.5, (y+1)*.5
		local pos: UDim2 = UDim2.new(x01, x*radiusOffset, y01, y*radiusOffset)
		self.Element.Position = pos
		self.Outline.Position = pos	
	else
		local cnc = rus.RenderStepped:Connect(function()
			local _, twAngle: number = self.TweenableAngle.Value:ToOrientation()
			local x, y: number = math.cos(twAngle), math.sin(twAngle)
			local x01, y01: number = (x+1)*.5, (y+1)*.5
			local pos: UDim2 = UDim2.new(x01, x*radiusOffset, y01, y*radiusOffset)
			self.Element.Position = pos
			self.Outline.Position = pos
		end)
		
		local phi: number = math.abs(prevAngle - angle) % 360
		local delta: number = if phi > 180 then 360 - phi else phi
		local twinfo: TweenInfo = TweenInfo.new(delta/RadialButton.animRotSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		
		local anim: Tween = tws:Create(self.TweenableAngle, twinfo, {Value = CFrame.Angles(0, angleRad, 0)})
		anim.Completed:Once(function()
			cnc:Disconnect()
		end)
		anim:Play()
	end
end

function RadialButton.Delete(self: RadialButton)
	self.Connection:Disconnect()
	self.Element:Destroy()
	self.Outline:Destroy()
end

function RadialButton.Select(self: RadialButton)
	tws:Create(self.Outline.UIStroke, RadialButton.selectionTweenInfo, RadialButton.selectedStrokeTweenPt):Play()
end

function RadialButton.Unselect(self: RadialButton)
	tws:Create(self.Outline.UIStroke, RadialButton.selectionTweenInfo, RadialButton.unselectedStrokeTweenPt):Play()
end

return (RadialButton::any)::class