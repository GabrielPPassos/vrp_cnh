local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
PassosCL = {}
Tunnel.bindInterface("vrp_cnh", PassosCL)

----------------------------------------------------------------------------
-- Configuração
----------------------------------------------------------------------------
local grupo_cnh = "CNH"
local preco = 200
local venda_preco = 100
local permissao_cnh = "cnh.permissao"
local permissao_pm = "policia.permissao"

----------------------------------------------------------------------------
-- Comandos
----------------------------------------------------------------------------
RegisterCommand('pedircnh', function(source, args, rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if args[1] then
		local outroplayer = parseInt(args[1])
		local nplayer = vRP.getUserSource(outroplayer)
		local request_ok = vRP.request(nplayer,"Deseja <b>passar</b> o seu cnh?",30)
		if request_ok then
			if PassosCL.checkCNH(outroplayer) then
				TriggerClientEvent("Notify", player, "sucesso", "O cidadão: ".. outroplayer .." possui a CNH")
			else
				TriggerClientEvent("Notify", player, "negado", "O cidadão: ".. outroplayer .." não possui a CNH")
			end
	    end
	end
end)

RegisterCommand('remcnh', function(source, args, rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if args[1] then
		local outroplayer = parseInt(args[1])
		local nplayer = vRP.getUserSource(outroplayer)
		local request_ok = vRP.request(nplayer,"Deseja <b>remover</b> o cnh do cidadão: ".. outroplayer .." ?",30)
		if request_ok then
			vRP.removeUserGroup(user_id, grupo_cnh)
			TriggerClientEvent("Notify", player, "sucesso", "Você <b>removeu</b> o CNH do cidadão: ".. outroplayer)
	    end
	end
end)

----------------------------------------------------------------------------
-- Funções
----------------------------------------------------------------------------
function PassosCL.comprando()
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	local request_ok = vRP.request(player,"Tem certeza que deseja <b>comprar</b> um cnh por ".. preco .." reais?",30)
	if request_ok then
		if vRP.tryFullPayment(user_id, preco) then
			vRP.addUserGroup(user_id, grupo_cnh)
			TriggerClientEvent("Notify", player, "sucesso", "Você pagou ".. preco .." reais em uma CNH")
		else
			TriggerClientEvent("Notify", player, "negado", "Você não possui dinheiro pra pagar o CNH")
		end
	end
end

function PassosCL.vendendo()
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	local request_ok = vRP.request(player,"Tem certeza que deseja <b>vender</b> o seu cnh por ".. venda_preco .." reais?",30)
	if request_ok then
		vRP.giveBankMoney(user_id, venda_preco)
		vRP.removeUserGroup(user_id, grupo_cnh)
		TriggerClientEvent("Notify", player, "sucesso", "Você vendeu o seu CNH por ".. venda_preco .." reais!")
	end
end

function PassosCL.checkCNH(id)
	local source = source
	local user_id = parseInt(id)
	return vRP.hasGroup(user_id, grupo_cnh)
end