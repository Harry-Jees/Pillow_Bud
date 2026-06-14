# PILLOW BUD — COMPLETE ULTRA-DETAILED MASTER PROMPT

**Use this prompt with:** Claude, VS Code Copilot, ChatGPT, or any AI coding assistant

Copy everything below. Paste into AI chat. Receive complete app.

---

## PART 0: PROJECT OVERVIEW

**Project Name:** Pillow Bud
**Tagline:** "Your emotional companion, always listening"
**Type:** Cross-platform mobile app (Flutter)
**Platforms:** iOS 15+ & Android 8.0+
**Philosophy:** Privacy-first, emotionally intelligent, completely local
**Purpose:** Provide an AI emotional companion that listens without judgment
**Target Users:** Privacy-conscious individuals seeking emotional support
**Cost:** Completely free (open source)
**Model:** Llama 3.2 1B (local, no cloud)

---

## PART 1: COMPLETE DESIGN SYSTEM

### 1.1 COLOR SYSTEM (HEX VALUES)

**Primary Palette:**
```
Primary Lavender:     #C4A8F8 (RGB: 196, 168, 248)
Secondary Teal:       #89C4F8 (RGB: 137, 196, 248)
Tertiary Sage:        #A8D8A8 (RGB: 168, 216, 168)
```

**Dark Mode (Default) Backgrounds:**
```
Dark Background:      #1A1225 (RGB: 26, 18, 37)
Card Background:      #2D1F4A (RGB: 45, 31, 74)
Surface Overlay:      #2D1F4A with 0.5 opacity
Subtle Border:        #FFFFFF with 7% opacity
```

**Light Mode (Secondary) Backgrounds:**
```
Light Background:     #F8F6FF (RGB: 248, 246, 255)
Card Background:      #FFFFFF (RGB: 255, 255, 255)
Light Border:         #000000 with 7% opacity
```

**Text Colors (Dark Mode):**
```
Primary Text:         #F0E8FF (RGB: 240, 232, 255)
Secondary Text:       #F0E8FF with 65% opacity
Tertiary Text:        #F0E8FF with 40% opacity
Muted Text:           #F0E8FF with 25% opacity
```

**Text Colors (Light Mode):**
```
Primary Text:         #1A1225 (RGB: 26, 18, 37)
Secondary Text:       #1A1225 with 65% opacity
Tertiary Text:        #1A1225 with 40% opacity
```

**Semantic Colors:**
```
Success/Positive:     #7ACF8E (RGB: 122, 207, 142)
Warning/Caution:      #FAC775 (RGB: 250, 199, 117)
Danger/Crisis:        #F09595 (RGB: 240, 149, 149)
Info/Neutral:         #89C4F8 (RGB: 137, 196, 248)
```

**Theme Presets (5 Built-in + Custom):**

Theme 1 - Lavender Dream (Default):
```
Primary:   #C4A8F8
Secondary: #89C4F8
Tertiary:  #A8D8A8
```

Theme 2 - Ocean Calm:
```
Primary:   #4A90E2
Secondary: #7AC8E8
Tertiary:  #6AB8D8
```

Theme 3 - Sunset Warmth:
```
Primary:   #E8A87C
Secondary: #F0B490
Tertiary:  #D89C6C
```

Theme 4 - Minty Fresh:
```
Primary:   #6AC4A8
Secondary: #A8D8C4
Tertiary:  #7ED4B8
```

Theme 5 - Rosy Blush:
```
Primary:   #D8A8C4
Secondary: #E8C4D8
Tertiary:  #C898B4
```

Custom Theme:
```
Hue slider: 0-360°
Saturation slider: 0-100%
Brightness slider: 0-100%
```

### 1.2 TYPOGRAPHY

**Font 1: Lora (Serif) - Headlines & Display**

Used for: Page titles, section headers, emphasis text

Variants loaded:
```
Lora-Regular.ttf    (weight: 400)
Lora-Medium.ttf     (weight: 500)
Lora-SemiBold.ttf   (weight: 600)
```

Sizes & Usage:
```
Display/Hero Text:
  Size: 28px
  Weight: 600
  Line Height: 1.4
  Letter Spacing: 0.02em
  Use: Page titles, splash screen

Heading 1:
  Size: 24px
  Weight: 500
  Line Height: 1.4
  Letter Spacing: 0.01em
  Use: Screen titles

Heading 2:
  Size: 18px
  Weight: 500
  Line Height: 1.4
  Letter Spacing: 0em
  Use: Section headers, dialog titles
```

**Font 2: DM Sans (Sans-serif) - Body & UI**

Used for: Body text, labels, buttons, input

Variants loaded:
```
DMSans-Regular.ttf  (weight: 400)
DMSans-Medium.ttf   (weight: 500)
DMSans-SemiBold.ttf (weight: 600)
```

Sizes & Usage:
```
Body Large:
  Size: 14px
  Weight: 400
  Line Height: 1.6
  Letter Spacing: 0em
  Use: Main body text, chat messages

Body Medium:
  Size: 13px
  Weight: 400
  Line Height: 1.6
  Letter Spacing: 0em
  Use: Secondary text, descriptions

Body Small:
  Size: 12px
  Weight: 400
  Line Height: 1.5
  Letter Spacing: 0em
  Use: Captions, metadata, help text

Label Large:
  Size: 12px
  Weight: 500
  Line Height: 1.4
  Letter Spacing: 0.02em
  Use: Button text, labels

Label Small:
  Size: 11px
  Weight: 500
  Line Height: 1.4
  Letter Spacing: 0.02em
  Use: Badge text, small labels, tags
```

### 1.3 SPACING SYSTEM (Baseline: 4px)

```
xs: 4px    (1 unit)
sm: 8px    (2 units)
md: 12px   (3 units)
lg: 16px   (4 units)
xl: 20px   (5 units)
xxl: 24px  (6 units)
xxxl: 32px (8 units)
```

Usage:
```
Padding within buttons:   md (12px)
Padding within cards:     lg (16px)
Margin between sections:  xl (20px) - xxl (24px)
Margin between items:     md (12px) - lg (16px)
Input field padding:      md (12px) horizontal, sm (8px) vertical
```

### 1.4 BORDER RADIUS

```
Soft (small elements):    12px
Standard (cards):         14px
Medium (buttons, inputs): 16px
Large (modals):           20px
Pill-shaped (full):       99px
```

Usage:
```
Buttons:                  16px
Text input fields:        16px
Cards:                    14px
Dialog boxes:             20px
Bottom sheets:            20px (top), 0px (bottom)
Buttons in input row:     16px (pill-shaped)
Indicators (dots):        50% (perfect circle)
```

### 1.5 SHADOWS & ELEVATION

**Philosophy:** Minimal shadows (flat modern design)

