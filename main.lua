require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.graphics.drawable.*"
import "android.graphics.Color"
import "android.graphics.Typeface"
import "android.media.MediaPlayer"
import "android.net.Uri"
import "android.content.Intent"
import "java.io.File"
import "java.lang.Boolean"

-- Target Background Audio Path
local MUSIC_PATH = "/storage/emulated/0/解说/Tools/yt/sounds/board game menu .mp3"
local mediaPlayer = nil

-- Custom Sound Effect Paths
local SOUND_DOS_DEDOS_ABAJO = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/dos dedos abajo.ogg"
local SOUND_DIALOGO = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/Diálogo.ogg"
local SOUND_DERECHA_IZQUIERDA = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/derecha izquierda.ogg"
local SOUND_CUADRO_DIALOGO = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/cuadro de diálogo.ogg"
local SOUND_CAMBIO_VENTANA = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/cambio de ventana.mp3"
local SOUND_ARRIBA_ABAJO = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/arriba abajo.mp3"
local SOUND_DOS_DEDOS_ARRIBA = "/storage/emulated/0/解说/Tools/dcs studio hub/sounds/2 dedos arriba.ogg"

-- Shared Preferences for Persistence
local sp = activity.getPreferences(0)
local isFirstRun = sp.getBoolean("welcome_seen", true)
local userCoins = sp.getInt("user_coins", 1000)
local selectedCar = sp.getString("selected_car", "Street Cruiser")

-- Interactive Race Variables
local raceTargetKM = 0
local currentRaceMeters = 0
local targetRaceMeters = 0
local currentRaceBet = 0
local carHealth = 100
local currentHazard = "NONE" -- "LEFT_CURVE", "RIGHT_CURVE", "OBSTACLE", "NONE"

-- Color Palette Definitions
local COLOR_BG = Color.parseColor("#FFF8E1")
local COLOR_PRIMARY = Color.parseColor("#FF6F00")
local COLOR_ACCENT = Color.parseColor("#4CAF50")
local COLOR_SECONDARY = Color.parseColor("#0288D1")
local COLOR_DANGER = Color.parseColor("#E53935")
local COLOR_TEXT = Color.parseColor("#3E2723")
local COLOR_INPUT_BG = Color.parseColor("#E0E0E0")
local COLOR_WHITE = Color.parseColor("#FFFFFF")

-- Button Specific Colors for Links
local COLOR_WA_GROUP = Color.parseColor("#25D366")
local COLOR_WA_CHANNEL = Color.parseColor("#0288D1")
local COLOR_WA_DEV = Color.parseColor("#FF6F00")

-- Helper function to generate rounded drawables
function createRoundedDrawable(color, radius)
  local drawable = GradientDrawable()
  drawable.setColor(color)
  drawable.setCornerRadius(radius)
  return drawable
end

-- Sound Effect Player Helper
function playEffectSound(filePath)
  pcall(function()
    local soundFile = File(filePath)
    if soundFile.exists() then
      local fxPlayer = MediaPlayer.create(activity, Uri.fromFile(soundFile))
      if fxPlayer ~= nil then
        fxPlayer.start()
        fxPlayer.setOnCompletionListener(luajava.createProxy("android.media.MediaPlayer$OnCompletionListener", {
          onCompletion = function(mp)
            mp.release()
          end
        }))
      end
    end
  end)
end

-- Background music controller
function playBackgroundMusic()
  if mediaPlayer == nil then
    local musicFile = File(MUSIC_PATH)
    if musicFile.exists() then
      local fileUri = Uri.fromFile(musicFile)
      mediaPlayer = MediaPlayer.create(activity, fileUri)
      
      if mediaPlayer ~= nil then
        pcall(function() mediaPlayer.setLooping(Boolean.TRUE) end)
        pcall(function() mediaPlayer.setLooping(true) end)
        pcall(function() mediaPlayer.start() end)
      end
    end
  end
end

-- Stop music controller
function stopMusic()
  if mediaPlayer ~= nil then
    pcall(function()
      if mediaPlayer.isPlaying() then mediaPlayer.stop() end
    end)
    pcall(function() mediaPlayer.release() end)
    mediaPlayer = nil
  end
end

