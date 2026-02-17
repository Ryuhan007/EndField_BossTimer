#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================
; Keys
; =========================
;TOGGLE_KEY := "PgUp"      ; 시작/정지 토글
TOGGLE_KEY := "``"      ; 시작/정지 토글
;RESET_KEY  := "^PgUp"     ; Ctrl+PgUp 리셋
RESET_KEY  := "^``"     ; Ctrl+PgUp 리셋
F12::ExitApp             ; 종료(원하면 주석 처리)

; =========================
; Style (여기만 조절)
; =========================
FONT_NAME := "Consolas"
FONT_SIZE := 25
BG_ALPHA  := 180         ; 0~255 (낮을수록 더 투명)

TEXT_W := 220             ; 중앙정렬 기준 폭(좌우 치우치면 늘려)
TEXT_H := 40

POS_X := 200              ; 시작 위치
POS_Y := 200

; =========================
; State
; =========================
running   := false
startTick := 0
elapsedMs := 0

; =========================
; GUI
; =========================
gTimer := Gui("+AlwaysOnTop -Caption +ToolWindow")
gTimer.BackColor := "000000"
WinSetTransparent(BG_ALPHA, gTimer.Hwnd)

gTimer.SetFont("s" FONT_SIZE " bold", FONT_NAME)

tText := gTimer.AddText(
    "x0 y0 w" TEXT_W " h" TEXT_H " Center cFFFFFF",
    "00:00.000"
)

gTimer.Show("NoActivate x" POS_X " y" POS_Y " w" TEXT_W " h" TEXT_H)

; =========================
; Drag to move
; =========================
OnMessage(0x201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(*) {
    PostMessage(0xA1, 2) ; 드래그 이동
}

; =========================
; Hotkeys
; =========================
Hotkey("$" TOGGLE_KEY, ToggleTimer)
Hotkey("$" RESET_KEY, ResetTimer)

; =========================
; Functions
; =========================
ToggleTimer(*) {
    global running, startTick, elapsedMs
    if !running {
        running := true
        startTick := A_TickCount - elapsedMs
        SetTimer(UpdateTimer, 16)
    } else {
        running := false
        elapsedMs := A_TickCount - startTick
        SetTimer(UpdateTimer, 0)
        UpdateTimer()
    }
}

ResetTimer(*) {
    global running, elapsedMs
    running := false
    elapsedMs := 0
    SetTimer(UpdateTimer, 0)
    UpdateTimer()
}

UpdateTimer(*) {
    global running, startTick, elapsedMs, tText
    ms := running ? (A_TickCount - startTick) : elapsedMs

    min := Floor(ms / 60000)
    sec := Floor(Mod(ms, 60000) / 1000)
    mmm := Mod(ms, 1000)

    tText.Value := Format("{:02}:{:02}.{:03}", min, sec, mmm)
}
