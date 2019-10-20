--[[]
Copyright (C) 2019 Meowspergers
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]--

calculator = {}
local g_bArcPressed = false
local g_bSTOPressed = false
local g_bRCLPressed = false
local g_bIsUIMinimized = true
local g_dwNormalHeight = 620
local g_TrigMode = 0 -- TODO: Persist this setting
local g_bMouseInFrame = false

function SciRPNCalcFrame_OnLoad(self)

	g_bIsUIMinimized = true
	SciRPNCalcFrame:SetHeight(70)
	SciRPNCalcFrame_SetAllChildrenVisibility(SciRPNCalcFrame, false)
	
	self:RegisterForDrag("LeftButton");
	calculator = SciRPNCalcTable.SciRPNCalc:New(6)
	calculator:SetTrigMode(g_TrigMode)
	SciRPNCalcFrame_UpdateDisplay(self)
	
end

function SciRPNCalcFrame_OnShow(self)

end

function SciRPNCalcFrame_OnMouseDown(self, button)
	
end

function SciRPNCalcFrame_OnMouseUp(self, button)
	
end

function SciRPNCalcFrame_OnEnter(self)
	g_bMouseInFrame = true
end

function SciRPNCalcFrame_OnLeave(self)
	g_bMouseInFrame = false
end

function SciRPNCalcFrame_OnKeyDown(self, key)
	if g_bMouseInFrame then
		self:SetPropagateKeyboardInput(false)
		if key == "ENTER" then
			SciRPNCalcFrame_EnterPress(self)
		elseif key == "NUMPAD1" then
			SciRPNCalcFrame_NumPress(self, nil, 1)
		elseif key == "NUMPAD2" then
			SciRPNCalcFrame_NumPress(self, nil, 2)
		elseif key == "NUMPAD3" then
			SciRPNCalcFrame_NumPress(self, nil, 3)
		elseif key == "NUMPAD4" then
			SciRPNCalcFrame_NumPress(self, nil, 4)
		elseif key == "NUMPAD5" then
			SciRPNCalcFrame_NumPress(self, nil, 5)
		elseif key == "NUMPAD6" then
			SciRPNCalcFrame_NumPress(self, nil, 6)
		elseif key == "NUMPAD7" then
			SciRPNCalcFrame_NumPress(self, nil, 7)
		elseif key == "NUMPAD8" then
			SciRPNCalcFrame_NumPress(self, nil, 8)
		elseif key == "NUMPAD9" then
			SciRPNCalcFrame_NumPress(self, nil, 9)
		elseif key == "NUMPAD0" then
			SciRPNCalcFrame_NumPress(self, nil, 0)
		elseif key == "NUMPADDECIMAL" then
			SciRPNCalcFrame_NumPress(self, nil, ".")
		elseif key == "NUMPADDIVIDE" then
			SciRPNCalcFrame_DivPress(self)
		elseif key == "NUMPADMULTIPLY" then
			SciRPNCalcFrame_MulPress(self)
		elseif key == "NUMPADPLUS" then
			SciRPNCalcFrame_AddPress(self)
		elseif key == "NUMPADMINUS" then
			SciRPNCalcFrame_SubPress(self)
		else
			self:SetPropagateKeyboardInput(true)
		end
	else
		self:SetPropagateKeyboardInput(true)
	end
end

function SciRPNCalcFrame_StartMoving(self)
	self:StartMoving()
end

function SciRPNCalcFrame_StopMoving(self)
	self:StopMovingOrSizing()
end


function SciRPNCalcFrame_CloseWindow(self)
	self:Hide()
end

function SciRPNCalcFrame_SetAllChildrenVisibility(self, v)

	if v then 
		degreesFontString:Show()
		radiansFontString:Show()
		gradiansFontString:Show()
	else
		degreesFontString:Hide()
		radiansFontString:Hide()
		gradiansFontString:Hide()
	end
	
	local childframes = {self:GetChildren()}
	for key, child in ipairs(childframes) do
		if child ~= btnMinimizeUI and child ~= btnCloseUI then
			if v then
				child:Show()
			else
				child:Hide()
			end
		end
	end
end

local function DebugPrint(str)
	--print(str)
end

function SciRPNCalcFrame_MinimizeUI(self, button)

	g_bIsUIMinimized = not g_bIsUIMinimized
	if g_bIsUIMinimized then
		self:SetHeight(70)
	else
		self:SetHeight(g_dwNormalHeight)
	end
	SciRPNCalcFrame_SetAllChildrenVisibility(self, not g_bIsUIMinimized)
end

function SciRPNCalcFrame_CheckDegrees(self, button, down)
	calculator:SetTrigMode(1)
	SciRPNCalcFrame_UpdateDisplay(SciRPNCalcFrame)
end

function SciRPNCalcFrame_CheckRadians(self, button, down)
	calculator:SetTrigMode(0)
	SciRPNCalcFrame_UpdateDisplay(SciRPNCalcFrame)
end

function SciRPNCalcFrame_CheckGradians(self, button, down)
	calculator:SetTrigMode(2)
	SciRPNCalcFrame_UpdateDisplay(SciRPNCalcFrame)
end

