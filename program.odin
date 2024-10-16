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
        isoMPos := projectToIso(int(rl.GetMouseX()), int(rl.GetMouseY()), 0)
        for x in 17..=27 {
            for y in 2..=12 {
                for z in 0..=3 {
                    tilePos := projectToIso(x,y,z)
                    mouseIsoPos := projectFromIso(f32(int(rl.GetMouseX()) - tileSize.x/2), f32(rl.GetMouseY()), z)
                    highlighted: bool = mouseIsoPos.x == x && mouseIsoPos.y == y
                    renderTile(tilePos, tileTexture, highlighted)
                }
            }
        }
        rl.EndDrawing()
    }
}

renderTile :: proc(pos:v2, tileTexture:rl.Texture, highlighted:bool) {
    imageRectangle:rl.Rectangle = {0,0, f32(tileSize.x), f32(tileSize.y + levelHeight)}
    color:rl.Color = highlighted ? rl.SKYBLUE : rl.WHITE
    rl.DrawTextureRec(tileTexture, imageRectangle, {f32(pos.x), f32(pos.y)}, color)
}

projectToIso :: proc(isoX,isoY,isoZ: int) -> v2 {
    a := (isoX - isoY) * tileSize.x/2
    //isoX := a / tilesize.x * 2 + isoY
    //isoY := b * 2 / tilesize.y + isoZ - isoX
    //isoX := a / tilesize.x * 2 + b * 2 / tilesize.y + isoZ - isoX
    b := (isoX + isoY - isoZ) * tileSize.y/2
    return {a,b}
}

projectFromIso :: proc (normalA, normalB: f32, normalZ:int=0) -> v2 {
    isoX := (normalA / f32(tileSize.x) * 2 + normalB * 2 / f32(tileSize.y) + f32(normalZ))/2
    isoY := normalB * 2 / f32(tileSize.y) + f32(normalZ) - isoX
    return {int(isoX), int(isoY)}
}
