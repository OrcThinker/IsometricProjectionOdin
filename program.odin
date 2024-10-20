package main

import "core:fmt"
import "core:math"
import "core:slice"
import rl "vendor:raylib"

v2 :: struct {
    x,y: int,
}

v3 :: struct {
    x,y,z: int
}

v4 :: struct {
    x,y,z,w: int
}

tileSize:v2 = {64,32}
levelHeight := 16
windowSize:v2 = {1024,860}
targetFps:i32= 60
throttle:i32= 6

main :: proc() {
    fmt.println("tesing empty app")
    initGameLoop()
}

initGameLoop :: proc() {
    rl.InitWindow(auto_cast(windowSize.x), auto_cast(windowSize.y), "odin test")
    rl.SetTargetFPS(targetFps)

    defer rl.CloseWindow()
    tileTexture: rl.Texture2D = rl.LoadTexture("./shortTile.png")
    deletedTiles:[dynamic]v3
    defer delete(deletedTiles)

    ticks:i32= 0

    iterationMin:v3 = {17, 2, 0}
    iterationMax:v3  = {27, 12, 3}
    // 1 column
    // iterationMin:v3 = {17, 2, 0}
    // iterationMax:v3  = {17, 2, 0}
    // alot of tiles
    // iterationMin:v3 = {0, 0, 0}
    // iterationMax:v3  = {40, 40, 1}
    tilesToRender:[dynamic]v3 = prepareTiles(iterationMin,iterationMax)
    fmt.println(len(tilesToRender))


    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground({255,190,0,255})

        ticks = ticks + 1
        if ticks < targetFps/throttle
        {
            ticks = 0
            //Here logic that is not bound to render
        }

        isoMPos := projectToIso(int(rl.GetMouseX()), int(rl.GetMouseY()), 0)
        highlightV3: v3

        for tile in tilesToRender {
            renderTileOnMouseOver(tile.x,tile.y,tile.z, tileTexture, false)
            if isHighlighted(tile.x,tile.y,tile.z, true) {
                highlightV3 = {tile.x,tile.y,tile.z}
            }
        }

        for tile,index in tilesToRender {
            renderTileOnMouseOver(tile.x,tile.y,tile.z, tileTexture, tile == highlightV3)
        }

        //Done post render so that it won't mess with render
        for tile,index in tilesToRender {
            if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && tile == highlightV3{
                fmt.println(index)
                ordered_remove(&tilesToRender, index)
            }
        }

        if rl.IsKeyPressed(rl.KeyboardKey.R) {
            delete(tilesToRender)
            tilesToRender = prepareTiles(iterationMin,iterationMax)
        }

        rl.EndDrawing()
    }
}

prepareTiles :: proc (iterationMin,iterationMax:v3) -> [dynamic]v3 {
    arr :[dynamic]v3
    for x in iterationMin.x..= iterationMax.x {
        for y in iterationMin.y..= iterationMax.y {
            for z in iterationMin.z..= iterationMax.z {
                tile:v3 = {x,y,z}
                append(&arr, tile)
            }
        }
    }
    return arr
}

renderTileOnMouseOver :: proc(x,y,z:int, tileTexture:rl.Texture, shouldRenderHighlighted:bool = false) {
    tilePos := projectToIso(x,y,z)
    renderTile(tilePos, tileTexture, shouldRenderHighlighted)
}

//Could use AABB checking but for now I am simply checking both upper and lower lever for height comparison
isHighlighted :: proc(x,y,z: int, considerLevelHeight: bool) -> bool {
    mouseIsoPos := projectFromIso(f32(int(rl.GetMouseX()) - tileSize.x/2), f32(rl.GetMouseY()), z)
    mouseIsoPosLower := projectFromIso(f32(int(rl.GetMouseX()) - tileSize.x/2), f32(rl.GetMouseY()), z - 1)

    startTileRenderPoint := projectToIso(x,y,z)
    startTileRenderPoint.y = startTileRenderPoint.y + tileSize.y/2

    highlighted: bool = (mouseIsoPos.x == x && mouseIsoPos.y == y) ||
        (mouseIsoPosLower.x == x && mouseIsoPosLower.y == y) ||
        (isInRect({int(rl.GetMouseX()), int(rl.GetMouseY())}, startTileRenderPoint.x, startTileRenderPoint.y, tileSize.x, tileSize.y/2))
    return highlighted
}

isInRect :: proc(point:v2, a,b,width,height:int) -> bool {
    return point.x > a && point.x < a+width &&
        point.y > b && point.y < b + height
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
