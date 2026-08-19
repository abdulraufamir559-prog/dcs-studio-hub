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

-- Target Audio File Path
local MUSIC_PATH = "/storage/emulated/0/解说/Tools/yt/sounds/board game menu .mp3"
local mediaPlayer = nil

-- Shared Preferences for App State & Notepad storage
local sp = activity.getPreferences(0)
local isFirstRun = sp.getBoolean("welcome_seen", true)

-- Color Palette Definitions
local COLOR_BG = Color.parseColor("#FFF8E1")
local COLOR_PRIMARY = Color.parseColor("#FF6F00")
local COLOR_ACCENT = Color.parseColor("#4CAF50")
local COLOR_SECONDARY = Color.parseColor("#0288D1")
local COLOR_DANGER = Color.parseColor("#E53935")
local COLOR_TEXT = Color.parseColor("#3E2723")
local COLOR_INPUT_BG = Color.parseColor("#E0E0E0")
local COLOR_WHITE = Color.parseColor("#FFFFFF")

-- Button Specific Colors for About Section
local COLOR_WA_GROUP = Color.parseColor("#25D366")
local COLOR_WA_CHANNEL = Color.parseColor("#0288D1")
local COLOR_WA_DEV = Color.parseColor("#FF6F00")

-- Helper function to generate rounded background drawables
function createRoundedDrawable(color, radius)
  local drawable = GradientDrawable()
  drawable.setColor(color)
  drawable.setCornerRadius(radius)
  return drawable
end

-- Robust background music controller using dynamic proxy
function playBackgroundMusic()
  if mediaPlayer == nil then
    local musicFile = File(MUSIC_PATH)
    if musicFile.exists() then
      local fileUri = Uri.fromFile(musicFile)
      mediaPlayer = MediaPlayer.create(activity, fileUri)
      
      if mediaPlayer ~= nil then
        pcall(function()
          mediaPlayer.setLooping(Boolean.TRUE)
        end)
        pcall(function()
          mediaPlayer.setLooping(true)
        end)
        
        pcall(function()
          local completionListener = luajava.createProxy("android.media.MediaPlayer$OnCompletionListener", {
            onCompletion = function(mp)
              pcall(function()
                mp.start()
              end)
            end
          })
          mediaPlayer.setOnCompletionListener(completionListener)
        end)
        
        pcall(function()
          mediaPlayer.start()
        end)
      else
        Toast.makeText(activity, "Failed to initialize media player!", Toast.LENGTH_SHORT).show()
      end
    else
      Toast.makeText(activity, "Audio file not found at path!", Toast.LENGTH_LONG).show()
    end
  end
end

-- Safe music release controller
function stopMusic()
  if mediaPlayer ~= nil then
    pcall(function()
      if mediaPlayer.isPlaying() then
        mediaPlayer.stop()
      end
    end)
    pcall(function()
      mediaPlayer.release()
    end)
    mediaPlayer = nil
  end
end