-- App Layout Container
layout = {
  LinearLayout,
  layout_width = "fill",
  layout_height = "fill",
  orientation = "vertical",
  backgroundColor = COLOR_BG,
  gravity = "center",
  padding = "16dp",

  -- PAGE 1: Welcome Screen
  {
    LinearLayout,
    id = "welcomeContainer",
    layout_width = "fill",
    layout_height = "wrap",
    orientation = "vertical",
    gravity = "center",
    visibility = isFirstRun and View.VISIBLE or View.GONE,

    {
      TextView,
      id = "tvWelcome",
      text = "Welcome To DCS Studios",
      textSize = "26sp",
      textColor = COLOR_PRIMARY,
      gravity = "center",
      contentDescription = "Welcome To DCS Studios heading",
      layout_marginBottom = "32dp"
    },
    {
      Button,
      id = "btnWelcomeNext",
      text = "NEXT",
      textSize = "18sp",
      textColor = COLOR_WHITE,
      layout_width = "200dp",
      layout_height = "55dp",
      contentDescription = "Next button, double tap to open name entry screen"
    }
  },

  -- PAGE 2: Name Input Screen
  {
    LinearLayout,
    id = "nameContainer",
    layout_width = "fill",
    layout_height = "wrap",
    orientation = "vertical",
    gravity = "center",
    visibility = View.GONE,

    {
      TextView,
      id = "tvEnterName",
      text = "Enter Your Name",
      textSize = "22sp",
      textColor = COLOR_PRIMARY,
      gravity = "center",
      contentDescription = "Enter your name heading",
      layout_marginBottom = "16dp"
    },
    {
      EditText,
      id = "etName",
      hint = "Type or generate name...",
      textSize = "16sp",
      textColor = COLOR_TEXT,
      layout_width = "fill",
      layout_height = "50dp",
      padding = "12dp",
      contentDescription = "Text box to enter your name",
      layout_marginBottom = "16dp"
    },
    {
      Button,
      id = "btnGenerate",
      text = "Generate Random Name",
      textSize = "16sp",
      textColor = COLOR_WHITE,
      layout_width = "fill",
      layout_height = "55dp",
      contentDescription = "Generate random name button, double tap to fill name",
      layout_marginBottom = "16dp"
    },
    {
      Button,
      id = "btnNameNext",
      text = "NEXT",
      textSize = "18sp",
      textColor = COLOR_WHITE,
      layout_width = "200dp",
      layout_height = "55dp",
      contentDescription = "Next button, double tap to enter main hub"
    }
  },

  -- PAGE 3: Main Tool Hub Screen
  {
    ScrollView,
    id = "hubContainer",
    layout_width = "fill",
    layout_height = "fill",
    visibility = (not isFirstRun) and View.VISIBLE or View.GONE,

    {
      LinearLayout,
      layout_width = "fill",
      layout_height = "wrap",
      orientation = "vertical",
      gravity = "center",
      padding = "10dp",

      {
        TextView,
        id = "tvHubHeading",
        text = "DCS Studios Hub",
        textSize = "26sp",
        textColor = COLOR_PRIMARY,
        gravity = "center",
        contentDescription = "DCS Studios Hub heading",
        layout_marginBottom = "12dp"
      },
      {
        TextView,
        id = "tvCoinDisplay",
        text = "Coins: " .. tostring(userCoins),
        textSize = "20sp",
        textColor = COLOR_ACCENT,
        gravity = "center",
        contentDescription = "Current total coins",
        layout_marginBottom = "16dp"
      },
      {
        Button,
        id = "btnWatchAd",
        text = "📺 Watch Ad (+3 Coins)",
        textSize = "16sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "50dp",
        contentDescription = "Watch advertisement button to earn 3 coins. Limit 10 per hour.",
        layout_marginBottom = "12dp"
      },
      {
        Button,
        id = "btnMoreOptions",
        text = "🏬 Car Showroom & Shop",
        textSize = "16sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "50dp",
        contentDescription = "Car showroom and shop button",
        layout_marginBottom = "12dp"
      },
      {
        Button,
        id = "btnGamesHub",
        text = "🎮 Games Hub",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Games Hub button",
        layout_marginBottom = "12dp"
      },
      {
        Button,
        id = "btnToolsHub",
        text = "🛠️ Tools & Features Hub",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Tools and features hub button",
        layout_marginBottom = "24dp"
      },
      {
        LinearLayout,
        layout_width = "fill",
        layout_height = "wrap",
        orientation = "horizontal",
        gravity = "center",

        {
          Button,
          id = "btnAbout",
          text = "About",
          textSize = "16sp",
          textColor = COLOR_WHITE,
          layout_width = "0dp",
          layout_weight = "1",
          layout_height = "50dp",
          layout_marginRight = "8dp",
          contentDescription = "About application button"
        },
        {
          Button,
          id = "btnExit",
          text = "Exit",
          textSize = "16sp",
          textColor = COLOR_WHITE,
          layout_width = "0dp",
          layout_weight = "1",
          layout_height = "50dp",
          layout_marginLeft = "8dp",
          contentDescription = "Exit application button"
        }
      }
    }
  },

  -- PAGE 4: Games Sub-Menu Screen
  {
    LinearLayout,
    id = "gamesContainer",
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    gravity = "center",
    visibility = View.GONE,

    {
      TextView,
      id = "tvGamesHeading",
      text = "Games Hub",
      textSize = "24sp",
      textColor = COLOR_PRIMARY,
      gravity = "center",
      contentDescription = "Games Hub heading",
      layout_marginBottom = "24dp"
    },
    {
      Button,
      id = "btnCarRacing",
      text = "🏎️ 1. Real Car Racing Game",
      textSize = "18sp",
      textColor = COLOR_WHITE,
      layout_width = "fill",
      layout_height = "55dp",
      contentDescription = "Real Car Racing Game option button",
      layout_marginBottom = "16dp"
    },
    {
      Button,
      id = "btnGamesBack",
      text = "Back to Main Hub",
      textSize = "16sp",
      textColor = COLOR_WHITE,
      layout_width = "200dp",
      layout_height = "50dp",
      contentDescription = "Back to main hub button"
    }
  },

  -- PAGE 5: Car Racing Setup Screen
  {
    ScrollView,
    id = "raceSetupContainer",
    layout_width = "fill",
    layout_height = "fill",
    visibility = View.GONE,

    {
      LinearLayout,
      layout_width = "fill",
      layout_height = "wrap",
      orientation = "vertical",
      gravity = "center",
      padding = "10dp",

      {
        TextView,
        id = "tvRaceHeading",
        text = "Car Racing Game Setup",
        textSize = "24sp",
        textColor = COLOR_PRIMARY,
        gravity = "center",
        contentDescription = "Car Racing Game setup heading",
        layout_marginBottom = "16dp"
      },
      {
        TextView,
        id = "tvSelectedCarInfo",
        text = "Active Car: " .. selectedCar,
        textSize = "16sp",
        textColor = COLOR_SECONDARY,
        gravity = "center",
        contentDescription = "Currently active racing car",
        layout_marginBottom = "20dp"
      },
      {
        TextView,
        text = "Select Race Distance (KM):",
        textSize = "16sp",
        textColor = COLOR_TEXT,
        gravity = "left",
        layout_width = "fill",
        layout_marginBottom = "8dp"
      },
      {
        EditText,
        id = "etRaceKM",
        hint = "Enter KM (e.g. 2)",
        textSize = "16sp",
        textColor = COLOR_TEXT,
        inputType = "number",
        layout_width = "fill",
        layout_height = "50dp",
        padding = "12dp",
        contentDescription = "Input text box for race kilometer distance",
        layout_marginBottom = "16dp"
      },
      {
        TextView,
        text = "Place Coin Bet (Optional):",
        textSize = "16sp",
        textColor = COLOR_TEXT,
        gravity = "left",
        layout_width = "fill",
        layout_marginBottom = "8dp"
      },
      {
        EditText,
        id = "etBetCoins",
        hint = "Enter coins to bet (0 for free)",
        textSize = "16sp",
        textColor = COLOR_TEXT,
        inputType = "number",
        layout_width = "fill",
        layout_height = "50dp",
        padding = "12dp",
        contentDescription = "Input text box for coin betting amount",
        layout_marginBottom = "20dp"
      },
      {
        Button,
        id = "btnStartRace",
        text = "🚀 START CAR & RACE",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Start car and race button, double tap to start manual race",
        layout_marginBottom = "16dp"
      },
      {
        Button,
        id = "btnRaceBack",
        text = "Back to Games Hub",
        textSize = "16sp",
        textColor = COLOR_WHITE,
        layout_width = "200dp",
        layout_height = "50dp",
        contentDescription = "Back to games menu button"
      }
    }
  },

  -- PAGE 6: Interactive Live Racing Game Screen
  {
    ScrollView,
    id = "activeRaceContainer",
    layout_width = "fill",
    layout_height = "fill",
    visibility = View.GONE,

    {
      LinearLayout,
      layout_width = "fill",
      layout_height = "wrap",
      orientation = "vertical",
      gravity = "center",
      padding = "10dp",

      {
        TextView,
        id = "tvLiveRaceTitle",
        text = "🏁 Race in Progress!",
        textSize = "22sp",
        textColor = COLOR_PRIMARY,
        gravity = "center",
        contentDescription = "Race in progress heading",
        layout_marginBottom = "12dp"
      },
      {
        TextView,
        id = "tvLiveDistance",
        text = "Distance: 0 / 0 Meters",
        textSize = "18sp",
        textColor = COLOR_TEXT,
        gravity = "center",
        contentDescription = "Distance progress meter",
        layout_marginBottom = "8dp"
      },
      {
        TextView,
        id = "tvLiveHealth",
        text = "Car Durability: 100%",
        textSize = "16sp",
        textColor = COLOR_ACCENT,
        gravity = "center",
        contentDescription = "Car health durability percentage",
        layout_marginBottom = "8dp"
      },
      {
        TextView,
        id = "tvLiveHazard",
        text = "Road Condition: Clear Track",
        textSize = "18sp",
        textColor = COLOR_SECONDARY,
        gravity = "center",
        contentDescription = "Road condition and upcoming obstacles",
        layout_marginBottom = "20dp"
      },

      -- Interactive Control Buttons ("Justices" / Gestures)
      {
        Button,
        id = "btnRaceAccel",
        text = "⬆️ ACCELERATE / SPEED UP",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "60dp",
        contentDescription = "Accelerate speed up gesture control button",
        layout_marginBottom = "12dp"
      },
      {
        LinearLayout,
        layout_width = "fill",
        layout_height = "wrap",
        orientation = "horizontal",
        gravity = "center",
        layout_marginBottom = "12dp",

        {
          Button,
          id = "btnRaceLeft",
          text = "⬅️ STEER LEFT",
          textSize = "16sp",
          textColor = COLOR_WHITE,
          layout_width = "0dp",
          layout_weight = "1",
          layout_height = "55dp",
          layout_marginRight = "6dp",
          contentDescription = "Steer left dodge gesture control button"
        },
        {
          Button,
          id = "btnRaceRight",
          text = "STEER RIGHT ➡️",
          textSize = "16sp",
          textColor = COLOR_WHITE,
          layout_width = "0dp",
          layout_weight = "1",
          layout_height = "55dp",
          layout_marginLeft = "6dp",
          contentDescription = "Steer right dodge gesture control button"
        }
      },
      {
        Button,
        id = "btnRaceBrake",
        text = "⬇️ BRAKE / SLOW DOWN",
        textSize = "16sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Brake and slow down gesture control button",
        layout_marginBottom = "20dp"
      },
      {
        Button,
        id = "btnQuitRace",
        text = "Forfeit Race",
        textSize = "14sp",
        textColor = COLOR_WHITE,
        layout_width = "180dp",
        layout_height = "45dp",
        contentDescription = "Forfeit race button"
      }
    }
  },

  -- PAGE 7: Tools Sub-Menu Screen
  {
    LinearLayout,
    id = "toolsContainer",
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    gravity = "center",
    visibility = View.GONE,

    {
      TextView,
      id = "tvToolsHeading",
      text = "Tools & Features",
      textSize = "24sp",
      textColor = COLOR_PRIMARY,
      gravity = "center",
      contentDescription = "Tools and Features heading",
      layout_marginBottom = "24dp"
    },
    {
      Button,
      id = "btnNotepad",
      text = "📝 1. Notepad",
      textSize = "18sp",
      textColor = COLOR_WHITE,
      layout_width = "fill",
      layout_height = "55dp",
      contentDescription = "Notepad feature button",
      layout_marginBottom = "16dp"
    },
    {
      Button,
      id = "btnToolsBack",
      text = "Back to Main Hub",
      textSize = "16sp",
      textColor = COLOR_WHITE,
      layout_width = "200dp",
      layout_height = "50dp",
      contentDescription = "Back to main hub button"
    }
  },

  -- PAGE 8: Notepad Screen
  {
    ScrollView,
    id = "notepadContainer",
    layout_width = "fill",
    layout_height = "fill",
    visibility = View.GONE,

    {
      LinearLayout,
      layout_width = "fill",
      layout_height = "wrap",
      orientation = "vertical",
      gravity = "center",
      padding = "10dp",

      {
        TextView,
        id = "tvNotepadHeading",
        text = "My Notepad",
        textSize = "24sp",
        textColor = COLOR_PRIMARY,
        gravity = "center",
        contentDescription = "My Notepad heading",
        layout_marginBottom = "20dp"
      },
      {
        EditText,
        id = "etNoteTitle",
        hint = "Title your note",
        textSize = "16sp",
        textColor = COLOR_TEXT,
        layout_width = "fill",
        layout_height = "50dp",
        padding = "12dp",
        contentDescription = "Text box to title your note",
        layout_marginBottom = "16dp"
      },
      {
        EditText,
        id = "etNoteContent",
        hint = "Enter note message...",
        textSize = "16sp",
        textColor = COLOR_TEXT,
        layout_width = "fill",
        layout_height = "120dp",
        gravity = "top|left",
        padding = "12dp",
        contentDescription = "Text box to enter note message",
        layout_marginBottom = "20dp"
      },
      {
        Button,
        id = "btnSaveNote",
        text = "Save Note",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Save note button",
        layout_marginBottom = "16dp"
      },
      {
        Button,
        id = "btnViewNotes",
        text = "View Saved Notes",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "View saved notes button",
        layout_marginBottom = "20dp"
      },
      {
        Button,
        id = "btnNotepadBack",
        text = "Back to Tools",
        textSize = "16sp",
        textColor = COLOR_WHITE,
        layout_width = "200dp",
        layout_height = "50dp",
        contentDescription = "Back to tools menu button"
      }
    }
  }
}

