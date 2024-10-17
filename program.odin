package main

import "core:fmt"
import rl "vendor:raylib"

v2 :: struct {
    x,y: int,
}

tileSize:v2 = {64,32}
levelHeight := 16
windowSize:v2 = {1024,860}
targetFps:i32= 60

main :: proc() {
    fmt.println("tesing empty app")
    initGameLoop()
}

initGameLoop :: proc() {
    rl.InitWindow(auto_cast(windowSize.x), auto_cast(windowSize.y), "odin test")
    rl.SetTargetFPS(targetFps)

    defer rl.CloseWindow()
    tileTexture: rl.Texture2D = rl.LoadTexture("./shortTile.png")
    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground({255,190,0,255})
        //Game Loop
        // tile1 := projectToIso(2,2,0)
        // tile2 := projectToIso(3,2,0)
        for x in 20..=30 {
            for y in 2..=12 {
                tilePos := projectToIso(x,y,0)
                renderTile(tilePos, tileTexture)
            }
        }
        // renderTile(tile2, tileTexture)
        rl.EndDrawing()
    }
}

renderTile :: proc(pos:v2, tileTexture:rl.Texture) {
    imageRectangle:rl.Rectangle = {0,0, f32(tileSize.x), f32(tileSize.y + levelHeight)}
    rl.DrawTextureRec(tileTexture, imageRectangle, {f32(pos.x), f32(pos.y)}, rl.WHITE)
}

projectToIso :: proc(isoX,isoY,isoZ: int) -> v2 {
    // sprite.x = (sprite.isoX - sprite.isoY) * _halfTileWidth;
    // sprite.y = (sprite.isoX + sprite.isoY - sprite.isoZ) * _halfTileHeight;
    a := (isoX - isoY) * tileSize.x/2
    b := (isoX + isoY - isoZ) * tileSize.y/2
    return {a,b}
}