```
No shadows by default

Optional subtle shadows:
  Elevation 1: 0px 2px 4px rgba(0,0,0,0.08)
  Elevation 2: 0px 4px 8px rgba(0,0,0,0.12)
```

Usage:
```
Most UI elements:         No shadow (flat)
Floating elements:        Optional elevation 1
Modal overlays:           Backdrop color instead of shadow
Buttons:                  No shadow, color change on press
Cards:                    No shadow, border instead
```

### 1.6 OPACITY & TRANSPARENCY

```
Full opacity:        1.0 (100%)
High emphasis:       0.85 (85%)
Medium emphasis:     0.65 (65%)
Low emphasis:        0.4 (40%)
Very low emphasis:   0.25 (25%)
Minimal:             0.12 (12%)
Hover/focus:         0.08 (8%)
```

Usage:
```
Primary text:           100% (1.0)
Secondary text:         65% (0.65)
Disabled text:          40% (0.4)
Placeholder text:       40% (0.4)
Borders:                7-10% (0.07-0.1)
Subtle backgrounds:     4-8% (0.04-0.08)
Hover states:           8% (0.08)
Focus indicators:       12% (0.12)
```

---

## PART 2: COMPLETE UI/UX SPECIFICATIONS

### 2.1 SCREEN DIMENSIONS & SAFE AREAS

Target Devices:
```
Android:
  Min screen: 4.5" (small phones)
  Max screen: 6.7" (large phones)
  Min SDK: 26 (Android 8.0)
  Aspect ratio: 16:9 to 20:9
  Safe area: notches, gesture bars
  Keyboard: adjustResize mode

iOS:
  Min version: iOS 15.0
  Screen sizes: iPhone SE to Pro Max
  Safe area: notches, dynamic island, home indicator
  Keyboard: automatic

Both:
  Min touch target: 48x48 dp
  Min spacing between: 8dp
```

### 2.2 SPACING RULES (Responsive)

```
Horizontal padding:
  Phone: 16px on all sides
  Tablet: 24px on all sides
  
Vertical spacing:
  Top safe area: Respect notch/status bar
  Bottom safe area: Respect home indicator/gesture bar
  
Between sections: 20-24px
Between items: 12-16px
Inside components: 12px (cards), 10px (buttons)
```

### 2.3 ANIMATION & TRANSITIONS

```
Fast animations:       200ms
Standard animations:   300ms
Slow animations:       500ms
Curves:
  Linear:     Curves.linear
  Ease-in:    Curves.easeIn
  Ease-out:   Curves.easeOut
  Decelerate: Curves.decelerate
```

Usage:
```
Button tap feedback:      200ms easeOut
Screen transitions:       300ms easeInOut
Modal entrance:           300ms easeOut
Page routing:             300ms materialPageRoute
Typing indicator:         1000ms infinite loop
Toast/snackbar:           300ms slideIn, 300ms slideOut
Chat message entrance:    300ms slideIn
Mood picker animation:    200ms scale
```

---

## PART 3: SCREEN-BY-SCREEN UI/UX SPECIFICATIONS

### 3.1 SPLASH SCREEN

**Duration:** 2 seconds

**Layout:**
```
┌─────────────────────────┐
│                         │
│      [PURPLE BOX]       │
│    [🛏️ EMOJI/LOGO]    │
│                         │
│   "Pillow Bud"         │
│   (Display Large)       │
│                         │
│ "YOUR EMOTIONAL         │
│  COMPANION"             │
│ (Caption style, 10px)  │
│                         │
└─────────────────────────┘
```

