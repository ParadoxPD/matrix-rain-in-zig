const std = @import("std");
const raylib = @import("raylib");

var prng = std.Random.DefaultPrng.init(42);
const rand = prng.random();

const Trail: type = struct {
    x: c_int,
    y: c_int,
    fallSpeed: c_int,
    textSize: c_int,
    trailLength: usize,
    textColor: raylib.Color,
    depthView: c_int,
    trail_array: []i32,

    pub fn init(x: c_int, y: c_int, fallSpeed: c_int, textSize: c_int, trailLength: usize, depthView: c_int, textColor: raylib.Color, array: []i32) !Trail {

        //Unsafe Not Freeing the allocator
        const allocator = std.heap.page_allocator;
        const trail_array: []i32 = try allocator.alloc(i32, trailLength);
        // defer allocator.free(trail_array);

        for (0..trailLength) |i| {
            trail_array[i] = array[i];
        }

        return Trail{
            .x = x,
            .y = y,
            .fallSpeed = fallSpeed,
            .textSize = textSize,
            .trailLength = trailLength,
            .depthView = depthView,
            .textColor = textColor,
            .trail_array = trail_array,
        };
    }

    pub fn setX(self: *Trail, x: c_int) void {
        self.x = x;
    }

    pub fn getX(self: *Trail) c_int {
        return self.x;
    }

    pub fn setY(self: *Trail, y: c_int) void {
        self.y = y;
    }

    pub fn getY(self: *Trail) c_int {
        return self.y;
    }

    pub fn setFallSpeed(self: *Trail, fallSpeed: c_int) void {
        self.fallSpeed = fallSpeed;
    }

    pub fn getFallSpeed(self: *Trail) c_int {
        return self.fallSpeed;
    }

    pub fn setTextSize(self: *Trail, textSize: c_int) void {
        self.textSize = textSize;
    }

    pub fn getTextSize(self: *Trail) c_int {
        return self.textSize;
    }
    pub fn setDepth(self: *Trail, depthView: c_int) void {
        self.depthView = depthView;
    }

    pub fn getDepth(self: *Trail) c_int {
        return self.depthView;
    }

    pub fn setTrailLength(self: *Trail, trailLength: c_int) void {
        self.trailLength = trailLength;
    }

    pub fn getTrailLength(self: *Trail) usize {
        return self.trailLength;
    }

    pub fn setTextColor(self: *Trail, textColor: c_int) void {
        self.textColor = textColor;
    }

    pub fn getTextColor(self: *Trail) raylib.Color {
        return self.textColor;
    }

    pub fn getTrailArray(self: *Trail) []i32 {
        return self.trail_array;
    }

    pub fn setTrailArray(self: *Trail, trail_array: []i32) void {
        for (0..self.trailLength) |i| {
            self.trail_array[i] = trail_array[i];
        }
    }
};

var screenWidth: c_int = 1500;
var screenHeight: c_int = 1000;
const windowTitle = "MaTrIX RaIn";
const windowFPS: c_int = 30;
var frameCount: c_int = 0;
const font_path = "assets/dejavu.fnt";
const icon_path = "assets/icon.png";

pub fn main() !void {

    // Initialization
    const backgroundColor = raylib.Color.init(40, 44, 52, 100);
    const textColor = raylib.Color.init(65, 253, 254, 255);
    const textSize: c_int = 30;

    raylib.initWindow(screenWidth, screenHeight, windowTitle);
    defer raylib.closeWindow();

    const display = raylib.getCurrentMonitor();
    screenWidth = raylib.getMonitorWidth(display);
    screenHeight = raylib.getMonitorHeight(display);
    raylib.setWindowSize(screenWidth, screenHeight);
    raylib.toggleFullscreen();

    const image = raylib.Image.init(icon_path);
    raylib.setWindowIcon(image);

    const font = raylib.Font.init(font_path);
    while (!font.isReady()) {}

    raylib.setTargetFPS(windowFPS);

    const numberOfTrails: usize = 500;
    const allocator = std.heap.page_allocator;
    const trails: []Trail = try allocator.alloc(Trail, numberOfTrails);
    defer allocator.free(trails);

    try create_trails(trails, numberOfTrails, textSize, textColor);

    // Main game loop
    while (!raylib.windowShouldClose()) {
        if (raylib.isKeyPressed(raylib.KeyboardKey.key_q)) {
            raylib.toggleFullscreen();
        }
        raylib.clearBackground(backgroundColor);

        raylib.beginDrawing();
        defer raylib.endDrawing();

        try update_trails(trails, numberOfTrails);
        try draw_trails(trails, numberOfTrails, font);

        frameCount = @mod(frameCount, 1000) + 1;
    }

    for (0..numberOfTrails) |i| {
        defer allocator.free(trails[i].trail_array);
    }
}

