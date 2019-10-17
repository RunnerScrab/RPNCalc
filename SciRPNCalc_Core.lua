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

SciRPNCalcTable = {SciRPNCalc = {}}

function SciRPNCalcTable.SciRPNCalc:Store(name)
	 self.Memory[name] = self:Pop()
	 self:ClearEntryFlag()
end

function SciRPNCalcTable.SciRPNCalc:Recall(name)
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

function SciRPNCalcTable.SciRPNCalc:New(stack_size)
	 new_stack = {}
	 if stack_size == nil then
	    stack_size = 4
	 end
	 for i = 1, stack_size do
	     table.insert(new_stack, 0.0)
	 end
	 obj = obj or {Stack = new_stack, Memory = {}, TrigMode = 1, bDecPtLast = false, bDigitEntryLast = false, bEnterLast = false}
	 setmetatable(obj, self)
	 self.__index = self
	 return obj
end

function SciRPNCalcTable.SciRPNCalc:SetTrigMode(v)
	self.TrigMode = v
end

function SciRPNCalcTable.SciRPNCalc:GetTrigMode()
	return self.TrigMode
end

function SciRPNCalcTable.SciRPNCalc:ClearAllFlags()
	self.bDecPtLast = false
	self.bDigitEntryLast = false
	self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:ClearStack()
	 for i=1,#self.Stack do
	     self.Stack[i] = 0.0
	 end
	 self.Memory = {}
	 self:ClearAllFlags()
end

function SciRPNCalcTable.SciRPNCalc:ClearEntryFlag()
	self.bDigitEntryLast = false
end

function SciRPNCalcTable.SciRPNCalc:SetEntryFlag()
	self.bDigitEntryLast = true
end

function SciRPNCalcTable.SciRPNCalc:IsEntryFlagSet()
	return self.bDigitEntryLast
end

