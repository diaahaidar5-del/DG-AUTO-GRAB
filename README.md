# DG AUTO GRAB

A Roblox auto-grab script with GUI toggle for "Steal a Brainrot" game.

## Features

✅ **Auto-grab** objects within 20 stud radius  
✅ **Red & Black GUI button** to toggle on/off  
✅ **Instant pickup** - no key press needed  
✅ **Smooth grabbing** with cooldown system  
✅ **Works on character respawn**

## Installation

### Using Loadstring (Recommended)

Copy and paste this into your executor (Delta, Synapse, etc.):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/diaahaidar5-del/DG-AUTO-GRAB/main/DG_AUTO_GRAB.lua"))()
```

### Manual Installation

1. Copy the script from `DG_AUTO_GRAB.lua`
2. Paste into Roblox Studio's Command Bar or LocalScript
3. Run the script

## How to Use

1. Execute the loadstring or run the script
2. A **red button** will appear in the top-left corner
3. Walk near any object (brainrot) within 20 studs
4. Objects automatically get grabbed and attached to your hand
5. Click the button to **toggle GRAB ON/OFF**
6. Button turns **grey** when disabled

## Settings

- **Grab Radius**: 20 studs (change `grabRadius = 20`)
- **Grab Cooldown**: 0.5 seconds (change `grabCooldown = 0.5`)
- **Button Position**: Top-left corner (adjust `Position = UDim2.new(0, 10, 0, 10)`)

## Credits

Created for Steal a Brainrot game

---

**Enjoy! 🎮**