**Design Details:**
- Background: Dark BG (#1A1225)
- Logo container: 80x80px, Primary color with 20% opacity (#C4A8F8 opacity: 0.2)
- Logo border radius: 20px
- Emoji size: 40px
- Title font: Lora, 28px, weight 600
- Subtitle: DM Sans, 10px, weight 400, letter-spacing: 1.5px
- Subtitle color: Text color with 40% opacity
- Animation: Fade in over 0.5s

**Interactions:**
- None (automatic transition after 2 seconds)

### 3.2 ONBOARDING SCREEN (5 Screens)

**Navigation:** PageView (horizontal swipe, but disabled)
- Swipe disabled to ensure sequential flow
- Manual "Next" button advancement

**Screen 1: Welcome**

```
┌─────────────────────────┐
│      WELCOME            │
│                         │
│  "Welcome to Pillow Bud"│
│  (Heading 1, 24px)     │
│                         │
│  "Your emotional        │
│   companion, always     │
│   listening"            │
│  (Body Large, 14px)     │
│  Color: Text 65%        │
│  Max width: 280px       │
│  Text align: Center     │
│                         │
│  [BEGIN BUTTON]         │
│                         │
└─────────────────────────┘
```

**Button Specs:**
- Size: 300px wide, 50px tall
- Background: Primary (#C4A8F8)
- Text: White, DM Sans, 14px, weight 500
- Border radius: 16px
- Tap feedback: Opacity 0.8
- No elevation

**Screen 2: Enter Name**

```
┌─────────────────────────┐
│   "What's your name?"   │
│   (Heading 1, 24px)     │
│                         │
│  ┌─────────────────┐   │
│  │ Enter your name │   │
│  │ (placeholder)   │   │
│  └─────────────────┘   │
│  (Text field)           │
│                         │
│  ┌──────────────────┐  │
│  │    CONTINUE      │  │
│  └──────────────────┘  │
│  (disabled if empty)    │
│                         │
└─────────────────────────┘
```

**Text Input Field:**
- Size: 280px wide, 48px tall
- Padding: 12px horizontal, 8px vertical
- Background: White 4% opacity (#FFFFFF 0.04)
- Border: White 10% opacity, 1px
- Border radius: 16px
- Font: DM Sans, 14px
- Text color: Primary text
- Placeholder color: Text 40% opacity
- Cursor color: Primary (#C4A8F8)
- Auto focus: Yes
- Keyboard: default

**Screen 3: Select Personality**

```
┌─────────────────────────┐
│ "How should Bud be with │
│  you?" (Heading 1, 22px)│
│                         │
│  ☐ Gentle              │
│    "Soft, validating"  │
│                         │
│  ☐ Curious             │
│    "Ask questions"     │
│                         │
│  ☐ Wise                │
│    "Reflective"        │
│                         │
│  ☑ Balanced            │
│    "Mix of all (default)│
│                         │
│  [CONTINUE]             │
└─────────────────────────┘
```

**Radio Button Option:**
- Container: Full width, 64px tall
- Padding: 12px
- Background: White 4% when unselected
- Background: Primary 12% when selected (#C4A8F8 0.12)
- Border: White 10% when unselected
- Border: Primary 20% when selected
- Border radius: 12px
- Radio dot: 16px diameter, left side

**Screen 4: Disclaimer**

```
┌─────────────────────────┐
│  "Important"            │
│  (Heading 1, 24px)      │
│                         │
│  "Bud is your emotional │
│  companion, not a       │
│  licensed therapist...  │
│  For serious concerns,  │
│  please talk to a       │
│  professional or call   │
│  a crisis helpline."    │
│  (Body Large, 14px)     │
│  Text align: Center     │
│  Line height: 1.6       │
│  Max width: 300px       │
│                         │
│  [I UNDERSTAND]         │
└─────────────────────────┘
```

**Screen 5: Ready**

```
┌─────────────────────────┐
│ "You're all set!"       │
│ (Heading 1, 28px, 600)  │
│                         │
│ "Bud is ready to        │
│  listen. Let's begin."  │
│ (Body Large, 14px)      │
│ Color: Text 65%         │
│                         │
│ [LET'S GO]              │
│                         │
└─────────────────────────┘
```

### 3.3 HOME SCREEN

**Layout:**
```
┌──────────────────────────┐
│  "Hey, [Name]"           │ ← Greeting
│  (Heading 2, 24px)       │
│                          │
│ ┌──────────────────────┐ │
│ │ How are you feeling? │ │
│ │ (Caption style)      │ │
│ │                      │ │
│ │ 😤  😢  😌  😊  😟   │ ← Mood picker
│ │ [Stressed] [Sad] ...│ │
│ └──────────────────────┘ │
│                          │
│ ┌──────────────────────┐ │
│ │ 🌸                   │ │ ← Bud preview
│ │ "I'm here whenever   │ │
│ │  you need to talk.   │ │
│ │  No judgment, just   │ │
│ │  listening."         │ │
│ └──────────────────────┘ │
│                          │
│ ┌──────────────────────┐ │
│ │   TALK TO BUD        │ │ ← CTA
│ └──────────────────────┘ │
│                          │
│ ┌──────────────────────┐ │ ← Bottom nav
│ │ 🏠  💬  📓  📊  👤 │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

**Components:**

Greeting Box:
- Text: "Hey, [UserName]"
- Font: Lora, 24px, weight 500
- Padding: 0px top, 24px bottom

Mood Picker Card:
- Full width, padding: 16px
- Background: White 4% opacity
- Border: 1px White 7% opacity
- Border radius: 16px
- Question text: DM Sans, 12px, White 40%
- 5 mood buttons in row:
  - Each: 48x72px
  - Emoji: 24px
  - Label: 9px, White 40%
  - No background (transparent)
  - Tap: Change opacity 100%

Bud Preview Card:
- Full width, padding: 16px
- Background: Primary 10% opacity (#C4A8F8 0.1)
- Border: 1px Primary 20% opacity
- Border radius: 14px
- Emoji: 20px (🌸)
- Text: DM Sans, 13px, White 75%
- Line height: 1.6
- Max 3 lines

Talk to Bud Button:
- Full width, 50px tall
- Background: Primary (#C4A8F8)
- Text: White, DM Sans, 14px, weight 500
- Border radius: 16px
- Margin: 24px vertical

Bottom Navigation:
- 5 tabs: Home | Bud | Journal | Insights | Me
- Icons: Material Icons, 24px
- Selected color: Primary
- Unselected color: White 40%
- Label text: 11px
- Height: 64px

### 3.4 CHAT SCREEN

**Layout:**
```
┌────────────────────────────┐
│ Bud                        │ ← Header
│ (I sense you're feeling…)  │
├────────────────────────────┤
│                            │
│          [BUD MESSAGE]     │
│          (bubble)          │
│                            │
│                            │
│                [USER MSG]  │
│                (bubble)    │
│                            │
│ Bud is thinking...         │
│ (indicator)                │
│                            │
├────────────────────────────┤
│ ┌───────────────────────┐  │
│ │ Share your thoughts   │  │
│ └───────────────────────┘  │
│  [SEND ICON]               │
└────────────────────────────┘
```

**Header:**
- Title: "Bud", DM Sans, 16px, weight 500
- Subtitle (when emotion detected): "I sense you're feeling [emotion]"
  - Font: DM Sans, 10px, White 50%
- Background: Transparent
- Padding: 16px

**Chat Bubbles - Bud:**
- Max width: 85% of screen
- Padding: 12px horizontal, 8px vertical
- Background: Primary 12% opacity (#C4A8F8 0.12)
- Border: 1px Primary 20% opacity
- Border radius: 
  - Top left: 4px
  - Top right: 14px
  - Bottom: 14px
- Text: DM Sans, 13px, White 85%
- Line height: 1.6
- Avatar: 28x28px circle, Primary 20% opacity, 🌸 emoji 14px
- Avatar margin: 8px right
- Alignment: Left
- Margin between messages: 12px vertical

**Chat Bubbles - User:**
- Max width: 85% of screen
- Padding: 12px horizontal, 8px vertical
- Background: Primary (#C4A8F8)
- Border radius:
  - Top left: 14px
  - Top right: 4px
  - Bottom: 14px
- Text: DM Sans, 13px, White
- Line height: 1.6
- Alignment: Right
- Margin: 8px from right edge

**Typing Indicator:**
- 3 animated dots
- Each dot: 8x8px, Primary color
- Animation: Scale 0->1, duration 1000ms, infinite
- Offset: 200ms between dots
- Text: "Bud is thinking" (optional, DM Sans 13px)

**Input Area:**
- Full width
- Border top: 1px White 10%
- Padding: 16px
- Text field + send button layout:
  - Text field: flex grow
  - Button: 40x40px right

**Text Input Field:**
- Background: White 4% opacity
- Border: 1px White 10%
- Border radius: 20px
- Padding: 14px horizontal, 10px vertical
- Font: DM Sans, 14px
- Max lines: 5
- Keyboard: Text

**Send Button:**
- Shape: Circle
- Size: 40x40px
- Background: Primary (#C4A8F8)
- Icon: Icons.send, White, 18px
- Margin: 10px left
- Disabled state: Opacity 0.5
- Tap feedback: Opacity 0.8

**Interactions:**
- Tap message: (none, just display)
- Long press message: (optional: copy, delete)
- Send button: Disabled if text empty
- Keyboard auto-dismisses after send
- Auto-scroll to bottom on new message
- Typing indicator shows during generation

### 3.5 JOURNAL SCREEN

**Layout:**
```
┌────────────────────────────┐
│ My Journal                 │
│ (Heading 2, 18px)          │
├────────────────────────────┤
│                            │
│ ┌──────────────────────┐   │
│ │ Today    😌          │   │
│ │ "Had a good chat...  │   │
│ │  Feeling calmer now" │   │
│ └──────────────────────┘   │
│                            │
│ ┌──────────────────────┐   │
│ │ Yesterday 😢         │   │
│ │ "Feeling overwhelmed │   │
│ │  about work"         │   │
│ └──────────────────────┘   │
│                            │
│ ┌──────────────────────┐   │
│ │ Mar 8     😤         │   │
│ │ "Stressed about…"   │   │
│ └──────────────────────┘   │
│                            │
├────────────────────────────┤
│           [+]              │ ← FAB
└────────────────────────────┘
```

**Header:**
- Title: "My Journal", Lora, 24px, weight 500
- Padding: 20px vertical, 16px horizontal

**Entry Card:**
- Full width, padding: 16px
- Background: White 4% opacity
- Border: 1px White 7%
- Border radius: 12px
- Margin: 0 16px 12px 16px
- Content:
  - Row 1: Date (DM Sans 11px, White 40%) + Emoji (20px) + [right-aligned]
  - Row 2: Text (DM Sans 12px, White 70%), max 2 lines, ellipsis
- Min height: 60px
- Tap: Opens full entry (dialog or new screen)

**Date Labels:**
- "Today": Current date
- "Yesterday": -1 day
- "Mar 8": Full date format for older entries

**FAB (Floating Action Button):**
- Position: Bottom right, 16px from edges, above nav bar (80px)
- Size: 56x56px
- Background: Primary (#C4A8F8)
- Icon: Icons.add, White, 24px
- Border radius: 50% (perfect circle)
- Tap: Open new entry dialog

**Empty State:**
```
┌────────────────────────────┐
│  "No entries yet."         │
│  "Start writing!"          │
│  (Text centered, White 40%)│
│                            │
│  Size: 16 each             │
└────────────────────────────┘
```

**New Entry Dialog:**
```
┌────────────────────────────┐
│   "New Journal Entry"      │
│   (Heading 2, 18px)        │
├────────────────────────────┤
│ ┌──────────────────────┐   │
│ │ Write your thoughts  │   │
│ │ (multiline input)    │   │
│ │                      │   │
│ │                      │   │
│ └──────────────────────┘   │
│                            │
│ Mood: [😤][😢][😌][😊][😄]│
│                            │
│ ┌──────────┐ ┌──────────┐ │
│ │  CANCEL  │ │   SAVE   │ │
│ └──────────┘ └──────────┘ │
└────────────────────────────┘
```

**Dialog Specs:**
- Background: Card Dark (#2D1F4A)
- Border radius: 16px
- Width: 90% of screen, max 400px
- Padding: 20px
- Shadow: Optional elevation 2

**Text Area:**
- Min height: 100px
- Max height: 200px
- Background: White 4% opacity
- Border radius: 8px
- Padding: 12px
- Font: DM Sans, 14px

**Mood Row:**
- 5 emoji buttons
- Each: 48x56px
- Selected: Primary 30% background
- Unselected: Transparent
- Border radius: 8px

**Buttons:**
- Cancel: Secondary button (outlined)
- Save: Primary button
- Width: 45% each, centered

### 3.6 INSIGHTS SCREEN

**Layout:**
```
┌────────────────────────────┐
│ Your Insights              │
│ (Heading 2, 24px)          │
├────────────────────────────┤
│ ┌──────────────────────┐   │
│ │ 🔥 7 days            │   │
│ │    Current check-in  │   │
│ │    streak            │   │
│ └──────────────────────┘   │
│                            │
│ "Mood this week"           │
│ (Caption, 12px, 40%)       │
│ ┌──────────────────────┐   │
│ │ Mon ▁▂▃ 😤          │   │
│ │ Tue ▄▅▆ 😌          │   │
│ │ Wed ▁▂▃ 😢          │   │
│ │ ... (chart)          │   │
│ └──────────────────────┘   │
│                            │
│ "Your emotional patterns"  │
│ │ Anxiety: 3 times     │   │
│ │ Happy: 5 times       │   │
│ │ Sad: 2 times         │   │
│ (Stats list)               │
│                            │
└────────────────────────────┘
```

**Streak Card:**
- Full width, padding: 16px
- Background: Primary 10% opacity
- Border: 1px Primary 20%
- Border radius: 14px
- Layout: Icon (24px) + Text
- Fire emoji: 🔥
- Main text: "7 days", Lora 20px, weight 600, Primary color
- Sub text: "Current check-in streak", DM Sans 11px, White 50%

**Chart Section:**
- Title: "Mood this week", DM Sans 12px, White 40%, margin-bottom: 12px
- Card: Full width, padding 16px, White 4% bg, radius 12px
- Bar chart: 7 rows (days), each with:
  - Day label: 30px wide, DM Sans 9px
  - Bar: Variable width (0-100px), Primary color, radius 4px
  - Height: 8px
  - Space between: 8px vertical
  - Emoji: 16px, right side
- Spacing: 8px between each row

**Stats List:**
- Title: "Your emotional patterns", caption style
- Items: Each emotion with count
- Format: "Anxiety: 3 times"
- Font: DM Sans 13px
- Icon: Optional emoji
- Accent color: Based on emotion type

### 3.7 PROFILE SCREEN

**Layout:**
```
┌────────────────────────────┐
│                            │
│       ┌─────────┐          │
│       │ [AVATAR]│          │
│       │    A    │          │
│       └─────────┘          │
│    [UserName]              │
│   "Member since today"     │
│                            │
├────────────────────────────┤
│ ABOUT                      │
│ ┌──────────────────────┐   │
│ │ App Name Pillow Bud  │   │
│ │ Version 1.0.0        │   │
│ └──────────────────────┘   │
│                            │
│ CRISIS RESOURCES           │
│ ┌──────────────────────┐   │
│ │ iCall India          │   │
│ │ 9152987821     [📞]  │   │
│ └──────────────────────┘   │
│ ┌──────────────────────┐   │
│ │ Vandrevala Found.    │   │
│ │ 1860-2662-345  [📞]  │   │
│ └──────────────────────┘   │
│ ┌──────────────────────┐   │
│ │ AASRA                │   │
│ │ 9820466726     [📞]  │   │
│ └──────────────────────┘   │
│                            │
│ [SETTINGS] [FEEDBACK]      │
│                            │
└────────────────────────────┘
```

**Avatar:**
- Size: 60x60px
- Background: Gradient Primary -> Secondary
- Text: First letter of name, White, Lora 24px, weight 600
- Border radius: 50%

**User Info:**
- Name: Lora, 18px, weight 500
- "Member since today": DM Sans 11px, White 40%
- Center aligned

**Settings Section:**
- Title: "ABOUT", DM Sans 12px, weight 500, White 40%, margin-top: 24px
- Items: Each in card (White 4% bg, Border 1px, radius 10px, padding 12px)
- Row layout: Label (left) + Value (right)
- Font: DM Sans 12px

**Crisis Resources:**
- Title: "CRISIS RESOURCES"
- Each resource card:
  - Organization name: Bold, DM Sans 12px
  - Phone number: DM Sans 11px, White 50%
  - Icon: 📞 right-aligned, 18px
  - Tap: Open phone dialer
  - Background: Danger 8% opacity for emphasis
  - Border: Danger 15% opacity

**Bottom Buttons:**
- 2 buttons in row, 45% width each
- Centered
- Secondary button style
- Spacing: 12px between

---

## PART 4: COMPLETE TECHNICAL SPECIFICATIONS

### 4.1 TECHNOLOGY STACK

**Framework & Language:**
```
Framework:        Flutter 3.x (latest stable)
Language:         Dart 3.0+
Platform Support: iOS 15.0+, Android 8.0+ (API 26+)
Build Tools:      gradle 7.x (Android), xcode 14+ (iOS)
```

**State Management:**
```
Primary:          Riverpod 2.5.1
Components:
  - StateProvider (simple state)
  - StateNotifierProvider (complex state)
  - FutureProvider (async operations)
  - StreamProvider (streams)
  - Provider (read-only)
  - ProviderScope (root wrapper)
```

**Local Database:**
```
Database:         Isar 4.2.0
Features:         - Encrypted by default
                  - NoSQL (CRUD operations)
                  - Fast transactions
                  - Full-text search ready
Storage Location: Device app documents directory
```

**UI Framework:**
```
Material Design 3: useMaterial3: true
Cupertino:        For iOS-specific components
Responsive:       MediaQuery.of() for breakpoints
Adaptive:         Platform-aware (iOS vs Android)
```

**AI/ML Integration:**
```
Phase 1 (Now):    Mock responses (hardcoded)
Phase 2:          flutter_gemma 0.0.1+ (when ready)
                  OR Ollama REST API locally
Alternative:      ollama_dart (when ready)
Model:            Llama 3.2 1B (GGUF quantized)
Model Size:       ~700 MB (quantized q4_k_m)
```

**HTTP & Networking:**
```
HTTP Client:      dio 5.4.0
Timeout:          120 seconds for LLM requests
Retry Strategy:   3 retries on network error
```

**File & Storage:**
```
File Management:  path_provider 2.1.1
Prefs:            shared_preferences 2.2.2
Model Download:   background_downloader 7.15.0
```

**Fonts & Styling:**
```
Font Manager:     google_fonts 6.1.0
Fonts Used:       Lora (serif), DM Sans (sans)
Dynamic Fonts:    Optional size adjustment
```

**Animations:**
```
Animation Library: flutter_animate 4.3.0
Core Animations:  Flutter's built-in Curves
Transitions:      MaterialPageRoute, CupertinoPageRoute
```

**Utilities:**
```
ID Generation:    uuid 4.0.0
Date/Time:        intl 0.19.0
Markdown:         markdown 7.1.0 (for responses)
JSON Processing:  dart:convert (built-in)
```

### 4.2 ARCHITECTURE LAYERS

**Layer 1: Presentation (UI)**
```
Components:
  - Screens (7 total)
  - Widgets (reusable)
  - Theme system
  - Navigation

Data Flow: User interaction → Riverpod → Screen update
```

**Layer 2: State Management (Riverpod)**
```
Providers:
  - App state (userName, mood, etc.)
  - Theme state (dark/light, colors)
  - Chat state (messages, loading)
  - Journal state (entries)
  - LLM state (responses, emotions)
```

**Layer 3: Services**
```
Services:
  - EmotionDetector (keyword matching + intensity)
  - SystemPromptGenerator (context-aware prompts)
  - LLMService (mock/real responses)
  - CrisisDetector (safety checking)
  - StorageService (preferences)
  - PersonalizationService (user customization)
  - DateUtils (formatting)
```

**Layer 4: Models (Data Classes)**
```
Models:
  - ChatMessage (id, text, timestamp, isFromBud)
  - JournalEntry (id, text, mood, date)
  - UserPreference (settings, personality)
```

**Layer 5: Database (Isar)**
```
Collections:
  - ChatSessionIsar
  - ChatMessageIsar
  - JournalEntryIsar
  - MoodLogIsar
  - UserPreferencesIsar
```

**Layer 6: AI/ML**
```
Components:
  - System Prompt Generator
  - Emotion Detector
  - LLM (mock or real)
  - Crisis Detection
  - Response Filtering
```

### 4.3 DATA MODELS

**ChatMessage:**
```dart
ChatMessage {
  String id (uuid)
  String text
  bool isFromBud
  DateTime timestamp
  String sessionId
}
```

**JournalEntry:**
```dart
JournalEntry {
  String id (uuid)
  String text
  String mood (emoji)
  DateTime dateCreated
  DateTime dateModified
}
```

**UserPreference:**
```dart
UserPreference {
  String userName
  String buddyPersonality ('gentle'|'curious'|'wise'|'balanced')
  bool isDarkMode
  String primaryColor (hex)
  String secondaryColor (hex)
  bool onboardingCompleted
  DateTime? onboardingCompletedAt
}
```

**MoodLog:**
```dart
MoodLog {
  String moodId (uuid)
  String mood (emotion name)
  DateTime timestamp
  String? context (optional)
}
```

**ChatSession:**
```dart
ChatSession {
  String id (uuid)
  String userName
  List<ChatMessage> messages
  DateTime createdAt
  DateTime lastModified
}
```

### 4.4 RIVERPOD PROVIDERS STRUCTURE

```dart
// User Data
userNameProvider = StateProvider<String>
userPreferenceProvider = StateProvider<UserPreference>
onboardingCompletedProvider = StateProvider<bool>

// Mood & Emotion
currentMoodProvider = StateProvider<String>
currentEmotionProvider = StateProvider<String>
emotionIntensityProvider = StateProvider<double>

// Chat
chatMessagesProvider = StateProvider<List<ChatMessage>>
isLoadingChatProvider = StateProvider<bool>
currentChatIdProvider = StateProvider<String>
budResponseProvider = FutureProvider.family<String, String>

// Journal
journalEntriesProvider = StateProvider<List<JournalEntry>>

// UI
isDarkModeProvider = StateProvider<bool>
isModelLoadingProvider = StateProvider<bool>
modelLoadingProgressProvider = StateProvider<double>
selectedThemeProvider = StateProvider<String>

// Theme
primaryColorProvider = StateProvider<Color>
secondaryColorProvider = StateProvider<Color>
currentThemeProvider = StateProvider<Map<String, Color>>

// LLM
llmServiceProvider = Provider<LLMService>
buddyPersonalityProvider = StateProvider<String>
isLoadingResponseProvider = StateProvider<bool>
```

### 4.5 FILE STRUCTURE & ORGANIZATION

```
pillow_bud/
├── lib/
│   ├── main.dart
│   │
│   ├── config/
│   │   ├── constants.dart (crisis resources, triggers)
│   │   └── app_config.dart (timings, settings)
│   │
│   ├── theme/
│   │   ├── app_colors.dart (all colors, hex values)
│   │   └── app_theme.dart (ThemeData, text styles)
│   │
│   ├── models/
│   │   ├── chat_message.dart
│   │   ├── journal_entry.dart
│   │   └── user_preference.dart
│   │
│   ├── services/
│   │   ├── emotion_detector.dart
│   │   ├── system_prompt_generator.dart
│   │   ├── llm_service.dart
│   │   ├── crisis_detector.dart
│   │   ├── storage_service.dart
│   │   ├── date_utils.dart
│   │   └── personalization_service.dart
│   │
│   ├── providers/
│   │   ├── app_state_provider.dart
│   │   ├── theme_provider.dart
│   │   └── llm_provider.dart
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── home_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── journal_screen.dart
│   │   ├── insights_screen.dart
│   │   └── profile_screen.dart
│   │
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   └── secondary_button.dart
│   │   ├── cards/
│   │   │   └── mood_card.dart
│   │   └── indicators/
│   │       └── typing_indicator.dart
│   │
│   └── utils/
│       └── extensions.dart
│
├── assets/
│   ├── fonts/
│   │   ├── Lora-Regular.ttf
│   │   ├── Lora-Medium.ttf
│   │   ├── Lora-SemiBold.ttf
│   │   ├── DMSans-Regular.ttf
│   │   ├── DMSans-Medium.ttf
│   │   └── DMSans-SemiBold.ttf
│   │
│   └── images/
│       └── .gitkeep
│
├── android/
│   └── app/
│       ├── build.gradle
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── kotlin/com/pillow_bud/app/MainActivity.kt
│           └── res/
│               ├── mipmap-ldpi/ic_launcher.png
│               ├── mipmap-mdpi/ic_launcher.png
│               ├── mipmap-hdpi/ic_launcher.png
│               ├── mipmap-xhdpi/ic_launcher.png
│               ├── mipmap-xxhdpi/ic_launcher.png
│               ├── mipmap-xxxhdpi/ic_launcher.png
│               └── values/
│                   ├── styles.xml
│                   └── values-night/styles.xml
│
├── ios/
│   └── Runner/
│       ├── Info.plist
│       └── Assets.xcassets/AppIcon.appiconset/
│
├── pubspec.yaml
├── pubspec.lock
├── .gitignore
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

---

## PART 5: COMPLETE REQUIREMENTS & IMPLEMENTATION DETAILS

### 5.1 FUNCTIONAL REQUIREMENTS

**User Management:**
- [ ] User can enter name during onboarding
- [ ] User can select personality mode (gentle/curious/wise/balanced)
- [ ] User preferences saved locally (SharedPreferences)
- [ ] User can change personality anytime in settings
- [ ] User data never sent to any server

**Chat Functionality:**
- [ ] User can type messages
- [ ] Emotion automatically detected from message
- [ ] Crisis phrases detected and handled appropriately
- [ ] Bud responds emotionally intelligently
- [ ] Responses adapt to detected emotion
- [ ] Responses adapt to personality mode
- [ ] Conversation history tracked and saved
- [ ] Typing indicator shows while generating response
- [ ] Messages displayed in asymmetric chat bubbles
- [ ] Smooth message animation on entrance
- [ ] Auto-scroll to newest message
- [ ] Can scroll up to see conversation history

**Journal Functionality:**
- [ ] User can create journal entries
- [ ] Entries show date (Today/Yesterday/Date format)
- [ ] Entries tagged with mood emoji
- [ ] Entries saved locally in database
- [ ] User can view all entries in list
- [ ] Tap entry to view full text (optional: edit/delete)
- [ ] Empty state when no entries

**Insights Functionality:**
- [ ] Show check-in streak (days in a row)
- [ ] Display weekly mood chart
- [ ] Show mood distribution statistics
- [ ] Display emotional patterns
- [ ] All data calculated from local entries

**Settings & Customization:**
- [ ] User can change personality mode
- [ ] User can select from 5 theme presets
- [ ] User can customize colors (hue/saturation/brightness)
- [ ] User can adjust font size
- [ ] User can toggle dark/light mode
- [ ] All settings saved locally
- [ ] Settings apply immediately (real-time)

**Crisis Safety:**
- [ ] 15+ crisis trigger phrases detected
- [ ] When triggered, show crisis helpline popup
- [ ] Show 3 Indian crisis resources (iCall, Vandrevala, AASRA)
- [ ] Compassionate messaging
- [ ] Allow user to close and continue or call

**App Settings:**
- [ ] About section (app name, version)
- [ ] Crisis resources with phone numbers
- [ ] Settings button (optional)
- [ ] Feedback button (optional)

### 5.2 NON-FUNCTIONAL REQUIREMENTS

**Performance:**
- App loads in < 2 seconds
- Responses from Bud within 1-2 seconds (mock: instant, real Llama: 3-5s)
- Smooth 60 FPS animations
- No jank when scrolling
- Memory usage < 100 MB typical
- Storage footprint < 50 MB (app only, not including model)

**Reliability:**
- App doesn't crash
- Graceful error handling
- Data persists after app restart
- Works offline completely
- No network calls (after model download)

**Security & Privacy:**
- All data stored locally (never cloud)
- Database encrypted by default (Isar)
- No telemetry or analytics
- No tracking pixels
- No ads
- User data deletable
- Source code open source (Apache 2.0)

**Accessibility:**
- WCAG AA contrast ratio compliance (18:1 on dark)
- Min touch target 48x48 dp
- Semantic widgets for screen readers
- No color-only information
- Text scalable

**Localization (Future):**
- Ready for multi-language
- Date formatting locale-aware
- Text direction support (RTL)

### 5.3 IMPLEMENTATION CHECKLIST

**Phase 1: Setup & Foundation**
- [ ] Flutter project created
- [ ] Dependencies added to pubspec.yaml
- [ ] Folder structure created
- [ ] Config files created (constants, colors, theme)
- [ ] Models defined (ChatMessage, JournalEntry, UserPreference)
- [ ] Riverpod providers setup

**Phase 2: Services Layer**
- [ ] EmotionDetector implemented (10 emotions, intensity calculation)
- [ ] SystemPromptGenerator implemented (4 personality modes)
- [ ] LLMService implemented (mock responses)
- [ ] CrisisDetector implemented (15 phrases)
- [ ] StorageService implemented (SharedPreferences)
- [ ] PersonalizationService implemented

**Phase 3: Screens**
- [ ] SplashScreen (2 sec animation)
- [ ] OnboardingScreen (5 screens, PageView)
- [ ] HomeScreen (greeting, mood picker, preview, CTA)
- [ ] ChatScreen (messages, bubbles, typing indicator, input)
- [ ] JournalScreen (list, new entry dialog, FAB)
- [ ] InsightsScreen (charts, stats, streak)
- [ ] ProfileScreen (user info, settings, crisis resources)
- [ ] Navigation between screens (BottomNavigationBar)

**Phase 4: Widgets**
- [ ] PrimaryButton (elevated, full width)
- [ ] SecondaryButton (outlined)
- [ ] TypingIndicator (3-dot animation)
- [ ] MoodCard (card component)
- [ ] Custom text inputs (rounded, styled)

**Phase 5: Theming**
- [ ] Dark theme implemented (default)
- [ ] Light theme implemented
- [ ] All colors used from app_colors.dart
- [ ] Typography applied correctly
- [ ] Spacing consistent

**Phase 6: Icon & Configuration**
- [ ] App icon created (512x512)
- [ ] Icon variants generated (all sizes)
- [ ] Icons placed in Android mipmap folders
- [ ] Icons placed in iOS Assets
- [ ] Android build.gradle updated
- [ ] AndroidManifest.xml configured
- [ ] MainActivity.kt created
- [ ] styles.xml created (light/dark)
- [ ] iOS Info.plist updated

**Phase 7: Testing**
- [ ] Flutter build succeeds
- [ ] App launches on Android device
- [ ] App launches on iOS device (if available)
- [ ] All screens navigable
- [ ] Onboarding works (save name, personality)
- [ ] Chat works (emotion detection, responses)
- [ ] Journal works (create, save, display)
- [ ] Icon visible on home screen
- [ ] App works offline
- [ ] No crashes

**Phase 8: AI Integration (Optional)**
- [ ] Mock system fully tested
- [ ] Ollama installed (optional)
- [ ] Ollama connected to app (optional)
- [ ] Real responses tested
- [ ] Response quality validated

**Phase 9: Deployment**
- [ ] GitHub repository created
- [ ] Code pushed to GitHub
- [ ] README written
- [ ] LICENSE added (Apache 2.0)
- [ ] Release created (v1.0.0)
- [ ] APK built and tested
- [ ] GitHub release published

---

## PART 6: EMOTIONAL INTELLIGENCE SYSTEM SPECIFICATIONS

### 6.1 EMOTION DETECTION

**Supported Emotions:**
```
1. Overwhelmed   - feeling too much at once
2. Anxious       - worried, nervous, scared
3. Sad           - depressed, down, empty
4. Lonely        - isolated, disconnected
5. Stressed      - pressure, busy, tense
6. Confused      - lost, uncertain, mixed up
7. Hopeful       - optimistic, improving
8. Calm          - peaceful, centered, grounded
9. Angry         - furious, mad, resentful
10. Uncertain    - unsure, indecisive
```

**Detection Method:**
```
Primary: Keyword matching (case-insensitive)
Secondary: Intensity markers detection
Result: Emotion name + intensity (0-1 scale)
```

**Intensity Markers:**
```
1.8: "unbearable"
1.7: "extremely"
1.6: "absolute", "intense"
1.5: "very", "completely", "total"
1.3: "so", "can't"
1.2: "really"
```

Default intensity: 0.5 (neutral)
Intensity range: 0.0 - 1.0 (clamped)

### 6.2 SYSTEM PROMPT GENERATION

**Base Prompt Template:**
```
You are Bud, an emotionally intelligent companion for [UserName].

Your role is to:
- Listen deeply and validate feelings
- Ask gentle, thoughtful follow-up questions
- Provide perspective when appropriate
- Be genuinely empathetic and human
- Create emotional safety through presence

You are NOT:
- A therapist (don't diagnose or treat)
- A life coach (don't give directives)
- A friend replacing real relationships
- An AI using corporate language
```

**Personality Modifications:**

GENTLE MODE:
```
- Focus primarily on listening and validation
- Use: "I hear you," "That makes sense," "That's valid"
- Ask minimal questions, mostly reflective
- Tone: soft, reassuring, grounding
- Goal: Help them feel less alone
```

CURIOUS MODE:
```
- Ask open-ended questions
- Use: "Tell me more," "I'm wondering," "What do you think..."
- Help them explore and discover
- Tone: warm, exploratory, engaged
- Goal: Deepen understanding of situation
```

WISE MODE:
```
- Offer reflective insights
- Use: "It sounds like," "I notice," "From what you've shared"
- Share observations for perspective
- Tone: thoughtful, grounded, philosophical
- Goal: Offer gentle wisdom without preaching
```

BALANCED MODE:
```
- Mix validation, curiosity, and wisdom
- Adapt to what moment needs
- Start with validation, add questions if helpful
- Tone: warm, present, flexible
- Goal: Meet them where they are
```

**Emotion-Specific Guidance:**

OVERWHELMED (Intensity: 0.7+):
```
- Acknowledge weight they're carrying
- Validate "this IS a lot"
- Help narrow focus
- Key phrases: "This is a lot," "One thing at a time"
- Question: "What's the smallest thing you need to address?"
```

ANXIOUS (Intensity: 0.7+):
```
- Validate worry (don't minimize)
- Offer grounding (not false reassurance)
- Distinguish worry from reality
- Key phrases: "That worry makes sense," "What's actually happening now?"
- If severe: Suggest 5-senses grounding
```

SAD:
```
- Create space for sadness
- Don't rush to fix it
- Explore what's underneath
- Key phrases: "That's worth feeling sad about," "What are you grieving?"
- Avoid: Toxic positivity, "silver linings"
```

LONELY:
```
- Validate pain of loneliness
- Help feel less alone through presence
- Explore isolation and connection
- Key phrases: "Loneliness is real," "You matter," "I'm listening"
- Ask: "Who could you reach out to?"
```

STRESSED:
```
- Acknowledge as legitimate
- Help identify stressors and control
- Offer perspective on what matters
- Key phrases: "That's stressful," "What can you control?"
- Normalize: Stress is a signal, not failure
```

CONFUSED:
```
- Validate confusion as okay
- Help think through it
- Break unclear into specific questions
- Key phrases: "Let's untangle this," "What's confusing?"
- Use: Questions to help clarify
```

HOPEFUL:
```
- Acknowledge and amplify hope
- Explore what created shift
- Support forward movement
- Key phrases: "That's wonderful," "What changed?", "Keep going"
- Avoid: Jinxing with warnings
```

CALM:
```
- Celebrate and protect calm
- Help anchor the feeling
- Explore what creates peace
- Key phrases: "Hold onto that," "What helps you feel this way?"
- Use: To deepen self-understanding
```

ANGRY:
```
- Validate anger without fear
- Often indicates something matters or boundary crossed
- Help understand what's underneath
- Key phrases: "Your anger makes sense," "What happened?"
- Avoid: Telling them to calm down
```

UNCERTAIN:
```
- Normalize uncertainty
- Help sit with not-knowing
- Explore what would help (action/acceptance/info)
- Key phrases: "It's okay to not know," "What would help most?"
- Avoid: False certainty
```

### 6.3 RESPONSE QUALITY STANDARDS

**Every response must:**
- [ ] Acknowledge specific emotion mentioned
- [ ] Match intensity of their emotion
- [ ] Use natural language and contractions
- [ ] Avoid clichés and generic advice
- [ ] Show genuine understanding
- [ ] Be under 200 words
- [ ] Not pretend to have personal experiences
- [ ] Avoid toxic positivity
- [ ] Include question or space for them to continue (usually)
- [ ] Feel human, not robotic

**Responses must NOT:**
- [ ] Diagnose mental health conditions
- [ ] Prescribe treatment or therapy
- [ ] Suggest therapy is unnecessary (if serious concern)
- [ ] Minimize their feelings
- [ ] Offer false reassurance
- [ ] Use corporate/AI language
- [ ] Be patronizing
- [ ] Make promises about future outcomes
- [ ] Suggest immediate radical changes

---

## PART 7: SPECIFIC IMPLEMENTATION CODE REQUIREMENTS

### 7.1 MAIN.DART REQUIREMENTS

```dart
MUST INCLUDE:
- ProviderScope wrapper
- Material app with theme
- Dark theme as default
- Splash screen as home
- No debug banner
- Proper error handling
```

### 7.2 APP_COLORS.DART REQUIREMENTS

```dart
MUST INCLUDE:
- All hex colors defined as constants
- Color(0xFFHEXVALUE) format
- Opacity variants for each color
- withOpacity() methods
- Exported as public constants
```

### 7.3 LLM_SERVICE.DART REQUIREMENTS

```dart
MUST INCLUDE:
- Emotion detection call
- System prompt generation call
- Mock response generation
- Crisis detection check
- Conversation history tracking
- Try-catch error handling
- Clear commenting
```

### 7.4 EMOTION_DETECTOR.DART REQUIREMENTS

```dart
MUST INCLUDE:
- Static keyword list for each emotion
- Case-insensitive matching
- Intensity marker detection
- Return emotion name + intensity
- Handle empty/neutral input
- All 10 emotions covered
```

### 7.5 CHAT_SCREEN.DART REQUIREMENTS

```dart
MUST INCLUDE:
- Riverpod integration
- Message state management
- Typing indicator during response
- Emotion indicator in header
- Asymmetric bubbles (user right, Bud left)
- Input field + send button
- Auto-scroll to bottom
- Crisis detection popup
- All animations working
```

### 7.6 PUBSPEC.YAML REQUIREMENTS

```yaml
MUST INCLUDE:
- All dependencies listed
- Correct versions (no breaking changes)
- Assets section (fonts, images)
- Flutter material design
- Fonts registered correctly
- No dev dependencies in production
```

---

## PART 8: BUILD & DEPLOYMENT REQUIREMENTS

### 8.1 ANDROID BUILD

```
Min SDK: 26 (Android 8.0)
Target SDK: 34 (Android 14)
Package: com.pillow_bud.app
App Name: Pillow Bud
Icon: Properly placed in all mipmap folders
```

### 8.2 iOS BUILD

```
Min version: iOS 15.0
Bundle ID: com.pillow_bud.app
App Name: Pillow Bud
Icon: Placed in AppIcon.appiconset
```

### 8.3 GITHUB REQUIREMENTS

```
Repo: pillow-bud
License: Apache 2.0
README: Complete with instructions
CONTRIBUTING: Included
.gitignore: Proper Flutter ignores
Releases: v1.0.0 with APK
```

---

## PART 9: EXECUTION INSTRUCTIONS

### 9.1 STEP-BY-STEP IMPLEMENTATION

1. **Create Flutter Project**
   ```bash
   flutter create pillow_bud
   cd pillow_bud
   flutter doctor
   ```

2. **Copy All Code Files** (from COMPLETE_FILE_STRUCTURE.md)
   - Create each file in correct location
   - Copy code exactly
   - Verify all imports

3. **Download Fonts**
   - Lora from Google Fonts
   - DM Sans from Google Fonts
   - Place in assets/fonts/

4. **Create App Icon**
   - Use appicon.co
   - Generate all sizes
   - Place in mipmap folders (Android)
   - Place in Assets.xcassets (iOS)

5. **Update Configuration Files**
   - android/app/build.gradle
   - android/app/src/main/AndroidManifest.xml
   - android/app/src/main/kotlin/MainActivity.kt
   - android/app/src/main/res/values/styles.xml
   - ios/Runner/Info.plist

6. **Get Dependencies**
   ```bash
   flutter pub get
   ```

7. **Test**
   ```bash
   flutter run
   ```

8. **Verify**
   - App launches
   - Icon on home screen
   - All screens accessible
   - Chat works
   - No crashes

### 9.2 VERIFICATION CHECKLIST

Before declaring complete:
- [ ] App icon visible on home screen
- [ ] Splash screen shows for 2 seconds
- [ ] Onboarding completes successfully
- [ ] Home screen displays with greeting
- [ ] Chat works (emotion detected, responses shown)
- [ ] Journal creates and saves entries
- [ ] Insights shows data
- [ ] Settings work
- [ ] All colors match specifications
- [ ] All fonts load correctly
- [ ] App works offline
- [ ] No console errors
- [ ] No crashes during normal use
- [ ] Animations smooth (60 FPS)
- [ ] Touch targets >= 48x48 dp

---

## SUMMARY

You now have a **complete, detailed specification** for Pillow Bud that includes:

✅ **Design System**
- All colors (hex values)
- Typography (sizes, weights, usage)
- Spacing, borders, shadows
- Theme system (5 presets + custom)

✅ **UI/UX Specifications**
- Every screen detailed
- Component specifications
- Layout dimensions
- Interactive behavior

✅ **Technical Stack**
- All dependencies with versions
- Architecture (6 layers)
- Data models
- Riverpod provider structure

✅ **Requirements**
- Functional (what it does)
- Non-functional (performance, security)
- Implementation checklist
- Verification steps

✅ **Emotional Intelligence**
- Emotion detection system
- System prompt generation
- Personality modes
- Response quality standards

✅ **Implementation Guide**
- Step-by-step execution
- File structure
- Configuration details
- Testing procedures

---

**This prompt contains everything needed to build Pillow Bud.**

Paste this entire prompt into Claude, Copilot, ChatGPT, or any AI coding assistant.

It will understand:
- Exactly what to build
- How it should look
- How it should function
- Technical requirements
- Every detail matters

The AI will generate production-ready code aligned with these specifications.

---

## END OF COMPLETE MASTER PROMPT

**Copy everything above. Paste into your AI of choice. Build Pillow Bud.** 💙🛏️