-- Render layout
activity.setContentView(loadlayout(layout))

-- Typography Application
tvWelcome.setTypeface(Typeface.DEFAULT_BOLD)
btnWelcomeNext.setTypeface(Typeface.DEFAULT_BOLD)
tvEnterName.setTypeface(Typeface.DEFAULT_BOLD)
btnGenerate.setTypeface(Typeface.DEFAULT_BOLD)
btnNameNext.setTypeface(Typeface.DEFAULT_BOLD)
tvHubHeading.setTypeface(Typeface.DEFAULT_BOLD)
tvCoinDisplay.setTypeface(Typeface.DEFAULT_BOLD)
btnWatchAd.setTypeface(Typeface.DEFAULT_BOLD)
btnMoreOptions.setTypeface(Typeface.DEFAULT_BOLD)
btnGamesHub.setTypeface(Typeface.DEFAULT_BOLD)
btnToolsHub.setTypeface(Typeface.DEFAULT_BOLD)
btnAbout.setTypeface(Typeface.DEFAULT_BOLD)
btnExit.setTypeface(Typeface.DEFAULT_BOLD)

tvGamesHeading.setTypeface(Typeface.DEFAULT_BOLD)
btnCarRacing.setTypeface(Typeface.DEFAULT_BOLD)
btnGamesBack.setTypeface(Typeface.DEFAULT_BOLD)