-- Main View Hierarchy
layout = {
  LinearLayout,
  layout_width = "fill",
  layout_height = "fill",
  orientation = "vertical",
  backgroundColor = COLOR_BG,
  gravity = "center",
  padding = "20dp",

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
        layout_marginBottom = "24dp"
      },
      {
        Button,
        id = "btnMoreOptions",
        text = "More Options",
        textSize = "16sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "50dp",
        contentDescription = "More options button",
        layout_marginBottom = "16dp"
      },
      {
        Button,
        id = "btnGamesHub",
        text = "Games Hub",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Games Hub button",
        layout_marginBottom = "16dp"
      },
      {
        Button,
        id = "btnToolsHub",
        text = "Tools & Features Hub",
        textSize = "18sp",
        textColor = COLOR_WHITE,
        layout_width = "fill",
        layout_height = "55dp",
        contentDescription = "Tools and features hub button",
        layout_marginBottom = "28dp"
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

  -- PAGE 4: Tools Sub-Menu Screen
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
      text = "1. Notepad",
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

  -- PAGE 5: Notepad Screen
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

-- Render main layout to Activity
activity.setContentView(loadlayout(layout))

-- Apply typography programmatically
tvWelcome.setTypeface(Typeface.DEFAULT_BOLD)
btnWelcomeNext.setTypeface(Typeface.DEFAULT_BOLD)
tvEnterName.setTypeface(Typeface.DEFAULT_BOLD)
btnGenerate.setTypeface(Typeface.DEFAULT_BOLD)
btnNameNext.setTypeface(Typeface.DEFAULT_BOLD)
tvHubHeading.setTypeface(Typeface.DEFAULT_BOLD)
btnMoreOptions.setTypeface(Typeface.DEFAULT_BOLD)
btnGamesHub.setTypeface(Typeface.DEFAULT_BOLD)
btnToolsHub.setTypeface(Typeface.DEFAULT_BOLD)
btnAbout.setTypeface(Typeface.DEFAULT_BOLD)
btnExit.setTypeface(Typeface.DEFAULT_BOLD)

tvToolsHeading.setTypeface(Typeface.DEFAULT_BOLD)
btnNotepad.setTypeface(Typeface.DEFAULT_BOLD)
btnToolsBack.setTypeface(Typeface.DEFAULT_BOLD)

tvNotepadHeading.setTypeface(Typeface.DEFAULT_BOLD)
btnSaveNote.setTypeface(Typeface.DEFAULT_BOLD)
btnViewNotes.setTypeface(Typeface.DEFAULT_BOLD)
btnNotepadBack.setTypeface(Typeface.DEFAULT_BOLD)

-- Apply custom rounded backgrounds
btnWelcomeNext.setBackground(createRoundedDrawable(COLOR_PRIMARY, 40))
etName.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 20))
btnGenerate.setBackground(createRoundedDrawable(COLOR_ACCENT, 40))
btnNameNext.setBackground(createRoundedDrawable(COLOR_PRIMARY, 40))

btnMoreOptions.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))
btnGamesHub.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnToolsHub.setBackground(createRoundedDrawable(COLOR_PRIMARY, 30))
btnAbout.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))
btnExit.setBackground(createRoundedDrawable(COLOR_DANGER, 30))

btnNotepad.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnToolsBack.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))

etNoteTitle.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 15))
etNoteContent.setBackground(createRoundedDrawable(COLOR_INPUT_BG, 15))
btnSaveNote.setBackground(createRoundedDrawable(COLOR_PRIMARY, 30))
btnViewNotes.setBackground(createRoundedDrawable(COLOR_ACCENT, 30))
btnNotepadBack.setBackground(createRoundedDrawable(COLOR_SECONDARY, 30))

-- Auto-play music if app opens directly to Hub for returning users
if (not isFirstRun) then
  playBackgroundMusic()
end

-- Initialize random number generator
math.randomseed(os.time())

--- Event Listeners ---

btnWelcomeNext.onClick = function()
  welcomeContainer.setVisibility(View.GONE)
  nameContainer.setVisibility(View.VISIBLE)
  tvEnterName.requestFocus()
end

