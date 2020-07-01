
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
PassosCL = Tunnel.getInterface("vrp_cnh")

----------------------------------------------------------------------------
-- Config
----------------------------------------------------------------------------
local detran = {{ 238.99,-1381.61,33.74 }}
local detranblip = {{name="Detran", id=538, c = 4, x=238.99, y=-1381.61, z=33.74}}

----------------------------------------------------------------------------
-- OPEN NUI
----------------------------------------------------------------------------
local menuactive = false
function cnh_nui()
	menuactive = not menuactive
	if menuactive then
		SetNuiFocus(true,true)
		SendNUIMessage({ showmenu = true })
	else
		SetNuiFocus(false)
		SendNUIMessage({ hidemenu = true })
	end
end

----------------------------------------------------------------------------
-- Choices NUI
----------------------------------------------------------------------------

RegisterNUICallback("ButtonClick",function(data,cb)
	if data == "comprar_cnh" then
		cnh_nui()
		PassosCL.comprando()
	elseif data == "vender_cnh" then
		cnh_nui()
		PassosCL.vendendo()
	elseif data == "fechar" then
		cnh_nui()
	end
end)

----------------------------------------------------------------------------
-- Threads
----------------------------------------------------------------------------

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	while true do
		Citizen.Wait(1)
		for _,mark in pairs(detran) do
			local x,y,z = table.unpack(mark)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),x,y,z,true)
			if distance <= 1.2 then
				if IsControlJustPressed(0,38) then
					cnh_nui()
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if checkDistance() then
			DrawMarker(23,238.99,-1381.61,33.74-0.99,1,1,0,0,0,0,1.0,1.0,1.0,255,255,255,50,0,1,0,0)
			DrawText3D(238.99,-1381.61,33.74+0.24, "~r~Passos vRP base", 2.0, 4, 150)
			DrawText3D(238.99,-1381.61,33.74+0.01, "Pressione ~r~[E]~w~ para acessar o menu do Detran", 2.0, 4, 150)
		end	 
	end
end)

Citizen.CreateThread(function()
	for k,v in pairs(detranblip)do
	  local blip = AddBlipForCoord(v.x, v.y, v.z)
	  SetBlipSprite(blip, v.id)
	  SetBlipScale(blip, 0.5)
	  SetBlipColour(blip, v.c)
	  SetBlipAsShortRange(blip, true)
	  BeginTextCommandSetBlipName("STRING");
	  AddTextComponentString(tostring(v.name))
	  EndTextCommandSetBlipName(blip)
	end
end)

----------------------------------------------------------------------------
-- Funções
----------------------------------------------------------------------------

function checkDistance()
	local ped = GetPlayerPed(-1)
	local x,y,z = table.unpack(GetEntityCoords(ped))
	local bowz,cdz = GetGroundZFor_3dCoord(x,y,z)
	local distance = GetDistanceBetweenCoords(x,y,cdz,238.99,-1381.61,33.74,true)
	if distance < 10 then
		return true
	else
		return false
	end		
end

function DrawText3D(x,y,z, text, scl, font, opacity) 
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
	local scale = (1/dist)*scl
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
   
	if onScreen then
		SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, opacity)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
	end
end