tvRaceHeading.setTypeface(Typeface.DEFAULT_BOLD)
tvSelectedCarInfo.setTypeface(Typeface.DEFAULT_BOLD)
btnStartRace.setTypeface(Typeface.DEFAULT_BOLD)
btnRaceBack.setTypeface(Typeface.DEFAULT_BOLD)

tvLiveRaceTitle.setTypeface(Typeface.DEFAULT_BOLD)
btnRaceAccel.setTypeface(Typeface.DEFAULT_BOLD)
btnRaceLeft.setTypeface(Typeface.DEFAULT_BOLD)
btnRaceRight.setTypeface(Typeface.DEFAULT_BOLD)
btnRaceBrake.setTypeface(Typeface.DEFAULT_BOLD)

tvToolsHeading.setTypeface(Typeface.DEFAULT_BOLD)
btnNotepad.setTypeface(Typeface.DEFAULT_BOLD)
btnToolsBack.setTypeface(Typeface.DEFAULT_BOLD)

tvNotepadHeading.setTypeface(Typeface.DEFAULT_BOLD)
btnSaveNote.setTypeface(Typeface.DEFAULT_BOLD)
btnViewNotes.setTypeface(Typeface.DEFAULT_BOLD)
btnNotepadBack.setTypeface(Typeface.DEFAULT_BOLD)