btnGenerate.onClick = function()
  local coolNames = {
    "ShadowKnight", "CyberDragon", "VortexHero", "BlazeRider",
    "DCS_Legend", "CosmicNova", "ThunderPro", "PixelMaster"
  }
  local randomIndex = math.random(1, #coolNames)
  local selectedName = coolNames[randomIndex]
  
  etName.setText(selectedName)
  etName.setContentDescription("Generated name: " .. selectedName)
  Toast.makeText(activity, "Generated: " .. selectedName, Toast.LENGTH_SHORT).show()
end

btnNameNext.onClick = function()
  local userName = tostring(etName.getText())
  if userName == "" or userName == nil then
    Toast.makeText(activity, "Please enter or generate a name first!", Toast.LENGTH_SHORT).show()
    return
  end
  
  -- Store state so welcome screen shows only once
  sp.edit().putBoolean("welcome_seen", false).commit()
  
  nameContainer.setVisibility(View.GONE)
  hubContainer.setVisibility(View.VISIBLE)
  tvHubHeading.requestFocus()
  
  -- Trigger background music playback
  playBackgroundMusic()
  Toast.makeText(activity, "Welcome " .. userName .. "!", Toast.LENGTH_SHORT).show()
end

btnMoreOptions.onClick = function()
  Toast.makeText(activity, "More Options clicked", Toast.LENGTH_SHORT).show()
end

btnGamesHub.onClick = function()
  Toast.makeText(activity, "Opening Games Hub...", Toast.LENGTH_SHORT).show()
end

-- Navigation to Tools & Features Sub-menu (Stops Background Music)
btnToolsHub.onClick = function()
  stopMusic() -- Stop music when opening Tools Hub
  hubContainer.setVisibility(View.GONE)
  toolsContainer.setVisibility(View.VISIBLE)
  tvToolsHeading.requestFocus()
end

btnToolsBack.onClick = function()
  toolsContainer.setVisibility(View.GONE)
  hubContainer.setVisibility(View.VISIBLE)
  tvHubHeading.requestFocus()
  playBackgroundMusic() -- Resume background music on main hub
end

-- Navigation to Notepad Screen
btnNotepad.onClick = function()
  toolsContainer.setVisibility(View.GONE)
  notepadContainer.setVisibility(View.VISIBLE)
  tvNotepadHeading.requestFocus()
end

btnNotepadBack.onClick = function()
  notepadContainer.setVisibility(View.GONE)
  toolsContainer.setVisibility(View.VISIBLE)
  tvToolsHeading.requestFocus()
end

-- Save Note Handler
btnSaveNote.onClick = function()
  local title = tostring(etNoteTitle.getText())
  local content = tostring(etNoteContent.getText())
  
  if title == "" and content == "" then
    Toast.makeText(activity, "Please enter a title or note message to save!", Toast.LENGTH_SHORT).show()
    return
  end
  
  sp.edit().putString("saved_note_title", title).putString("saved_note_content", content).commit()
  Toast.makeText(activity, "Note saved successfully!", Toast.LENGTH_SHORT).show()
end

-- View Note Handler
btnViewNotes.onClick = function()
  local savedTitle = sp.getString("saved_note_title", "")
  local savedContent = sp.getString("saved_note_content", "")
  
  if savedTitle == "" and savedContent == "" then
    Toast.makeText(activity, "You currently do not have any saved notes.", Toast.LENGTH_LONG).show()
  else
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

-- About Section with Custom Colored Options Layout
btnAbout.onClick = function()
  stopMusic() -- Stop background music when opening About

  -- Custom view for About dialog with multi-colored option buttons
  local aboutCustomLayout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "wrap",
    orientation = "vertical",
    padding = "20dp",

    {
      TextView,
      text = "DCS Studios Hub v1.0",
      textSize = "18sp",
      textColor = COLOR_PRIMARY,
      gravity = "center",
      contentDescription = "DCS Studios Hub version 1.0",
      layout_marginBottom = "6dp"
    },
    {
      TextView,
      text = "Designed with full accessibility and screen reader support.",
      textSize = "14sp",
      textColor = COLOR_TEXT,
      gravity = "center",
      contentDescription = "Designed with full accessibility and screen reader support",
      layout_marginBottom = "20dp"
    },

    -- Distinct Green WhatsApp Group Button
    {
      Button,
      id = "btnAboutGroup",
      text = "📌 Join WhatsApp Group",
      textSize = "15sp",
      textColor = COLOR_WHITE,
      layout_width = "fill",
      layout_height = "52dp",
      contentDescription = "Join WhatsApp Group button",
      layout_marginBottom = "12dp"
    },

    -- Distinct Blue WhatsApp Channel Button
    {
      Button,
      id = "btnAboutChannel",
      text = "📢 Join WhatsApp Channel",
      textSize = "15sp",
      textColor = COLOR_WHITE,
      layout_width = "fill",
      layout_height = "52dp",
      contentDescription = "Join WhatsApp Channel button",
      layout_marginBottom = "12dp"
    },

    -- Distinct Orange Developer Contact Button
    {
      Button,
      id = "btnAboutDev",
      text = "💬 Send Feedback to Developer",
      textSize = "15sp",
      textColor = COLOR_WHITE,
      layout_width = "fill",
      layout_height = "52dp",
      contentDescription = "Send feedback to developer button",
      layout_marginBottom = "12dp"
    }
  }

  local dialogView = loadlayout(aboutCustomLayout)

  -- Apply custom typography to dialog buttons
  btnAboutGroup.setTypeface(Typeface.DEFAULT_BOLD)
  btnAboutChannel.setTypeface(Typeface.DEFAULT_BOLD)
  btnAboutDev.setTypeface(Typeface.DEFAULT_BOLD)

  -- Set unique background colors for each button
  btnAboutGroup.setBackground(createRoundedDrawable(COLOR_WA_GROUP, 25))
  btnAboutChannel.setBackground(createRoundedDrawable(COLOR_WA_CHANNEL, 25))
  btnAboutDev.setBackground(createRoundedDrawable(COLOR_WA_DEV, 25))

  -- Dialog Instance Construction
  local aboutDialog = AlertDialog.Builder(activity)
    .setTitle("About & Official Links")
    .setView(dialogView)
    .setPositiveButton("Close", {
      onClick = function()
        playBackgroundMusic() -- Resume background music on Close
      end
    })
    .create()

  -- Ensure background music resumes if dismissed or canceled
  aboutDialog.setOnCancelListener({
    onCancel = function()
      playBackgroundMusic()
    end
  })

  -- WhatsApp Group Button Click Listener
  btnAboutGroup.onClick = function()
    local groupUri = Uri.parse("https://chat.whatsapp.com/Cq9qmBKXpjP3t7Jy7oPtWk?s=cl&p=a&ilr=4")
    activity.startActivity(Intent(Intent.ACTION_VIEW, groupUri))
  end

  -- WhatsApp Channel Button Click Listener
  btnAboutChannel.onClick = function()
    local channelUri = Uri.parse("https://whatsapp.com/channel/0029Vb8bJN9JJhzSxuBvc817")
    activity.startActivity(Intent(Intent.ACTION_VIEW, channelUri))
  end

  -- Developer WhatsApp Feedback Button Click Listener
  btnAboutDev.onClick = function()
    local longFeedbackText = "Respected Developer,\n\n"
      .. "I am writing this message to express my heartfelt appreciation and admiration for the DCS Studios Hub application that you have crafted. It is an extraordinary piece of work that uniquely combines functionality, modern UI design, and outstanding user accessibility.\n\n"
      .. "The overall user experience of the application is exceptionally smooth and intuitive. From the beautiful welcome screen setup to the seamless layout transitions, every single detail shows your commitment to quality mobile app development. The built-in audio system and background sound features elevate the app environment, making it engaging and interactive.\n\n"
      .. "Furthermore, I am thoroughly impressed by the newly added Tools Hub and Notepad feature. The clean interface allowing users to quickly write down notes with titles and content, alongside instant access and deletion controls, makes it extremely practical for daily use. Your attention to detail—especially ensuring full compatibility with screen readers and accessibility options—is truly commendable and highly impactful.\n\n"
      .. "I am deeply grateful for your dedication in making such a refined tool available. Please accept this sincere appreciation from a dedicated user. I eagerly look forward to upcoming releases, new feature implementations, and future updates from DCS Studios.\n\n"
      .. "Keep up the phenomenal development work!\n\n"
      .. "Warm regards,\nA Very Satisfied User"

    local encodedMessage = Uri.encode(longFeedbackText)
    local whatsappUri = Uri.parse("https://api.whatsapp.com/send?phone=923234391100&text=" .. encodedMessage)
    activity.startActivity(Intent(Intent.ACTION_VIEW, whatsappUri))
  end

  aboutDialog.show()
end

-- Exit Dialog Handling
btnExit.onClick = function()
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

-- Handle Activity destruction cleanup
function onDestroy()
  stopMusic()
end