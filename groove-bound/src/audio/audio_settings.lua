-- Applies the saved audio profile to both streamed music and static SFX.
-- Muting is non-destructive: the three granular mixer values are preserved.

local AudioSettings = {}

function AudioSettings.apply(app)
  local options = app.profile.options
  local master = options.muted and 0 or options.master_volume
  if app.assets then
    app.assets:set_sfx_volume(master * options.sfx_volume)
  end
  if app.music then
    app.music:set_volume(master, options.music_volume)
  end
end

function AudioSettings.set_muted(app, muted)
  app.profile.options.muted = muted == true
  app.save:save(app.profile)
  AudioSettings.apply(app)
  return app.profile.options.muted
end

function AudioSettings.toggle_muted(app)
  return AudioSettings.set_muted(app, not app.profile.options.muted)
end

return AudioSettings