-- Apply Rounded Backgrounds
btnWelcomeNext.setBackground(createRoundedDrawable(COLOR_PRIMARY, 40))
etName.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 20))
btnGenerate.setBackground(createRoundedDrawable(COLOR_ACCENT, 40))
btnNameNext.setBackground(createRoundedDrawable(COLOR_PRIMARY, 40))

btnWatchAd.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnMoreOptions.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))
btnGamesHub.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnToolsHub.setBackground(createRoundedDrawable(COLOR_PRIMARY, 30))
btnAbout.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))
btnExit.setBackground(createRoundedDrawable(COLOR_DANGER, 30))

btnCarRacing.setBackground(createRoundedDrawable(COLOR_PRIMARY, 30))
btnGamesBack.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))

etRaceKM.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 15))
etBetCoins.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 15))
btnStartRace.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnRaceBack.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))

btnRaceAccel.setBackground(createRoundedDrawable(COLOR_ACCENT, 25))
btnRaceLeft.setBackground(createRoundedDrawable(COLOR_SECONDARY, 25))
btnRaceRight.setBackground(createRoundedDrawable(COLOR_SECONDARY, 25))
btnRaceBrake.setBackground(createRoundedDrawable(COLOR_DANGER, 25))
btnQuitRace.setBackground(createRoundedDrawable(COLOR_DANGER, 20))

btnNotepad.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnToolsBack.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))

etNoteTitle.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 15))
etNoteContent.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 15))
btnSaveNote.setBackground(createRoundedDrawable(COLOR_PRIMARY, 30))
btnViewNotes.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnNotepadBack.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))

-- Auto-play background music if on Hub
if (not isFirstRun) then
  playBackgroundMusic()
end

math.randomseed(os.time())

--- Helper: Update Interactive Race Screen ---
function updateLiveRaceUI()
  tvLiveDistance.setText("Distance: " .. tostring(currentRaceMeters) .. " / " .. tostring(targetRaceMeters) .. " Meters")
  tvLiveHealth.setText("Car Durability: " .. tostring(carHealth) .. "%")
  
  if currentHazard == "LEFT_CURVE" then
    tvLiveHazard.setText("⚠️ Warning: Sharp Left Curve ahead! (Use STEER LEFT or BRAKE)")
  elseif currentHazard == "RIGHT_CURVE" then
    tvLiveHazard.setText("⚠️ Warning: Sharp Right Curve ahead! (Use STEER RIGHT or BRAKE)")
  elseif currentHazard == "OBSTACLE" then
    tvLiveHazard.setText("🚧 Warning: Road Block Obstacle ahead! (Use BRAKE immediately!)")
  else
    tvLiveHazard.setText("🟢 Road Condition: Clear Track! Accelerate freely.")
  end
end

--- Helper: Generate Next Hazard ---
function generateNextHazard()
  local rand = math.random(1, 100)
  if rand > 70 then
    currentHazard = "LEFT_CURVE"
  elseif rand > 40 then
    currentHazard = "RIGHT_CURVE"
  elseif rand > 25 then
    currentHazard = "OBSTACLE"
  else
    currentHazard = "NONE"
  end
end

--- Helper: Check Race Victory or Defeat ---
function checkRaceStatus()
  if carHealth <= 0 then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    userCoins = userCoins - currentRaceBet
    if userCoins < 0 then userCoins = 0 end
    sp.edit().putInt("user_coins", userCoins).commit()
    tvCoinDisplay.setText("Coins: " .. tostring(userCoins))

    activeRaceContainer.setVisibility(View.GONE)
    raceSetupContainer.setVisibility(View.VISIBLE)
    playBackgroundMusic()

    AlertDialog.Builder(activity)
      .setTitle("💥 Car Crashed!")
      .setMessage("Your car crashed due to damage!\n\nLost: -" .. tostring(currentRaceBet) .. " Coins!")
      .setPositiveButton("Try Again", nil)
      .show()
    return
  end

  if currentRaceMeters >= targetRaceMeters then
    playEffectSound(SOUND_DOS_DEDOS_ARRIBA)
    userCoins = userCoins + currentRaceBet
    sp.edit().putInt("user_coins", userCoins).commit()
    tvCoinDisplay.setText("Coins: " .. tostring(userCoins))

    activeRaceContainer.setVisibility(View.GONE)
    raceSetupContainer.setVisibility(View.VISIBLE)
    playBackgroundMusic()

    AlertDialog.Builder(activity)
      .setTitle("🏆 Race Victory!")
      .setMessage("Congratulations! You completed the " .. tostring(raceTargetKM) .. " KM race with your " .. selectedCar .. "!\n\nWon: +" .. tostring(currentRaceBet) .. " Coins!")
      .setPositiveButton("Awesome", nil)
      .show()
    return
  end
end

--- Event Handlers ---

btnWelcomeNext.onClick = function()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  welcomeContainer.setVisibility(View.GONE)
  nameContainer.setVisibility(View.VISIBLE)
  tvEnterName.requestFocus()
end

