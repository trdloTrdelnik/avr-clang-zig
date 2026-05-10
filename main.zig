
const DDRC: *volatile u8 = @ptrFromInt(0x07 + 0x20);
const PORTC: *volatile u8 = @ptrFromInt(0x08 + 0x20);
const LED_PIN: u3 = 7;
const F_CPU: u32 = 1_000_000;

fn delayLoop2(count: u16) void {
    var c = count;
    asm volatile (
        \\1: sbiw %[c],1
        \\   brne 1b
        : [c] "=w" (c)
        : [cin] "0" (c)
    );
}

fn delayMs(comptime ms: f64) void {
    comptime var remaining = ms;
    inline while (remaining > 0) {
        const chunk = @min(remaining, 65535.0 / (@as(f64, F_CPU) / 4000.0));
        const ticks: u16 = @intFromFloat((@as(f64, F_CPU) / 4000.0) * chunk);
        delayLoop2(ticks);
        remaining -= chunk;
    }
}

export fn main() void {
    DDRC.* |= (1 << LED_PIN);
    while (true) {
        PORTC.* |= (1 << LED_PIN);
        delayMs(1000);
        PORTC.* &= ~@as(u8, 1 << LED_PIN);
        delayMs(3000);
    }
}
