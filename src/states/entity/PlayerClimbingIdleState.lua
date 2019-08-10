--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerClimbingIdleState = Class{__includes = BaseState}

function PlayerClimbingIdleState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {6},
        interval = 1
    }

    self.player.currentAnimation = self.animation
end

function PlayerClimbingIdleState:update(dt)

    -- prevent climbing down below ground level
    if self.player.y > 5 * self.player.height - 8 then
        self.player.y = 5 * self.player.height - 8
    end
    -- prevent climbing too high
    if self.player.y < 1 * self.player.height - 12 then
        self.player.y = 1 * self.player.height - 12
    end

    if love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.player:changeState('climbing')
    end

    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
        self.player:changeState('falling')
    end

    if love.keyboard.wasPressed('space') then
        self.player:changeState('jump')
    end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            gSounds['death']:play()
            gStateMachine:change('start')
        end
    end
end
