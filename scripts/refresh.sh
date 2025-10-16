#!/bin/env bash
pywalfox update
hyprctl reload

pkill -SIGUSR2 waybar
eww open clock
eww reload

makoctl reload
