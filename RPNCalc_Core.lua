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

RPNCalcTable = {RPNCalc = {}}

function RPNCalcTable.RPNCalc:Store(name)
	 self.Memory[name] = self:Pop()
	 self:ClearEntryFlag()
end

function RPNCalcTable.RPNCalc:Recall(name)
	local value = self.Memory[name]
	if not self:IsEntryFlagSet() then
		if not self.bEnterLast then
				self:Push(self.Stack[1])
		end
	end
	if value ~= nil then
		self.Stack[1] = value
	else
		self:Push(0.0)
	end
	self:ClearEntryFlag()
	self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:New(stack_size)
	 new_stack = {}
	 if stack_size == nil then
	    stack_size = 4
	 end
	 for i = 1, stack_size do
	     table.insert(new_stack, 0.0)
	 end
	 obj = obj or {Stack = new_stack, Memory = {}, TrigMode = 0, bDecPtLast = false, bDigitEntryLast = false, bEnterLast = false}
	 setmetatable(obj, self)
	 self.__index = self
	 return obj
end

function RPNCalcTable.RPNCalc:ClearAllFlags()
	self.bDecPtLast = false
	self.bDigitEntryLast = false
	self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:ClearStack()
	 for i=1,#self.Stack do
	     self.Stack[i] = 0.0
	 end
	 self.Memory = {}
	 self:ClearAllFlags()
end

function RPNCalcTable.RPNCalc:ClearEntryFlag()
	self.bDigitEntryLast = false
end

function RPNCalcTable.RPNCalc:SetEntryFlag()
	self.bDigitEntryLast = true
end

function RPNCalcTable.RPNCalc:IsEntryFlagSet()
	return self.bDigitEntryLast
end