btnGenerate.onClick = function()
  playEffectSound(SOUND_DOS_DEDOS_ABAJO)
  local coolNames = {"ShadowKnight", "CyberDragon", "VortexHero", "BlazeRider", "DCS_Legend"}
  local selectedName = coolNames[math.random(1, #coolNames)]
  etName.setText(selectedName)
  Toast.makeText(activity, "Generated: " .. selectedName, Toast.LENGTH_SHORT).show()
end

btnNameNext.onClick = function()
  local userName = tostring(etName.getText())
  if userName == "" then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    Toast.makeText(activity, "Please enter or generate a name first!", Toast.LENGTH_SHORT).show()
    return
  end
  
  sp.edit().putBoolean("welcome_seen", false).commit()
  nameContainer.setVisibility(View.GONE)
  hubContainer.setVisibility(View.VISIBLE)
  playBackgroundMusic()
  playEffectSound(SOUND_DOS_DEDOS_ARRIBA)
end

-- Watch Ad System (3 Coins per Ad, 10 Ads limit per hour)
btnWatchAd.onClick = function()
  local currentTime = os.time()
  local lastWindowStart = sp.getLong("ad_window_start", 0)
  local currentAdCount = sp.getInt("ad_count", 0)

  -- Check if 1 hour (3600 seconds) has elapsed to reset window
  if (currentTime - lastWindowStart) >= 3600 then
    lastWindowStart = currentTime
    currentAdCount = 0
    sp.edit().putLong("ad_window_start", currentTime).putInt("ad_count", 0).commit()
  end

  if currentAdCount < 10 then
    currentAdCount = currentAdCount + 1
    userCoins = userCoins + 3
    sp.edit().putInt("user_coins", userCoins).putInt("ad_count", currentAdCount).putLong("ad_window_start", lastWindowStart).commit()

    tvCoinDisplay.setText("Coins: " .. tostring(userCoins))
    playEffectSound(SOUND_DOS_DEDOS_ARRIBA)

    AlertDialog.Builder(activity)
      .setTitle("📺 Ad Finished!")
      .setMessage("You watched an ad and earned +3 Coins!\n\nAds watched this hour: " .. tostring(currentAdCount) .. "/10")
      .setPositiveButton("Claim Coins", nil)
      .show()
  else
    playEffectSound(SOUND_CUADRO_DIALOGO)
    local secondsLeft = 3600 - (currentTime - lastWindowStart)
    local minutesLeft = math.ceil(secondsLeft / 60)

    AlertDialog.Builder(activity)
      .setTitle("⏰ Hourly Limit Reached")
      .setMessage("You have reached your limit of 10 ads per hour.\n\nPlease wait " .. tostring(minutesLeft) .. " minute(s) to watch more ads.")
      .setPositiveButton("OK", nil)
      .show()
  end
end

-- More Options & Showroom Shop Handler
btnMoreOptions.onClick = function()
  stopMusic()
  playEffectSound(SOUND_DIALOGO)

  local shopOptions = {
    "🚗 1. Street Cruiser (Free - Owned)",
    "🏎️ 2. Phantom GT (Cost: 500 Coins) - +15 Speed",
    "⚡ 3. Vortex Beast (Cost: 1500 Coins) - +35 Speed"
  }

  AlertDialog.Builder(activity)
    .setTitle("Car Showroom & Shop (Coins: " .. tostring(userCoins) .. ")")
    .setItems(shopOptions, {
      onClick = function(dialog, which)
        playEffectSound(SOUND_DERECHA_IZQUIERDA)
        if which == 0 then
          selectedCar = "Street Cruiser"
          sp.edit().putString("selected_car", selectedCar).commit()
          tvSelectedCarInfo.setText("Active Car: " .. selectedCar)
          Toast.makeText(activity, "Equipped Street Cruiser!", Toast.LENGTH_SHORT).show()
        elseif which == 1 then
          if sp.getBoolean("car_phantom", false) or userCoins >= 500 then
            if not sp.getBoolean("car_phantom", false) then
              userCoins = userCoins - 500
              sp.edit().putInt("user_coins", userCoins).putBoolean("car_phantom", true).commit()
              tvCoinDisplay.setText("Coins: " .. tostring(userCoins))
            end
            selectedCar = "Phantom GT"
            sp.edit().putString("selected_car", selectedCar).commit()
            tvSelectedCarInfo.setText("Active Car: " .. selectedCar)
            Toast.makeText(activity, "Equipped Phantom GT!", Toast.LENGTH_SHORT).show()
          else
            Toast.makeText(activity, "Not enough coins for Phantom GT!", Toast.LENGTH_SHORT).show()
          end
        elseif which == 2 then
          if sp.getBoolean("car_vortex", false) or userCoins >= 1500 then
            if not sp.getBoolean("car_vortex", false) then
              userCoins = userCoins - 1500
              sp.edit().putInt("user_coins", userCoins).putBoolean("car_vortex", true).commit()
              tvCoinDisplay.setText("Coins: " .. tostring(userCoins))
            end
            selectedCar = "Vortex Beast"
            sp.edit().putString("selected_car", selectedCar).commit()
            tvSelectedCarInfo.setText("Active Car: " .. selectedCar)
            Toast.makeText(activity, "Equipped Vortex Beast!", Toast.LENGTH_SHORT).show()
          else
            Toast.makeText(activity, "Not enough coins for Vortex Beast!", Toast.LENGTH_SHORT).show()
          end
        end
      end
    })
    .setPositiveButton("Close", {
      onClick = function() playBackgroundMusic() end
    })
    .show()
end

-- Games Hub Navigation
btnGamesHub.onClick = function()
  stopMusic()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  hubContainer.setVisibility(View.GONE)
  gamesContainer.setVisibility(View.VISIBLE)
end

btnGamesBack.onClick = function()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  gamesContainer.setVisibility(View.GONE)
  hubContainer.setVisibility(View.VISIBLE)
  playBackgroundMusic()
end

-- Car Racing Setup Navigation
btnCarRacing.onClick = function()
  playEffectSound(SOUND_DIALOGO)
  gamesContainer.setVisibility(View.GONE)
  raceSetupContainer.setVisibility(View.VISIBLE)
end

btnRaceBack.onClick = function()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  raceSetupContainer.setVisibility(View.GONE)
  gamesContainer.setVisibility(View.VISIBLE)
end

-- Start Interactive Race
btnStartRace.onClick = function()
  local kmText = tostring(etRaceKM.getText())
  local betText = tostring(etBetCoins.getText())

  raceTargetKM = tonumber(kmText) or 0
  currentRaceBet = tonumber(betText) or 0

  if raceTargetKM <= 0 then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    Toast.makeText(activity, "Please enter a valid distance in KM!", Toast.LENGTH_SHORT).show()
    return
  end

  if currentRaceBet > userCoins then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    Toast.makeText(activity, "You do not have enough coins for this bet!", Toast.LENGTH_SHORT).show()
    return
  end

  -- Setup Race Parameters
  targetRaceMeters = raceTargetKM * 1000
  currentRaceMeters = 0
  carHealth = 100
  currentHazard = "NONE"

  stopMusic()
  playEffectSound(SOUND_ARRIBA_ABAJO)
  
  raceSetupContainer.setVisibility(View.GONE)
  activeRaceContainer.setVisibility(View.VISIBLE)
  updateLiveRaceUI()
end

-- Interactive Controls During Race ("Justices" / Actions)
btnRaceAccel.onClick = function()
  local speedGain = 100
  if selectedCar == "Phantom GT" then speedGain = 135 end
  if selectedCar == "Vortex Beast" then speedGain = 175 end

  if currentHazard == "OBSTACLE" then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    carHealth = carHealth - 30
    Toast.makeText(activity, "Crashed into obstacle! -30% Durability", Toast.LENGTH_SHORT).show()
  elseif currentHazard == "LEFT_CURVE" or currentHazard == "RIGHT_CURVE" then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    carHealth = carHealth - 15
    Toast.makeText(activity, "Slipped on sharp turn! -15% Durability", Toast.LENGTH_SHORT).show()
  else
    playEffectSound(SOUND_ARRIBA_ABAJO)
  end

  currentRaceMeters = currentRaceMeters + speedGain
  generateNextHazard()
  updateLiveRaceUI()
  checkRaceStatus()
end

btnRaceLeft.onClick = function()
  playEffectSound(SOUND_DERECHA_IZQUIERDA)
  if currentHazard == "LEFT_CURVE" then
    currentRaceMeters = currentRaceMeters + 80
    Toast.makeText(activity, "Perfect left drift turn!", Toast.LENGTH_SHORT).show()
    currentHazard = "NONE"
  else
    currentRaceMeters = currentRaceMeters + 40
  end
  updateLiveRaceUI()
  checkRaceStatus()
end

btnRaceRight.onClick = function()
  playEffectSound(SOUND_DERECHA_IZQUIERDA)
  if currentHazard == "RIGHT_CURVE" then
    currentRaceMeters = currentRaceMeters + 80
    Toast.makeText(activity, "Perfect right drift turn!", Toast.LENGTH_SHORT).show()
    currentHazard = "NONE"
  else
    currentRaceMeters = currentRaceMeters + 40
  end
  updateLiveRaceUI()
  checkRaceStatus()
end

btnRaceBrake.onClick = function()
  playEffectSound(SOUND_DOS_DEDOS_ABAJO)
  if currentHazard == "OBSTACLE" then
    Toast.makeText(activity, "Safely stopped before obstacle!", Toast.LENGTH_SHORT).show()
    currentHazard = "NONE"
  else
    Toast.makeText(activity, "Braked safely.", Toast.LENGTH_SHORT).show()
  end
  updateLiveRaceUI()
end

btnQuitRace.onClick = function()
  playEffectSound(SOUND_CUADRO_DIALOGO)
  activeRaceContainer.setVisibility(View.GONE)
  raceSetupContainer.setVisibility(View.VISIBLE)
  playBackgroundMusic()
  Toast.makeText(activity, "Race forfeited.", Toast.LENGTH_SHORT).show()
end

-- Navigation to Tools
btnToolsHub.onClick = function()
  stopMusic()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  hubContainer.setVisibility(View.GONE)
  toolsContainer.setVisibility(View.VISIBLE)
end

btnToolsBack.onClick = function()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  toolsContainer.setVisibility(View.GONE)
  hubContainer.setVisibility(View.VISIBLE)
  playBackgroundMusic()
end

btnNotepad.onClick = function()
  playEffectSound(SOUND_DIALOGO)
  toolsContainer.setVisibility(View.GONE)
  notepadContainer.setVisibility(View.VISIBLE)
end

btnNotepadBack.onClick = function()
  playEffectSound(SOUND_CAMBIO_VENTANA)
  notepadContainer.setVisibility(View.GONE)
  toolsContainer.setVisibility(View.VISIBLE)
end

btnSaveNote.onClick = function()
  local title = tostring(etNoteTitle.getText())
  local content = tostring(etNoteContent.getText())
  
  if title == "" and content == "" then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    Toast.makeText(activity, "Please enter note content to save!", Toast.LENGTH_SHORT).show()
    return
  end
  
  playEffectSound(SOUND_DOS_DEDOS_ARRIBA)
  sp.edit().putString("saved_note_title", title).putString("saved_note_content", content).commit()
  Toast.makeText(activity, "Note saved successfully!", Toast.LENGTH_SHORT).show()
end

btnViewNotes.onClick = function()
  local savedTitle = sp.getString("saved_note_title", "")
  local savedContent = sp.getString("saved_note_content", "")
  
  if savedTitle == "" and savedContent == "" then
    playEffectSound(SOUND_CUADRO_DIALOGO)
    Toast.makeText(activity, "You currently do not have any saved notes.", Toast.LENGTH_LONG).show()
  else
    playEffectSound(SOUND_DIALOGO)
    AlertDialog.Builder(activity)
      .setTitle(savedTitle ~= "" and savedTitle or "Saved Note")
      .setMessage(savedContent)
      .setPositiveButton("OK", nil)
      .setNegativeButton("Clear Note", {
        onClick = function()
          sp.edit().remove("saved_note_title").remove("saved_note_content").commit()
          etNoteTitle.setText("")
          etNoteContent.setText("")
          Toast.makeText(activity, "Note deleted!", Toast.LENGTH_SHORT).show()
        end
      })
      .show()
  end
end

-- About Section Handler (Includes Full Race Controls & Justices Guide)
btnAbout.onClick = function()
  stopMusic()
  playEffectSound(SOUND_DIALOGO)

  local aboutCustomLayout = {
    ScrollView,
    layout_width = "fill",
    layout_height = "wrap",

    {
      LinearLayout,
      layout_width = "fill",
      layout_height = "wrap",
      orientation = "vertical",
      padding = "20dp",

      {
        TextView,
        text = "DCS Studios Hub v1.0",
        textSize = "20sp",
        textColor = COLOR_PRIMARY,
        gravity = "center",
        layout_marginBottom = "8dp"
      },
      {
        TextView,
        text = "🎮 CAR RACING GAME CONTROLS & JUSTICES GUIDE:\n\n" ..
               "1. ACCELERATE (Up): Increases car distance meter forward. Fastest way to win!\n" ..
               "2. STEER LEFT / RIGHT: Used when road warnings show sharp turns. Avoids damage and gives drift bonus.\n" ..
               "3. BRAKE (Down): Used when Road Block Obstacles appear to avoid losing car durability.\n" ..
               "4. AD REWARDS: Watch ads to earn +3 Coins per ad (Maximum 10 ads per hour).\n" ..
               "5. CAR SHOWROOM: Purchase faster cars (Phantom GT, Vortex Beast) using earned coins to gain major speed boosts in races!",
        textSize = "14sp",
        textColor = COLOR_TEXT,
        gravity = "left",
        layout_marginBottom = "20dp"
      },
      {
        Button,
        id = "btnAboutGroup",
        text = "📌 Join WhatsApp Group",
        textSize = "15sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "52dp",
        layout_marginBottom = "12dp"
      },
      {
        Button,
        id = "btnAboutChannel",
        text = "📢 Join WhatsApp Channel",
        textSize = "15sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "52dp",
        layout_marginBottom = "12dp"
      },
      {
        Button,
        id = "btnAboutDev",
        text = "💬 Send Feedback to Developer",
        textSize = "15sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "52dp",
        layout_marginBottom = "12dp"
      }
    }
  }

  local dialogView = loadlayout(aboutCustomLayout)

  btnAboutGroup.setTypeface(Typeface.DEFAULT_BOLD)
  btnAboutChannel.setTypeface(Typeface.DEFAULT_BOLD)
  btnAboutDev.setTypeface(Typeface.DEFAULT_BOLD)

  btnAboutGroup.setBackground(createRoundedDrawable(COLOR_WA_GROUP, 25))
  btnAboutChannel.setBackground(createRoundedDrawable(COLOR_WA_CHANNEL, 25))
  btnAboutDev.setBackground(createRoundedDrawable(COLOR_WA_DEV, 25))

  local aboutDialog = AlertDialog.Builder(activity)
    .setTitle("About & Racing Guide")
    .setView(dialogView)
    .setPositiveButton("Close", {
      onClick = function() playBackgroundMusic() end
    })
    .create()

  aboutDialog.setOnCancelListener({
    onCancel = function() playBackgroundMusic() end
  })

  btnAboutGroup.onClick = function()
    local groupUri = Uri.parse("https://chat.whatsapp.com/Cq9qmBKXpjP3t7Jy7oPtWk?s=cl&p=a&ilr=4")
    activity.startActivity(Intent(Intent.ACTION_VIEW, groupUri))
  end

  btnAboutChannel.onClick = function()
    local channelUri = Uri.parse("https://whatsapp.com/channel/0029Vb8bJN9JJhzSxuBvc817")
    activity.startActivity(Intent(Intent.ACTION_VIEW, channelUri))
  end

  btnAboutDev.onClick = function()
    local feedbackText = "Respected Developer,\n\nI love using DCS Studios Hub, the live Car Racing game, and the Ad Coin Reward System!"
    local encodedMessage = Uri.encode(feedbackText)
    local whatsappUri = Uri.parse("https://api.whatsapp.com/send?phone=923234391100&text=" .. encodedMessage)
    activity.startActivity(Intent(Intent.ACTION_VIEW, whatsappUri))
  end

  aboutDialog.show()
end

-- Exit App Handler
btnExit.onClick = function()
  playEffectSound(SOUND_CUADRO_DIALOGO)
  AlertDialog.Builder(activity)
    .setTitle("Exit App")
    .setMessage("Are you sure you want to exit this app?")
    .setPositiveButton("Yes", {
      onClick = function()
        stopMusic()
        activity.finish()
      end
    })
    .setNegativeButton("No", nil)
    .show()
end

function onDestroy()
  stopMusic()
end