fn create_trails(trails: []Trail, numberOfTrails: usize, textSize: c_int, textColor: anytype) !void {
    for (0..numberOfTrails) |i| {
        const x_val = rand_range(0, screenWidth);
        const y_val = rand_range(-100, screenHeight);
        const depth = rand_range(0, 4);
        // std.debug.print("{}\n", .{x_val});
        const length = @as(usize, @intCast(rand_range(10, 20)));

        const allocator = std.heap.page_allocator;
        var characters: []i32 = try allocator.alloc(i32, length);
        defer allocator.free(characters);

        for (0..length) |j| {
            characters[j] = get_random_char();
        }
        const trail = try Trail.init(x_val, y_val, rand_range(10, 20), generateDepthBasedTextSize(textSize, depth), length, depth, textColor, characters);
        trails[i] = trail;
    }
}

fn update_trails(trails: []Trail, numberOfTrails: usize) !void {
    for (0..numberOfTrails) |i| {
        var newY: c_int = trails[i].getY() + trails[i].getFallSpeed();
        if ((newY - trails[i].getTextSize() * @as(c_int, @intCast(trails[i].getTrailLength())) > screenHeight) or (trails[i].getX() < 0 or trails[i].getX() > screenWidth)) {
            newY = rand_range(-100, 0);
            // const depth = rand_range(0, 4);
            // trails[i].setTextSize(generateDepthBasedTextSize(30, depth));
            trails[i].setX(rand_range(0, screenWidth));
        }
        trails[i].setY(newY);

        if (@mod(newY, 10) == 0) {
            const length = trails[i].getTrailLength();
            const allocator = std.heap.page_allocator;
            var characters: []i32 = try allocator.alloc(i32, length);
            defer allocator.free(characters);

            for (0..length) |j| {
                characters[j] = get_random_char();
            }
            trails[i].setTrailArray(characters);
        }

        // if (@mod(frameCount, 2) == 0) {
        //     if (trails[i].getX() < @divFloor(screenWidth, 2)) {
        //         trails[i].setX(trails[i].getX() - 1);
        //     } else {
        //         trails[i].setX(trails[i].getX() + 1);
        //     }
        // }
        // if (@mod(frameCount, 10) == 0) {
        //     trails[i].setTextSize(trails[i].getTextSize() + 1);
        // }
    }
}

fn draw_trails(trails: []Trail, numberOfTrails: usize, font: raylib.Font) !void {
    for (0..numberOfTrails) |i| {
        for (0..trails[i].getTrailLength()) |j| {
            const opacity = 1.5 * @as(f32, @floatFromInt(trails[i].getTrailLength() - j)) / @as(f32, @floatFromInt(trails[i].getTrailLength()));
            // const opacity = 1;
            const pos = raylib.Vector2.init(@as(f32, @floatFromInt(trails[i].getX())), @as(f32, @floatFromInt(trails[i].getY() - @as(c_int, @intCast(j)) * trails[i].getTextSize())));
            if (j == 0) {
                raylib.drawTextCodepoint(font, trails[i].trail_array[j], pos, @as(f32, @floatFromInt(trails[i].getTextSize())), raylib.Color.init(1, 253, 251, 255));
            } else {
                raylib.drawTextCodepoint(font, trails[i].trail_array[j], pos, @as(f32, @floatFromInt(trails[i].getTextSize())), trails[i].getTextColor().fade(opacity));
            }
        }
    }
}

fn generateDepthBasedTextSize(textSize: c_int, depth: c_int) c_int {
    const size: c_int = @divFloor(textSize, depth + 1);
    return size;
}

fn rand_range(x: c_int, y: c_int) c_int {
    const num: c_int = rand.intRangeAtMost(c_int, x, y);
    return num;
}

fn get_random_char() i32 {
    return @as(i32, @intCast(rand_range(1, 255)));
}
