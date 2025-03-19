--Known issues
--1. On some stages, when reverting back from the Land Master Fox cannot move upward.
--2. When changing into Blue sub the lighting can get fucked up

Effect = {
    "CHANGE",         --Change the players form(Arwing, Landmaster, Blue Marine.)
    "DRAIN",          --Slowly drains players HP
    "DRIFT",          --Drifts player to the left slightly
    "FAST",           --Speeds up the player
    "HEAL",           --Slowly heals the players HP
    "INVERT",         --Invert laser aim
    "SLOW",           --Slows down the player
    "SPIN",           --Spins the camera around
}

--Starting values
effect_timer = math.random(1800, 3600)
current_effect = math.random(1, #Effect)
started_change = false

landmaster_levels = {
    PlanetId.PLANET_TITANIA,
    PlanetId.PLANET_MACBETH
}
space_levels = {
    PlanetId.PLANET_METEO,
    PlanetId.PLANET_AREA_6,
    PlanetId.PLANET_BOLSE,
    PlanetId.PLANET_SECTOR_Z,
    PlanetId.PLANET_SECTOR_X,
    PlanetId.PLANET_SECTOR_Y,
    PlanetId.PLANET_SOLAR,
    PlanetId.PLANET_VENOM
}

function CheckPlanet(current_planet, planet_list)
    --Checks if the player is on a given planet
    local is_on_list = false
    for _, value in ipairs(planet_list) do
        if current_planet == value then
            is_on_list = true
            break
        end
    end
    return is_on_list
end

function OnPlayUpdate(ev)
    if ev.player.state == PlayerState.PLAYERSTATE_ACTIVE then
        --Change
        if Effect[current_effect] == Effect[1] then
            if started_change == false then
                if CheckPlanet(Game.sCurrentPlanetId(), space_levels) == true then
                    --Landmaster cannot be used in space levels, we instead will force the form to the Blue Marine
                    ev.player.form = PlayerForm.FORM_BLUE_MARINE
                else
                    --If on a stage that can support all forms, select a random form different from the stages starting form.
                    while true do
                        new_form = math.random(PlayerForm.FORM_ARWING, PlayerForm.FORM_BLUE_MARINE)
                        if new_form != ev.player.form then
                            ev.player.form = new_form
                            break
                        end
                    end
                end
                started_change = true
            else
                --In the event you load into a stage while CHANGE is taken effect
                if Game.gLevelMode() == LevelMode.LEVELMODE_ALL_RANGE and ev.player.form == PlayerForm.FORM_BLUE_MARINE then
                    --Blue marine does not work in all range mode, we cancel the effect early.
                    effect_timer = 1
                elseif CheckPlanet(Game.sCurrentPlanetId(), landmaster_levels) == true then
                    --Only landmaster works as expected in Landmaster stages, we cancel the effect early.
                    effect_timer = 1
                end
            end

        --HP drain
        elseif Effect[current_effect] == Effect[2] and math.random(0, 100) >= 95 then
            ev.player.damage = ev.player.damage + 1

        --Drift
        elseif Effect[current_effect] == Effect[3] and ev.player.pos.x > -1100.0 then
            if ev.player.form == PlayerForm.FORM_ARWING then
                ev.player.pos.x = ev.player.pos.x - 8
            elseif ev.player.form == PlayerForm.FORM_LANDMASTER then
                ev.player.pos.x = ev.player.pos.x - 4
            elseif ev.player.form == PlayerForm.FORM_BLUE_MARINE then
                ev.player.pos.x = ev.player.pos.x - 4
            end

        --Fast mode
        elseif Effect[current_effect] == Effect[4] then
            if Game.gBossActive == true and Game.gLevelMode() != LevelMode.LEVELMODE_ALL_RANGE then
                --Fox can outrun bosses during FAST on non all-range bosses, so we will setup FAST to expire immediately and not execute its effect
                effect_timer = 1
            else
                if ev.player.form == PlayerForm.FORM_ARWING then
                    ev.player.baseSpeed = 80
                elseif ev.player.form == PlayerForm.FORM_LANDMASTER then
                    ev.player.baseSpeed = 40
                elseif ev.player.form == PlayerForm.FORM_BLUE_MARINE then
                    ev.player.baseSpeed = 60
                end
            end

        --HP heal
        elseif Effect[current_effect] == Effect[5] and math.random(0, 100) >= 95 then
            ev.player.heal = ev.player.heal + 1

        --Slow mode
        elseif Effect[current_effect] == Effect[7] then
            ev.player.baseSpeed = 10

        --Spin
        elseif Effect[current_effect] == Effect[8] then
            if ev.player.camRoll >= 360.0 then
                ev.player.camRoll = ev.player.camRoll - 360
            end
            ev.player.camRoll = ev.player.camRoll + 3
        end

        --Effect timer
        effect_timer = effect_timer - 1
        if effect_timer == 0 then
            --Selects a new effect that is different from the current one.
            while true do
                new_effect = math.random(1, #Effect)
                if new_effect != current_effect then
                    current_effect = new_effect
                    break
                end
            end
            --Resets all values affected by effects to the default values, and reverts the players form based on what stage is being played
            ev.player.camRoll = 0.0
            ev.player.baseSpeed = 40
            if CheckPlanet(Game.sCurrentPlanetId(), landmaster_levels) == true then
                ev.player.form = PlayerForm.FORM_LANDMASTER
            elseif Game.sCurrentPlanetId() == PlanetId.PLANET_AQUAS then
                ev.player.form = PlayerForm.FORM_BLUE_MARINE
            else
                ev.player.form = PlayerForm.FORM_ARWING
            end
            started_change = false
            effect_timer = math.random(1800, 3600)
        end
    end
end

RegisterListener(Events.PlayerPreUpdateEvent, OnPlayUpdate, EventPriority.NORMAL)

function OnDisplayUpdate(ev)
    --Draws text showing current effect
    RCP_AutoSetupDL(SetupDL.SETUPDL_75_POINT)
    Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: " .. Effect[current_effect]);
end

RegisterListener(Events.DrawLivesCounterHUDEvent, OnDisplayUpdate, EventPriority.NORMAL)

function OnShotFired(ev)
    --Invert firing
    if Effect[current_effect] == Effect[6] then
        ev.shot.vel.x = -ev.shot.vel.x
        ev.shot.vel.y = -ev.shot.vel.y
    end
end

RegisterListener(Events.PlayerActionPostShootEvent, OnShotFired, EventPriority.NORMAL)