function RPNCalcTable.RPNCalc:ClearAccumulator()
	self.Stack[1] = 0.0
	self:SetEntryFlag()
	self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:Swap()
	 local temp = self.Stack[1]
	 self.Stack[1] = self.Stack[2]
	 self.Stack[2] = temp
	 self:ClearEntryFlag()
	 self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:RotateStackDown()
	 local v = self.Stack[1]
	 for i = 1, #self.Stack - 1 do
	     self.Stack[i] = self.Stack[i+1]
	 end
	 self.Stack[#self.Stack] = v
	 self:ClearEntryFlag()
	 self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:RotateStackUp()
	 local v = self.Stack[#self.Stack]
	 for i = #self.Stack, 2,-1 do
	     self.Stack[i] = self.Stack[i-1]
	 end
	 self.Stack[1] = v
	 self:ClearEntryFlag()
end

function RPNCalcTable.RPNCalc:PushAccumulator()
	self:Push(self.Stack[1])
end

function RPNCalcTable.RPNCalc:Push(v)
	 for i=#self.Stack, 2, -1 do
	     self.Stack[i] = self.Stack[i - 1]
	 end
	 self.Stack[1] = v
	 self:ClearEntryFlag()
end

function RPNCalcTable.RPNCalc:Pop()
	 local v = self.Stack[1]
	 for i = 1, #self.Stack - 1 do
	     self.Stack[i] = self.Stack[i+1]
	 end
	 self.Stack[#self.Stack] = 0.0
	 return v
end

function RPNCalcTable.RPNCalc:ApplyBinaryOperation(operator)
	 local b = self:Pop()
	 local a = self:Pop()
	 self:Push(operator(a, b))
	 self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:ApplyUnaryOperation(operator)
	 local a = self:Pop()
	 self:Push(operator(a))
	 self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:ApplyTrigonometricOperation(operation)
	local a = self:Pop()
	
	if self.TrigMode == 0 then
		-- Default: operand in radians
		
	elseif self.TrigMode == 1 then
		-- Degrees:
		a = (a * math.pi)/180
	else
		-- Gradians:
		a = (math.pi*a)/200.0
	end
	local result = operation(a)
	self:Push(result)
	self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:ApplyInverseTrigonometricOperation(operation)
	local a = self:Pop()
	local result = operation(a)
	if self.TrigMode == 0 then
		-- Default: result in radians
		
	elseif self.TrigMode == 1 then
		-- Degrees:
		result = (result * 180)/math.pi
	else
		-- Gradians:
		a = (200*result)/math.pi
	end
	
	self:Push(result)
	self.bEnterLast = false
end

function RPNCalcTable.RPNCalc:Add()
	 self:ApplyBinaryOperation(function(a, b) return a + b end)
end

function RPNCalcTable.RPNCalc:Sub()
	 self:ApplyBinaryOperation(function(a, b) return a - b end)
end

function RPNCalcTable.RPNCalc:Mul()
	 self:ApplyBinaryOperation(function(a, b) return a * b end)
end

function RPNCalcTable.RPNCalc:Div()
	 self:ApplyBinaryOperation(function(a, b) return a/b end)
end

function RPNCalcTable.RPNCalc:Exponentiate()
	 self:ApplyBinaryOperation(function(a, b) return a^b end)
end	

function RPNCalcTable.RPNCalc:e_To_x()
	 self:ApplyUnaryOperation(function(a) return math.exp(a) end)
end

function RPNCalcTable.RPNCalc:Sqrt()
	 self:ApplyUnaryOperation(function(a) return math.sqrt(a) end)
end

function RPNCalcTable.RPNCalc:NaturalLog()
	 self:ApplyUnaryOperation(function(a) return math.log(a) end)
end

function RPNCalcTable.RPNCalc:Log10()
	 self:ApplyUnaryOperation(function(a) return math.log10(a) end)
end	 

function RPNCalcTable.RPNCalc:Inv()
	 self:ApplyUnaryOperation(function(a) return 1/a end)
end

function RPNCalcTable.RPNCalc:Square()
	 self:ApplyUnaryOperation(function(a) return a^2 end)
end

function RPNCalcTable.RPNCalc:Sin()
	self:ApplyTrigonometricOperation(math.sin)
end

function RPNCalcTable.RPNCalc:Cos()
	self:ApplyTrigonometricOperation(math.cos)
end

function RPNCalcTable.RPNCalc:Tan()
	self:ApplyTrigonometricOperation(math.tan)
end

function RPNCalcTable.RPNCalc:Arcsin()
	self:ApplyInverseTrigonometricOperation(math.asin)
end

function RPNCalcTable.RPNCalc:Arccos()
	self:ApplyInverseTrigonometricOperation(math.acos)
end

function RPNCalcTable.RPNCalc:Arctan()
	self:ApplyInverseTrigonometricOperation(math.atan)
end

function RPNCalcTable.RPNCalc:Negate()
	-- CH S on the HP-35
	self:ApplyUnaryOperation(function(a) return a * (-1); end)
end

function RPNCalcTable.RPNCalc:AppendToAccumulator(char)
	if tonumber(self.Stack[1]) == 0 and char == "E" then
		self.Stack[1] = "1"
		self:SetEntryFlag()
	elseif char == "E" then
		self:SetEntryFlag()
	end
	
	if not self:IsEntryFlagSet() then
		if not self.bEnterLast then
			self:Push(self.Stack[1])
		end
		self.Stack[1] = ""
	end
	
	local bHasE = string.find(self.Stack[1], "E") ~= nil
	local bHasDecPt = string.find(self.Stack[1], "%.") ~= nil
	
	if char == "E" and bHasE then
	
	elseif char == "." and (bHasDecPt or bHasE) then
	
	else
		if self.Stack[1] == 0 or self.Stack[1] == "0" then
			self.Stack[1] = ""
		end
		self.Stack[1] = self.Stack[1] .. tostring(char)
		self:SetEntryFlag()
	end
end

function RPNCalcTable.RPNCalc:EnterKey()
	-- This pushes the stack up and places 0.0 in the accumulator
	self:PushAccumulator()
	self.bEnterLast = true
	self:ClearEntryFlag()
end


function RPNCalcTable.RPNCalc:Print()
	 for i = #self.Stack, 1, -1 do
	     print(i .. ":" ..self.Stack[i])
	 end
end
