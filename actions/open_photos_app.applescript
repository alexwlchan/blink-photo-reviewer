#!/usr/bin/env osascript
-- This script brings Photos.app to the front, and opens the selected photo.

on run argv
  if (count of argv) ≠ 1 then
    tell me to error "Usage: open_photos_app.applescript [PHOTO_ID]"
  end if

  tell application "Photos"
    spotlight media item id (item 1 of argv)
    activate
  end tell
end run