function SciRPNCalcTable.SciRPNCalc:ClearAccumulator()
	self.Stack[1] = 0.0
	self:SetEntryFlag()
	self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:Swap()
	 local temp = self.Stack[1]
	 self.Stack[1] = self.Stack[2]
	 self.Stack[2] = temp
	 self:ClearEntryFlag()
	 self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:RotateStackDown()
	 local v = self.Stack[1]
	 for i = 1, #self.Stack - 1 do
	     self.Stack[i] = self.Stack[i+1]
	 end
	 self.Stack[#self.Stack] = v
	 self:ClearEntryFlag()
	 self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:RotateStackUp()
	 local v = self.Stack[#self.Stack]
	 for i = #self.Stack, 2,-1 do
	     self.Stack[i] = self.Stack[i-1]
	 end
	 self.Stack[1] = v
	 self:ClearEntryFlag()
end

function SciRPNCalcTable.SciRPNCalc:PushAccumulator()
	self:Push(self.Stack[1])
end

function SciRPNCalcTable.SciRPNCalc:Push(v)
	 for i=#self.Stack, 2, -1 do
	     self.Stack[i] = self.Stack[i - 1]
	 end
	 self.Stack[1] = v
	 self:ClearEntryFlag()
end

function SciRPNCalcTable.SciRPNCalc:Pop()
	 local v = self.Stack[1]
	 for i = 1, #self.Stack - 1 do
	     self.Stack[i] = self.Stack[i+1]
	 end
	 self.Stack[#self.Stack] = 0.0
	 return v
end

function SciRPNCalcTable.SciRPNCalc:ApplyBinaryOperation(operator)
	 local b = self:Pop()
	 local a = self:Pop()
	 self:Push(operator(a, b))
	 self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:ApplyUnaryOperation(operator)
	 local a = self:Pop()
	 self:Push(operator(a))
	 self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:ApplyTrigonometricOperation(operation)
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

function SciRPNCalcTable.SciRPNCalc:ApplyInverseTrigonometricOperation(operation)
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

function SciRPNCalcTable.SciRPNCalc:Add()
	 self:ApplyBinaryOperation(function(a, b) return a + b end)
end

function SciRPNCalcTable.SciRPNCalc:Sub()
	 self:ApplyBinaryOperation(function(a, b) return a - b end)
end

function SciRPNCalcTable.SciRPNCalc:Mul()
	 self:ApplyBinaryOperation(function(a, b) return a * b end)
end

function SciRPNCalcTable.SciRPNCalc:Div()
-- Do not permit division by integer 0
	local divisor = tonumber(self.Stack[1])
	if divisor ~= nil and divisor ~= 0 then
		self:ApplyBinaryOperation(function(a, b) return a/b end)
	end
end

function SciRPNCalcTable.SciRPNCalc:Exponentiate()
	-- Like the HP-35, do not permit the sqrt of a negative number
	
	local base = self.Stack[2]
	local exponent = self.Stack[1]
	
	if tonumber(base) == nil or tonumber(exponent) == nil then
		do return end
	end
	
	local bBaseIsNeg = tonumber(base) < 0
	local bExponentIsFractional = math.abs(tonumber(exponent)) < 1
	
	if not bBaseIsNeg or not bExponentIsFractional then
			self:ApplyBinaryOperation(function(a, b) return a^b end)
	else
		self.bEnterLast = false
	end
	 
end	

function SciRPNCalcTable.SciRPNCalc:e_To_x()
	 self:ApplyUnaryOperation(function(a) return math.exp(a) end)
end

function SciRPNCalcTable.SciRPNCalc:Sqrt()
	-- Like the HP-35, do not permit the sqrt of a negative number
	local operand = self.Stack[1]
	
	if operand ~= nil and tonumber(operand) ~= nil then
		if string.find(operand, "-") == nil or tonumber(operand) >= 0 then
			self:ApplyUnaryOperation(function(a) return math.sqrt(a) end)
			do return end
		end
	end
	self.Stack[1] = 0.0
	self.bEnterLast = false
end

function SciRPNCalcTable.SciRPNCalc:NaturalLog()
	 self:ApplyUnaryOperation(function(a) return math.log(a) end)
end

function SciRPNCalcTable.SciRPNCalc:Log10()
	 self:ApplyUnaryOperation(function(a) return math.log10(a) end)
end	 

function SciRPNCalcTable.SciRPNCalc:Inv()
	 self:ApplyUnaryOperation(function(a) return 1/a end)
end

function SciRPNCalcTable.SciRPNCalc:Square()
	 self:ApplyUnaryOperation(function(a) return a^2 end)
end

function SciRPNCalcTable.SciRPNCalc:Sin()
	self:ApplyTrigonometricOperation(math.sin)
end

function SciRPNCalcTable.SciRPNCalc:Cos()
	self:ApplyTrigonometricOperation(math.cos)
end

function SciRPNCalcTable.SciRPNCalc:Tan()
	self:ApplyTrigonometricOperation(math.tan)
end

function SciRPNCalcTable.SciRPNCalc:Arcsin()
	self:ApplyInverseTrigonometricOperation(math.asin)
end

function SciRPNCalcTable.SciRPNCalc:Arccos()
	self:ApplyInverseTrigonometricOperation(math.acos)
end

function SciRPNCalcTable.SciRPNCalc:Arctan()
	self:ApplyInverseTrigonometricOperation(math.atan)
end

function StringLastMatch(str, char)
	local matchi = 0
	local lastmatchi = nil
	repeat
		matchi = string.find(str, char, matchi  + 1)
		if matchi ~= nil then
			lastmatchi = matchi
		end
	until matchi == nil
	return lastmatchi
end

function SciRPNCalcTable.SciRPNCalc:Negate()
	-- CH S on the HP-35
	local bHasE = string.find(self.Stack[1], "E") ~= nil
	
	if bHasE then
		-- Special case for entering E format numbers
		local Ematchbegin, Ematchend = string.find(self.Stack[1], "E")
		local Nmatchend = StringLastMatch(self.Stack[1], "-")
		if Nmatchend == nil or Nmatchend < Ematchbegin then
			-- Permit a negative sign before E, but not one already after
			self:AppendToAccumulator("-")
		end
	else
		self:ApplyUnaryOperation(function(a) return a * (-1); end)
	end
end

function SciRPNCalcTable.SciRPNCalc:AppendToAccumulator(char)
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
		-- Do nothing if E EX is pressed and we are already in that mode
	elseif char == "." and (bHasDecPt or bHasE) then
		-- Do not permit an extra decimal point inside a mantissa
	else
		if self.Stack[1] == 0 or self.Stack[1] == "0" then
			self.Stack[1] = ""
		end
		self.Stack[1] = self.Stack[1] .. tostring(char)
		self:SetEntryFlag()
	end
end

function SciRPNCalcTable.SciRPNCalc:EnterKey()
	-- This pushes the stack up and places 0.0 in the accumulator
	self:PushAccumulator()
	self.bEnterLast = true
	self:ClearEntryFlag()
end


function SciRPNCalcTable.SciRPNCalc:Print()
	 for i = #self.Stack, 1, -1 do
	     print(i .. ":" ..self.Stack[i])
	 end
end
