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
local g_bIsUIMinimized = false
local g_dwNormalHeight = 608

function RPNCalcFrame_OnLoad(self)
	g_dwNormalHeight = 608
	g_bIsUIMinimized = false
	self:RegisterForDrag("LeftButton");
	calculator = RPNCalcTable.RPNCalc:New(6)
	RPNCalcFrame_UpdateDisplay(self)

end

function RPNCalcFrame_OnShow(self)

end

function RPNCalcFrame_OnMouseDown(self, button)
	
end

function RPNCalcFrame_OnMouseUp(self, button)
	
end

function RPNCalcFrame_OnKeyDown(self, key)
	self:SetPropagateKeyboardInput(false)
	if key == "ENTER" then
		RPNCalcFrame_EnterPress(self)
	elseif key == "NUMPAD1" then
		RPNCalcFrame_NumPress(self, nil, 1)
	elseif key == "NUMPAD2" then
		RPNCalcFrame_NumPress(self, nil, 2)
	elseif key == "NUMPAD3" then
		RPNCalcFrame_NumPress(self, nil, 3)
	elseif key == "NUMPAD4" then
		RPNCalcFrame_NumPress(self, nil, 4)
	elseif key == "NUMPAD5" then
		RPNCalcFrame_NumPress(self, nil, 5)
	elseif key == "NUMPAD6" then
		RPNCalcFrame_NumPress(self, nil, 6)
	elseif key == "NUMPAD7" then
		RPNCalcFrame_NumPress(self, nil, 7)
	elseif key == "NUMPAD8" then
		RPNCalcFrame_NumPress(self, nil, 8)
	elseif key == "NUMPAD9" then
		RPNCalcFrame_NumPress(self, nil, 9)
	elseif key == "NUMPAD0" then
		RPNCalcFrame_NumPress(self, nil, 0)
	elseif key == "NUMPADDECIMAL" then
		RPNCalcFrame_NumPress(self, nil, ".")
	elseif key == "NUMPADDIVIDE" then
		RPNCalcFrame_DivPress(self)
	elseif key == "NUMPADMULTIPLY" then
		RPNCalcFrame_MulPress(self)
	elseif key == "NUMPADPLUS" then
		RPNCalcFrame_AddPress(self)
	elseif key == "NUMPADMINUS" then
		RPNCalcFrame_SubPress(self)
	else
		self:SetPropagateKeyboardInput(true)
	end
end

function RPNCalcFrame_StartMoving(self)
	self:StartMoving()
end

function RPNCalcFrame_StopMoving(self)
	self:StopMovingOrSizing()
end


function RPNCalcFrame_CloseWindow(self)
	self:Hide()
end

local function RPNCalcFrame_SetAllChildrenVisibility(self, v)
	local childframes = {self:GetChildren()}
	for key, child in ipairs(childframes) do
		if child ~= btnMinimizeUI and child ~= btnCloseUI then
			if v == true then
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

function RPNCalcFrame_MinimizeUI(self, button)
	DebugPrint("MinimizeUI Called w/" .. button)
	g_bIsUIMinimized = not g_bIsUIMinimized
	if g_bIsUIMinimized == true then
		self:SetHeight(75)
	else
		self:SetHeight(g_dwNormalHeight)
	end
	RPNCalcFrame_SetAllChildrenVisibility(self, not g_bIsUIMinimized)
end

function RPNCalcFrame_UpdateDisplay(self)
	RPNOutputFrame:Clear()
	for row=6,1,-1 do
		RPNOutputFrame:AddMessage("r".. row .. ": " .. calculator.Stack[row], 1.0, 1.0, 1.0)
	end
	
	if g_bArcPressed == true then
		btnArc:SetText("ARC")
		btnArc:LockHighlight()
	else
		btnArc:SetText("arc")
		btnArc:UnlockHighlight()
	end
	
	if g_bRCLPressed == true then
		btnRcl:LockHighlight()
	else
		btnRcl:UnlockHighlight()
	end
	
	if g_bSTOPressed == true then
		btnSto:LockHighlight()
	else
		btnSto:UnlockHighlight()
	end
	
	RPNCalc_HighlightNumberKeys(self, g_bSTOPressed == true or g_bRCLPressed == true)
	
end

function RPNCalc_HighlightNumberKeys(self, on)
	local numkeys = {btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9}
	for i = 1, #numkeys do
		if on == true then
			numkeys[i]:LockHighlight()
		else
			numkeys[i]:UnlockHighlight()
		end
	end
end

function RPNCalcFrame_NumPress(self, button, number)
	if g_bRCLPressed == true or g_bSTOPressed == true then
		if g_bRCLPressed == true then
			calculator:Recall(number)
			g_bRCLPressed = false
		end
		
		if g_bSTOPressed == true then
			calculator:Store(number)
			g_bSTOPressed = false
		end
	else
		calculator:AppendToAccumulator(number)
	end
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_MulPress(self)
	calculator:Mul()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_DivPress(self)
	calculator:Div()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_SubPress(self)
	calculator:Sub()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_AddPress(self)
	calculator:Add()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_PowPress(self)
	calculator:Exponentiate()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_EtoXPress(self)
	calculator:e_To_x()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_SqrtPress(self)
	calculator:Sqrt()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_NaturalLogPress(self)
	calculator:NaturalLog()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_Log10Press(self)
	calculator:Log10()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_InvPress(self)
	calculator:Inv()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_SquarePress(self)
	calculator:Square()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_SinPress(self)
	if g_bArcPressed == true then
		calculator:Arcsin()
	else
		calculator:Sin()
	end
	g_bArcPressed = false
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_CosPress(self)
	if g_bArcPressed == true then
		calculator:Arccos()
	else
		calculator:Cos()
	end
	g_bArcPressed = false
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_TanPress(self)
	if g_bArcPressed == true then
		calculator:Arctan()
	else
		calculator:Tan()
	end
	g_bArcPressed = false
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_ArcPress(self)
	-- This is a one time use mode button
	g_bArcPressed = not g_bArcPressed
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_NegPress(self)
	calculator:Negate()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_RotDownPress(self)
	calculator:RotateStackDown()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_SwapPress(self)
	calculator:Swap()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_PiPress(self)
	calculator:Push("3.14159265358979")
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_StoPress(self)
	g_bSTOPressed = not g_bSTOPressed
	g_bRCLPressed = false
	RPNCalcFrame_UpdateDisplay(self)
end
function RPNCalcFrame_RclPress(self)
	g_bRCLPressed = not g_bRCLPressed
	g_bSTOPressed = false
	RPNCalcFrame_UpdateDisplay(self)
end
function RPNCalcFrame_EexPress(self)
	
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_ClrXPress(self)
	calculator:ClearAccumulator()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_CLRPress(self)
	calculator:ClearStack()
	RPNCalcFrame_UpdateDisplay(self)
end

function RPNCalcFrame_EnterPress(self)
	calculator:EnterKey()
	RPNCalcFrame_UpdateDisplay(self)
end