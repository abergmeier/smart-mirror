# Smart Mirror

## Hardware

- Raspberry PI 4 (RPI4)
- Power outlet which gets turned of with lights

# Possible hardware

- PIJuice - possibly wait until has USB-C connector

## Possible software

- Raspberry OS

## Goals

- Average "bootup" in ~1s

## Possible things to try

- Can RPI4 be hibernated
  - No support for hibernation in kernel
- Can RPI4 restore from hibernate
- Is there a Power source/semi-USP that keeps power for a few seconds while notifying RPI4?
  - Seems like PIJuice might be a good choice
- How fast is booting/restoring with RPI4 and NVMe
- Install Wayland/Weston and setup in fullscreen mode
  - Ensure it runs on top of latest Mesa/Vulkan implementation
- Get a Vulkan context from Wayland
- Draw onto Vulkan context with Skia or something equally "simple".