function SciRPNCalcFrame_UpdateTrigModeCheckboxes(self)
	local mode = calculator:GetTrigMode()

	if mode == 0 then
		-- Radians
		checkDeg:SetChecked(false)
		checkRad:SetChecked(true)
		checkGrad:SetChecked(false)
	elseif mode == 1 then
		-- Degrees
		checkDeg:SetChecked(true)
		checkRad:SetChecked(false)
		checkGrad:SetChecked(false)
	else
		-- Gradians
		checkDeg:SetChecked(false)
		checkRad:SetChecked(false)
		checkGrad:SetChecked(true)
	end
end

function GetRowFormatString(val)
	if string.find(val, "E") ~= nil then
		return "%s"
	elseif tonumber(val) == nil then
		return "%s"
	elseif string.find(val, "%.") ~= nil then
		return "%.10f"
	else
		return "%d"
	end
end

function SciRPNCalcFrame_UpdateDisplay(self)
	RPNOutputFrame:Clear()

	for row=#calculator.Stack,3,-1 do
		local val = calculator.Stack[row]
		local str = string.format(GetRowFormatString(val), val)
		RPNOutputFrame:AddMessage("r".. (row - 2) .. ": " .. str, 1.0, 1.0, 1.0)
	end
	
	local val = calculator.Stack[2]
	local str = string.format(GetRowFormatString(val), val)
	RPNOutputFrame:AddMessage("y : " .. str, 1.0, 1.0, 1.0)
	val = calculator.Stack[1]
	str = string.format(GetRowFormatString(val), val)
	RPNOutputFrame:AddMessage("x : " .. str, 1.0, 1.0, 1.0)
	if g_bArcPressed then
		btnArc:SetText("ARC")
		btnArc:LockHighlight()
	else
		btnArc:SetText("arc")
		btnArc:UnlockHighlight()
	end
	
	if g_bRCLPressed then
		btnRcl:LockHighlight()
	else
		btnRcl:UnlockHighlight()
	end
	
	if g_bSTOPressed then
		btnSto:LockHighlight()
	else
		btnSto:UnlockHighlight()
	end
	
	SciRPNCalcFrame_UpdateTrigModeCheckboxes(self)
	
	SciRPNCalc_HighlightNumberKeys(self, g_bSTOPressed or g_bRCLPressed)
	
end

function SciRPNCalc_HighlightNumberKeys(self, on)
	local numkeys = {btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9}
	for i = 1, #numkeys do
		if on then
			numkeys[i]:LockHighlight()
		else
			numkeys[i]:UnlockHighlight()
		end
	end
end

function SciRPNCalcFrame_NumPress(self, button, number)
	if g_bRCLPressed then
		calculator:Recall(number)
		g_bSTOPressed = false
		g_bRCLPressed = false
	elseif g_bSTOPressed then
		calculator:Store(number)
		g_bSTOPressed = false
		g_bRCLPressed = false
	else
		calculator:AppendToAccumulator(number)
	end
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_MulPress(self)
	calculator:Mul()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_DivPress(self)
	calculator:Div()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_SubPress(self)
	calculator:Sub()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_AddPress(self)
	calculator:Add()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_PowPress(self)
	calculator:Exponentiate()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_EtoXPress(self)
	calculator:e_To_x()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_SqrtPress(self)
	calculator:Sqrt()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_NaturalLogPress(self)
	calculator:NaturalLog()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_Log10Press(self)
	calculator:Log10()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_InvPress(self)
	calculator:Inv()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_SquarePress(self)
	calculator:Square()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_SinPress(self)
	if g_bArcPressed then
		calculator:Arcsin()
	else
		calculator:Sin()
	end
	g_bArcPressed = false
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_CosPress(self)
	if g_bArcPressed then
		calculator:Arccos()
	else
		calculator:Cos()
	end
	g_bArcPressed = false
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_TanPress(self)
	if g_bArcPressed then
		calculator:Arctan()
	else
		calculator:Tan()
	end
	g_bArcPressed = false
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_ArcPress(self)
	-- This is a one time use mode button
	g_bArcPressed = not g_bArcPressed
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_NegPress(self)
	calculator:Negate()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_RotDownPress(self)
	calculator:RotateStackDown()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_SwapPress(self)
	calculator:Swap()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_PiPress(self)
	calculator:Push(math.pi)
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_StoPress(self)
	g_bSTOPressed = not g_bSTOPressed
	g_bRCLPressed = false
	SciRPNCalcFrame_UpdateDisplay(self)
end
function SciRPNCalcFrame_RclPress(self)
	g_bRCLPressed = not g_bRCLPressed
	g_bSTOPressed = false
	SciRPNCalcFrame_UpdateDisplay(self)
end
function SciRPNCalcFrame_EexPress(self)
	SciRPNCalcFrame_NumPress(self, nil, "E")
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_ClrXPress(self)
	calculator:ClearAccumulator()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_CLRPress(self)
	calculator:ClearStack()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function SciRPNCalcFrame_EnterPress(self)
	calculator:EnterKey()
	SciRPNCalcFrame_UpdateDisplay(self)
end

function ShowSciRPNCalc()
	SciRPNCalcFrame:Show()
end

SlashCmdList["SCIRPNCALC"] = ShowSciRPNCalc;
SLASH_SCIRPNCALC1 = "/scirpncalc";