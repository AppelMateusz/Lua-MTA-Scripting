local db=dbConnect("sqlite","save.db")
dbExec(db,"CREATE TABLE IF NOT EXISTS `Save` (ID INTEGER, Model INTEGER, owner VARCHAR, c1 INTEGER, c2 INTEGER, c3 INTEGER, c4 INTEGER, c5 INTEGER, c6 INTEGER, tuning VARCHAR, x VARCHAR, y VARCHAR, z VARCHAR, przebieg INTEGER, hp INTEGER, paliwo INTEGER, rot INTEGER, driveType INTEGER, numberOfGears INTEGER, maxVelocity INTEGER, engineAcceleration INTEGER, steeringLock INTEGER, rejka VARCHAR, opis VARCHAR)")




addCommandHandler("save",function(plr)
    dbExec(db,"DELETE FROM `Save`")
    for _,v in ipairs(getElementsByType("vehicle"))do
		if(getElementData(v, "owner")) then
			local owner=getElementData(v,"owner") or false
			local c1,c2,c3,c4,c5,c6=getVehicleColor(v,true)
			local model=getElementModel(v)
			local rejka=getVehiclePlateText(v)
			local id=getElementData(v,"v:id") or math.random(1,10000)
			local hp=getElementHealth(v)
			local opis=getElementData(v,"pojazd_opis") or ""
			local przebieg=getElementData(v,"przeb") or 0
			local paliwo=getElementData(v,"fuel") or 0
			local x1,y1,z1=getElementPosition(v)
			local _,_,rot1=getVehicleRotation(v)
			local x=getElementData(v,"x") or x1
			local y=getElementData(v,"y") or y1
			local z=getElementData(v,"z") or z1
			local rot=getElementData(v,"rot") or rot1
			local hd = getVehicleHandling(v)
			local driveType = hd["driveType"]
			local numberOfGears = hd["numberOfGears"]
			local maxVelocity = hd["maxVelocity"]
			local engineAcceleration = hd["engineAcceleration"]
			local steeringLock = hd["steeringLock"]
			local tuning = toJSON(getVehicleUpgrades(v))
			dbExec(db,"INSERT INTO `Save` (ID,Model,owner,c1,c2,c3,c4,c5,c6,przebieg,hp,paliwo,tuning,x,y,z,rot,driveType,numberOfGears,maxVelocity,engineAcceleration,steeringLock,rejka,opis) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",id,model,owner,c1,c2,c3,c4,c5,c6,przebieg,hp,paliwo,tuning,x,y,z,rot,driveType,numberOfGears,maxVelocity,engineAcceleration,steeringLock,rejka,opis)
		end
	end
end)




addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),function()
    local q=dbQuery(db,"SELECT * FROM `Save`")
    local x=dbPoll(q,-1)
    dbFree(q)
    for _,v in ipairs(x)do
        local car=createVehicle(v.Model,v.x,v.y,v.z)
        setVehicleColor(car,v.c1,v.c2,v.c3,v.c4,v.c5,v.c6)
        setElementData(car,"owner",v.owner)
        setElementData(car,"przeb",v.przebieg)
        setElementData(car,"fuel",v.paliwo)
		setVehiclePlateText(car,v.rejka)
		setElementData(car,"pojazd_opis",v.opis)
        setElementData(car,"v:id",v.ID)
        setElementHealth(car,v.hp)
        setElementData(car,"x",v.x)
        setElementData(car,"y",v.y)
        setElementData(car,"z",v.z)
        setElementData(car,"rot",v.rot)
        setVehicleRotation(car,0,0,v.rot)
        setVehicleHandling(car,"driveType",v.driveType)
        setVehicleHandling(car,"numberOfGears",v.numberOfGears)
        setVehicleHandling(car,"maxVelocity",v.maxVelocity)
        setVehicleHandling(car,"engineAcceleration",v.engineAcceleration)
        setVehicleHandling(car,"steeringLock",v.steeringLock)
        tuning=fromJSON(v.tuning)
        for _,value in ipairs(tuning)do
            addVehicleUpgrade(car,value)
        end
    end
end)

addCommandHandler("kreclicznik",function(plr,cmd,wartoscp)
    if isObjectInACLGroup("user."..getPlayerName(plr),aclGetGroup("Admin")) then
        if not wartoscp then return end
		local auto = getPedOccupiedVehicle (plr)
        setElementData(auto ,"przeb",wartoscp)
        executeCommandHandler("save",plr)
    end
end)

addCommandHandler("stworzauto",function(plr,cmd,model)
    if isObjectInACLGroup("user."..getPlayerName(plr),aclGetGroup("Admin")) then
        if not model then return end
        local x,y,z=getElementPosition(plr)
        local v=createVehicle(model,x,y,z)
        local _,_,rot=getVehicleRotation(v)
        setElementPosition(plr,x,y,z+2)
        setVehicleRotation(plr,0,0,rot)
        setElementData(v,"owner",getAccountName(getPlayerAccount(plr)))
        setElementData(v,"przeb",0)
        executeCommandHandler("save",plr)
    end
end)
    
addCommandHandler("zaparkuj",function(plr)
    if getPedOccupiedVehicle(plr) then
        if getElementData(getPedOccupiedVehicle(plr),"owner")==getAccountName(getPlayerAccount(plr)) then
            local x,y,z=getElementPosition(getPedOccupiedVehicle(plr))
            local _,_,rot1=getVehicleRotation(getPedOccupiedVehicle(plr))
            setElementData(getPedOccupiedVehicle(plr),"x",x)
            setElementData(getPedOccupiedVehicle(plr),"y",y)
            setElementData(getPedOccupiedVehicle(plr),"z",z)
            setElementData(getPedOccupiedVehicle(plr),"rot",rot)
            outputChatBox("*Twój pojazd został zaparkowany.",plr,255,255,255)
            executeCommandHandler("save",plr)
        end
    end
end)
        
        
addCommandHandler("przepiszpojazd",function(plr,cmd,nick)
    if getPedOccupiedVehicle(plr) then
        local kt = getPlayerAccount(plr)
         if getElementData(getPedOccupiedVehicle(plr),"owner")==getAccountName(getPlayerAccount(plr)) then
            local auto=getPedOccupiedVehicle(plr)
            local gracz=getPlayerFromName(nick)
            if not gracz then return outputChatBox("*Nie znaleziono takiego gracza.",plr,255,255,255) end
            setElementData(auto,"owner",getAccountName(getPlayerAccount(nick)))
            executeCommandHandler("save",plr)
            outputChatBox("*Pomyślne przepisanie pojazdu.",plr,255,255,255)
            outputChatBox("*Otrzymujesz pojazd : "..getVehicleName(auto).." od gracza : "..getPlayerName(plr).."!",gracz,255,255,255)
        end
    end
end)

addEventHandler("onVehicleStartEnter",root,function(plr,seat)
    if seat==0 then
        local own=getElementData(source,"owner")
        if own then
		local kontogracza = getAccountName(getPlayerAccount(plr))
			--if isObjectInACLGroup("user."..getPlayerName(plr),aclGetGroup("Admin")) then return end
			if isObjectInACLGroup("user."..(kontogracza),aclGetGroup("Admin")) then return end
				if own~=getAccountName(getPlayerAccount(plr)) then
					cancelEvent()
					outputChatBox("*To auto należy do innego gracza.",plr,255,255,255)
				end
        end
    end
end)

