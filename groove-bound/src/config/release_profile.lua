-- Detects whether the current runtime came from the public release packager.
-- Source checkouts remain development builds; packaged archives include the
-- marker at their root so debug and Admin routes can be disabled centrally.

local ReleaseProfile = {}

ReleaseProfile.MARKER = "release-build.txt"

function ReleaseProfile.detect(file_exists)
  file_exists = file_exists or function(path)
    return love and love.filesystem
      and love.filesystem.getInfo(path, "file") ~= nil
  end
  return {
    is_release = file_exists(ReleaseProfile.MARKER) == true,
    marker = ReleaseProfile.MARKER,
  }
end

function ReleaseProfile.is_release()
  return ReleaseProfile.detect().is_release
end

return ReleaseProfile
