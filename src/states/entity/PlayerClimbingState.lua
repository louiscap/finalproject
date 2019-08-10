--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerClimbingState = Class{__includes = BaseState}

function PlayerClimbingState:init(player)
    self.player = player
    self.animation = Animation {
        frames = {6, 7},
        interval = 0.25
    }
    self.player.currentAnimation = self.animation
end

function PlayerClimbingState:update(dt)
    self.player.currentAnimation:update(dt)
    
    -- prevent climbing down below ground level
    if self.player.y > 5 * self.player.height - 8 then
        self.player.y = 5 * self.player.height - 8
    end
    -- prevent climbing too high
    if self.player.y < 1 * self.player.height - 12 then
        self.player.y = 1 * self.player.height - 12
    end

    -- climbingidle if we're not pressing anything at all
    if not love.keyboard.isDown('up') and not love.keyboard.isDown('down')
            and not love.keyboard.isDown('left') and not love.keyboard.isDown('right') then
        self.player:changeState('climbingidle')
    -- move up or down
    elseif love.keyboard.isDown('up') then
        self.player.y = self.player.y - PLAYER_WALK_SPEED * 0.5 * dt
    elseif love.keyboard.isDown('down') then
        self.player.y = self.player.y + PLAYER_WALK_SPEED * 0.5 * dt
    -- if left or right, then fall off ladder
    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player:changeState('falling')
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player:changeState('falling')
    end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            gSounds['death']:play()
            gStateMachine:change('start')
        end
    end

    if love.keyboard.wasPressed('space') then
        self.player:changeState('jump')
    end

end
