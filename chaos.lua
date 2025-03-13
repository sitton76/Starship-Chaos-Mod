Effect = {
    CHANGE = 0,         --Change the players form(Arwing, Landmaster, Blue Marine.)
    DRAIN = 1,          --Slowly drains players HP
    DRIFT = 2,          --Drifts player to the left slightly
    FAST = 3,           --Speeds up the player
    HEAL = 4,           --Slowly heals the players HP
    INVERT = 5,         --Invert laser aim
    SLOW = 6,           --Slows down the player
    SPIN = 7,           --Spins the camera around
}

--Starting values
effect_timer = math.random(1800, 3600)
current_effect = math.random(Effect.CHANGE, Effect.SPIN)
started_change = false

function OnPlayUpdate(ev)
    --HP drain
    if current_effect == Effect.DRAIN and math.random(0, 100) >= 95 then
        ev.player.damage = ev.player.damage + 1

    --Drift
    elseif current_effect == Effect.DRIFT and ev.player.pos.x > -1100.0 then
        if ev.player.form == PlayerForm.FORM_ARWING then
            ev.player.pos.x = ev.player.pos.x - 8
        elseif ev.player.form == PlayerForm.FORM_LANDMASTER then
            ev.player.pos.x = ev.player.pos.x - 4
        elseif ev.player.form == PlayerForm.FORM_BLUE_MARINE then
            ev.player.pos.x = ev.player.pos.x - 4
        end

    --Fast mode
    elseif current_effect == Effect.FAST then
        if Game.gBossActive == true and Game.gLevelMode != LevelMode.LEVELMODE_ALL_RANGE then
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

    --Change
    elseif current_effect == Effect.CHANGE then
        if started_change == false then
            if Game.sCurrentPlanetId() == PlanetId.PLANET_TITANIA or Game.sCurrentPlanetId() == PlanetId.PLANET_MACBETH then
                --Landmaster stages don't seem to like other forms, so we instead cancel the form change and set the timer up to expire early.
                effect_timer = 1
            elseif Game.sCurrentPlanetId() == PlanetId.PLANET_METEO or Game.sCurrentPlanetId() == PlanetId.PLANET_SECTOR_X or PlanetId.PLANET_SECTOR_Y or PlanetId.PLANET_SECTOR_Z or PlanetId.PLANET_SOLAR or PlanetId.PLANET_BOLSE or PlanetId.PLANET_AREA_6 then
                --Landmaster cannot be used in space levels, we instead will force the form to the Blue Marine
                ev.player.form = PlayerForm.FORM_BLUE_MARINE
            else
                --If on a stage that can support all forms, select a random form different from the stages starting form.
                while true do
                    new_form = math.random(PlayerForm.FORM_ARWING, PlayerForm.FORM_BLUE_MARINE)
                    if new_form != ev.player.form then
                        ev.player.form = new_form
                        started_change = true
                        break
                    end
                end
            started_change = true
            end
        end

    --HP heal
    elseif current_effect == Effect.HEAL and math.random(0, 100) >= 95 then
        ev.player.heal = ev.player.heal + 1

    --Slow mode
    elseif current_effect == Effect.SLOW then
        ev.player.baseSpeed = 10

    --Spin
    elseif current_effect == Effect.SPIN then
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
            new_effect = math.random(Effect.CHANGE, Effect.SPIN)
            if new_effect != current_effect then
                current_effect = new_effect
                break
            end
        end
        --Resets all values affected by effects to the default values, and reverts the players form based on what stage is being played
        ev.player.camRoll = 0.0
        ev.player.rot.y = 0.0
        ev.player.baseSpeed = 40
        if Game.sCurrentPlanetId() == PlanetId.PLANET_TITANIA or Game.sCurrentPlanetId == PlanetId.PLANET_MACBETH then
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

RegisterListener(Events.PlayerPreUpdateEvent, OnPlayUpdate, EventPriority.NORMAL)

function OnDisplayUpdate(ev)
    --Draws text showing current effect
    RCP_AutoSetupDL(SetupDL.SETUPDL_75_POINT)
    if current_effect == Effect.CHANGE then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: CHANGE");
    elseif current_effect == Effect.DRAIN then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: DRAIN");
    elseif current_effect == Effect.DRIFT then 
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: DRIFT");
    elseif current_effect == Effect.FAST then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: FAST");
    elseif current_effect == Effect.HEAL then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: HEAL");
    elseif current_effect == Effect.INVERT then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: INVERT");
    elseif current_effect == Effect.SLOW then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: SLOW");
    elseif current_effect == Effect.SPIN then
        Graphics_DisplaySmallText(0, 50, 1.0, 1.0, "EFFECT: SPIN");
    end
end

RegisterListener(Events.DrawLivesCounterHUDEvent, OnDisplayUpdate, EventPriority.NORMAL)

function OnShotFired(ev)
    if current_effect == Effect.INVERT then
        ev.shot.vel.x = -ev.shot.vel.x
        ev.shot.vel.y = -ev.shot.vel.y
    end
end

RegisterListener(Events.PlayerActionPostShootEvent, OnShotFired, EventPriority.NORMAL)