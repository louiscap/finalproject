--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = 16
    local topperset = 15
    -- insert blank tables into tiles for later access
    for y = 1, height do
        table.insert(tiles, {})
    end
    -- row by row generation
    for y = 1, height do
        --local tileID = TILE_ID_EMPTY
        -- lay out the empty space
        for x = 1, width do
            if y < 8  or (x > 9 and x < 14 ) or (x > 23 and x < 29) then
                table.insert(tiles[y], Tile(x, y, TILE_ID_EMPTY, nil, tileset, topperset))
            else
                table.insert(tiles[y], Tile(x, y, TILE_ID_GROUND, y == 8 and topper or nil, tileset, topperset))
            end
        end
    end
    -- platforms at various places and heights
    --platform_height = 5
    local pf = {{4,8}, {16,17}}
    for i, range in ipairs(pf) do
        local y = 5
        for x = range[1], range[2] do
            tiles[y][x] = Tile(x, y, TILE_ID_GROUND, nil, 53, 104)
        end
    end

    --platform_height = 3
    local pf = {{10,12}, {36,41}}
    for i, range in ipairs(pf) do
        local y = 3
        for x = range[1], range[2] do
            tiles[y][x] = Tile(x, y, TILE_ID_GROUND, nil, 53, 104)
        end
    end

    -- ladder
    local x = 37
    for y = 2,7 do
        table.insert(objects,
            GameObject {
                texture = 'ladders',
                x = (x - 1) * TILE_SIZE,
                y = (y - 1) * TILE_SIZE,
                width = 16,
                height = 16,
                -- make it a preset variant
                frame = 8,
                collidable = true,
                hit = false,
                solid = false,
            }
        )
    end

    -- wall
    for x = 44,46 do
        for y = 3,7 do
            tiles[y][x] = Tile(x, y, TILE_ID_GROUND, nil, 53, 104)
        end
    end

    -- flag
    local pole1 = GameObject {
        texture = 'flags',
        x = (width - 2) * TILE_SIZE,
        y = 4 * TILE_SIZE,
        width = 16,
        height = 16,
        frame = 1,
        collidable = true,
        solid = false }
    table.insert(objects, pole1)

    local pole2 = GameObject {
        texture = 'flags',
        x = (width - 2) * TILE_SIZE,
        y = 5 * TILE_SIZE,
        width = 16,
        height = 16,
        frame = 10,
        collidable = true,
        solid = false }
    table.insert(objects, pole2)

    local pole3 = GameObject {
        texture = 'flags',
        x = (width - 2) * TILE_SIZE,
        y = 6 * TILE_SIZE,
        width = 16,
        height = 16,
        frame = 19,
        collidable = true,
        consumable = false,
        solid = false,
        onCollide= function()
            gSounds['music']:pause()
            gSounds['victory']:play()
        end
        }
    table.insert(objects, pole3)

    table.insert(objects, GameObject {
        texture = 'flags',
        x = (width - 2) * TILE_SIZE + 8,
        y = 4 * TILE_SIZE + 8,
        width = 16,
        height = 16,
        frame = 25,
        collidable = false }
        )

    -- table of xy coords to put jump blocks
    local jb = {{6,2}, {7,2}, {15,5}, {31,5}}
    for i, xy in ipairs(jb) do
        table.insert(objects,
            -- jump block
            GameObject {
                texture = 'jump-blocks',
                x = (xy[1] - 1) * TILE_SIZE,
                y = (xy[2] - 1) * TILE_SIZE,
                width = 16,
                height = 16,
                -- make it a preset variant
                frame = 25,
                collidable = true,
                hit = false,
                solid = true,
                -- collision function takes itself
                onCollide = function(obj)
                    -- spawn a gem if we haven't already hit the block
                    if not obj.hit then
                        -- chance to spawn gem, not guaranteed
                        if math.random(2) == 1 then
                            -- maintain reference so we can set it to nil
                            local coin = GameObject {
                                texture = 'coins',
                                x = (xy[1] - 1) * TILE_SIZE,
                                y = (xy[2] - 1) * TILE_SIZE - 4,
                                width = 16,
                                height = 16,
                                frame = math.random(#COINS),
                                collidable = true,
                                consumable = true,
                                solid = false,
                                -- coin has its own function to add to the player's score
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    player.score = player.score + 100
                                end
                            }
                            -- make the coin move up from the block and play a sound
                            Timer.tween(0.1, {
                                [coin] = {y = (xy[2] - 2) * TILE_SIZE}
                            })
                            gSounds['powerup-reveal']:play()

                            table.insert(objects, coin)
                        end
                        obj.hit = true
                    end
                    gSounds['empty-block']:play()
                end
            }
        )
    end

    -- xy coords to put jump block with mushroom
    local mr = {{18,5}}
    for i, xy in ipairs(mr) do
        table.insert(objects,
            -- jump block
            GameObject {
                texture = 'jump-blocks',
                x = (xy[1] - 1) * TILE_SIZE,
                y = (xy[2] - 1) * TILE_SIZE,
                width = 16,
                height = 16,
                -- make it a preset variant
                frame = 25,
                collidable = true,
                hit = false,
                solid = true,
                -- collision function takes itself
                onCollide = function(obj)
                    -- spawn a gem if we haven't already hit the block
                    if not obj.hit then
                        -- spawn mushroom,  guaranteed
                        if true then
                            -- maintain reference so we can set it to nil
                            local mushroom = GameObject {
                                texture = 'mushrooms',
                                x = (xy[1] - 1) * TILE_SIZE,
                                y = (xy[2] - 1) * TILE_SIZE - 4,
                                width = 16,
                                height = 16,
                                frame = 23,
                                collidable = true,
                                consumable = true,
                                solid = false,
                                -- mushroom gives special powers
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    player.score = player.score + 500
                                    -- change texture, increase speed and jump
                                    player.texture = "blue-alien"
                                    PLAYER_WALK_SPEED = PLAYER_WALK_SPEED * 1.5
                                    PLAYER_JUMP_VELOCITY = PLAYER_JUMP_VELOCITY * 1.3
                                    -- revert back to normal
                                    Timer.after(5, function ()
                                        player.texture = 'green-alien'
                                        PLAYER_WALK_SPEED = PLAYER_WALK_SPEED / 1.5
                                        PLAYER_JUMP_VELOCITY = PLAYER_JUMP_VELOCITY / 1.3
                                        end)
                                end
                            }
                            -- make the gem move up from the block and play a sound
                            Timer.tween(0.1, {
                                [mushroom] = {y = (xy[2] - 2) * TILE_SIZE}
                            })
                            gSounds['powerup-reveal']:play()

                            table.insert(objects, mushroom)
                        end
                        obj.hit = true
                    end
                    gSounds['empty-block']:play()
                end
            }
        )
    end


    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end
