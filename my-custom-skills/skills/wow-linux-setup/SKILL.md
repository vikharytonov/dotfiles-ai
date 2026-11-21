---
name: wow-linux-setup
description: >-
  Runbook and instructions for configuring, reviewing, troubleshooting, and updating
  Battle.net and World of Warcraft games (WoW Forever, WoW TBC, Classic, Retail)
  on this PC using Lutris, Wine-TkG, Wine-GE, VKD3D, and DXVK.
---

# World of Warcraft & Battle.net Linux Optimization & Troubleshooting Runbook

## 1. System Hardware & Environment Context
- **Machine:** AMD Ryzen 9 7940HS (8C/16T) + Radeon 780M Graphics (Phoenix RDNA3)
- **Memory & OS:** 64 GB DDR5, Ubuntu 24.04 LTS (Kernel 6.8+, Mesa 25.2+ RADV driver)
- **Wine Prefix:** `/home/vikharitonov/Games/battlenet`
- **Battle.net Executable:** `/home/vikharitonov/Games/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe`
- **Lutris Runners Directory:** `~/.local/share/lutris/runners/wine/`
- **Lutris Config:** `~/.config/lutris/games/battlenet-standard-*.yml`
- **ProtonUp-Qt:** Installed at `~/.local/bin/protonup-qt`
- **Runner Updater Script:** `~/.gemini/config/skills/wow-linux-setup/scripts/update_runner.sh`

---

## 2. Update & Troubleshooting Hierarchy (Order of Operations)

When experiencing crashes, performance drops, or preparing for game updates, **always follow this order from lowest to highest risk**:

1. **Step 1: Check In-Game Settings / API Mode [Lowest Risk]**
   - Toggle between **DirectX 12** and **DirectX 11** in WoW settings (or add `-d3d11` to launch arguments).
   - Ensure **AMD FSR (FidelityFX Super Resolution)** is enabled at 85–90% render scale.
   - *Why first:* Solves 80% of graphical stutters without changing any system software.

2. **Step 2: Update VKD3D / DXVK in Lutris [Low Risk]**
   - In Lutris: Right-click Battle.net → **Configure** → **Runner options**.
   - Check **VKD3D version** (e.g. `v2.14`+) or **DXVK version** (e.g. `v2.4.1` / `v2.5.3`).
   - *Why second:* VKD3D handles DirectX 12 translation independently of Wine. Upgrading it often fixes graphical artifacts or raid frame drops without breaking the Battle.net launcher.

3. **Step 3: Update System GPU Drivers (Mesa / RADV) [Medium Risk]**
   - Ensure Ubuntu's Mesa driver packages are up to date via `apt`:
     ```bash
     sudo apt update && sudo apt install --only-upgrade libgl1-mesa-dri mesa-vulkan-drivers
     ```
   - *Why third:* Keeps the AMD RDNA3 Vulkan pipeline optimized for new game patches.

4. **Step 4: Switch / Update the Wine Runner [Highest Risk]**
   - **Do NOT upgrade Wine unless Steps 1–3 failed, or Battle.net itself refuses to launch.**
   - **First preference:** Try switching between existing, tested local runners:
     * `wine-10.7-staging-tk-x86_64` (Modern high-performance baseline)
     * `wine-ge-8-26-x86_64` (Proven fallback for launcher/crypto issues)
   - **Second preference (Upgrade to latest):** Run the automated script:
     ```bash
     ~/.gemini/config/skills/wow-linux-setup/scripts/update_runner.sh --apply
     ```
   - **Rollback immediately if unstable:**
     ```bash
     ~/.gemini/config/skills/wow-linux-setup/scripts/update_runner.sh --rollback
     ```

---

## 3. Recommended Configuration by Game

### A. WoW: Forever (Modern Engine Client)
* **Graphics API:** DirectX 12 (VKD3D-Proton).
* **Recommended Runner:** `wine-10.7-staging-tk-x86_64` (or latest TkG if verified stable).
* **Lutris Settings:**
  * DXVK: Enabled (`v2.4.1` or `v2.5.3`)
  * VKD3D: Enabled (`v2.14` or newer)
  * Esync / Fsync: Enabled
* **In-Game Settings (Optimal for Radeon 780M):**
  * Resolution: 1080p
  * Graphics Quality: 4 – 5
  * Resample Quality: AMD FSR (Render Scale: 85–90%)
  * Projected Textures: Enabled

### B. WoW: TBC (The Burning Crusade)
* **Client 2.4.3 (Legacy / Private):**
  * Graphics API: DirectX 9 (handled by DXVK).
  * Launch arguments: `-opengl` only if DX9 has issues, but DXVK provides superior framerates.
  * Recommended Runner: `wine-10.7-staging-tk-x86_64` or `wine-ge-8-26-x86_64`.
* **TBC Classic (Modern Battle.net Client):**
  * Follow same settings as WoW Forever (DirectX 12 + VKD3D).

---

## 4. Troubleshooting Runbook

### Issue 1: Battle.net Update Loop or "Agent.exe" Hangs
```bash
# 1. Kill all Wine/Battle.net processes
pkill -9 -f "Battle.net"
pkill -9 -f "Agent.exe"

# 2. Clear corrupted Battle.net cache
rm -rf "/home/vikharitonov/Games/battlenet/drive_c/ProgramData/Battle.net"
rm -rf "/home/vikharitonov/Games/battlenet/drive_c/ProgramData/Blizzard Entertainment"
```

### Issue 2: Black Screen or Flickering in Battle.net Launcher
- Ensure Hardware Acceleration is disabled in launcher settings:
  Edit `/home/vikharitonov/Games/battlenet/drive_c/users/$USER/AppData/Roaming/Battle.net/Battle.net.config`
  Set `"HardwareAcceleration": "false"`.

### Issue 3: Micro-Stutter / Shader Compilation Lag
- Ensure shader disk caching environment variables are present in Lutris game configuration:
  * `__GL_SHADER_DISK_CACHE=1`
  * `__GL_SHADER_DISK_CACHE_PATH=/home/vikharitonov/Games/battlenet`
  * `DXVK_STATE_CACHE_PATH=/home/vikharitonov/Games/battlenet`

### Issue 4: Game Crashes on Launch in DX12 Mode
- Add `-d3d11` to the game's command-line launch arguments in Battle.net launcher settings (Game Settings → Additional command line arguments).
