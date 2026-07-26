-- First-draft canon. Dialogue is kept outside screen code so later rewrites
-- and video replacements do not alter campaign progression.

return {
  prologue = {
    id = "prologue",
    title = "THE NIGHT THE SKY MISSED A BEAT",
    slides = {
      {
        atlas = "prologue", col = 1, row = 1,
        speaker = "NARRATOR",
        text = "Backbeat never slept. Every rooftop, train line, and alley carried a piece of the city's song.",
        duration = 6.5,
      },
      {
        atlas = "prologue", col = 2, row = 1,
        speaker = "NARRATOR",
        text = "Then the Break arrived—a cosmic chord played backwards through every speaker at once.",
        duration = 6.5,
      },
      {
        atlas = "prologue", col = 1, row = 2,
        speaker = "EMERGENCY BROADCAST",
        text = "Pulse Tower offline. Instrument-class invaders assembling. "
          .. "All Resonance-bound citizens: answer the downbeat.",
        duration = 7.0,
      },
      {
        atlas = "prologue", col = 2, row = 2,
        speaker = "JOE",
        text = "The universe wants an encore? Fine. Let's make it loud enough to remember us.",
        duration = 6.5,
      },
    },
  },

  joe_intro = {
    id = "joe_intro",
    title = "JOE  •  THE BACKBEAT",
    slides = {
      {
        atlas = "prologue", col = 2, row = 2,
        speaker = "JOE",
        text = "I know these streets. If the noise wants Backbeat, it comes through me first.",
        duration = 6.0,
      },
      {
        atlas = "prologue", col = 2, row = 1,
        speaker = "LYRA",
        text = "Hold the centre, Joe. I'll chase the signal. Same song, different parts.",
        duration = 6.0,
      },
    },
  },

  lyra_intro = {
    id = "lyra_intro",
    title = "LYRA VEX  •  THE LIVE WIRE",
    slides = {
      {
        atlas = "prologue", col = 2, row = 2,
        speaker = "LYRA",
        text = "Alien robots crashed my favourite rooftop show. I am taking that personally.",
        duration = 6.0,
      },
      {
        atlas = "prologue", col = 2, row = 1,
        speaker = "JOE",
        text = "Fast feet, loud strings. I'll keep the exit open—just try not to steal every spotlight.",
        duration = 6.0,
      },
    },
  },

  stage2_transition = {
    id = "stage2_transition",
    title = "THE FIRST PRESS",
    slides = {
      {
        atlas = "campaign", col = 1, row = 1,
        speaker = "LYRA",
        text = "That record was inside the Baron's core. It isn't music—it is a map pretending to be music.",
        duration = 7.0,
      },
      {
        atlas = "campaign", col = 2, row = 1,
        speaker = "JOE",
        text = "The signal dives below Backbeat. Orbit Line. Closed for years, still broadcasting to the stars.",
        duration = 7.0,
      },
      {
        atlas = "campaign", col = 1, row = 2,
        speaker = "LYRA",
        text = "Then we ride the dead line. Whatever is conducting this invasion is waiting at the last stop.",
        duration = 7.0,
      },
    },
  },

  ending = {
    id = "ending",
    title = "AN ENCORE IN ORBIT",
    slides = {
      {
        atlas = "campaign", col = 2, row = 2,
        speaker = "THE GRAND CONDUCTOR",
        text = "FIRST MOVEMENT: INCOMPLETE. ASSEMBLING THE ORCHESTRA.",
        duration = 7.0,
      },
      {
        atlas = "campaign", col = 2, row = 1,
        speaker = "JOE",
        text = "That was only one piece of it. Good. I was worried the night might end early.",
        duration = 6.0,
      },
      {
        atlas = "campaign", col = 2, row = 2,
        speaker = "LYRA",
        text = "Let it assemble. Next time, we bring the whole city as our backing band.",
        duration = 6.0,
      },
    },
  },
}
