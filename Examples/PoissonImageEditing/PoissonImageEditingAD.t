local W,H = opt.Dim("W",0), opt.Dim("H",1)
local S = ad.ProblemSpec()
local X = S:Image("X", opt.float4,W,H,0)
local T = S:Image("T", opt.float4,W,H,1)
local M = S:Image("M", float, W,H,2)
S:UsePreconditioner(false)



local terms = terralib.newlist()


S:Exclude(ad.not_(ad.eq(M(0,0),0)))

-- mask
local m = M(0,0)
local m0 = M( 1,0)
local m1 = M(-1,0)
local m2 = M( 0,1)
local m3 = M(0,-1)

--image 0
local p = X(0,0)
local q0 = X( 1,0)
local q1 = X(-1,0)
local q2 = X( 0,1)
local q3 = X(0,-1)

-- image 1
local t = T(0,0)
local t0 = T( 1,0)
local t1 = T(-1,0)
local t2 = T( 0,1)
local t3 = T(0,-1)


local laplacianCost0 = ((p - q0) - (t - t0))
local laplacianCost1 = ((p - q1) - (t - t1))
local laplacianCost2 = ((p - q2) - (t - t2))
local laplacianCost3 = ((p - q3) - (t - t3))


for i = 0,3 do	
	--local laplacianCost0F =  laplacianCost0(i)
	--local laplacianCost1F =  laplacianCost1(i)
	--local laplacianCost2F =  laplacianCost2(i)
	--local laplacianCost3F =  laplacianCost3(i)
	
	local laplacianCost0F = ad.select(opt.InBounds(0,0,0,0),ad.select(opt.InBounds(1,0,0,0),laplacianCost0(i),0),0)
	local laplacianCost1F = ad.select(opt.InBounds(0,0,0,0),ad.select(opt.InBounds(-1,0,0,0),laplacianCost1(i),0),0)
	local laplacianCost2F = ad.select(opt.InBounds(0,0,0,0),ad.select(opt.InBounds(0,1,0,0),laplacianCost2(i),0),0)
	local laplacianCost3F = ad.select(opt.InBounds(0,0,0,0),ad.select(opt.InBounds(0,-1,0,0),laplacianCost3(i),0),0)
	
	terms:insert(laplacianCost0F)
	terms:insert(laplacianCost1F)
	terms:insert(laplacianCost2F)
	terms:insert(laplacianCost3F)
end

local cost = ad.sumsquared(unpack(terms))
return S:Cost(cost)