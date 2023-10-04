#NoEnv
#SingleInstance, force
SetMouseDelay,-1
SetDefaultMouseSpeed, 0
SetKeyDelay, 0
SetControlDelay -1
SetBatchLines, -1
global TibiaFileDir, GuiVersion
IniRead, TibiaFileDir, TibiaSettings.ini, Config, MHPath
Menu, Tray, NoStandard
global TibiaVersion
global settingsFile := A_WorkingDir "\TibiaSettings.ini"
global defaultSettingsFile
global userData
global timeAHRemaining
global TColor:="378ED6", GColor1:=242424, GColor2:=333333
global ProfileComb, HKProfileComb, Vocation, Locked, LockedID
global HotkeysConfigured := []
global Macro := 0, Waiting := 1, SleepExaust1sg, SleepExaust500ms, SleepFast
global StartButton := 0, ConfigHotkeys:="ConfigHotkeys"
global Timer := { exaustFood: 0, exaustRing: 0, exaustSupport: 0, exaustNormalFood: 0, AntiAfk: 0, exaustAmulet: 0, exaustAmmo: 0, exaustSpecialPotion: 0, exaustWeapon: 0, exaustPotion: 0, ClickAttack: 0, exaustDummy: 0, Targeting: 1, TimedSpell1: 0, TimedSpell2: 0, TimedSpell3: 0, OCRQuiver: 0, exaustBoots: 0, exaustMagicShield: 0, SecondaryBattleList: 0, MessagesSound: 0, exaustGoldConverter: 0, TakeFromFloor: 0 }
global connectionLost := 0
global LootMessage := []
global Ptr := A_PtrSize ? "UPtr" : "UInt"
      global WindowInfo := []
      global WinID, IDClassNN, WinExE, MHTibia, ConfigID, RunningID, ComboID
      global AllReads := []
      global PNG := []
      global Hotkeys:=[]
      global InI:=[]
      global Tabs:=[]
      global SQTLoot:=[]
      global SP:=[]
      global isAttacking := False
      global emptyBattle := False
      global TargetingCounter := 5
      global ProfileToCopy
      global GlobalLanguage := "Portuguese"
      global VersionType := "OTServer"
      global WindowTitle, FindProcessesID, arrLIST
      global ArColor:=[], Data:=[], Dados:=[], Cords:=[], OldLootCor:="Nada"
      Data.ServerIPPort := "http://207.180.226.91:1447/AHK"
      Cords.Potions:=[]
      global classButton:=[], PartyListButton:=[]
      global bw := 0 , bh := 0, TogWinTab := 0, MoveTest:=0
      global ProcBitBlt, ProcCreateBitmap, ProcBitmapLock, ProcBitmapUnlock, ProcDisposeImage
      global StrideBit, ScanBit, PNGScanWidth, PNGScanHeight, ImageSearchMCode
      class classOBJ {
            __New(file) {
                  if !FileExist(file)
                        FileAppend,% emptyvar,% file
                  else {
                        FileRead, src, % file
                        Temp := this.base
                        this := this.objLoad(src)
                        if ( !IsObject(this) )
                              this := {}
                        this.base := Temp
                  }
                  this.file := file
                  Return this
            }
            Write(Section, Key, Value) {
                  if ( !IsObject(this[Section]) )
                        this[Section] := {}
                  if (value == "")
                        this[Section].Remove(Key)
                  else
                        this[Section][Key] := value
            }
            Save(obj) {
                  saveObj := this.objSave(obj)
                  FileDelete, % this.file
                  FileAppend, % saveObj, % this.file
            }
            objLoad(ByRef src) {
                  static q := Chr(34)
                  key := ""
                  is_key := false
                  stack := [ tree := [] ]
                  is_arr := { (tree): 1 }
                  pos := 0
                  while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
                        if InStr(" `t`n`r", ch)
                              continue
                        is_array := is_arr[obj := stack[1]]
                        if i := InStr("{[", ch) {
                              val := {}
                              is_array ? ObjPush(obj, val) : obj[key] := val
                              ObjInsertAt(stack, 1, val)
                              is_arr[val] := !(is_key := ch == "{")
                        }
                        else if InStr("}]", ch)
                              ObjRemoveAt(stack, 1)
                        else if InStr(",:", ch)
                              is_key := (!is_array && ch == ",")
                        else {
                              if (ch == q) {
                                    i := pos
                                    i := InStr(src, q,, i+1)
                                    val := SubStr(src, pos+1, i-pos-1)
                                    pos := i
                                    i := 0
                                    if is_key {
                                          key := val
                                          continue
                                    }
                              }
                              else {
                                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos) + 0
                                    pos += i-1
                              }
                              is_array ? ObjPush(obj, val) : obj[key] := val
                        }
                  }
                  return tree[1]
            }
            objSave(obj) {
                  static q := Chr(34)
                  if IsObject(obj) {
                        is_array := 0, out := ""
                        for k in obj
                              is_array := k == A_Index
                        until !is_array
                        for k, v in obj {
                              if !is_array
                                    out .= ( ObjGetCapacity([k], 1) ? this.objSave(k) : q . k . q ) . ":"
                              out .= this.objSave(v) . ","
                        }
                        if (out != "")
                              out := Trim(out, ",")
                        return is_array ? "[" . out . "]" : "{" . out . "}"
                  }
                  else if (ObjGetCapacity([obj], 1) == "")
                        return obj
                  return q . obj . q
            }
      }
      class bcrypt
      {
            static BCRYPT_OBJECT_LENGTH := "ObjectLength"
            static BCRYPT_HASH_LENGTH := "HashDigestLength"
            static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008
            static hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr")
            hash(String, AlgID, encoding := "utf-8")
            {
                  AlgID := this.CheckAlgorithm(AlgID)
                  ALG_HANDLE := this.BCryptOpenAlgorithmProvider(AlgID)
                  OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
                  HASH_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
                  HASH_HANDLE := this.BCryptCreateHash(ALG_HANDLE, HASH_OBJECT, OBJECT_LENGTH)
                  this.BCryptHashData(HASH_HANDLE, STRING, encoding)
                  HASH_LENGTH := this.BCryptFinishHash(HASH_HANDLE, HASH_LENGTH, HASH_DATA)
                  hash := this.CalcHash(HASH_DATA, HASH_LENGTH)
                  this.BCryptDestroyHash(HASH_HANDLE)
                  this.BCryptCloseAlgorithmProvider(ALG_HANDLE)
                  return hash
            }
            hmac(String, Hmac, AlgID, encoding := "utf-8")
            {
                  AlgID := this.CheckAlgorithm(AlgID)
                  ALG_HANDLE := this.BCryptOpenAlgorithmProvider(AlgID, this.BCRYPT_ALG_HANDLE_HMAC_FLAG)
                  OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
                  HASH_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
                  HASH_HANDLE := this.BCryptCreateHmac(ALG_HANDLE, HMAC, HASH_OBJECT, OBJECT_LENGTH, encoding)
                  this.BCryptHashData(HASH_HANDLE, STRING, encoding)
                  HASH_LENGTH := this.BCryptFinishHash(HASH_HANDLE, HASH_LENGTH, HASH_DATA)
                  hash := this.CalcHash(HASH_DATA, HASH_LENGTH)
                  this.BCryptDestroyHash(HASH_HANDLE)
                  this.BCryptCloseAlgorithmProvider(ALG_HANDLE)
                  return hash
            }
            BCryptOpenAlgorithmProvider(ALGORITHM, FLAGS := 0)
            {
                  if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", BCRYPT_ALG_HANDLE
                        , "ptr", &ALGORITHM
                  , "ptr", 0
                  , "uint", FLAGS) != 0)
                  throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)
                  return BCRYPT_ALG_HANDLE
            }
            BCryptGetProperty(BCRYPT_HANDLE, PROPERTY, cbOutput)
            {
                  if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", BCRYPT_HANDLE
                        , "ptr", &PROPERTY
                  , "uint*", pbOutput
                  , "uint", cbOutput
                  , "uint*", cbResult
                  , "uint", 0) != 0)
                  throw Exception("BCryptGetProperty: " NT_STATUS, -1)
                  return pbOutput
            }
            BCryptCreateHash(BCRYPT_ALG_HANDLE, ByRef pbHashObject, cbHashObject)
            {
                  VarSetCapacity(pbHashObject, cbHashObject, 0)
                  if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", BCRYPT_ALG_HANDLE
                        , "ptr*", BCRYPT_HASH_HANDLE
                  , "ptr", &pbHashObject
                  , "uint", cbHashObject
                  , "ptr", 0
                  , "uint", 0
                  , "uint", 0) != 0)
                  throw Exception("BCryptCreateHash: " NT_STATUS, -1)
                  return BCRYPT_HASH_HANDLE
            }
            BCryptCreateHmac(BCRYPT_ALG_HANDLE, HMAC, ByRef pbHashObject, cbHashObject, encoding := "utf-8")
            {
                  VarSetCapacity(pbHashObject, cbHashObject, 0)
                  VarSetCapacity(pbSecret, (StrPut(HMAC, encoding) - 1) * ((encoding = "utf-16" || encoding = "cp1200") ? 2 : 1), 0)
                  cbSecret := StrPut(HMAC, &pbSecret, encoding) - 1
                  if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", BCRYPT_ALG_HANDLE
                        , "ptr*", BCRYPT_HASH_HANDLE
                  , "ptr", &pbHashObject
                  , "uint", cbHashObject
                  , "ptr", &pbSecret
                  , "uint", cbSecret
                  , "uint", 0) != 0)
                  throw Exception("BCryptCreateHash: " NT_STATUS, -1)
                  return BCRYPT_HASH_HANDLE
            }
            BCryptHashData(BCRYPT_HASH_HANDLE, STRING, encoding := "utf-8")
            {
                  VarSetCapacity(pbInput, (StrPut(STRING, encoding) - 1) * ((encoding = "utf-16" || encoding = "cp1200") ? 2 : 1), 0)
                  cbInput := StrPut(STRING, &pbInput, encoding) - 1
                  if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", BCRYPT_HASH_HANDLE
                        , "ptr", &pbInput
                  , "uint", cbInput
                  , "uint", 0) != 0)
                  throw Exception("BCryptHashData: " NT_STATUS, -1)
                  return true
            }
            BCryptHashFile(BCRYPT_HASH_HANDLE, pbInput, cbInput)
            {
                  if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", BCRYPT_HASH_HANDLE
                        , "ptr", &pbInput
                  , "uint", cbInput
                  , "uint", 0) != 0)
                  throw Exception("BCryptHashData: " NT_STATUS, -1)
                  return true
            }
            BCryptFinishHash(BCRYPT_HASH_HANDLE, cbOutput, ByRef pbOutput)
            {
                  VarSetCapacity(pbOutput, cbOutput, 0)
                  if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr", BCRYPT_HASH_HANDLE
                        , "ptr", &pbOutput
                  , "uint", cbOutput
                  , "uint", 0) != 0)
                  throw Exception("BCryptFinishHash: " NT_STATUS, -1)
                  return cbOutput
            }
            BCryptDestroyHash(BCRYPT_HASH_HANDLE)
            {
                  if (NT_STATUS := DllCall("bcrypt\BCryptDestroyHash", "ptr", BCRYPT_HASH_HANDLE) != 0)
                        throw Exception("BCryptDestroyHash: " NT_STATUS, -1)
                  return true
            }
            BCryptCloseAlgorithmProvider(BCRYPT_ALG_HANDLE)
            {
                  if (NT_STATUS := DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", BCRYPT_ALG_HANDLE
                        , "uint", 0) != 0)
                  throw Exception("BCryptCloseAlgorithmProvider: " NT_STATUS, -1)
                  return true
            }
            CheckAlgorithm(ALGORITHM)
            {
                  static HASH_ALGORITHM := ["MD2", "MD4", "MD5", "SHA1", "SHA256", "SHA384", "SHA512"]
                  for index, value in HASH_ALGORITHM
                        if (value = ALGORITHM)
                        return Format("{:U}", ALGORITHM)
                  throw Exception("Invalid hash algorithm", -1, ALGORITHM)
            }
            CalcHash(Byref HASH_DATA, HASH_LENGTH)
            {
                  loop % HASH_LENGTH
                        HASH .= Format("{:02x}", NumGet(HASH_DATA, A_Index - 1, "uchar"))
                  return HASH
            }
      }
      UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255) {
            Static Ptr := "UPtr"
            if ((x != "") && (y != ""))
                  VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")
            if (w = "") || (h = "")
                  GetWindowRect(hwnd, W, H)
            return DllCall("UpdateLayeredWindow"
            , Ptr, hwnd
            , Ptr, 0
            , Ptr, ((x = "") && (y = "")) ? 0 : &pt
            , "int64*", w|h<<32
            , Ptr, hdc
            , "int64*", 0
            , "uint", 0
            , "UInt*", Alpha<<16|1<<24
            , "uint", 2)
      }
      BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, raster:="") {
            Static Ptr := "UPtr"
            return DllCall("gdi32\BitBlt"
            , Ptr, dDC
            , "int", dX, "int", dY
            , "int", dW, "int", dH
            , Ptr, sDC
            , "int", sX, "int", sY
            , "uint", Raster ? Raster : 0x00CC0020)
      }
      StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster:="") {
            Static Ptr := "UPtr"
            return DllCall("gdi32\StretchBlt"
            , Ptr, ddc
            , "int", dX, "int", dY
            , "int", dW, "int", dH
            , Ptr, sdc
            , "int", sX, "int", sY
            , "int", sW, "int", sH
            , "uint", Raster ? Raster : 0x00CC0020)
      }
      SetStretchBltMode(hdc, iStretchMode:=4) {
            return DllCall("gdi32\SetStretchBltMode"
            , "UPtr", hdc
            , "int", iStretchMode)
      }
      SetImage(hwnd, hBitmap) {
            Static Ptr := "UPtr"
            E := DllCall("SendMessage", Ptr, hwnd, "UInt", 0x172, "UInt", 0x0, Ptr, hBitmap )
            DeleteObject(E)
            return E
      }
      SetSysColorToControl(hwnd, SysColor:=15) {
            Static Ptr := "UPtr"
            GetWindowRect(hwnd, W, H)
            bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
            pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
            pBitmap := Gdip_CreateBitmap(w, h)
            G := Gdip_GraphicsFromImage(pBitmap)
            Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
            hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
            SetImage(hwnd, hBitmap)
            Gdip_DeleteBrush(pBrushClear)
            Gdip_DeleteGraphics(G)
            Gdip_DisposeImage(pBitmap)
            DeleteObject(hBitmap)
            return 0
      }
      Gdip_BitmapFromScreen(Screen:=0, Raster:="") {
            hhdc := 0
            Static Ptr := "UPtr"
            if (Screen = 0)
            {
                  _x := DllCall("GetSystemMetrics", "Int", 76 )
                  _y := DllCall("GetSystemMetrics", "Int", 77 )
                  _w := DllCall("GetSystemMetrics", "Int", 78 )
                  _h := DllCall("GetSystemMetrics", "Int", 79 )
            } else if (SubStr(Screen, 1, 5) = "hwnd:")
            {
                  hwnd := SubStr(Screen, 6)
                  if !WinExist("ahk_id " hwnd)
                        return -2
                  GetWindowRect(hwnd, _w, _h)
                  _x := _y := 0
                  hhdc := GetDCEx(hwnd, 3)
            } else if IsInteger(Screen)
            {
                  M := GetMonitorInfo(Screen)
                  _x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
            } else
            {
                  S := StrSplit(Screen, "|")
                  _x := S[1], _y := S[2], _w := S[3], _h := S[4]
            }
            if (_x = "") || (_y = "") || (_w = "") || (_h = "")
                  return -1
            chdc := CreateCompatibleDC(), hbm := CreateDIBSection(_w, _h, chdc)
            obm := SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GetDC()
            BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
            ReleaseDC(hhdc)
            pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
            SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
            return pBitmap
      }
      Gdip_BitmapFromHWND(hwnd, clientOnly:=0) {
            if DllCall("IsIconic", "ptr", hwnd)
                  DllCall("ShowWindow", "ptr", hwnd, "int", 4)
            Static Ptr := "UPtr"
            thisFlag := 0
            If (clientOnly=1)
            {
                  VarSetCapacity(rc, 16, 0)
                  DllCall("GetClientRect", "ptr", hwnd, "ptr", &rc)
                  Width := NumGet(rc, 8, "int")
                  Height := NumGet(rc, 12, "int")
                  thisFlag := 1
            } Else GetWindowRect(hwnd, Width, Height)
            hbm := CreateDIBSection(Width, Height)
            hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
            PrintWindow(hwnd, hdc, 2 + thisFlag)
            pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
            SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
            return pBitmap
      }
      CreateRectF(ByRef RectF, x, y, w, h) {
            VarSetCapacity(RectF, 16)
            NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float")
            NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
      }
      CreateRect(ByRef Rect, x, y, x2, y2) {
            VarSetCapacity(Rect, 16)
            NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint")
            NumPut(x2, Rect, 8, "uint"), NumPut(y2, Rect, 12, "uint")
      }
      CreateSizeF(ByRef SizeF, w, h) {
            VarSetCapacity(SizeF, 8)
            NumPut(w, SizeF, 0, "float")
            NumPut(h, SizeF, 4, "float")
      }
      CreatePointF(ByRef PointF, x, y) {
            VarSetCapacity(PointF, 8)
            NumPut(x, PointF, 0, "float")
            NumPut(y, PointF, 4, "float")
      }
      CreatePointsF(ByRef PointsF, inPoints) {
            Points := StrSplit(inPoints, "|")
            PointsCount := Points.Length()
            VarSetCapacity(PointsF, 8 * PointsCount, 0)
            for eachPoint, Point in Points
            {
                  Coord := StrSplit(Point, ",")
                  NumPut(Coord[1], &PointsF, 8*(A_Index-1), "float")
                  NumPut(Coord[2], &PointsF, (8*(A_Index-1))+4, "float")
            }
            Return PointsCount
      }
      CreateDIBSection(w, h, hdc:="", bpp:=32, ByRef ppvBits:=0, Usage:=0, hSection:=0, Offset:=0) {
            Static Ptr := "UPtr"
            hdc2 := hdc ? hdc : GetDC()
            VarSetCapacity(bi, 40, 0)
            NumPut(40, bi, 0, "uint")
            NumPut(w, bi, 4, "uint")
            NumPut(h, bi, 8, "uint")
            NumPut(1, bi, 12, "ushort")
            NumPut(bpp, bi, 14, "ushort")
            NumPut(0, bi, 16, "uInt")
            hbm := DllCall("CreateDIBSection"
            , Ptr, hdc2
            , Ptr, &bi
            , "uint", Usage
            , "UPtr*", ppvBits
            , Ptr, hSection
            , "uint", OffSet, Ptr)
            if !hdc
                  ReleaseDC(hdc2)
            return hbm
      }
      PrintWindow(hwnd, hdc, Flags:=2) {
            Static Ptr := "UPtr"
            return DllCall("PrintWindow", Ptr, hwnd, Ptr, hdc, "uint", Flags)
      }
      DestroyIcon(hIcon) {
            return DllCall("DestroyIcon", "UPtr", hIcon)
      }
      GetIconDimensions(hIcon, ByRef Width, ByRef Height) {
            Static Ptr := "UPtr"
            Width := Height := 0
            VarSetCapacity(ICONINFO, size := 16 + 2 * A_PtrSize, 0)
            if !DllCall("user32\GetIconInfo", Ptr, hIcon, Ptr, &ICONINFO)
                  return -1
            hbmMask := NumGet(&ICONINFO, 16, Ptr)
            hbmColor := NumGet(&ICONINFO, 16 + A_PtrSize, Ptr)
            VarSetCapacity(BITMAP, size, 0)
            if DllCall("gdi32\GetObject", Ptr, hbmColor, "Int", size, Ptr, &BITMAP)
            {
                  Width := NumGet(&BITMAP, 4, "Int")
                  Height := NumGet(&BITMAP, 8, "Int")
            }
            if !DeleteObject(hbmMask)
                  return -2
            if !DeleteObject(hbmColor)
                  return -3
            return 0
      }
      PaintDesktop(hdc) {
            return DllCall("PaintDesktop", "UPtr", hdc)
      }
      CreateCompatibleDC(hdc:=0) {
            return DllCall("CreateCompatibleDC", "UPtr", hdc)
      }
      SelectObject(hdc, hgdiobj) {
            Static Ptr := "UPtr"
            return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
      }
      DeleteObject(hObject) {
            return DllCall("DeleteObject", "UPtr", hObject)
      }
      GetDC(hwnd:=0) {
            return DllCall("GetDC", "UPtr", hwnd)
      }
      GetDCEx(hwnd, flags:=0, hrgnClip:=0) {
            Static Ptr := "UPtr"
            return DllCall("GetDCEx", Ptr, hwnd, Ptr, hrgnClip, "int", flags)
      }
      ReleaseDC(hdc, hwnd:=0) {
            Static Ptr := "UPtr"
            return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
      }
      DeleteDC(hdc) {
            return DllCall("DeleteDC", "UPtr", hdc)
      }
      Gdip_LibraryVersion() {
            return 1.45
      }
      Gdip_LibrarySubVersion() {
            return 1.85
      }
      Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate := 0) {
            pBitmap := 0
            pStream := 0
            If !(BRAFromMemIn)
                  Return -1
            Headers := StrSplit(StrGet(&BRAFromMemIn, 256, "CP0"), "`n")
            Header := StrSplit(Headers.1, "|")
            If (Header.Length() != 4) || (Header.2 != "BRA!")
                  Return -2
            _Info := StrSplit(Headers.2, "|")
            If (_Info.Length() != 3)
                  Return -3
            OffsetTOC := StrPut(Headers.1, "CP0") + StrPut(Headers.2, "CP0")
            OffsetData := _Info.2
            SearchIndex := Alternate ? 1 : 2
            TOC := StrGet(&BRAFromMemIn + OffsetTOC, OffsetData - OffsetTOC - 1, "CP0")
            RX1 := A_AhkVersion < "2" ? "mi`nO)^" : "mi`n)^"
                  Offset := Size := 0
                  If RegExMatch(TOC, RX1 . (Alternate ? File "\|.+?" : "\d+\|" . File) . "\|(\d+)\|(\d+)$", FileInfo) {
                        Offset := OffsetData + FileInfo.1
                        Size := FileInfo.2
                  }
                  If (Size=0)
                        Return -4
                  hData := DllCall("GlobalAlloc", "UInt", 2, "UInt", Size, "UPtr")
                  pData := DllCall("GlobalLock", "Ptr", hData, "UPtr")
                  DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", &BRAFromMemIn + Offset, "Ptr", Size)
                  DllCall("GlobalUnlock", "Ptr", hData)
                  DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", 1, "PtrP", pStream)
                  pBitmap := Gdip_CreateBitmapFromStream(pStream)
                  ObjRelease(pStream)
            Return pBitmap
      }
      Gdip_BitmapFromBase64(ByRef Base64) {
            Static Ptr := "UPtr"
            pBitmap := 0
            DecLen := 0
            if !(DllCall("crypt32\CryptStringToBinary", Ptr, &Base64, "UInt", 0, "UInt", 0x01, Ptr, 0, "UIntP", DecLen, Ptr, 0, Ptr, 0))
            return -1
      VarSetCapacity(Dec, DecLen, 0)
      if !(DllCall("crypt32\CryptStringToBinary", Ptr, &Base64, "UInt", 0, "UInt", 0x01, Ptr, &Dec, "UIntP", DecLen, Ptr, 0, Ptr, 0))
            return -2
      if !(pStream := DllCall("shlwapi\SHCreateMemStream", Ptr, &Dec, "UInt", DecLen, "UPtr"))
            return -3
      pBitmap := Gdip_CreateBitmapFromStream(pStream, 1)
      ObjRelease(pStream)
      return pBitmap
}
Gdip_CreateBitmapFromStream(pStream, ICM:=0) {
      pBitmap := 0
      If (ICM=1)
            DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "UPtr", pStream, "PtrP", pBitmap)
      Else
            DllCall("gdiplus\GdipCreateBitmapFromStream", "UPtr", pStream, "PtrP", pBitmap)
      Return pBitmap
}
Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}
Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r) {
      Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
      Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
      Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
      Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
      _E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
      Gdip_ResetClip(pGraphics)
      Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
      Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
      Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
      Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
      Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
      Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
      Gdip_ResetClip(pGraphics)
      return _E
}
Gdip_DrawRoundedRectangle2(pGraphics, pPen, x, y, w, h, r, Angle:=0) {
      penWidth := Gdip_GetPenWidth(pPen)
      pw := penWidth / 2
      if (w <= h && (r + pw > w / 2))
      {
            r := (w / 2 > pw) ? w / 2 - pw : 0
      } else if (h < w && r + pw > h / 2)
      {
            r := (h / 2 > pw) ? h / 2 - pw : 0
      } else if (r < pw / 2)
      {
            r := pw / 2
      }
      r2 := r * 2
      path1 := Gdip_CreatePath(0)
      Gdip_AddPathArc(path1, x + pw, y + pw, r2, r2, 180, 90)
      Gdip_AddPathLine(path1, x + pw + r, y + pw, x + w - r - pw, y + pw)
      Gdip_AddPathArc(path1, x + w - r2 - pw, y + pw, r2, r2, 270, 90)
      Gdip_AddPathLine(path1, x + w - pw, y + r + pw, x + w - pw, y + h - r - pw)
      Gdip_AddPathArc(path1, x + w - r2 - pw, y + h - r2 - pw, r2, r2, 0, 90)
      Gdip_AddPathLine(path1, x + w - r - pw, y + h - pw, x + r + pw, y + h - pw)
      Gdip_AddPathArc(path1, x + pw, y + h - r2 - pw, r2, r2, 90, 90)
      Gdip_AddPathLine(path1, x + pw, y + h - r - pw, x + pw, y + r + pw)
      Gdip_ClosePathFigure(path1)
      If (Angle>0)
            Gdip_RotatePathAtCenter(path1, Angle)
      _E := Gdip_DrawPath(pGraphics, pPen, path1)
      Gdip_DeletePath(path1)
      return _E
}
Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}
Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawBezier"
      , Ptr, pGraphics
      , Ptr, pPen
      , "float", x1
      , "float", y1
      , "float", x2
      , "float", y2
      , "float", x3
      , "float", y3
      , "float", x4
      , "float", y4)
}
Gdip_DrawBezierCurve(pGraphics, pPen, Points) {
      iCount := CreatePointsF(PointsF, Points)
      return DllCall("gdiplus\GdipDrawBeziers", "UPtr", pGraphics, "UPtr", pPen, "UPtr", &PointsF, "UInt", iCount)
}
Gdip_DrawClosedCurve(pGraphics, pPen, Points, Tension:="") {
      iCount := CreatePointsF(PointsF, Points)
      If Tension
            return DllCall("gdiplus\GdipDrawClosedCurve2", "UPtr", pGraphics, "UPtr", pPen, "UPtr", &PointsF, "UInt", iCount, "float", Tension)
      Else
            return DllCall("gdiplus\GdipDrawClosedCurve", "UPtr", pGraphics, "UPtr", pPen, "UPtr", &PointsF, "UInt", iCount)
}
Gdip_DrawCurve(pGraphics, pPen, Points, Tension:="") {
      iCount := CreatePointsF(PointsF, Points)
      If Tension
            return DllCall("gdiplus\GdipDrawCurve2", "UPtr", pGraphics, "UPtr", pPen, "UPtr", &PointsF, "UInt", iCount, "float", Tension)
      Else
            return DllCall("gdiplus\GdipDrawCurve", "UPtr", pGraphics, "UPtr", pPen, "UPtr", &PointsF, "UInt", iCount)
}
Gdip_DrawPolygon(pGraphics, pPen, Points) {
      iCount := CreatePointsF(PointsF, Points)
      return DllCall("gdiplus\GdipDrawPolygon", "UPtr", pGraphics, "UPtr", pPen, "UPtr", &PointsF, "UInt", iCount)
}
Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawArc"
      , Ptr, pGraphics
      , Ptr, pPen
      , "float", x, "float", y
      , "float", w, "float", h
      , "float", StartAngle
      , "float", SweepAngle)
}
Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawPie", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}
Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawLine"
      , Ptr, pGraphics
      , Ptr, pPen
      , "float", x1, "float", y1
      , "float", x2, "float", y2)
}
Gdip_DrawLines(pGraphics, pPen, Points) {
      Static Ptr := "UPtr"
      iCount := CreatePointsF(PointsF, Points)
      return DllCall("gdiplus\GdipDrawLines", Ptr, pGraphics, Ptr, pPen, Ptr, &PointsF, "int", iCount)
}
Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipFillRectangle"
      , Ptr, pGraphics
      , Ptr, pBrush
      , "float", x, "float", y
      , "float", w, "float", h)
}
Gdip_FillRoundedRectangle2(pGraphics, pBrush, x, y, w, h, r) {
      r := (w <= h) ? (r < w // 2) ? r : w // 2 : (r < h // 2) ? r : h // 2
      path1 := Gdip_CreatePath(0)
      Gdip_AddPathRectangle(path1, x+r, y, w-(2*r), r)
      Gdip_AddPathRectangle(path1, x+r, y+h-r, w-(2*r), r)
      Gdip_AddPathRectangle(path1, x, y+r, r, h-(2*r))
      Gdip_AddPathRectangle(path1, x+w-r, y+r, r, h-(2*r))
      Gdip_AddPathRectangle(path1, x+r, y+r, w-(2*r), h-(2*r))
      Gdip_AddPathPie(path1, x, y, 2*r, 2*r, 180, 90)
      Gdip_AddPathPie(path1, x+w-(2*r), y, 2*r, 2*r, 270, 90)
      Gdip_AddPathPie(path1, x, y+h-(2*r), 2*r, 2*r, 90, 90)
      Gdip_AddPathPie(path1, x+w-(2*r), y+h-(2*r), 2*r, 2*r, 0, 90)
      E := Gdip_FillPath(pGraphics, pBrush, path1)
      Gdip_DeletePath(path1)
      return E
}
Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r) {
      Region := Gdip_GetClipRegion(pGraphics)
      Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
      Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
      Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
      Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
      _E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
      Gdip_SetClipRegion(pGraphics, Region, 0)
      Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
      Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
      Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
      Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
      Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
      Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
      Gdip_SetClipRegion(pGraphics, Region, 0)
      Gdip_DeleteRegion(Region)
      return _E
}
Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode:=0) {
      Static Ptr := "UPtr"
      iCount := CreatePointsF(PointsF, Points)
      return DllCall("gdiplus\GdipFillPolygon", Ptr, pGraphics, Ptr, pBrush, Ptr, &PointsF, "int", iCount, "int", FillMode)
}
Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipFillPie"
      , Ptr, pGraphics
      , Ptr, pBrush
      , "float", x
      , "float", y
      , "float", w
      , "float", h
      , "float", StartAngle
      , "float", SweepAngle)
}
Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
}
Gdip_FillRegion(pGraphics, pBrush, Region) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipFillRegion", Ptr, pGraphics, Ptr, pBrush, Ptr, Region)
}
Gdip_FillPath(pGraphics, pBrush, pPath) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipFillPath", Ptr, pGraphics, Ptr, pBrush, Ptr, pPath)
}
Gdip_FillClosedCurve(pGraphics, pBrush, Points, Tension:="", FillMode:=0) {
      Static Ptr := "UPtr"
      iCount := CreatePointsF(PointsF, Points)
      If Tension
            Return DllCall("gdiplus\GdipFillClosedCurve2", Ptr, pGraphics, Ptr, pBrush, "UPtr", &PointsF, "int", iCount, "float", Tension, "int", FillMode)
      Else
            Return DllCall("gdiplus\GdipFillClosedCurve", Ptr, pGraphics, Ptr, pBrush, "UPtr", &PointsF, "int", iCount)
}
Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx:="", sy:="", sw:="", sh:="", Matrix:=1, Unit:=2, ImageAttr:=0) {
      Static Ptr := "UPtr"
      If !ImageAttr
      {
            if !IsNumber(Matrix)
                  ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
            else if (Matrix != 1)
                  ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
      } Else usrImageAttr := 1
      if (sx="" && sy="" && sw="" && sh="")
      {
            sx := sy := 0
            Gdip_GetImageDimensions(pBitmap, sw, sh)
      }
      iCount := CreatePointsF(PointsF, Points)
      _E := DllCall("gdiplus\GdipDrawImagePointsRect"
      , Ptr, pGraphics
      , Ptr, pBitmap
      , Ptr, &PointsF
      , "int", iCount
      , "float", sX
      , "float", sY
      , "float", sW
      , "float", sH
      , "int", Unit
      , Ptr, ImageAttr ? ImageAttr : 0
      , Ptr, 0
      , Ptr, 0)
      if (ImageAttr && usrImageAttr!=1)
            Gdip_DisposeImageAttributes(ImageAttr)
      return _E
}
Gdip_DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1, Unit:=2, ImageAttr:=0) {
      Static Ptr := "UPtr"
      If !ImageAttr
      {
            if !IsNumber(Matrix)
                  ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
            else if (Matrix!=1)
                  ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
      } Else usrImageAttr := 1
      If (dx!="" && dy!="" && dw="" && dh="" && sx="" && sy="" && sw="" && sh="")
      {
            sx := sy := 0
            sw := dw := Gdip_GetImageWidth(pBitmap)
            sh := dh := Gdip_GetImageHeight(pBitmap)
      } Else If (sx="" && sy="" && sw="" && sh="")
      {
            If (dx="" && dy="" && dw="" && dh="")
            {
                  sx := dx := 0, sy := dy := 0
                  sw := dw := Gdip_GetImageWidth(pBitmap)
                  sh := dh := Gdip_GetImageHeight(pBitmap)
            } Else
            {
                  sx := sy := 0
                  Gdip_GetImageDimensions(pBitmap, sw, sh)
            }
      }
      _E := DllCall("gdiplus\GdipDrawImageRectRect"
      , Ptr, pGraphics
      , Ptr, pBitmap
      , "float", dX, "float", dY
      , "float", dW, "float", dH
      , "float", sX, "float", sY
      , "float", sW, "float", sH
      , "int", Unit
      , Ptr, ImageAttr ? ImageAttr : 0
      , Ptr, 0, Ptr, 0)
      if (ImageAttr && usrImageAttr!=1)
            Gdip_DisposeImageAttributes(ImageAttr)
      return _E
}
Gdip_DrawImageFast(pGraphics, pBitmap, X:=0, Y:=0) {
      Static Ptr := "UPtr"
      _E := DllCall("gdiplus\GdipDrawImage"
      , Ptr, pGraphics
      , Ptr, pBitmap
      , "float", X
      , "float", Y)
      return _E
}
Gdip_DrawImageRect(pGraphics, pBitmap, X, Y, W, H) {
      Static Ptr := "UPtr"
      _E := DllCall("gdiplus\GdipDrawImageRect"
      , Ptr, pGraphics
      , Ptr, pBitmap
      , "float", X, "float", Y
      , "float", W, "float", H)
      return _E
}
Gdip_SetImageAttributesColorMatrix(clrMatrix, ImageAttr:=0, grayMatrix:=0, ColorAdjustType:=1, fEnable:=1, ColorMatrixFlag:=0) {
      Static Ptr := "UPtr"
      If (StrLen(clrMatrix)<5 && ImageAttr)
            Return -1
      If StrLen(clrMatrix)<5
            Return
      VarSetCapacity(ColourMatrix, 100, 0)
      Matrix := RegExReplace(RegExReplace(clrMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
      Matrix := StrSplit(Matrix, "|")
      Loop 25
      {
            M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
            NumPut(M, ColourMatrix, (A_Index-1)*4, "float")
      }
      Matrix := ""
      Matrix := RegExReplace(RegExReplace(grayMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
      Matrix := StrSplit(Matrix, "|")
      If (StrLen(Matrix)>2 && ColorMatrixFlag=2)
      {
            VarSetCapacity(GrayscaleMatrix, 100, 0)
            Loop 25
            {
                  M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
                  NumPut(M, GrayscaleMatrix, (A_Index-1)*4, "float")
            }
      }
      If !ImageAttr
      {
            created := 1
            ImageAttr := Gdip_CreateImageAttributes()
      }
      E := DllCall("gdiplus\GdipSetImageAttributesColorMatrix"
      , Ptr, ImageAttr
      , "int", ColorAdjustType
      , "int", fEnable
      , Ptr, &ColourMatrix
      , Ptr, &GrayscaleMatrix
      , "int", ColorMatrixFlag)
      E := created=1 ? ImageAttr : E
      return E
}
Gdip_CreateImageAttributes() {
      ImageAttr := 0
      DllCall("gdiplus\GdipCreateImageAttributes", "UPtr*", ImageAttr)
      return ImageAttr
}
Gdip_CloneImageAttributes(ImageAttr) {
      Static Ptr := "UPtr"
      newImageAttr := 0
      DllCall("gdiplus\GdipCloneImageAttributes", Ptr, ImageAttr, "UPtr*", newImageAttr)
      return newImageAttr
}
Gdip_SetImageAttributesThreshold(ImageAttr, Threshold, ColorAdjustType:=1, fEnable:=1) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetImageAttributesThreshold", Ptr, ImageAttr, "int", ColorAdjustType, "int", fEnable, "float", Threshold)
}
Gdip_SetImageAttributesResetMatrix(ImageAttr, ColorAdjustType) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetImageAttributesToIdentity", Ptr, ImageAttr, "int", ColorAdjustType)
}
Gdip_SetImageAttributesGamma(ImageAttr, Gamma, ColorAdjustType:=1, fEnable:=1) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetImageAttributesGamma", Ptr, ImageAttr, "int", ColorAdjustType, "int", fEnable, "float", Gamma)
}
Gdip_SetImageAttributesToggle(ImageAttr, ColorAdjustType, fEnable) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetImageAttributesNoOp", Ptr, ImageAttr, "int", ColorAdjustType, "int", fEnable)
}
Gdip_SetImageAttributesOutputChannel(ImageAttr, ColorChannelFlags, ColorAdjustType:=1, fEnable:=1) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetImageAttributesOutputChannel", Ptr, ImageAttr, "int", ColorAdjustType, "int", fEnable, "int", ColorChannelFlags)
}
Gdip_SetImageAttributesColorKeys(ImageAttr, ARGBLow, ARGBHigh, ColorAdjustType:=1, fEnable:=1) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetImageAttributesColorKeys", Ptr, ImageAttr, "int", ColorAdjustType, "int", fEnable, "uint", ARGBLow, "uint", ARGBHigh)
}
Gdip_SetImageAttributesWrapMode(ImageAttr, WrapMode, ARGB) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetImageAttributesWrapMode", Ptr, ImageAttr, "int", WrapMode, "uint", ARGB, "int", 0)
}
Gdip_ResetImageAttributes(ImageAttr, ColorAdjustType) {
      Static Ptr := "UPtr"
      DllCall("gdiplus\GdipResetImageAttributes", Ptr, ImageAttr, "int", ColorAdjustType)
}
Gdip_GraphicsFromImage(pBitmap, InterpolationMode:="", SmoothingMode:="", PageUnit:="", CompositingQuality:="") {
      pGraphics := 0
      DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", pGraphics)
      If pGraphics
      {
            If (InterpolationMode!="")
                  Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
            If (SmoothingMode!="")
                  Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
            If (PageUnit!="")
                  Gdip_SetPageUnit(pGraphics, PageUnit)
            If (CompositingQuality!="")
                  Gdip_SetCompositingQuality(pGraphics, CompositingQuality)
      }
      return pGraphics
}
Gdip_GraphicsFromHDC(hDC, hDevice:="", InterpolationMode:="", SmoothingMode:="", PageUnit:="", CompositingQuality:="") {
      pGraphics := 0
      If hDevice
            DllCall("Gdiplus\GdipCreateFromHDC2", "UPtr", hDC, "UPtr", hDevice, "UPtr*", pGraphics)
      Else
            DllCall("gdiplus\GdipCreateFromHDC", "UPtr", hdc, "UPtr*", pGraphics)
      If pGraphics
      {
            If (InterpolationMode!="")
                  Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
            If (SmoothingMode!="")
                  Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
            If (PageUnit!="")
                  Gdip_SetPageUnit(pGraphics, PageUnit)
            If (CompositingQuality!="")
                  Gdip_SetCompositingQuality(pGraphics, CompositingQuality)
      }
      return pGraphics
}
Gdip_GraphicsFromHWND(HWND, useICM:=0, InterpolationMode:="", SmoothingMode:="", PageUnit:="", CompositingQuality:="") {
      pGraphics := 0
      function2call := (useICM=1) ? "GdipCreateFromHWNDICM" : "GdipCreateFromHWND"
            DllCall("gdiplus\" function2call, "UPtr", HWND, "UPtr*", pGraphics)
            If pGraphics
            {
                  If (InterpolationMode!="")
                        Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
                  If (SmoothingMode!="")
                        Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
                  If (PageUnit!="")
                        Gdip_SetPageUnit(pGraphics, PageUnit)
                  If (CompositingQuality!="")
                        Gdip_SetCompositingQuality(pGraphics, CompositingQuality)
            }
      return pGraphics
}
Gdip_GetDC(pGraphics) {
      hDC := 0
      DllCall("gdiplus\GdipGetDC", "UPtr", pGraphics, "UPtr*", hDC)
      return hDC
}
Gdip_ReleaseDC(pGraphics, hdc) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipReleaseDC", Ptr, pGraphics, Ptr, hdc)
}
Gdip_GraphicsClear(pGraphics, ARGB:=0x00ffffff) {
      return DllCall("gdiplus\GdipGraphicsClear", "UPtr", pGraphics, "int", ARGB)
}
Gdip_GraphicsFlush(pGraphics, intent) {
      return DllCall("gdiplus\GdipFlush", "UPtr", pGraphics, "int", intent)
}
Gdip_BlurBitmap(pBitmap, BlurAmount, usePARGB:=0, quality:=7) {
      If (BlurAmount>100)
            BlurAmount := 100
      Else If (BlurAmount<1)
            BlurAmount := 1
      PixelFormat := (usePARGB=1) ? "0xE200B" : "0x26200A"
            Gdip_GetImageDimensions(pBitmap, sWidth, sHeight)
            dWidth := sWidth//BlurAmount
            dHeight := sHeight//BlurAmount
            pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight, PixelFormat)
            G1 := Gdip_GraphicsFromImage(pBitmap1)
            Gdip_SetInterpolationMode(G1, quality)
            Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)
            Gdip_DeleteGraphics(G1)
            pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight, PixelFormat)
            G2 := Gdip_GraphicsFromImage(pBitmap2)
            Gdip_SetInterpolationMode(G2, quality)
            Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)
            Gdip_DeleteGraphics(G2)
            Gdip_DisposeImage(pBitmap1)
      return pBitmap2
}
Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75, toBase64:=0) {
      Static Ptr := "UPtr"
      nCount := 0
      nSize := 0
      _p := 0
      SplitPath sOutput,,, Extension
      If !RegExMatch(Extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
      Return -1
Extension := "." Extension
DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
VarSetCapacity(ci, nSize)
DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
If !(nCount && nSize)
      Return -2
If (A_IsUnicode)
{
      StrGet_Name := "StrGet"
      N := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %N%
            {
                  sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
                  If !InStr(sString, "*" Extension)
                        Continue
                  pCodec := &ci+idx
                  Break
            }
      } Else
      {
      N := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %N%
            {
                  Location := NumGet(ci, 76*(A_Index-1)+44)
                  nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int", 0, "uint", 0, "uint", 0)
                  VarSetCapacity(sString, nSize)
                  DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
                  If !InStr(sString, "*" Extension)
                        Continue
                  pCodec := &ci+76*(A_Index-1)
                  Break
            }
      }
      If !pCodec
      Return -3
If (Quality!=75)
{
      Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
      If (quality>90 && toBase64=1)
            Quality := 90
      If RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
      {
            DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
            VarSetCapacity(EncoderParameters, nSize, 0)
            DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
            nCount := NumGet(EncoderParameters, "UInt")
      N := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %N%
            {
                  elem := (24+A_PtrSize)*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                  If (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
                  {
                        _p := elem+&EncoderParameters-pad-4
                        NumPut(Quality, NumGet(NumPut(4, NumPut(1, _p+0)+20, "UInt")), "UInt")
                        Break
                  }
            }
      }
}
If (toBase64=1)
{
      DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
      _E := DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint", _p ? _p : 0)
      If _E
      Return -6
DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
pData := DllCall("GlobalLock", "ptr",hData, "ptr")
nSize := DllCall("GlobalSize", "uint",pData)
VarSetCapacity(bin, nSize, 0)
DllCall("RtlMoveMemory", "ptr",&bin, "ptr",pData, "uptr",nSize)
DllCall("GlobalUnlock", "ptr",hData)
ObjRelease(pStream)
DllCall("GlobalFree", "ptr",hData)
DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&bin, "uint",nSize, "uint",0x40000001, "ptr",0, "uint*",base64Length)
VarSetCapacity(base64, base64Length, 0)
_E := DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&bin, "uint",nSize, "uint",0x40000001, "ptr",&base64, "uint*",base64Length)
If !_E
      Return -7
VarSetCapacity(bin, 0)
Return StrGet(&base64, base64Length, "CP0")
}
_E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, "WStr", sOutput, Ptr, pCodec, "uint", _p ? _p : 0)
Return _E ? -5 : 0
}
Gdip_GetPixel(pBitmap, x, y) {
      ARGB := 0
      DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "int", x, "int", y, "uint*", ARGB)
      return ARGB
}
Gdip_GetPixelColor(pBitmap, x, y, Format) {
      ARGBdec := Gdip_GetPixel(pBitmap, x, y)
      If (format=1)
      {
      Return Format("{1:#x}", ARGBdec)
} Else If (format=2)
{
      Gdip_FromARGB(ARGBdec, A, R, G, B)
      Return R "," G "," B "," A
} Else If (format=3)
{
      clr := Format("{1:#x}", ARGBdec)
      Return "0x" SubStr(clr, -1) SubStr(clr, 7, 2) SubStr(clr, 5, 2)
} Else If (format=4)
{
      Return SubStr(Format("{1:#x}", ARGBdec), 5)
} Else Return ARGBdec
}
Gdip_SetPixel(pBitmap, x, y, ARGB) {
      return DllCall("gdiplus\GdipBitmapSetPixel", "UPtr", pBitmap, "int", x, "int", y, "int", ARGB)
}
Gdip_GetImageWidth(pBitmap) {
      Width := 0
      DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", Width)
      return Width
}
Gdip_GetImageHeight(pBitmap) {
      Height := 0
      DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", Height)
      return Height
}
Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height) {
      If StrLen(pBitmap)<3
      Return -1
Width := 0, Height := 0
E := Gdip_GetImageDimension(pBitmap, Width, Height)
Width := Round(Width)
Height := Round(Height)
return E
}
Gdip_GetImageDimension(pBitmap, ByRef w, ByRef h) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipGetImageDimension", Ptr, pBitmap, "float*", w, "float*", h)
}
Gdip_GetImageBounds(pBitmap) {
      rData := {}
      VarSetCapacity(RectF, 16, 0)
      status := DllCall("gdiplus\GdipGetImageBounds", "UPtr", pBitmap, "UPtr", &RectF, "Int*", 0)
      If (!status) {
            rData.x := NumGet(&RectF, 0, "float")
            , rData.y := NumGet(&RectF, 4, "float")
            , rData.w := NumGet(&RectF, 8, "float")
            , rData.h := NumGet(&RectF, 12, "float")
      } Else {
      Return status
}
return rData
}
Gdip_GetImageFlags(pBitmap) {
      Flags := 0
      DllCall("gdiplus\GdipGetImageFlags", "UPtr", pBitmap, "UInt*", Flags)
      Return Flags
}
Gdip_GetImageRawFormat(pBitmap) {
      Static RawFormatsList := {"{B96B3CA9-0728-11D3-9D7B-0000F81EF32E}":"Undefined", "{B96B3CAA-0728-11D3-9D7B-0000F81EF32E}":"MemoryBMP", "{B96B3CAB-0728-11D3-9D7B-0000F81EF32E}":"BMP", "{B96B3CAC-0728-11D3-9D7B-0000F81EF32E}":"EMF", "{B96B3CAD-0728-11D3-9D7B-0000F81EF32E}":"WMF", "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}":"JPEG", "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}":"PNG", "{B96B3CB0-0728-11D3-9D7B-0000F81EF32E}":"GIF", "{B96B3CB1-0728-11D3-9D7B-0000F81EF32E}":"TIFF", "{B96B3CB2-0728-11D3-9D7B-0000F81EF32E}":"EXIF", "{B96B3CB5-0728-11D3-9D7B-0000F81EF32E}":"Icon"}
      VarSetCapacity(pGuid, 16, 0)
      E1 := DllCall("gdiplus\GdipGetImageRawFormat", "UPtr", pBitmap, "Ptr", &pGuid)
      size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
      E2 := DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", size)
      R1 := E2 ? StrGet(&sguid) : E2
      R2 := RawFormatsList[R1]
      Return R2 ? R2 : R1
}
Gdip_GetImagePixelFormat(pBitmap, mode:=0) {
      Static PixelFormatsList := {0x30101:"1-INDEXED", 0x30402:"4-INDEXED", 0x30803:"8-INDEXED", 0x101004:"16-GRAYSCALE", 0x021005:"16-RGB555", 0x21006:"16-RGB565", 0x61007:"16-ARGB1555", 0x21808:"24-RGB", 0x22009:"32-RGB", 0x26200A:"32-ARGB", 0xE200B:"32-PARGB", 0x10300C:"48-RGB", 0x34400D:"64-ARGB", 0x1A400E:"64-PARGB"}
      PixelFormat := 0
      E := DllCall("gdiplus\GdipGetImagePixelFormat", "UPtr", pBitmap, "UPtr*", PixelFormat)
      If E
      Return -1
If (mode=0)
      Return PixelFormat
inHEX := Format("{1:#x}", PixelFormat)
If (PixelFormatsList.Haskey(inHEX) && mode=2)
      result := PixelFormatsList[inHEX]
Else
      result := inHEX
return result
}
Gdip_GetImageType(pBitmap) {
      result := 0
      E := DllCall("gdiplus\GdipGetImageType", Ptr, pBitmap, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetDPI(pGraphics, ByRef DpiX, ByRef DpiY) {
      DpiX := Gdip_GetDpiX(pGraphics)
      DpiY := Gdip_GetDpiY(pGraphics)
}
Gdip_GetDpiX(pGraphics) {
      dpix := 0
      DllCall("gdiplus\GdipGetDpiX", "UPtr", pGraphics, "float*", dpix)
      return Round(dpix)
}
Gdip_GetDpiY(pGraphics) {
      dpiy := 0
      DllCall("gdiplus\GdipGetDpiY", "UPtr", pGraphics, "float*", dpiy)
      return Round(dpiy)
}
Gdip_GetImageHorizontalResolution(pBitmap) {
      dpix := 0
      DllCall("gdiplus\GdipGetImageHorizontalResolution", "UPtr", pBitmap, "float*", dpix)
      return Round(dpix)
}
Gdip_GetImageVerticalResolution(pBitmap) {
      dpiy := 0
      DllCall("gdiplus\GdipGetImageVerticalResolution", "UPtr", pBitmap, "float*", dpiy)
      return Round(dpiy)
}
Gdip_BitmapSetResolution(pBitmap, dpix, dpiy) {
      return DllCall("gdiplus\GdipBitmapSetResolution", "UPtr", pBitmap, "float", dpix, "float", dpiy)
}
Gdip_BitmapGetDPIResolution(pBitmap, ByRef dpix, ByRef dpiy) {
      dpix := dpiy := 0
      If StrLen(pBitmap)<3
      Return
dpix := Gdip_GetImageHorizontalResolution(pBitmap)
dpiy := Gdip_GetImageVerticalResolution(pBitmap)
}
Gdip_CreateBitmapFromGraphics(pGraphics, Width, Height) {
      pBitmap := 0
      DllCall("gdiplus\GdipCreateBitmapFromGraphics", "int", Width, "int", Height, "UPtr", pGraphics, "UPtr*", pBitmap)
      Return pBitmap
}
Gdip_CreateBitmapFromFile(sFile, IconNumber:=1, IconSize:="", useICM:=0) {
      Static Ptr := "UPtr"
      PtrA := "UPtr*"
      pBitmap := 0
      pBitmapOld := 0
      hIcon := 0
      SplitPath sFile,,, Extension
      if RegExMatch(Extension, "^(?i:exe|dll)$")
      {
            Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
            BufSize := 16 + (2*A_PtrSize)
            VarSetCapacity(buf, BufSize, 0)
            For eachSize, Size in StrSplit( Sizes, "|" )
            {
                  DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", Size, "int", Size, PtrA, hIcon, PtrA, 0, "uint", 1, "uint", 0)
                  if !hIcon
                        continue
                  if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, &buf)
                  {
                        DestroyIcon(hIcon)
                        continue
                  }
                  hbmMask := NumGet(buf, 12 + (A_PtrSize - 4))
                  hbmColor := NumGet(buf, 12 + (A_PtrSize - 4) + A_PtrSize)
                  if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, &buf))
                  {
                        DestroyIcon(hIcon)
                        continue
                  }
                  break
            }
            if !hIcon
                  return -1
            Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
            hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
            if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3)
            {
                  DestroyIcon(hIcon)
                  return -2
            }
            VarSetCapacity(dib, 104)
            DllCall("GetObject", Ptr, hbm, "int", A_PtrSize = 8 ? 104 : 84, Ptr, &dib)
            Stride := NumGet(dib, 12, "Int")
            Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0))
            pBitmapOld := Gdip_CreateBitmap(Width, Height, 0, Stride, Bits)
            pBitmap := Gdip_CreateBitmap(Width, Height)
            _G := Gdip_GraphicsFromImage(pBitmap)
            Gdip_DrawImage(_G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
            SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
            Gdip_DeleteGraphics(_G), Gdip_DisposeImage(pBitmapOld)
            DestroyIcon(hIcon)
      } else
      {
      function2call := (useICM=1) ? "GdipCreateBitmapFromFileICM" : "GdipCreateBitmapFromFile"
            E := DllCall("gdiplus\" function2call, "WStr", sFile, PtrA, pBitmap)
      }
      return pBitmap
}
Gdip_CreateARGBBitmapFromHBITMAP(hImage) {
      DllCall("GetObject"
      , "ptr", hImage
      , "int", VarSetCapacity(dib, 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize)
      , "ptr", &dib)
      width := NumGet(dib, 4, "uint")
      height := NumGet(dib, 8, "uint")
      bpp := NumGet(dib, 18, "ushort")
      if (bpp!=32)
      return Gdip_CreateBitmapFromHBITMAP(hImage)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hImage)
cdc := CreateCompatibleDC(hdc)
hbm := CreateDIBSection(width, -height, hdc, 32, pBits)
ob2 := SelectObject(cdc, hbm)
pBitmap := Gdip_CreateBitmap(width, height)
CreateRect(Rect, 0, 0, width, height)
VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)
, NumPut( width, BitmapData, 0, "uint")
, NumPut( height, BitmapData, 4, "uint")
, NumPut( 4 * width, BitmapData, 8, "int")
, NumPut( 0xE200B, BitmapData, 12, "int")
, NumPut( pBits, BitmapData, 16, "ptr")
DllCall("gdiplus\GdipBitmapLockBits"
, "ptr", pBitmap
, "ptr", &Rect
, "uint", 6
, "int", 0xE200B
, "ptr", &BitmapData)
BitBlt(cdc, 0, 0, width, height, hdc, 0, 0)
DllCall("gdiplus\GdipBitmapUnlockBits", "ptr",pBitmap, "ptr",&BitmapData)
SelectObject(cdc, ob2)
DeleteObject(hbm), DeleteDC(cdc)
SelectObject(hdc, obm), DeleteDC(hdc)
return pBitmap
}
Gdip_CreateBitmapFromHBITMAP(hBitmap, hPalette:=0) {
      Static Ptr := "UPtr"
      pBitmap := 0
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, hPalette, "UPtr*", pBitmap)
      return pBitmap
}
Gdip_CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff) {
      hBitmap := 0
      DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", hBitmap, "int", Background)
      return hBitmap
}
Gdip_CreateARGBHBITMAPFromBitmap(ByRef pBitmap) {
      Gdip_GetImageDimensions(pBitmap, Width, Height)
      hdc := CreateCompatibleDC()
      hbm := CreateDIBSection(width, -height, hdc, 32, pBits)
      obm := SelectObject(hdc, hbm)
      CreateRect(Rect, 0, 0, width, height)
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)
      , NumPut( width, BitmapData, 0, "uint")
      , NumPut( height, BitmapData, 4, "uint")
      , NumPut( 4 * width, BitmapData, 8, "int")
      , NumPut( 0xE200B, BitmapData, 12, "int")
      , NumPut( pBits, BitmapData, 16, "ptr")
      DllCall("gdiplus\GdipBitmapLockBits"
      , "ptr", pBitmap
      , "ptr", &Rect
      , "uint", 5
      , "int", 0xE200B
      , "ptr", &BitmapData)
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)
      SelectObject(hdc, obm)
      DeleteObject(hdc)
      return hbm
}
Gdip_CreateBitmapFromHICON(hIcon) {
      pBitmap := 0
      DllCall("gdiplus\GdipCreateBitmapFromHICON", "UPtr", hIcon, "UPtr*", pBitmap)
      return pBitmap
}
Gdip_CreateHICONFromBitmap(pBitmap) {
      hIcon := 0
      DllCall("gdiplus\GdipCreateHICONFromBitmap", "UPtr", pBitmap, "UPtr*", hIcon)
      return hIcon
}
Gdip_CreateBitmap(Width, Height, PixelFormat:=0, Stride:=0, Scan0:=0) {
      pBitmap := 0
      If !PixelFormat
            PixelFormat := 0x26200A
      DllCall("gdiplus\GdipCreateBitmapFromScan0"
      , "int", Width
      , "int", Height
      , "int", Stride
      , "int", PixelFormat
      , "UPtr", Scan0
      , "UPtr*", pBitmap)
      Return pBitmap
}
Gdip_CreateBitmapFromClipboard() {
      Static Ptr := "UPtr"
      pid := DllCall("GetCurrentProcessId","uint")
      hwnd := WinExist("ahk_pid " . pid)
      if !DllCall("IsClipboardFormatAvailable", "uint", 8)
      {
            if DllCall("IsClipboardFormatAvailable", "uint", 2)
            {
                  if !DllCall("OpenClipboard", Ptr, hwnd)
                        return -1
                  hData := DllCall("User32.dll\GetClipboardData", "UInt", 0x0002, "UPtr")
                  hBitmap := DllCall("User32.dll\CopyImage", "UPtr", hData, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2004, "Ptr")
                  DllCall("CloseClipboard")
                  pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
                  DeleteObject(hBitmap)
                  return pBitmap
            }
      return -2
}
if !DllCall("OpenClipboard", Ptr, hwnd)
      return -1
hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
if !hBitmap
{
      DllCall("CloseClipboard")
      return -3
}
DllCall("CloseClipboard")
If hBitmap
{
      pBitmap := Gdip_CreateARGBBitmapFromHBITMAP(hBitmap)
      If pBitmap
            isUniform := Gdip_TestBitmapUniformity(pBitmap, 7, maxLevelIndex)
      If (pBitmap && isUniform=1 && maxLevelIndex<=2)
      {
            Gdip_DisposeImage(pBitmap)
            pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
      }
      DeleteObject(hBitmap)
}
if !pBitmap
      return -4
return pBitmap
}
Gdip_SetBitmapToClipboard(pBitmap) {
      Static Ptr := "UPtr"
      off1 := A_PtrSize = 8 ? 52 : 44
      off2 := A_PtrSize = 8 ? 32 : 24
      pid := DllCall("GetCurrentProcessId","uint")
      hwnd := WinExist("ahk_pid " . pid)
      r1 := DllCall("OpenClipboard", Ptr, hwnd)
      If !r1
      Return -1
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, 0)
If !hBitmap
{
      DllCall("CloseClipboard")
      Return -3
}
r2 := DllCall("EmptyClipboard")
If !r2
{
      DeleteObject(hBitmap)
      DllCall("CloseClipboard")
      Return -2
}
DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
hdib := DllCall("GlobalAlloc", "uint", 2, Ptr, 40+NumGet(oi, off1, "UInt"), Ptr)
pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)
DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr, NumGet(oi, off2 - A_PtrSize, Ptr), Ptr, NumGet(oi, off1, "UInt"))
DllCall("GlobalUnlock", Ptr, hdib)
DeleteObject(hBitmap)
r3 := DllCall("SetClipboardData", "uint", 8, Ptr, hdib)
DllCall("CloseClipboard")
DllCall("GlobalFree", Ptr, hdib)
E := r3 ? 0 : -4
Return E
}
Gdip_CloneBitmapArea(pBitmap, x:="", y:="", w:=0, h:=0, PixelFormat:=0, KeepPixelFormat:=0) {
      pBitmapDest := 0
      If !PixelFormat
            PixelFormat := 0x26200A
      If (KeepPixelFormat=1)
            PixelFormat := Gdip_GetImagePixelFormat(pBitmap, 1)
      If (y="")
            y := 0
      If (x="")
            x := 0
      If (!w && !h)
            Gdip_GetImageDimensions(pBitmap, w, h)
      E := DllCall("gdiplus\GdipCloneBitmapArea"
      , "float", x, "float", y
      , "float", w, "float", h
      , "int", PixelFormat
      , "UPtr", pBitmap
      , "UPtr*", pBitmapDest)
      return pBitmapDest
}
Gdip_CloneBitmap(pBitmap) {
      pBitmapDest := 0
      E := DllCall("gdiplus\GdipCloneImage"
      , "UPtr", pBitmap
      , "UPtr*", pBitmapDest)
      return pBitmapDest
}
Gdip_BitmapSelectActiveFrame(pBitmap, FrameIndex) {
      Countu := 0
      CountFrames := 0
      Static Ptr := "UPtr"
      DllCall("gdiplus\GdipImageGetFrameDimensionsCount", Ptr, pBitmap, "UInt*", Countu)
      VarSetCapacity(dIDs, 16, 0)
      DllCall("gdiplus\GdipImageGetFrameDimensionsList", Ptr, pBitmap, "Uint", &dIDs, "UInt", Countu)
      DllCall("gdiplus\GdipImageGetFrameCount", Ptr, pBitmap, "Uint", &dIDs, "UInt*", CountFrames)
      If (FrameIndex>CountFrames)
            FrameIndex := CountFrames
      Else If (FrameIndex<1)
            FrameIndex := 0
      E := DllCall("gdiplus\GdipImageSelectActiveFrame", Ptr, pBitmap, Ptr, &dIDs, "uint", FrameIndex)
      If E
      Return -1
Return CountFrames
}
Gdip_GetBitmapFramesCount(pBitmap) {
      Countu := 0
      CountFrames := 0
      Static Ptr := "UPtr"
      DllCall("gdiplus\GdipImageGetFrameDimensionsCount", Ptr, pBitmap, "UInt*", Countu)
      VarSetCapacity(dIDs, 16, 0)
      DllCall("gdiplus\GdipImageGetFrameDimensionsList", Ptr, pBitmap, "Uint", &dIDs, "UInt", Countu)
      DllCall("gdiplus\GdipImageGetFrameCount", Ptr, pBitmap, "Uint", &dIDs, "UInt*", CountFrames)
      Return CountFrames
}
Gdip_CreateCachedBitmap(pBitmap, pGraphics) {
      pCachedBitmap := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipCreateCachedBitmap", Ptr, pBitmap, Ptr, pGraphics, "Ptr*", pCachedBitmap)
      return pCachedBitmap
}
Gdip_DeleteCachedBitmap(pCachedBitmap) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDeleteCachedBitmap", Ptr, pCachedBitmap)
}
Gdip_DrawCachedBitmap(pGraphics, pCachedBitmap, X, Y) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawCachedBitmap", Ptr, pGraphics, Ptr, pCachedBitmap, "int", X, "int", Y)
}
Gdip_ImageRotateFlip(pBitmap, RotateFlipType:=1) {
      return DllCall("gdiplus\GdipImageRotateFlip", "UPtr", pBitmap, "int", RotateFlipType)
}
Gdip_RotateBitmapAtCenter(pBitmap, Angle, pBrush:=0, InterpolationMode:=7, PixelFormat:=0) {
      If !Angle
      {
            newBitmap := Gdip_CloneBitmap(pBitmap)
      Return newBitmap
}
Gdip_GetImageDimensions(pBitmap, Width, Height)
Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)
If (RWidth*RHeight>536848912) || (Rwidth>32100) || (RHeight>32100)
      Return
If (pBrush=0)
{
      pBrush := Gdip_BrushCreateSolid("0xFF000000")
      defaultBrush := 1
}
PixelFormatReadable := Gdip_GetImagePixelFormat(pBitmap, 2)
If InStr(PixelFormatReadable, "indexed")
{
      hbm := CreateDIBSection(RWidth, RHeight,,24)
      hdc := CreateCompatibleDC()
      obm := SelectObject(hdc, hbm)
      G := Gdip_GraphicsFromHDC(hdc)
      indexedMode := 1
} Else
{
      If (PixelFormat=-1)
            PixelFormat := "0xE200B"
      newBitmap := Gdip_CreateBitmap(RWidth, RHeight, PixelFormat)
      G := Gdip_GraphicsFromImage(newBitmap)
}
Gdip_SetInterpolationMode(G, InterpolationMode)
Gdip_SetSmoothingMode(G, 4)
If StrLen(pBrush)>1
      Gdip_FillRectangle(G, pBrush, 0, 0, RWidth, RHeight)
Gdip_TranslateWorldTransform(G, xTranslation, yTranslation)
Gdip_RotateWorldTransform(G, Angle)
Gdip_DrawImageRect(G, pBitmap, 0, 0, Width, Height)
If (indexedMode=1)
{
      newBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
      SelectObject(hdc, obm)
      DeleteObject(hbm)
      DeleteDC(hdc)
}
Gdip_DeleteGraphics(G)
If (defaultBrush=1)
      Gdip_DeleteBrush(pBrush)
Return newBitmap
}
Gdip_ResizeBitmap(pBitmap, givenW, givenH, KeepRatio, InterpolationMode:="", KeepPixelFormat:=0, checkTooLarge:=0) {
      Gdip_GetImageDimensions(pBitmap, Width, Height)
      If (KeepRatio=1)
      {
            calcIMGdimensions(Width, Height, givenW, givenH, ResizedW, ResizedH)
      } Else
      {
            ResizedW := givenW
            ResizedH := givenH
      }
      If (((ResizedW*ResizedH>536848912) || (ResizedW>32100) || (ResizedH>32100)) && checkTooLarge=1)
      Return
PixelFormatReadable := Gdip_GetImagePixelFormat(pBitmap, 2)
If (KeepPixelFormat=1)
      PixelFormat := Gdip_GetImagePixelFormat(pBitmap, 1)
Else If (KeepPixelFormat=-1)
      PixelFormat := "0xE200B"
Else If Strlen(KeepPixelFormat)>3
      PixelFormat := KeepPixelFormat
If InStr(PixelFormatReadable, "indexed")
{
      hbm := CreateDIBSection(ResizedW, ResizedH,,24)
      hdc := CreateCompatibleDC()
      obm := SelectObject(hdc, hbm)
      G := Gdip_GraphicsFromHDC(hdc, InterpolationMode, 4)
      Gdip_DrawImageRect(G, pBitmap, 0, 0, ResizedW, ResizedH)
      newBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
      If (KeepPixelFormat=1)
            Gdip_BitmapSetColorDepth(newBitmap, SubStr(PixelFormatReadable, 1, 1), 1)
      SelectObject(hdc, obm)
      DeleteObject(hbm)
      DeleteDC(hdc)
      Gdip_DeleteGraphics(G)
} Else
{
      newBitmap := Gdip_CreateBitmap(ResizedW, ResizedH, PixelFormat)
      G := Gdip_GraphicsFromImage(newBitmap, InterpolationMode)
      Gdip_DrawImageRect(G, pBitmap, 0, 0, ResizedW, ResizedH)
      Gdip_DeleteGraphics(G)
}
Return newBitmap
}
Gdip_CreatePen(ARGB, w, Unit:=2) {
      pPen := 0
      E := DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", Unit, "UPtr*", pPen)
      return pPen
}
Gdip_CreatePenFromBrush(pBrush, w, Unit:=2) {
      pPen := 0
      E := DllCall("gdiplus\GdipCreatePen2", "UPtr", pBrush, "float", w, "int", 2, "UPtr*", pPen, "int", Unit)
      return pPen
}
Gdip_SetPenWidth(pPen, width) {
      return DllCall("gdiplus\GdipSetPenWidth", "UPtr", pPen, "float", width)
}
Gdip_GetPenWidth(pPen) {
      width := 0
      E := DllCall("gdiplus\GdipGetPenWidth", "UPtr", pPen, "float*", width)
      If E
      return -1
return width
}
Gdip_GetPenDashStyle(pPen) {
      DashStyle := 0
      E := DllCall("gdiplus\GdipGetPenDashStyle", "UPtr", pPen, "float*", DashStyle)
      If E
      return -1
return DashStyle
}
Gdip_SetPenColor(pPen, ARGB) {
      return DllCall("gdiplus\GdipSetPenColor", "UPtr", pPen, "UInt", ARGB)
}
Gdip_GetPenColor(pPen) {
      ARGB := 0
      E := DllCall("gdiplus\GdipGetPenColor", "UPtr", pPen, "UInt*", ARGB)
      If E
      return -1
return Format("{1:#x}", ARGB)
}
Gdip_SetPenBrushFill(pPen, pBrush) {
      return DllCall("gdiplus\GdipSetPenBrushFill", "UPtr", pPen, "UPtr", pBrush)
}
Gdip_ResetPenTransform(pPen) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipResetPenTransform", Ptr, pPen)
}
Gdip_MultiplyPenTransform(pPen, hMatrix, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipMultiplyPenTransform", Ptr, pPen, Ptr, hMatrix, "int", matrixOrder)
}
Gdip_RotatePenTransform(pPen, Angle, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipRotatePenTransform", Ptr, pPen, "float", Angle, "int", matrixOrder)
}
Gdip_ScalePenTransform(pPen, ScaleX, ScaleY, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipScalePenTransform", Ptr, pPen, "float", ScaleX, "float", ScaleY, "int", matrixOrder)
}
Gdip_TranslatePenTransform(pPen, X, Y, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipTranslatePenTransform", Ptr, pPen, "float", X, "float", Y, "int", matrixOrder)
}
Gdip_SetPenTransform(pPen, pMatrix) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetPenTransform", Ptr, pPen, Ptr, pMatrix)
}
Gdip_GetPenTransform(pPen) {
      Static Ptr := "UPtr"
      pMatrix := 0
      DllCall("gdiplus\GdipGetPenTransform", Ptr, pPen, "UPtr*", pMatrix)
      Return pMatrix
}
Gdip_GetPenBrushFill(pPen) {
      Static Ptr := "UPtr"
      pBrush := 0
      E := DllCall("gdiplus\GdipGetPenBrushFill", Ptr, pPen, "int*", pBrush)
      Return pBrush
}
Gdip_GetPenFillType(pPen) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetPenFillType", Ptr, pPen, "int*", result)
      If E
      return -2
Return result
}
Gdip_GetPenStartCap(pPen) {
      result := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetPenStartCap", Ptr, pPen, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetPenEndCap(pPen) {
      result := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetPenEndCap", Ptr, pPen, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetPenDashCaps(pPen) {
      result := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetPenDashCap197819", Ptr, pPen, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetPenAlignment(pPen) {
      result := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetPenMode", Ptr, pPen, "int*", result)
      If E
      return -1
Return result
}
Gdip_SetPenLineCaps(pPen, StartCap, EndCap, DashCap) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenLineCap197819", Ptr, pPen, "int", StartCap, "int", EndCap, "int", DashCap)
}
Gdip_SetPenStartCap(pPen, LineCap) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenStartCap", Ptr, pPen, "int", LineCap)
}
Gdip_SetPenEndCap(pPen, LineCap) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenEndCap", Ptr, pPen, "int", LineCap)
}
Gdip_SetPenDashCaps(pPen, LineCap) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenDashCap197819", Ptr, pPen, "int", LineCap)
}
Gdip_SetPenAlignment(pPen, Alignment) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenMode", Ptr, pPen, "int", Alignment)
}
Gdip_GetPenCompoundCount(pPen) {
      result := 0
      E := DllCall("gdiplus\GdipGetPenCompoundCount", Ptr, pPen, "int*", result)
      If E
      Return -1
Return result
}
Gdip_SetPenCompoundArray(pPen, inCompounds) {
      arrCompounds := StrSplit(inCompounds, "|")
      totalCompounds := arrCompounds.Length()
      VarSetCapacity(pCompounds, 8 * totalCompounds, 0)
      Loop %totalCompounds%
            NumPut(arrCompounds[A_Index], &pCompounds, 4*(A_Index - 1), "float")
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenCompoundArray", Ptr, pPen, Ptr, &pCompounds, "int", totalCompounds)
}
Gdip_SetPenDashStyle(pPen, DashStyle) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenDashStyle", Ptr, pPen, "Int", DashStyle)
}
Gdip_SetPenDashArray(pPen, Dashes) {
      Static Ptr := "UPtr"
      Points := StrSplit(Dashes, ",")
      PointsCount := Points.Length()
      VarSetCapacity(PointsF, 8 * PointsCount, 0)
      Loop %PointsCount%
            NumPut(Points[A_Index], &PointsF, 4*(A_Index - 1), "float")
      Return DllCall("gdiplus\GdipSetPenDashArray", Ptr, pPen, Ptr, &PointsF, "int", PointsCount)
}
Gdip_SetPenDashOffset(pPen, Offset) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenDashOffset", Ptr, pPen, "float", Offset)
}
Gdip_GetPenDashArray(pPen) {
      iCount := Gdip_GetPenDashCount(pPen)
      If (iCount=-1)
      Return 0
VarSetCapacity(PointsF, 8 * iCount, 0)
Static Ptr := "UPtr"
DllCall("gdiplus\GdipGetPenDashArray", Ptr, pPen, "uPtr", &PointsF, "int", iCount)
Loop %iCount%
{
      A := NumGet(&PointsF, 4*(A_Index-1), "float")
      printList .= A ","
}
Return Trim(printList, ",")
}
Gdip_GetPenCompoundArray(pPen) {
      iCount := Gdip_GetPenCompoundCount(pPen)
      VarSetCapacity(PointsF, 4 * iCount, 0)
      Static Ptr := "UPtr"
      DllCall("gdiplus\GdipGetPenCompoundArray", Ptr, pPen, "uPtr", &PointsF, "int", iCount)
      Loop %iCount%
      {
            A := NumGet(&PointsF, 4*(A_Index-1), "float")
            printList .= A "|"
      }
      Return Trim(printList, "|")
}
Gdip_SetPenLineJoin(pPen, LineJoin) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenLineJoin", Ptr, pPen, "int", LineJoin)
}
Gdip_SetPenMiterLimit(pPen, MiterLimit) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenMiterLimit", Ptr, pPen, "float", MiterLimit)
}
Gdip_SetPenUnit(pPen, Unit) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetPenUnit", Ptr, pPen, "int", Unit)
}
Gdip_GetPenDashCount(pPen) {
      result := 0
      E := DllCall("gdiplus\GdipGetPenDashCount", Ptr, pPen, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetPenDashOffset(pPen) {
      result := 0
      E := DllCall("gdiplus\GdipGetPenDashOffset", Ptr, pPen, "float*", result)
      If E
      Return -1
Return result
}
Gdip_GetPenLineJoin(pPen) {
      result := 0
      E := DllCall("gdiplus\GdipGetPenLineJoin", Ptr, pPen, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetPenMiterLimit(pPen) {
      result := 0
      E := DllCall("gdiplus\GdipGetPenMiterLimit", Ptr, pPen, "float*", result)
      If E
      Return -1
Return result
}
Gdip_GetPenUnit(pPen) {
      result := 0
      E := DllCall("gdiplus\GdipGetPenUnit", Ptr, pPen, "int*", result)
      If E
      Return -1
Return result
}
Gdip_ClonePen(pPen) {
      newPen := 0
      E := DllCall("gdiplus\GdipClonePen", "UPtr", pPen, "UPtr*", newPen)
      Return newPen
}
Gdip_BrushCreateSolid(ARGB:=0xff000000) {
      pBrush := 0
      E := DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, "UPtr*", pBrush)
      return pBrush
}
Gdip_SetSolidFillColor(pBrush, ARGB) {
      return DllCall("gdiplus\GdipSetSolidFillColor", "UPtr", pBrush, "UInt", ARGB)
}
Gdip_GetSolidFillColor(pBrush) {
      ARGB := 0
      E := DllCall("gdiplus\GdipGetSolidFillColor", "UPtr", pBrush, "UInt*", ARGB)
      If E
      return -1
return Format("{1:#x}", ARGB)
}
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle:=0) {
      pBrush := 0
      E := DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, "UPtr*", pBrush)
      return pBrush
}
Gdip_GetHatchBackgroundColor(pHatchBrush) {
      ARGB := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetHatchBackgroundColor", Ptr, pHatchBrush, "uint*", ARGB)
      If E
      Return -1
return Format("{1:#x}", ARGB)
}
Gdip_GetHatchForegroundColor(pHatchBrush) {
      ARGB := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetHatchForegroundColor", Ptr, pHatchBrush, "uint*", ARGB)
      If E
      Return -1
return Format("{1:#x}", ARGB)
}
Gdip_GetHatchStyle(pHatchBrush) {
      result := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetHatchStyle", Ptr, pHatchBrush, "int*", result)
      If E
      Return -1
Return result
}
Gdip_CreateTextureBrush(pBitmap, WrapMode:=1, x:=0, y:=0, w:="", h:="", matrix:="", ScaleX:="", ScaleY:="", Angle:=0, ImageAttr:=0) {
      Static Ptr := "UPtr"
      PtrA := "UPtr*"
      pBrush := 0
      if !(w && h)
      {
            DllCall("gdiplus\GdipCreateTexture", Ptr, pBitmap, "int", WrapMode, PtrA, pBrush)
      } else
      {
            If !ImageAttr
            {
                  if !IsNumber(Matrix)
                        ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
                  else if (Matrix != 1)
                        ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
            } Else usrImageAttr := 1
            If ImageAttr
            {
                  DllCall("gdiplus\GdipCreateTextureIA", Ptr, pBitmap, Ptr, ImageAttr, "float", x, "float", y, "float", w, "float", h, PtrA, pBrush)
                  If pBrush
                        Gdip_SetTextureWrapMode(pBrush, WrapMode)
            } Else
            DllCall("gdiplus\GdipCreateTexture2", Ptr, pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, PtrA, pBrush)
      }
      if (ImageAttr && usrImageAttr!=1)
            Gdip_DisposeImageAttributes(ImageAttr)
      If (ScaleX && ScaleX && pBrush)
            Gdip_ScaleTextureTransform(pBrush, ScaleX, ScaleY)
      If (Angle && pBrush)
            Gdip_RotateTextureTransform(pBrush, Angle)
      return pBrush
}
Gdip_RotateTextureTransform(pTexBrush, Angle, MatrixOrder:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipRotateTextureTransform", Ptr, pTexBrush, "float", Angle, "int", MatrixOrder)
}
Gdip_ScaleTextureTransform(pTexBrush, ScaleX, ScaleY, MatrixOrder:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipScaleTextureTransform", Ptr, pTexBrush, "float", ScaleX, "float", ScaleY, "int", MatrixOrder)
}
Gdip_TranslateTextureTransform(pTexBrush, X, Y, MatrixOrder:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipTranslateTextureTransform", Ptr, pTexBrush, "float", X, "float", Y, "int", MatrixOrder)
}
Gdip_MultiplyTextureTransform(pTexBrush, hMatrix, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipMultiplyTextureTransform", Ptr, pTexBrush, Ptr, hMatrix, "int", matrixOrder)
}
Gdip_SetTextureTransform(pTexBrush, hMatrix) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetTextureTransform", Ptr, pTexBrush, Ptr, hMatrix)
}
Gdip_GetTextureTransform(pTexBrush) {
      hMatrix := 0
      Static Ptr := "UPtr"
      DllCall("gdiplus\GdipGetTextureTransform", Ptr, pTexBrush, "UPtr*", hMatrix)
      Return hMatrix
}
Gdip_ResetTextureTransform(pTexBrush) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipResetTextureTransform", Ptr, pTexBrush)
}
Gdip_SetTextureWrapMode(pTexBrush, WrapMode) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetTextureWrapMode", Ptr, pTexBrush, "int", WrapMode)
}
Gdip_GetTextureWrapMode(pTexBrush) {
      result := 0
      Static Ptr := "UPtr"
      E := DllCall("gdiplus\GdipGetTextureWrapMode", Ptr, pTexBrush, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetTextureImage(pTexBrush) {
      Static Ptr := "UPtr"
      pBitmapDest := 0
      E := DllCall("gdiplus\GdipGetTextureImage", Ptr, pTexBrush
      , "UPtr*", pBitmapDest)
      Return pBitmapDest
}
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode:=1) {
      return Gdip_CreateLinearGrBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode)
}
Gdip_CreateLinearGrBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode:=1) {
      Static Ptr := "UPtr"
      CreatePointF(PointF1, x1, y1)
      CreatePointF(PointF2, x2, y2)
      pLinearGradientBrush := 0
      DllCall("gdiplus\GdipCreateLineBrush", Ptr, &PointF1, Ptr, &PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, "UPtr*", pLinearGradientBrush)
      return pLinearGradientBrush
}
Gdip_SetLinearGrBrushColors(pLinearGradientBrush, ARGB1, ARGB2) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetLineColors", Ptr, pLinearGradientBrush, "UInt", ARGB1, "UInt", ARGB2)
}
Gdip_GetLinearGrBrushColors(pLinearGradientBrush, ByRef ARGB1, ByRef ARGB2) {
      Static Ptr := "UPtr"
      VarSetCapacity(colors, 8, 0)
      E := DllCall("gdiplus\GdipGetLineColors", Ptr, pLinearGradientBrush, "Ptr", &colors)
      ARGB1 := NumGet(colors, 0, "UInt")
      ARGB2 := NumGet(colors, 4, "UInt")
      ARGB1 := Format("{1:#x}", ARGB1)
      ARGB2 := Format("{1:#x}", ARGB2)
      return E
}
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode:=1, WrapMode:=1) {
      return Gdip_CreateLinearGrBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode, WrapMode)
}
Gdip_CreateLinearGrBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode:=1, WrapMode:=1) {
      CreateRectF(RectF, x, y, w, h)
      pLinearGradientBrush := 0
      E := DllCall("gdiplus\GdipCreateLineBrushFromRect", "UPtr", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "UPtr*", pLinearGradientBrush)
      return pLinearGradientBrush
}
Gdip_GetLinearGrBrushGammaCorrection(pLinearGradientBrush) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetLineGammaCorrection", Ptr, pLinearGradientBrush, "int*", result)
      If E
      Return -1
Return result
}
Gdip_SetLinearGrBrushGammaCorrection(pLinearGradientBrush, UseGammaCorrection) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetLineGammaCorrection", Ptr, pLinearGradientBrush, "int", UseGammaCorrection)
}
Gdip_GetLinearGrBrushRect(pLinearGradientBrush) {
      rData := {}
      VarSetCapacity(RectF, 16, 0)
      status := DllCall("gdiplus\GdipGetLineRect", "UPtr", pLinearGradientBrush, "UPtr", &RectF)
      If (!status) {
            rData.x := NumGet(&RectF, 0, "float")
            , rData.y := NumGet(&RectF, 4, "float")
            , rData.w := NumGet(&RectF, 8, "float")
            , rData.h := NumGet(&RectF, 12, "float")
      } Else {
      Return status
}
return rData
}
Gdip_ResetLinearGrBrushTransform(pLinearGradientBrush) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipResetLineTransform", Ptr, pLinearGradientBrush)
}
Gdip_ScaleLinearGrBrushTransform(pLinearGradientBrush, ScaleX, ScaleY, matrixOrder:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipScaleLineTransform", Ptr, pLinearGradientBrush, "float", ScaleX, "float", ScaleY, "int", matrixOrder)
}
Gdip_MultiplyLinearGrBrushTransform(pLinearGradientBrush, hMatrix, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipMultiplyLineTransform", Ptr, pLinearGradientBrush, Ptr, hMatrix, "int", matrixOrder)
}
Gdip_TranslateLinearGrBrushTransform(pLinearGradientBrush, X, Y, matrixOrder:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipTranslateLineTransform", Ptr, pLinearGradientBrush, "float", X, "float", Y, "int", matrixOrder)
}
Gdip_RotateLinearGrBrushTransform(pLinearGradientBrush, Angle, matrixOrder:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipRotateLineTransform", Ptr, pLinearGradientBrush, "float", Angle, "int", matrixOrder)
}
Gdip_SetLinearGrBrushTransform(pLinearGradientBrush, pMatrix) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetLineTransform", Ptr, pLinearGradientBrush, Ptr, pMatrix)
}
Gdip_GetLinearGrBrushTransform(pLineGradientBrush) {
      Static Ptr := "UPtr"
      pMatrix := 0
      DllCall("gdiplus\GdipGetLineTransform", Ptr, pLineGradientBrush, "UPtr*", pMatrix)
      Return pMatrix
}
Gdip_RotateLinearGrBrushAtCenter(pLinearGradientBrush, Angle, MatrixOrder:=1) {
      Rect := Gdip_GetLinearGrBrushRect(pLinearGradientBrush)
      cX := Rect.x + (Rect.w / 2)
      cY := Rect.y + (Rect.h / 2)
      pMatrix := Gdip_CreateMatrix()
      Gdip_TranslateMatrix(pMatrix, -cX , -cY)
      Gdip_RotateMatrix(pMatrix, Angle, MatrixOrder)
      Gdip_TranslateMatrix(pMatrix, cX, cY, MatrixOrder)
      E := Gdip_SetLinearGrBrushTransform(pLinearGradientBrush, pMatrix)
      Gdip_DeleteMatrix(pMatrix)
      Return E
}
Gdip_GetLinearGrBrushWrapMode(pLinearGradientBrush) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetLineWrapMode", Ptr, pLinearGradientBrush, "int*", result)
      If E
      return -1
Return result
}
Gdip_SetLinearGrBrushLinearBlend(pLinearGradientBrush, nFocus, nScale) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetLineLinearBlend", Ptr, pLinearGradientBrush, "float", nFocus, "float", nScale)
}
Gdip_SetLinearGrBrushSigmaBlend(pLinearGradientBrush, nFocus, nScale) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetLineSigmaBlend", Ptr, pLinearGradientBrush, "float", nFocus, "float", nScale)
}
Gdip_SetLinearGrBrushWrapMode(pLinearGradientBrush, WrapMode) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetLineWrapMode", Ptr, pLinearGradientBrush, "int", WrapMode)
}
Gdip_GetLinearGrBrushBlendCount(pLinearGradientBrush) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetLineBlendCount", Ptr, pLinearGradientBrush, "int*", result)
      If E
      return -1
Return result
}
Gdip_SetLinearGrBrushPresetBlend(pBrush, pA, pB, pC, pD, clr1, clr2, clr3, clr4) {
      Static Ptr := "UPtr"
      CreateRectF(POSITIONS, pA, pB, pC, pD)
      CreateRect(COLORS, clr1, clr2, clr3, clr4)
      E:= DllCall("gdiplus\GdipSetLinePresetBlend", Ptr, pBrush, "Ptr", &COLORS, "Ptr", &POSITIONS, "Int", 4)
      Return E
}
Gdip_CloneBrush(pBrush) {
      pBrushClone := 0
      E := DllCall("gdiplus\GdipCloneBrush", "UPtr", pBrush, "UPtr*", pBrushClone)
      return pBrushClone
}
Gdip_GetBrushType(pBrush) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetBrushType", Ptr, pBrush, "int*", result)
      If E
      return -1
Return result
}
Gdip_DeleteRegion(Region) {
      return DllCall("gdiplus\GdipDeleteRegion", "UPtr", Region)
}
Gdip_DeletePen(pPen) {
      return DllCall("gdiplus\GdipDeletePen", "UPtr", pPen)
}
Gdip_DeleteBrush(pBrush) {
      return DllCall("gdiplus\GdipDeleteBrush", "UPtr", pBrush)
}
Gdip_DisposeImage(pBitmap, noErr:=0) {
      If (StrLen(pBitmap)<=2 && noErr=1)
      Return 0
r := DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
If (r=2 || r=1) && (noErr=1)
      r := 0
Return r
}
Gdip_DeleteGraphics(pGraphics) {
      return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}
Gdip_DisposeImageAttributes(ImageAttr) {
      return DllCall("gdiplus\GdipDisposeImageAttributes", "UPtr", ImageAttr)
}
Gdip_DeleteFont(hFont) {
      return DllCall("gdiplus\GdipDeleteFont", "UPtr", hFont)
}
Gdip_DeleteStringFormat(hStringFormat) {
      return DllCall("gdiplus\GdipDeleteStringFormat", "UPtr", hStringFormat)
}
Gdip_DeleteFontFamily(hFontFamily) {
      return DllCall("gdiplus\GdipDeleteFontFamily", "UPtr", hFontFamily)
}
Gdip_DeletePrivateFontCollection(hFontCollection) {
      Return DllCall("gdiplus\GdipDeletePrivateFontCollection", "ptr*", hFontCollection)
}
Gdip_DeleteMatrix(hMatrix) {
      return DllCall("gdiplus\GdipDeleteMatrix", "UPtr", hMatrix)
}
Gdip_DrawOrientedString(pGraphics, String, FontName, Size, Style, X, Y, Width, Height, Angle:=0, pBrush:=0, pPen:=0, Align:=0, ScaleX:=1) {
      If (!pBrush && !pPen)
      Return -3
If RegExMatch(FontName, "^(.\:\\.)")
{
      hFontCollection := Gdip_NewPrivateFontCollection()
      hFontFamily := Gdip_CreateFontFamilyFromFile(FontName, hFontCollection)
} Else hFontFamily := Gdip_FontFamilyCreate(FontName)
If !hFontFamily
      hFontFamily := Gdip_FontFamilyCreateGeneric(1)
If !hFontFamily
{
      If hFontCollection
            Gdip_DeletePrivateFontCollection(hFontCollection)
      Return -1
}
FormatStyle := 0x4000
hStringFormat := Gdip_StringFormatCreate(FormatStyle)
If !hStringFormat
      hStringFormat := Gdip_StringFormatGetGeneric(1)
If !hStringFormat
{
      Gdip_DeleteFontFamily(hFontFamily)
      If hFontCollection
            Gdip_DeletePrivateFontCollection(hFontCollection)
      Return -2
}
Gdip_SetStringFormatTrimming(hStringFormat, 3)
Gdip_SetStringFormatAlign(hStringFormat, Align)
pPath := Gdip_CreatePath()
E := Gdip_AddPathString(pPath, String, hFontFamily, Style, Size, hStringFormat, X, Y, Width, Height)
If (ScaleX>0 && ScaleX!=1)
{
      hMatrix := Gdip_CreateMatrix()
      Gdip_ScaleMatrix(hMatrix, ScaleX, 1)
      Gdip_TransformPath(pPath, hMatrix)
      Gdip_DeleteMatrix(hMatrix)
}
Gdip_RotatePathAtCenter(pPath, Angle)
If (!E && pBrush)
      E := Gdip_FillPath(pGraphics, pBrush, pPath)
If (!E && pPen)
      E := Gdip_DrawPath(pGraphics, pPen, pPath)
PathBounds := Gdip_GetPathWorldBounds(pPath)
Gdip_DeleteStringFormat(hStringFormat)
Gdip_DeleteFontFamily(hFontFamily)
Gdip_DeletePath(pPath)
If hFontCollection
      Gdip_DeletePrivateFontCollection(hFontCollection)
Return E ? E : PathBounds
}
Gdip_TextToGraphics(pGraphics, Text, Options, Font:="Arial", Width:="", Height:="", Measure:=0, userBrush:=0, Unit:=0) {
      Static Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
      , Alignments := "Near|Left|Centre|Center|Far|Right"
      IWidth := Width, IHeight:= Height
      pattern_opts := (A_AhkVersion < "2") ? "iO)" : "i)"
            RegExMatch(Options, pattern_opts "X([\-\d\.]+)(p*)", xpos)
            RegExMatch(Options, pattern_opts "Y([\-\d\.]+)(p*)", ypos)
            RegExMatch(Options, pattern_opts "W([\-\d\.]+)(p*)", Width)
            RegExMatch(Options, pattern_opts "H([\-\d\.]+)(p*)", Height)
            RegExMatch(Options, pattern_opts "C(?!(entre|enter))([a-f\d]+)", Colour)
            RegExMatch(Options, pattern_opts "Top|Up|Bottom|Down|vCentre|vCenter", vPos)
            RegExMatch(Options, pattern_opts "NoWrap", NoWrap)
            RegExMatch(Options, pattern_opts "R(\d)", Rendering)
            RegExMatch(Options, pattern_opts "S(\d+)(p*)", Size)
            if Colour && IsInteger(Colour[2]) && !Gdip_DeleteBrush(Gdip_CloneBrush(Colour[2]))
            {
                  PassBrush := 1
                  pBrush := Colour[2]
            }
            if !(IWidth && IHeight) && ((xpos && xpos[2]) || (ypos && ypos[2]) || (Width && Width[2]) || (Height && Height[2]) || (Size && Size[2]))
                  return -1
            Style := 0
            For eachStyle, valStyle in StrSplit(Styles, "|")
            {
                  if RegExMatch(Options, "\b" valStyle)
                        Style |= (valStyle != "StrikeOut") ? (A_Index-1) : 8
            }
            Align := 0
            For eachAlignment, valAlignment in StrSplit(Alignments, "|")
            {
                  if RegExMatch(Options, "\b" valAlignment)
                        Align |= A_Index//2.1
            }
            xpos := (xpos && (xpos[1] != "")) ? xpos[2] ? IWidth*(xpos[1]/100) : xpos[1] : 0
            ypos := (ypos && (ypos[1] != "")) ? ypos[2] ? IHeight*(ypos[1]/100) : ypos[1] : 0
            Width := (Width && Width[1]) ? Width[2] ? IWidth*(Width[1]/100) : Width[1] : IWidth
            Height := (Height && Height[1]) ? Height[2] ? IHeight*(Height[1]/100) : Height[1] : IHeight
            If !PassBrush
                  Colour := "0x" (Colour && Colour[2] ? Colour[2] : "ff000000")
            Rendering := (Rendering && (Rendering[1] >= 0) && (Rendering[1] <= 5)) ? Rendering[1] : 4
            Size := (Size && (Size[1] > 0)) ? Size[2] ? IHeight*(Size[1]/100) : Size[1] : 12
            If RegExMatch(Font, "^(.\:\\.)")
            {
                  hFontCollection := Gdip_NewPrivateFontCollection()
                  hFontFamily := Gdip_CreateFontFamilyFromFile(Font, hFontCollection)
            } Else hFontFamily := Gdip_FontFamilyCreate(Font)
            If !hFontFamily
                  hFontFamily := Gdip_FontFamilyCreateGeneric(1)
            hFont := Gdip_FontCreate(hFontFamily, Size, Style, Unit)
            FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
            hStringFormat := Gdip_StringFormatCreate(FormatStyle)
            If !hStringFormat
                  hStringFormat := Gdip_StringFormatGetGeneric(1)
            pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
            if !(hFontFamily && hFont && hStringFormat && pBrush && pGraphics)
            {
                  E := !pGraphics ? -2 : !hFontFamily ? -3 : !hFont ? -4 : !hStringFormat ? -5 : !pBrush ? -6 : 0
                  If pBrush
                        Gdip_DeleteBrush(pBrush)
                  If hStringFormat
                        Gdip_DeleteStringFormat(hStringFormat)
                  If hFont
                        Gdip_DeleteFont(hFont)
                  If hFontFamily
                        Gdip_DeleteFontFamily(hFontFamily)
                  If hFontCollection
                        Gdip_DeletePrivateFontCollection(hFontCollection)
                  return E
            }
            CreateRectF(RC, xpos, ypos, Width, Height)
            Gdip_SetStringFormatAlign(hStringFormat, Align)
            If InStr(Options, "autotrim")
                  Gdip_SetStringFormatTrimming(hStringFormat, 3)
            Gdip_SetTextRenderingHint(pGraphics, Rendering)
            ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hStringFormat, RC)
            ReturnRCtest := StrSplit(ReturnRC, "|")
            testX := Floor(ReturnRCtest[1]) - 2
            If (testX>xpos)
            {
                  nxpos := Floor(xpos - (testX - xpos))
                  CreateRectF(RC, nxpos, ypos, Width, Height)
                  ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hStringFormat, RC)
            }
            If vPos
            {
                  ReturnRC := StrSplit(ReturnRC, "|")
                  if (vPos[0] = "vCentre") || (vPos[0] = "vCenter")
                        ypos += (Height-ReturnRC[4])//2
                  else if (vPos[0] = "Top") || (vPos[0] = "Up")
                        ypos += 0
                  else if (vPos[0] = "Bottom") || (vPos[0] = "Down")
                        ypos += Height-ReturnRC[4]
                  CreateRectF(RC, xpos, ypos, Width, ReturnRC[4])
                  ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hStringFormat, RC)
            }
            thisBrush := userBrush ? userBrush : pBrush
            if !Measure
                  _E := Gdip_DrawString(pGraphics, Text, hFont, hStringFormat, thisBrush, RC)
            if !PassBrush
                  Gdip_DeleteBrush(pBrush)
            Gdip_DeleteStringFormat(hStringFormat)
            Gdip_DeleteFont(hFont)
            Gdip_DeleteFontFamily(hFontFamily)
            If hFontCollection
                  Gdip_DeletePrivateFontCollection(hFontCollection)
      return _E ? _E : ReturnRC
}
Gdip_DrawString(pGraphics, sString, hFont, hStringFormat, pBrush, ByRef RectF) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipDrawString"
      , Ptr, pGraphics
      , "WStr", sString
      , "int", -1
      , Ptr, hFont
      , Ptr, &RectF
      , Ptr, hStringFormat
      , Ptr, pBrush)
}
Gdip_MeasureString(pGraphics, sString, hFont, hStringFormat, ByRef RectF) {
      Static Ptr := "UPtr"
      VarSetCapacity(RC, 16)
      Chars := 0
      Lines := 0
      DllCall("gdiplus\GdipMeasureString"
      , Ptr, pGraphics
      , "WStr", sString
      , "int", -1
      , Ptr, hFont
      , Ptr, &RectF
      , Ptr, hStringFormat
      , Ptr, &RC
      , "uint*", Chars
      , "uint*", Lines)
      return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}
Gdip_DrawStringAlongPolygon(pGraphics, String, FontName, FontSize, Style, pBrush, DriverPoints:=0, pPath:=0, minDist:=0, flatness:=4, hMatrix:=0, Unit:=0) {
      If (!minDist || minDist<1)
            minDist := FontSize//4 + 1
      If (pPath && !DriverPoints)
      {
            newPath := Gdip_ClonePath(pPath)
            Gdip_PathOutline(newPath, flatness)
            DriverPoints := Gdip_GetPathPoints(newPath)
            Gdip_DeletePath(newPath)
            If !DriverPoints
                  Return -5
      }
      If (!pPath && !DriverPoints)
      Return -4
If RegExMatch(FontName, "^(.\:\\.)")
{
      hFontCollection := Gdip_NewPrivateFontCollection()
      hFontFamily := Gdip_CreateFontFamilyFromFile(FontName, hFontCollection)
} Else hFontFamily := Gdip_FontFamilyCreate(FontName)
If !hFontFamily
      hFontFamily := Gdip_FontFamilyCreateGeneric(1)
If !hFontFamily
{
      If hFontCollection
            Gdip_DeletePrivateFontCollection(hFontCollection)
      Return -1
}
hFont := Gdip_FontCreate(hFontFamily, FontSize, Style, Unit)
If !hFont
{
      If hFontCollection
            Gdip_DeletePrivateFontCollection(hFontCollection)
      Gdip_DeleteFontFamily(hFontFamily)
      Return -2
}
Points := StrSplit(DriverPoints, "|")
PointsCount := Points.Length()
If (PointsCount<2)
{
      If hFontCollection
            Gdip_DeletePrivateFontCollection(hFontCollection)
      Gdip_DeleteFont(hFont)
      Gdip_DeleteFontFamily(hFontFamily)
      Return -3
}
txtLen := StrLen(String)
If (PointsCount<txtLen)
{
      loopsMax := txtLen * 3
      newDriverPoints := DriverPoints
      Loop %loopsMax%
      {
            newDriverPoints := GenerateIntermediatePoints(newDriverPoints, minDist, totalResult)
            If (totalResult>=txtLen)
                  Break
      }
      String := SubStr(String, 1, totalResult)
} Else newDriverPoints := DriverPoints
E := Gdip_DrawDrivenString(pGraphics, String, hFont, pBrush, newDriverPoints, 1, hMatrix)
Gdip_DeleteFont(hFont)
Gdip_DeleteFontFamily(hFontFamily)
If hFontCollection
      Gdip_DeletePrivateFontCollection(hFontCollection)
return E
}
GenerateIntermediatePoints(PointsList, minDist, ByRef resultPointsCount) {
      AllPoints := StrSplit(PointsList, "|")
      PointsCount := AllPoints.Length()
      thizIndex := 0.5
      resultPointsCount := 0
      loopsMax := PointsCount*2
      Loop %loopsMax%
      {
            thizIndex += 0.5
            thisIndex := InStr(thizIndex, ".5") ? thizIndex : Trim(Round(thizIndex))
            thisPoint := AllPoints[thisIndex]
            theseCoords := StrSplit(thisPoint, ",")
            If (theseCoords[1]!="" && theseCoords[2]!="")
            {
                  resultPointsCount++
                  newPointsList .= theseCoords[1] "," theseCoords[2] "|"
            } Else
            {
                  aIndex := Trim(Round(thizIndex - 0.5))
                  bIndex := Trim(Round(thizIndex + 0.5))
                  theseAcoords := StrSplit(AllPoints[aIndex], ",")
                  theseBcoords := StrSplit(AllPoints[bIndex], ",")
                  If (theseAcoords[1]!="" && theseAcoords[2]!="")
                        && (theseBcoords[1]!="" && theseBcoords[2]!="")
                  {
                        newPosX := (theseAcoords[1] + theseBcoords[1])//2
                        newPosY := (theseAcoords[2] + theseBcoords[2])//2
                        distPosX := newPosX - theseAcoords[1]
                        distPosY := newPosY - theseAcoords[2]
                        If (distPosX>minDist || distPosY>minDist)
                        {
                              newPointsList .= newPosX "," newPosY "|"
                              resultPointsCount++
                        }
                  }
            }
      }
      If !newPointsList
      Return PointsList
Return Trim(newPointsList, "|")
}
Gdip_DrawDrivenString(pGraphics, String, hFont, pBrush, DriverPoints, Flags:=1, hMatrix:=0) {
      txtLen := -1
      Static Ptr := "UPtr"
      iCount := CreatePointsF(PointsF, DriverPoints)
      return DllCall("gdiplus\GdipDrawDriverString", Ptr, pGraphics, "UPtr", &String, "int", txtLen, Ptr, hFont, Ptr, pBrush, Ptr, &PointsF, "int", Flags, Ptr, hMatrix)
}
Gdip_StringFormatCreate(FormatFlags:=0, LangID:=0) {
      hStringFormat := 0
      E := DllCall("gdiplus\GdipCreateStringFormat", "int", FormatFlags, "int", LangID, "UPtr*", hStringFormat)
      return hStringFormat
}
Gdip_CloneStringFormat(hStringFormat) {
      Static Ptr := "UPtr"
      newHStringFormat := 0
      DllCall("gdiplus\GdipCloneStringFormat", Ptr, hStringFormat, "uint*", newHStringFormat)
      Return newHStringFormat
}
Gdip_StringFormatGetGeneric(whichFormat:=0) {
      hStringFormat := 0
      If (whichFormat=1)
            DllCall("gdiplus\GdipStringFormatGetGenericTypographic", "UPtr*", hStringFormat)
      Else
            DllCall("gdiplus\GdipStringFormatGetGenericDefault", "UPtr*", hStringFormat)
      Return hStringFormat
}
Gdip_SetStringFormatAlign(hStringFormat, Align) {
      return DllCall("gdiplus\GdipSetStringFormatAlign", "UPtr", hStringFormat, "int", Align)
}
Gdip_GetStringFormatAlign(hStringFormat) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetStringFormatAlign", Ptr, hStringFormat, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetStringFormatLineAlign(hStringFormat) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetStringFormatLineAlign", Ptr, hStringFormat, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetStringFormatDigitSubstitution(hStringFormat) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetStringFormatDigitSubstitution", Ptr, hStringFormat, "ushort*", 0, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetStringFormatHotkeyPrefix(hStringFormat) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetStringFormatHotkeyPrefix", Ptr, hStringFormat, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetStringFormatTrimming(hStringFormat) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetStringFormatTrimming", Ptr, hStringFormat, "int*", result)
      If E
      Return -1
Return result
}
Gdip_SetStringFormatLineAlign(hStringFormat, StringAlign) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipSetStringFormatLineAlign", Ptr, hStringFormat, "int", StringAlign)
}
Gdip_SetStringFormatDigitSubstitution(hStringFormat, DigitSubstitute, LangID:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetStringFormatDigitSubstitution", Ptr, hStringFormat, "ushort", LangID, "int", DigitSubstitute)
}
Gdip_SetStringFormatFlags(hStringFormat, Flags) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetStringFormatFlags", Ptr, hStringFormat, "int", Flags)
}
Gdip_SetStringFormatHotkeyPrefix(hStringFormat, PrefixProcessMode) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetStringFormatHotkeyPrefix", Ptr, hStringFormat, "int", PrefixProcessMode)
}
Gdip_SetStringFormatTrimming(hStringFormat, TrimMode) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetStringFormatTrimming", Ptr, hStringFormat, "int", TrimMode)
}
Gdip_FontCreate(hFontFamily, Size, Style:=0, Unit:=0) {
      hFont := 0
      DllCall("gdiplus\GdipCreateFont", "UPtr", hFontFamily, "float", Size, "int", Style, "int", Unit, "UPtr*", hFont)
      return hFont
}
Gdip_FontFamilyCreate(FontName) {
      hFontFamily := 0
      _E := DllCall("gdiplus\GdipCreateFontFamilyFromName"
      , "WStr", FontName, "uint", 0
      , "UPtr*", hFontFamily)
      return hFontFamily
}
Gdip_NewPrivateFontCollection() {
      hFontCollection := 0
      DllCall("gdiplus\GdipNewPrivateFontCollection", "ptr*", hFontCollection)
      Return hFontCollection
}
Gdip_CreateFontFamilyFromFile(FontFile, hFontCollection, FontName:="") {
      If !hFontCollection
      Return
hFontFamily := 0
E := DllCall("gdiplus\GdipPrivateAddFontFile", "ptr", hFontCollection, "str", FontFile)
if (FontName="" && !E)
{
      VarSetCapacity(pFontFamily, 10, 0)
      DllCall("gdiplus\GdipGetFontCollectionFamilyList", "ptr", hFontCollection, "int", 1, "ptr", &pFontFamily, "int*", found)
      VarSetCapacity(FontName, 100)
      DllCall("gdiplus\GdipGetFamilyName", "ptr", NumGet(pFontFamily, 0, "ptr"), "str", FontName, "ushort", 1033)
}
If !E
      DllCall("gdiplus\GdipCreateFontFamilyFromName", "str", FontName, "ptr", hFontCollection, "uint*", hFontFamily)
Return hFontFamily
}
Gdip_FontFamilyCreateGeneric(whichStyle) {
      hFontFamily := 0
      If (whichStyle=0)
            DllCall("gdiplus\GdipGetGenericFontFamilyMonospace", "UPtr*", hFontFamily)
      Else If (whichStyle=1)
            DllCall("gdiplus\GdipGetGenericFontFamilySansSerif", "UPtr*", hFontFamily)
      Else If (whichStyle=2)
            DllCall("gdiplus\GdipGetGenericFontFamilySerif", "UPtr*", hFontFamily)
      Return hFontFamily
}
Gdip_CreateFontFromDC(hDC) {
      pFont := 0
      r := DllCall("gdiplus\GdipCreateFontFromDC", "UPtr", hDC, "UPtr*", pFont)
      Return pFont
}
Gdip_CreateFontFromLogfontW(hDC, LogFont) {
      pFont := 0
      DllCall("Gdiplus\GdipCreateFontFromLogfontW", "Ptr", hDC, "Ptr", LogFont, "UPtrP", pFont)
      return pFont
}
Gdip_GetFontHeight(hFont, pGraphics:=0) {
      Static Ptr := "UPtr"
      result := 0
      DllCall("gdiplus\GdipGetFontHeight", Ptr, hFont, Ptr, pGraphics, "float*", result)
      Return result
}
Gdip_GetFontHeightGivenDPI(hFont, DPI:=72) {
      Static Ptr := "UPtr"
      result := 0
      DllCall("gdiplus\GdipGetFontHeightGivenDPI", Ptr, hFont, "float", DPI, "float*", result)
      Return result
}
Gdip_GetFontSize(hFont) {
      Static Ptr := "UPtr"
      result := 0
      DllCall("gdiplus\GdipGetFontSize", Ptr, hFont, "float*", result)
      Return result
}
Gdip_GetFontStyle(hFont) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetFontStyle", Ptr, hFont, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetFontUnit(hFont) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetFontUnit", Ptr, hFont, "int*", result)
      If E
      Return -1
Return result
}
Gdip_CloneFont(hfont) {
      Static Ptr := "UPtr"
      newHFont := 0
      DllCall("gdiplus\GdipCloneFont", Ptr, hFont, "UPtr*", newHFont)
      Return newHFont
}
Gdip_GetFontFamily(hFont) {
      Static Ptr := "UPtr"
      hFontFamily := 0
      DllCall("gdiplus\GdipGetFamily", Ptr, hFont, "UPtr*", hFontFamily)
      Return hFontFamily
}
Gdip_CloneFontFamily(hFontFamily) {
      Static Ptr := "UPtr"
      newHFontFamily := 0
      DllCall("gdiplus\GdipCloneFontFamily", Ptr, hFontFamily, "UPtr*", newHFontFamily)
      Return newHFontFamily
}
Gdip_IsFontStyleAvailable(hFontFamily, Style) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsStyleAvailable", Ptr, hFontFamily, "int", Style, "Int*", result)
      If E
      Return -1
Return result
}
Gdip_GetFontFamilyCellScents(hFontFamily, ByRef Ascent, ByRef Descent, Style:=0) {
      Static Ptr := "UPtr"
      Ascent := 0
      Descent := 0
      E := DllCall("gdiplus\GdipGetCellAscent", Ptr, hFontFamily, "int", Style, "ushort*", Ascent)
      E := DllCall("gdiplus\GdipGetCellDescent", Ptr, hFontFamily, "int", Style, "ushort*", Descent)
      Return E
}
Gdip_GetFontFamilyEmHeight(hFontFamily, Style:=0) {
      Static Ptr := "UPtr"
      result := 0
      DllCall("gdiplus\GdipGetEmHeight", Ptr, hFontFamily, "int", Style, "ushort*", result)
      Return result
}
Gdip_GetFontFamilyLineSpacing(hFontFamily, Style:=0) {
      Static Ptr := "UPtr"
      result := 0
      DllCall("gdiplus\GdipGetLineSpacing", Ptr, hFontFamily, "int", Style, "ushort*", result)
      Return result
}
Gdip_GetFontFamilyName(hFontFamily) {
      Static Ptr := "UPtr"
      VarSetCapacity(FontName, 90)
      DllCall("gdiplus\GdipGetFamilyName", Ptr, hFontFamily, "Ptr", &FontName, "ushort", 0)
      Return FontName
}
Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y) {
      hMatrix := 0
      DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, "UPtr*", hMatrix)
      return hMatrix
}
Gdip_CreateMatrix() {
      hMatrix := 0
      DllCall("gdiplus\GdipCreateMatrix", "UPtr*", hMatrix)
      return hMatrix
}
Gdip_InvertMatrix(hMatrix) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipInvertMatrix", Ptr, hMatrix)
}
Gdip_IsMatrixEqual(hMatrixA, hMatrixB) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsMatrixEqual", Ptr, hMatrixA, Ptr, hMatrixB, "int*", result)
      If E
      Return -1
Return result
}
Gdip_IsMatrixIdentity(hMatrix) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsMatrixIdentity", Ptr, hMatrix, "int*", result)
      If E
      Return -1
Return result
}
Gdip_IsMatrixInvertible(hMatrix) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsMatrixInvertible", Ptr, hMatrix, "int*", result)
      If E
      Return -1
Return result
}
Gdip_MultiplyMatrix(hMatrixA, hMatrixB, matrixOrder) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipMultiplyMatrix", Ptr, hMatrixA, Ptr, hMatrixB, "int", matrixOrder)
}
Gdip_CloneMatrix(hMatrix) {
      Static Ptr := "UPtr"
      newHMatrix := 0
      DllCall("gdiplus\GdipCloneMatrix", Ptr, hMatrix, "UPtr*", newHMatrix)
      return newHMatrix
}
Gdip_CreatePath(BrushMode:=0) {
      pPath := 0
      DllCall("gdiplus\GdipCreatePath", "int", BrushMode, "UPtr*", pPath)
      return pPath
}
Gdip_AddPathEllipse(pPath, x, y, w, h) {
      return DllCall("gdiplus\GdipAddPathEllipse", "UPtr", pPath, "float", x, "float", y, "float", w, "float", h)
}
Gdip_AddPathRectangle(pPath, x, y, w, h) {
      return DllCall("gdiplus\GdipAddPathRectangle", "UPtr", pPath, "float", x, "float", y, "float", w, "float", h)
}
Gdip_AddPathRoundedRectangle(pPath, x, y, w, h, r) {
      E := 0
      r := (w <= h) ? (r < w / 2) ? r : w / 2 : (r < h / 2) ? r : h / 2
      If (E := Gdip_AddPathRectangle(pPath, x+r, y, w-(2*r), r))
      Return E
If (E := Gdip_AddPathRectangle(pPath, x+r, y+h-r, w-(2*r), r))
      Return E
If (E := Gdip_AddPathRectangle(pPath, x, y+r, r, h-(2*r)))
      Return E
If (E := Gdip_AddPathRectangle(pPath, x+w-r, y+r, r, h-(2*r)))
      Return E
If (E := Gdip_AddPathRectangle(pPath, x+r, y+r, w-(2*r), h-(2*r)))
      Return E
If (E := Gdip_AddPathPie(pPath, x, y, 2*r, 2*r, 180, 90))
      Return E
If (E := Gdip_AddPathPie(pPath, x+w-(2*r), y, 2*r, 2*r, 270, 90))
      Return E
If (E := Gdip_AddPathPie(pPath, x, y+h-(2*r), 2*r, 2*r, 90, 90))
      Return E
If (E := Gdip_AddPathPie(pPath, x+w-(2*r), y+h-(2*r), 2*r, 2*r, 0, 90))
      Return E
Return E
}
Gdip_AddPathPolygon(pPath, Points) {
      Static Ptr := "UPtr"
      iCount := CreatePointsF(PointsF, Points)
      return DllCall("gdiplus\GdipAddPathPolygon", Ptr, pPath, Ptr, &PointsF, "int", iCount)
}
Gdip_AddPathClosedCurve(pPath, Points, Tension:=1) {
      iCount := CreatePointsF(PointsF, Points)
      If Tension
      return DllCall("gdiplus\GdipAddPathClosedCurve2", "UPtr", pPath, "UPtr", &PointsF, "int", iCount, "float", Tension)
Else
      return DllCall("gdiplus\GdipAddPathClosedCurve", "UPtr", pPath, "UPtr", &PointsF, "int", iCount)
}
Gdip_AddPathCurve(pPath, Points, Tension:="") {
      iCount := CreatePointsF(PointsF, Points)
      If Tension
      return DllCall("gdiplus\GdipAddPathCurve2", "UPtr", pPath, "UPtr", &PointsF, "int", iCount, "float", Tension)
Else
      return DllCall("gdiplus\GdipAddPathCurve", "UPtr", pPath, "UPtr", &PointsF, "int", iCount)
}
Gdip_AddPathToPath(pPathA, pPathB, fConnect) {
      return DllCall("gdiplus\GdipAddPathCurve2", "UPtr", pPathA, "UPtr", pPathB, "int", fConnect)
}
Gdip_AddPathStringSimplified(pPath, String, FontName, Size, Style, X, Y, Width, Height, Align:=0, NoWrap:=0) {
      FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
      If RegExMatch(FontName, "^(.\:\\.)")
      {
            hFontCollection := Gdip_NewPrivateFontCollection()
            hFontFamily := Gdip_CreateFontFamilyFromFile(FontName, hFontCollection)
      } Else hFontFamily := Gdip_FontFamilyCreate(FontName)
      If !hFontFamily
            hFontFamily := Gdip_FontFamilyCreateGeneric(1)
      If !hFontFamily
      {
            If hFontCollection
                  Gdip_DeletePrivateFontCollection(hFontCollection)
      Return -1
}
hStringFormat := Gdip_StringFormatCreate(FormatStyle)
If !hStringFormat
      hStringFormat := Gdip_StringFormatGetGeneric(1)
If !hStringFormat
{
      Gdip_DeleteFontFamily(hFontFamily)
      If hFontCollection
            Gdip_DeletePrivateFontCollection(hFontCollection)
      Return -2
}
Gdip_SetStringFormatTrimming(hStringFormat, 3)
Gdip_SetStringFormatAlign(hStringFormat, Align)
E := Gdip_AddPathString(pPath, String, hFontFamily, Style, Size, hStringFormat, X, Y, Width, Height)
Gdip_DeleteStringFormat(hStringFormat)
Gdip_DeleteFontFamily(hFontFamily)
If hFontCollection
      Gdip_DeletePrivateFontCollection(hFontCollection)
Return E
}
Gdip_AddPathString(pPath, String, hFontFamily, Style, Size, hStringFormat, X, Y, W, H) {
      Static Ptr := "UPtr"
      CreateRectF(RectF, X, Y, W, H)
      E := DllCall("gdiplus\GdipAddPathString", Ptr, pPath, "WStr", String, "int", -1, Ptr, hFontFamily, "int", Style, "float", Size, Ptr, &RectF, Ptr, hStringFormat)
      Return E
}
Gdip_SetPathFillMode(pPath, FillMode) {
      return DllCall("gdiplus\GdipSetPathFillMode", "UPtr", pPath, "int", FillMode)
}
Gdip_GetPathFillMode(pPath) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetPathFillMode", Ptr, pPath, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetPathLastPoint(pPath, ByRef X, ByRef Y) {
      Static Ptr := "UPtr"
      VarSetCapacity(PointF, 8, 0)
      E := DllCall("gdiplus\GdipGetPathLastPoint", Ptr, pPath, "UPtr", &PointF)
      If !E
      {
            x := NumGet(PointF, 0, "float")
            y := NumGet(PointF, 4, "float")
      }
      Return E
}
Gdip_GetPathPointsCount(pPath) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetPointCount", Ptr, pPath, "int*", result)
      If E
      Return -1
Return result
}
Gdip_GetPathPoints(pPath) {
      PointsCount := Gdip_GetPathPointsCount(pPath)
      If (PointsCount=-1)
      Return 0
Static Ptr := "UPtr"
VarSetCapacity(PointsF, 8 * PointsCount, 0)
DllCall("gdiplus\GdipGetPathPoints", Ptr, pPath, Ptr, &PointsF, "intP", PointsCount)
Loop %PointsCount%
{
      A := NumGet(&PointsF, 8*(A_Index-1), "float")
      B := NumGet(&PointsF, (8*(A_Index-1))+4, "float")
      printList .= A "," B "|"
}
Return Trim(printList, "|")
}
Gdip_FlattenPath(pPath, flatness, hMatrix:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipFlattenPath", Ptr, pPath, Ptr, hMatrix, "float", flatness)
}
Gdip_WidenPath(pPath, pPen, hMatrix:=0, Flatness:=1) {
      return DllCall("gdiplus\GdipWidenPath", "UPtr", pPath, "uint", pPen, "UPtr", hMatrix, "float", Flatness)
}
Gdip_PathOutline(pPath, flatness:=1, hMatrix:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipWindingModeOutline", Ptr, pPath, Ptr, hMatrix, "float", flatness)
}
Gdip_ResetPath(pPath) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipResetPath", Ptr, pPath)
}
Gdip_ReversePath(pPath) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipReversePath", Ptr, pPath)
}
Gdip_IsOutlineVisiblePathPoint(pGraphics, pPath, pPen, X, Y) {
      result := 0
      E := DllCall("gdiplus\GdipIsOutlineVisiblePathPoint", Ptr, pPath, "float", X, "float", Y, Ptr, pPen, Ptr, pGraphics, "int*", result)
      If E
      Return -1
Return result
}
Gdip_IsVisiblePathPoint(pPath, x, y, pGraphics) {
      result := 0
      E := DllCall("gdiplus\GdipIsVisiblePathPoint", "UPtr", pPath, "float", x, "float", y, "UPtr", pGraphics, "UPtr*", result)
      If E
      return -1
return result
}
Gdip_DeletePath(pPath) {
      return DllCall("gdiplus\GdipDeletePath", "UPtr", pPath)
}
Gdip_SetTextRenderingHint(pGraphics, RenderingHint) {
      return DllCall("gdiplus\GdipSetTextRenderingHint", "UPtr", pGraphics, "int", RenderingHint)
}
Gdip_SetInterpolationMode(pGraphics, InterpolationMode) {
      return DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", pGraphics, "int", InterpolationMode)
}
Gdip_SetSmoothingMode(pGraphics, SmoothingMode) {
      return DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pGraphics, "int", SmoothingMode)
}
Gdip_SetCompositingMode(pGraphics, CompositingMode) {
      return DllCall("gdiplus\GdipSetCompositingMode", "UPtr", pGraphics, "int", CompositingMode)
}
Gdip_SetCompositingQuality(pGraphics, CompositionQuality) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetCompositingQuality", Ptr, pGraphics, "int", CompositionQuality)
}
Gdip_SetPageScale(pGraphics, Scale) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetPageScale", Ptr, pGraphics, "float", Scale)
}
Gdip_SetPageUnit(pGraphics, Unit) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetPageUnit", Ptr, pGraphics, "int", Unit)
}
Gdip_SetPixelOffsetMode(pGraphics, PixelOffsetMode) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetPixelOffsetMode", Ptr, pGraphics, "int", PixelOffsetMode)
}
Gdip_SetRenderingOrigin(pGraphics, X, Y) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetRenderingOrigin", Ptr, pGraphics, "int", X, "int", Y)
}
Gdip_SetTextContrast(pGraphics, Contrast) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetTextContrast", Ptr, pGraphics, "uint", Contrast)
}
Gdip_RestoreGraphics(pGraphics, State) {
      return DllCall("Gdiplus\GdipRestoreGraphics", "UPtr", pGraphics, "UInt", State)
}
Gdip_SaveGraphics(pGraphics) {
      State := 0
      DllCall("Gdiplus\GdipSaveGraphics", "Ptr", pGraphics, "UIntP", State)
      return State
}
Gdip_GetTextContrast(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetTextContrast", Ptr, pGraphics, "uint*", result)
      If E
      return -1
Return result
}
Gdip_GetCompositingMode(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetCompositingMode", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetCompositingQuality(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetCompositingQuality", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetInterpolationMode(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetInterpolationMode", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetSmoothingMode(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetSmoothingMode", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetPageScale(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetPageScale", Ptr, pGraphics, "float*", result)
      If E
      return -1
Return result
}
Gdip_GetPageUnit(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetPageUnit", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetPixelOffsetMode(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetPixelOffsetMode", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_GetRenderingOrigin(pGraphics, ByRef X, ByRef Y) {
      Static Ptr := "UPtr"
      x := 0
      y := 0
      return DllCall("gdiplus\GdipGetRenderingOrigin", Ptr, pGraphics, "uint*", X, "uint*", Y)
}
Gdip_GetTextRenderingHint(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipGetTextRenderingHint", Ptr, pGraphics, "int*", result)
      If E
      return -1
Return result
}
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder:=0) {
      return DllCall("gdiplus\GdipRotateWorldTransform", "UPtr", pGraphics, "float", Angle, "int", MatrixOrder)
}
Gdip_ScaleWorldTransform(pGraphics, ScaleX, ScaleY, MatrixOrder:=0) {
      return DllCall("gdiplus\GdipScaleWorldTransform", "UPtr", pGraphics, "float", ScaleX, "float", ScaleY, "int", MatrixOrder)
}
Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder:=0) {
      return DllCall("gdiplus\GdipTranslateWorldTransform", "UPtr", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}
Gdip_MultiplyWorldTransform(pGraphics, hMatrix, matrixOrder:=0) {
      Static Ptr := "UPtr"
      Return DllCall("gdiplus\GdipMultiplyWorldTransform", Ptr, pGraphics, Ptr, hMatrix, "int", matrixOrder)
}
Gdip_ResetWorldTransform(pGraphics) {
      return DllCall("gdiplus\GdipResetWorldTransform", "UPtr", pGraphics)
}
Gdip_ResetPageTransform(pGraphics) {
      return DllCall("gdiplus\GdipResetPageTransform", "UPtr", pGraphics)
}
Gdip_SetWorldTransform(pGraphics, hMatrix) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetWorldTransform", Ptr, pGraphics, Ptr, hMatrix)
}
Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation) {
      pi := 3.14159, TAngle := Angle*(pi/180)
      Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
      if ((Bound >= 0) && (Bound <= 90))
            xTranslation := Height*Sin(TAngle), yTranslation := 0
      else if ((Bound > 90) && (Bound <= 180))
            xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
      else if ((Bound > 180) && (Bound <= 270))
            xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
      else if ((Bound > 270) && (Bound <= 360))
            xTranslation := 0, yTranslation := -Width*Sin(TAngle)
}
Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight) {
      Static pi := 3.14159
      if !(Width && Height)
      return -1
TAngle := Angle*(pi/180)
RWidth := Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle))
RHeight := Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle))
}
Gdip_GetRotatedEllipseDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight) {
      if !(Width && Height)
      return -1
pPath := Gdip_CreatePath()
Gdip_AddPathEllipse(pPath, 0, 0, Width, Height)
pMatrix := Gdip_CreateMatrix()
Gdip_RotateMatrix(pMatrix, Angle, MatrixOrder)
E := Gdip_TransformPath(pPath, pMatrix)
Gdip_DeleteMatrix(pMatrix)
pathBounds := Gdip_GetPathWorldBounds(pPath)
Gdip_DeletePath(pPath)
RWidth := pathBounds.w
RHeight := pathBounds.h
Return E
}
Gdip_GetWorldTransform(pGraphics) {
      Static Ptr := "UPtr"
      hMatrix := 0
      E := DllCall("gdiplus\GdipGetWorldTransform", Ptr, pGraphics, "UPtr*", hMatrix)
      Return hMatrix
}
Gdip_IsVisibleGraphPoint(pGraphics, X, Y) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsVisiblePoint", Ptr, pGraphics, "float", X, "float", Y, "int*", result)
      If E
      Return -1
Return result
}
Gdip_IsVisibleGraphRect(pGraphics, X, Y, Width, Height) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsVisibleRect", Ptr, pGraphics, "float", X, "float", Y, "float", Width, "float", Height, "int*", result)
      If E
      Return -1
Return result
}
Gdip_IsVisibleGraphRectEntirely(pGraphics, X, Y, Width, Height) {
      a := Gdip_IsVisibleGraphPoint(pGraphics, X, Y)
      b := Gdip_IsVisibleGraphPoint(pGraphics, X + Width, Y)
      c := Gdip_IsVisibleGraphPoint(pGraphics, X + Width, Y + Height)
      d := Gdip_IsVisibleGraphPoint(pGraphics, X, Y + Height)
      If (a=1 && b=1 && c=1 && d=1)
      Return 1
Else If (a=-1 || b=-1 || c=-1 || d=-1)
      Return -1
Else
      Return 0
}
Gdip_IsClipEmpty(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsClipEmpty", Ptr, pGraphics, "int*", result)
      If E
      Return -1
Return result
}
Gdip_IsVisibleClipEmpty(pGraphics) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsVisibleClipEmpty", Ptr, pGraphics, "uint*", result)
      If E
      Return -1
Return result
}
Gdip_SetClipFromGraphics(pGraphics, pGraphicsSrc, CombineMode:=0) {
      return DllCall("gdiplus\GdipSetClipGraphics", "UPtr", pGraphics, "UPtr", pGraphicsSrc, "int", CombineMode)
}
Gdip_GetClipBounds(pGraphics) {
      rData := {}
      VarSetCapacity(RectF, 16, 0)
      status := DllCall("gdiplus\GdipGetClipBounds", "UPtr", pGraphics, "UPtr", &RectF)
      If (!status) {
            rData.x := NumGet(&RectF, 0, "float")
            , rData.y := NumGet(&RectF, 4, "float")
            , rData.w := NumGet(&RectF, 8, "float")
            , rData.h := NumGet(&RectF, 12, "float")
      } Else {
      Return status
}
return rData
}
Gdip_GetVisibleClipBounds(pGraphics) {
      rData := {}
      VarSetCapacity(RectF, 16, 0)
      status := DllCall("gdiplus\GdipGetVisibleClipBounds", "UPtr", pGraphics, "UPtr", &RectF)
      If (!status) {
            rData.x := NumGet(&RectF, 0, "float")
            , rData.y := NumGet(&RectF, 4, "float")
            , rData.w := NumGet(&RectF, 8, "float")
            , rData.h := NumGet(&RectF, 12, "float")
      } Else {
      Return status
}
return rData
}
Gdip_TranslateClip(pGraphics, dX, dY) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipTranslateClip", Ptr, pGraphics, "float", dX, "float", dY)
}
Gdip_ResetClip(pGraphics) {
      return DllCall("gdiplus\GdipResetClip", "UPtr", pGraphics)
}
Gdip_GetClipRegion(pGraphics) {
      Region := Gdip_CreateRegion()
      E := DllCall("gdiplus\GdipGetClip", "UPtr", pGraphics, "UInt", Region)
      If E
      return -1
return Region
}
Gdip_SetClipRegion(pGraphics, Region, CombineMode:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetClipRegion", Ptr, pGraphics, Ptr, Region, "int", CombineMode)
}
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode:=0) {
      return DllCall("gdiplus\GdipSetClipRect", "UPtr", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}
Gdip_SetClipPath(pGraphics, pPath, CombineMode:=0) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetClipPath", Ptr, pGraphics, Ptr, pPath, "int", CombineMode)
}
Gdip_CreateRegion() {
      Region := 0
      DllCall("gdiplus\GdipCreateRegion", "UInt*", Region)
      return Region
}
Gdip_CombineRegionRegion(Region, Region2, CombineMode) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipCombineRegionRegion", Ptr, Region, Ptr, Region2, "int", CombineMode)
}
Gdip_CombineRegionRect(Region, x, y, w, h, CombineMode) {
      Static Ptr := "UPtr"
      CreateRectF(RectF, x, y, w, h)
      return DllCall("gdiplus\GdipCombineRegionRect", Ptr, Region, Ptr, &RectF, "int", CombineMode)
}
Gdip_CombineRegionPath(Region, pPath, CombineMode) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipCombineRegionPath", Ptr, Region, Ptr, pPath, "int", CombineMode)
}
Gdip_CreateRegionPath(pPath) {
      Static Ptr := "UPtr"
      Region := 0
      E := DllCall("gdiplus\GdipCreateRegionPath", Ptr, pPath, "UInt*", Region)
      If E
      return -1
return Region
}
Gdip_CreateRegionRect(x, y, w, h) {
      CreateRectF(RectF, x, y, w, h)
      E := DllCall("gdiplus\GdipCreateRegionRect", "UPtr", &RectF, "UInt*", Region)
      If E
      return -1
return Region
}
Gdip_IsEmptyRegion(pGraphics, Region) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsEmptyRegion", Ptr, Region, Ptr, pGraphics, "uInt*", result)
      If E
      return -1
Return result
}
Gdip_IsEqualRegion(pGraphics, Region1, Region2) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsEqualRegion", Ptr, Region1, Ptr, Region2, Ptr, pGraphics, "uInt*", result)
      If E
      return -1
Return result
}
Gdip_IsInfiniteRegion(pGraphics, Region) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsInfiniteRegion", Ptr, Region, Ptr, pGraphics, "uInt*", result)
      If E
      return -1
Return result
}
Gdip_IsVisibleRegionPoint(pGraphics, Region, x, y) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsVisibleRegionPoint", Ptr, Region, "float", X, "float", Y, Ptr, pGraphics, "uInt*", result)
      If E
      return -1
Return result
}
Gdip_IsVisibleRegionRect(pGraphics, Region, x, y, width, height) {
      Static Ptr := "UPtr"
      result := 0
      E := DllCall("gdiplus\GdipIsVisibleRegionRect", Ptr, Region, "float", X, "float", Y, "float", Width, "float", Height, Ptr, pGraphics, "uInt*", result)
      If E
      return -1
Return result
}
Gdip_IsVisibleRegionRectEntirely(pGraphics, Region, x, y, width, height) {
      a := Gdip_IsVisibleRegionPoint(pGraphics, Region, X, Y)
      b := Gdip_IsVisibleRegionPoint(pGraphics, Region, X + Width, Y)
      c := Gdip_IsVisibleRegionPoint(pGraphics, Region, X + Width, Y + Height)
      d := Gdip_IsVisibleRegionPoint(pGraphics, Region, X, Y + Height)
      If (a=1 && b=1 && c=1 && d=1)
      Return 1
Else If (a=-1 || b=-1 || c=-1 || d=-1)
      Return -1
Else
      Return 0
}
Gdip_SetEmptyRegion(Region) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetEmpty", Ptr, Region)
}
Gdip_SetInfiniteRegion(Region) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipSetInfinite", Ptr, Region)
}
Gdip_GetRegionBounds(pGraphics, Region) {
      rData := {}
      VarSetCapacity(RectF, 16, 0)
      status := DllCall("gdiplus\GdipGetRegionBounds", "UPtr", Region, "UPtr", pGraphics, "UPtr", &RectF)
      If (!status) {
            rData.x := NumGet(&RectF, 0, "float")
            , rData.y := NumGet(&RectF, 4, "float")
            , rData.w := NumGet(&RectF, 8, "float")
            , rData.h := NumGet(&RectF, 12, "float")
      } Else {
      Return status
}
return rData
}
Gdip_TranslateRegion(Region, X, Y) {
      Static Ptr := "UPtr"
      return DllCall("gdiplus\GdipTranslateRegion", Ptr, Region, "float", X, "float", Y)
}
Gdip_RotateRegionAtCenter(pGraphics, Region, Angle, MatrixOrder:=1) {
      Rect := Gdip_GetRegionBounds(pGraphics, Region)
      cX := Rect.x + (Rect.w / 2)
      cY := Rect.y + (Rect.h / 2)
      pMatrix := Gdip_CreateMatrix()
      Gdip_TranslateMatrix(pMatrix, -cX , -cY)
      Gdip_RotateMatrix(pMatrix, Angle, MatrixOrder)
      Gdip_TranslateMatrix(pMatrix, cX, cY, MatrixOrder)
      E := Gdip_TransformRegion(Region, pMatrix)
      Gdip_DeleteMatrix(pMatrix)
      Return E
}
Gdip_TransformRegion(Region, pMatrix) {
      return DllCall("gdiplus\GdipTransformRegion", "UPtr", Region, "UPtr", pMatrix)
}
Gdip_CloneRegion(Region) {
      newRegion := 0
      DllCall("gdiplus\GdipCloneRegion", "UPtr", Region, "UInt*", newRegion)
      return newRegion
}
Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode := 3, PixelFormat := 0x26200a) {
      Static Ptr := "UPtr"
      CreateRect(_Rect, x, y, w, h)
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)
      _E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, &_Rect, "uint", LockMode, "int", PixelFormat, Ptr, &BitmapData)
      Stride := NumGet(BitmapData, 8, "Int")
      Scan0 := NumGet(BitmapData, 16, Ptr)
      return _E
}
Gdip_UnlockBits(pBitmap, ByRef BitmapData) {
      Static Ptr := "UPtr"
      return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, &BitmapData)
}
Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride) {
      NumPut(ARGB, Scan0+0, (x*4)+(y*Stride), "UInt")
}
Gdip_GetLockBitPixel(Scan0, x, y, Stride) {
      return NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")
}
Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize) {
      static PixelateBitmap
      Static Ptr := "UPtr"
      if (!PixelateBitmap)
      {
            if (A_PtrSize!=8)
                  MCode_PixelateBitmap := "
            (LTrim Join
            558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
            397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
            8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
            4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
            C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
            8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
            148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
            B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
            F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
            038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
            1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
            FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
            D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
            45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
            89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
            0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
            75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
            8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
            B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
            451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
            75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
            8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
            )"
            else
                  MCode_PixelateBitmap := "
            (LTrim Join
            4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
            448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
            4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
            C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
            24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
            004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
            0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
            DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
            024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
            99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
            8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
            4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
            000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
            ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
            4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
            99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
            8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
            2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
            FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
            83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
            F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
            0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
            413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
            )"
            VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
            nCount := StrLen(MCode_PixelateBitmap)//2
      N := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %N%
                  NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "UChar")
            DllCall("VirtualProtect", Ptr, &PixelateBitmap, Ptr, VarSetCapacity(PixelateBitmap), "uint", 0x40, "UPtr*", 0)
      }
      Gdip_GetImageDimensions(pBitmap, Width, Height)
      if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
      return -1
if (BlockSize > Width || BlockSize > Height)
      return -2
E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
if (E1 || E2)
      return -3
DllCall(&PixelateBitmap, Ptr, Scan01, Ptr, Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)
Gdip_UnlockBits(pBitmap, BitmapData1)
Gdip_UnlockBits(pBitmapOut, BitmapData2)
return 0
}
Gdip_ToARGB(A, R, G, B) {
      return (A << 24) | (R << 16) | (G << 8) | B
}
Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B) {
      A := (0xff000000 & ARGB) >> 24
      R := (0x00ff0000 & ARGB) >> 16
      G := (0x0000ff00 & ARGB) >> 8
      B := 0x000000ff & ARGB
}
Gdip_AFromARGB(ARGB) {
      return (0xff000000 & ARGB) >> 24
}
Gdip_RFromARGB(ARGB) {
      return (0x00ff0000 & ARGB) >> 16
}
Gdip_GFromARGB(ARGB) {
      return (0x0000ff00 & ARGB) >> 8
}
Gdip_BFromARGB(ARGB) {
      return 0x000000ff & ARGB
}
StrGetB(Address, Length:=-1, Encoding:=0) {
      if !IsInteger(Length)
            Encoding := Length, Length := -1
      if (Address+0 < 1024)
      return
if (Encoding = "UTF-16")
      Encoding := 1200
else if (Encoding = "UTF-8")
      Encoding := 65001
else if SubStr(Encoding,1,2)="CP"
      Encoding := SubStr(Encoding,3)
if !Encoding
{
      if (Length == -1)
            Length := DllCall("lstrlen", "uint", Address)
      VarSetCapacity(String, Length)
      DllCall("lstrcpyn", "str", String, "uint", Address, "int", Length + 1)
}
else if (Encoding = 1200)
{
      char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "uint", 0, "uint", 0, "uint", 0, "uint", 0)
      VarSetCapacity(String, char_count)
      DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "str", String, "int", char_count, "uint", 0, "uint", 0)
}
else if IsInteger(Encoding)
{
      char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", 0, "int", 0)
      VarSetCapacity(String, char_count * 2)
      char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", &String, "int", char_count * 2)
      String := StrGetB(&String, char_count, 1200)
}
return String
}
Gdip_Startup(multipleInstances:=0) {
      Static Ptr := "UPtr"
      pToken := 0
      If (multipleInstances=0)
      {
            if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
                  DllCall("LoadLibrary", "str", "gdiplus")
      } Else DllCall("LoadLibrary", "str", "gdiplus")
      VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
      DllCall("gdiplus\GdiplusStartup", "UPtr*", pToken, Ptr, &si, Ptr, 0)
      return pToken
}
Gdip_Shutdown(pToken) {
      Static Ptr := "UPtr"
      DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
      hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
      if hModule
            DllCall("FreeLibrary", Ptr, hModule)
      return 0
}
IsInteger(Var) {
      Static Integer := "Integer"
      If Var Is Integer
      Return True
Return False
}
IsNumber(Var) {
      Static number := "number"
      If Var Is number
      Return True
Return False
}
GetMonitorCount() {
      Monitors := MDMF_Enum()
      for k,v in Monitors
            count := A_Index
      return count
}
GetMonitorInfo(MonitorNum) {
      Monitors := MDMF_Enum()
      for k,v in Monitors
            if (v.Num = MonitorNum)
      return v
}
GetPrimaryMonitor() {
      Monitors := MDMF_Enum()
      for k,v in Monitors
            If (v.Primary)
      return v.Num
}
MDMF_Enum(HMON := "") {
      Static CallbackFunc := Func(A_AhkVersion < "2" ? "RegisterCallback" : "CallbackCreate")
      Static EnumProc := CallbackFunc.Call("MDMF_EnumProc")
      Static Obj := (A_AhkVersion < "2") ? "Object" : "Map"
            Static Monitors := {}
            If (HMON = "")
            {
                  Monitors := %Obj%("TotalCount", 0)
                  If !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", &Monitors, "Int")
                        Return False
            }
      Return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
      Monitors := Object(ObjectAddr)
      Monitors[HMON] := MDMF_GetInfo(HMON)
      Monitors["TotalCount"]++
      If (Monitors[HMON].Primary)
            Monitors["Primary"] := HMON
      Return True
}
MDMF_FromHWND(HWND, Flag := 0) {
      Return DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", Flag, "Ptr")
}
MDMF_FromPoint(ByRef X := "", ByRef Y := "", Flag := 0) {
      If (X = "") || (Y = "") {
            VarSetCapacity(PT, 8, 0)
            DllCall("User32.dll\GetCursorPos", "Ptr", &PT, "Int")
            If (X = "")
                  X := NumGet(PT, 0, "Int")
            If (Y = "")
                  Y := NumGet(PT, 4, "Int")
      }
      Return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", Flag, "Ptr")
}
MDMF_FromRect(X, Y, W, H, Flag := 0) {
      VarSetCapacity(RC, 16, 0)
      NumPut(X, RC, 0, "Int"), NumPut(Y, RC, 4, "Int"), NumPut(X + W, RC, 8, "Int"), NumPut(Y + H, RC, 12, "Int")
      Return DllCall("User32.dll\MonitorFromRect", "Ptr", &RC, "UInt", Flag, "Ptr")
}
MDMF_GetInfo(HMON) {
      NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
      If DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", &MIEX, "Int")
Return {Name: (Name := StrGet(&MIEX + 40, 32))
      , Num: RegExReplace(Name, ".*(\d+)$", "$1")
      , Left: NumGet(MIEX, 4, "Int")
      , Top: NumGet(MIEX, 8, "Int")
      , Right: NumGet(MIEX, 12, "Int")
      , Bottom: NumGet(MIEX, 16, "Int")
      , WALeft: NumGet(MIEX, 20, "Int")
      , WATop: NumGet(MIEX, 24, "Int")
      , WARight: NumGet(MIEX, 28, "Int")
      , WABottom: NumGet(MIEX, 32, "Int")
, Primary: NumGet(MIEX, 36, "UInt")}
Return False
}
Gdip_LoadImageFromFile(sFile, useICM:=0) {
      pImage := 0
      function2call := (useICM=1) ? "GdipLoadImageFromFileICM" : "GdipLoadImageFromFile"
            R := DllCall("gdiplus\" function2call, "WStr", sFile, "UPtrP", pImage)
            ErrorLevel := R
      Return pImage
}
Gdip_GetPropertyCount(pImage) {
      PropCount := 0
      Static Ptr := "UPtr"
      R := DllCall("gdiplus\GdipGetPropertyCount", Ptr, pImage, "UIntP", PropCount)
      ErrorLevel := R
      Return PropCount
}
Gdip_GetPropertyIdList(pImage) {
      PropNum := Gdip_GetPropertyCount(pImage)
      Static Ptr := "UPtr"
      If (ErrorLevel) || (PropNum = 0)
      Return False
VarSetCapacity(PropIDList, 4 * PropNum, 0)
R := DllCall("gdiplus\GdipGetPropertyIdList", Ptr, pImage, "UInt", PropNum, "Ptr", &PropIDList)
If (R) {
      ErrorLevel := R
      Return False
}
PropArray := {Count: PropNum}
Loop %PropNum%
{
      PropID := NumGet(PropIDList, (A_Index - 1) << 2, "UInt")
      PropArray[PropID] := Gdip_GetPropertyTagName(PropID)
}
Return PropArray
}
Gdip_GetPropertyItem(pImage, PropID) {
      PropItem := {Length: 0, Type: 0, Value: ""}
      ItemSize := 0
      R := DllCall("gdiplus\GdipGetPropertyItemSize", "Ptr", pImage, "UInt", PropID, "UIntP", ItemSize)
      If (R) {
            ErrorLevel := R
      Return False
}
Static Ptr := "UPtr"
VarSetCapacity(Item, ItemSize, 0)
R := DllCall("gdiplus\GdipGetPropertyItem", Ptr, pImage, "UInt", PropID, "UInt", ItemSize, "Ptr", &Item)
If (R) {
      ErrorLevel := R
      Return False
}
PropLen := NumGet(Item, 4, "UInt")
PropType := NumGet(Item, 8, "Short")
PropAddr := NumGet(Item, 8 + A_PtrSize, "UPtr")
PropItem.Length := PropLen
PropItem.Type := PropType
If (PropLen > 0)
{
      PropVal := ""
      Gdip_GetPropertyItemValue(PropVal, PropLen, PropType, PropAddr)
      If (PropType = 1) || (PropType = 7) {
            PropItem.SetCapacity("Value", PropLen)
            ValAddr := PropItem.GetAddress("Value")
            DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", ValAddr, "Ptr", &PropVal, "Ptr", PropLen)
      } Else {
            PropItem.Value := PropVal
      }
}
ErrorLevel := 0
Return PropItem
}
Gdip_GetAllPropertyItems(pImage) {
      BufSize := PropNum := ErrorLevel := 0
      R := DllCall("gdiplus\GdipGetPropertySize", "Ptr", pImage, "UIntP", BufSize, "UIntP", PropNum)
      If (R) || (PropNum = 0) {
            ErrorLevel := R ? R : 19
      Return False
}
VarSetCapacity(Buffer, BufSize, 0)
Static Ptr := "UPtr"
R := DllCall("gdiplus\GdipGetAllPropertyItems", Ptr, pImage, "UInt", BufSize, "UInt", PropNum, "Ptr", &Buffer)
If (R) {
      ErrorLevel := R
      Return False
}
PropsObj := {Count: PropNum}
PropSize := 8 + (2 * A_PtrSize)
Loop %PropNum%
{
      OffSet := PropSize * (A_Index - 1)
      PropID := NumGet(Buffer, OffSet, "UInt")
      PropLen := NumGet(Buffer, OffSet + 4, "UInt")
      PropType := NumGet(Buffer, OffSet + 8, "Short")
      PropAddr := NumGet(Buffer, OffSet + 8 + A_PtrSize, "UPtr")
      PropVal := ""
      PropsObj[PropID] := {}
      PropsObj[PropID, "Length"] := PropLen
      PropsObj[PropID, "Type"] := PropType
      PropsObj[PropID, "Value"] := PropVal
      If (PropLen > 0)
      {
            Gdip_GetPropertyItemValue(PropVal, PropLen, PropType, PropAddr)
            If (PropType = 1) || (PropType = 7)
            {
                  PropsObj[PropID].SetCapacity("Value", PropLen)
                  ValAddr := PropsObj[PropID].GetAddress("Value")
                  DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", ValAddr, "Ptr", PropAddr, "Ptr", PropLen)
            } Else {
                  PropsObj[PropID].Value := PropVal
            }
      }
}
ErrorLevel := 0
Return PropsObj
}
Gdip_GetPropertyTagName(PropID) {
      Static PropTagsA := {0x0001:"GPS LatitudeRef",0x0002:"GPS Latitude",0x0003:"GPS LongitudeRef",0x0004:"GPS Longitude",0x0005:"GPS AltitudeRef",0x0006:"GPS Altitude",0x0007:"GPS Time",0x0008:"GPS Satellites",0x0009:"GPS Status",0x000A:"GPS MeasureMode",0x001D:"GPS Date",0x001E:"GPS Differential",0x00FE:"NewSubfileType",0x00FF:"SubfileType",0x0102:"Bits Per Sample",0x0103:"Compression",0x0106:"Photometric Interpolation",0x0107:"ThreshHolding",0x010A:"Fill Order",0x010D:"Document Name",0x010E:"Image Description",0x010F:"Equipment Make",0x0110:"Equipment Model",0x0112:"Orientation",0x0115:"Samples Per Pixel",0x0118:"Min Sample Value",0x0119:"Max Sample Value",0x011D:"Page Name",0x0122:"GrayResponseUnit",0x0123:"GrayResponseCurve",0x0128:"Resolution Unit",0x012D:"Transfer Function",0x0131:"Software Used",0x0132:"Internal Date Time",0x013B:"Artist"
            ,0x013C:"Host Computer",0x013D:"Predictor",0x013E:"White Point",0x013F:"Primary Chromaticities",0x0140:"Color Map",0x014C:"Ink Set",0x014D:"Ink Names",0x014E:"Number Of Inks",0x0150:"Dot Range",0x0151:"Target Printer",0x0152:"Extra Samples",0x0153:"Sample Format",0x0156:"Transfer Range",0x0200:"JPEGProc",0x0205:"JPEGLosslessPredictors",0x0301:"Gamma",0x0302:"ICC Profile Descriptor",0x0303:"SRGB Rendering Intent",0x0320:"Image Title",0x5010:"JPEG Quality",0x5011:"Grid Size",0x501A:"Color Transfer Function",0x5100:"Frame Delay",0x5101:"Loop Count",0x5110:"Pixel Unit",0x5111:"Pixel Per Unit X",0x5112:"Pixel Per Unit Y",0x8298:"Copyright",0x829A:"EXIF Exposure Time",0x829D:"EXIF F Number",0x8773:"ICC Profile",0x8822:"EXIF ExposureProg",0x8824:"EXIF SpectralSense",0x8827:"EXIF ISO Speed",0x9003:"EXIF Date Original",0x9004:"EXIF Date Digitized"
            ,0x9102:"EXIF CompBPP",0x9201:"EXIF Shutter Speed",0x9202:"EXIF Aperture",0x9203:"EXIF Brightness",0x9204:"EXIF Exposure Bias",0x9205:"EXIF Max. Aperture",0x9206:"EXIF Subject Dist",0x9207:"EXIF Metering Mode",0x9208:"EXIF Light Source",0x9209:"EXIF Flash",0x920A:"EXIF Focal Length",0x9214:"EXIF Subject Area",0x927C:"EXIF Maker Note",0x9286:"EXIF Comments",0xA001:"EXIF Color Space",0xA002:"EXIF PixXDim",0xA003:"EXIF PixYDim",0xA004:"EXIF Related WAV",0xA005:"EXIF Interop",0xA20B:"EXIF Flash Energy",0xA20E:"EXIF Focal X Res",0xA20F:"EXIF Focal Y Res",0xA210:"EXIF FocalResUnit",0xA214:"EXIF Subject Loc",0xA215:"EXIF Exposure Index",0xA217:"EXIF Sensing Method",0xA300:"EXIF File Source",0xA301:"EXIF Scene Type",0xA401:"EXIF Custom Rendered",0xA402:"EXIF Exposure Mode",0xA403:"EXIF White Balance",0xA404:"EXIF Digital Zoom Ratio"
            ,0xA405:"EXIF Focal Length In 35mm Film",0xA406:"EXIF Scene Capture Type",0xA407:"EXIF Gain Control",0xA408:"EXIF Contrast",0xA409:"EXIF Saturation",0xA40A:"EXIF Sharpness",0xA40B:"EXIF Device Setting Description",0xA40C:"EXIF Subject Distance Range",0xA420:"EXIF Unique Image ID"}
            Static PropTagsB := {0x0000:"GpsVer",0x000B:"GpsGpsDop",0x000C:"GpsSpeedRef",0x000D:"GpsSpeed",0x000E:"GpsTrackRef",0x000F:"GpsTrack",0x0010:"GpsImgDirRef",0x0011:"GpsImgDir",0x0012:"GpsMapDatum",0x0013:"GpsDestLatRef",0x0014:"GpsDestLat",0x0015:"GpsDestLongRef",0x0016:"GpsDestLong",0x0017:"GpsDestBearRef",0x0018:"GpsDestBear",0x0019:"GpsDestDistRef",0x001A:"GpsDestDist",0x001B:"GpsProcessingMethod",0x001C:"GpsAreaInformation",0x0100:"Original Image Width",0x0101:"Original Image Height",0x0108:"CellWidth",0x0109:"CellHeight",0x0111:"Strip Offsets",0x0116:"RowsPerStrip",0x0117:"StripBytesCount",0x011A:"XResolution",0x011B:"YResolution",0x011C:"Planar Config",0x011E:"XPosition",0x011F:"YPosition",0x0120:"FreeOffset",0x0121:"FreeByteCounts",0x0124:"T4Option",0x0125:"T6Option",0x0129:"PageNumber",0x0141:"Halftone Hints",0x0142:"TileWidth",0x0143:"TileLength",0x0144:"TileOffset"
                  ,0x0145:"TileByteCounts",0x0154:"SMin Sample Value",0x0155:"SMax Sample Value",0x0201:"JPEGInterFormat",0x0202:"JPEGInterLength",0x0203:"JPEGRestartInterval",0x0206:"JPEGPointTransforms",0x0207:"JPEGQTables",0x0208:"JPEGDCTables",0x0209:"JPEGACTables",0x0211:"YCbCrCoefficients",0x0212:"YCbCrSubsampling",0x0213:"YCbCrPositioning",0x0214:"REFBlackWhite",0x5001:"ResolutionXUnit",0x5002:"ResolutionYUnit",0x5003:"ResolutionXLengthUnit",0x5004:"ResolutionYLengthUnit",0x5005:"PrintFlags",0x5006:"PrintFlagsVersion",0x5007:"PrintFlagsCrop",0x5008:"PrintFlagsBleedWidth",0x5009:"PrintFlagsBleedWidthScale",0x500A:"HalftoneLPI",0x500B:"HalftoneLPIUnit",0x500C:"HalftoneDegree",0x500D:"HalftoneShape",0x500E:"HalftoneMisc",0x500F:"HalftoneScreen",0x5012:"ThumbnailFormat",0x5013:"ThumbnailWidth",0x5014:"ThumbnailHeight",0x5015:"ThumbnailColorDepth"
                  ,0x5016:"ThumbnailPlanes",0x5017:"ThumbnailRawBytes",0x5018:"ThumbnailSize",0x5019:"ThumbnailCompressedSize",0x501B:"ThumbnailData",0x5020:"ThumbnailImageWidth",0x5021:"ThumbnailImageHeight",0x5022:"ThumbnailBitsPerSample",0x5023:"ThumbnailCompression",0x5024:"ThumbnailPhotometricInterp",0x5025:"ThumbnailImageDescription",0x5026:"ThumbnailEquipMake",0x5027:"ThumbnailEquipModel",0x5028:"ThumbnailStripOffsets",0x5029:"ThumbnailOrientation",0x502A:"ThumbnailSamplesPerPixel",0x502B:"ThumbnailRowsPerStrip",0x502C:"ThumbnailStripBytesCount",0x502D:"ThumbnailResolutionX",0x502E:"ThumbnailResolutionY",0x502F:"ThumbnailPlanarConfig",0x5030:"ThumbnailResolutionUnit",0x5031:"ThumbnailTransferFunction",0x5032:"ThumbnailSoftwareUsed",0x5033:"ThumbnailDateTime",0x5034:"ThumbnailArtist",0x5035:"ThumbnailWhitePoint"
                  ,0x5036:"ThumbnailPrimaryChromaticities",0x5037:"ThumbnailYCbCrCoefficients",0x5038:"ThumbnailYCbCrSubsampling",0x5039:"ThumbnailYCbCrPositioning",0x503A:"ThumbnailRefBlackWhite",0x503B:"ThumbnailCopyRight",0x5090:"LuminanceTable",0x5091:"ChrominanceTable",0x5102:"Global Palette",0x5103:"Index Background",0x5104:"Index Transparent",0x5113:"Palette Histogram",0x8769:"ExifIFD",0x8825:"GpsIFD",0x8828:"ExifOECF",0x9000:"ExifVer",0x9101:"EXIF CompConfig",0x9290:"EXIF DTSubsec",0x9291:"EXIF DTOrigSS",0x9292:"EXIF DTDigSS",0xA000:"EXIF FPXVer",0xA20C:"EXIF Spatial FR",0xA302:"EXIF CfaPattern"}
                  r := PropTagsA.HasKey(PropID) ? PropTagsA[PropID] : "Unknown"
                        If (r="Unknown")
                              r := PropTagsB.HasKey(PropID) ? PropTagsB[PropID] : "Unknown"
                        Return r
                  }
                  Gdip_GetPropertyTagType(PropType) {
                        Static PropTypes := {1: "Byte", 2: "ASCII", 3: "Short", 4: "Long", 5: "Rational", 7: "Undefined", 9: "SLong", 10: "SRational"}
                        Return PropTypes.HasKey(PropType) ? PropTypes[PropType] : "Unknown"
                        }
                        Gdip_GetPropertyItemValue(ByRef PropVal, PropLen, PropType, PropAddr) {
                              PropVal := ""
                              If (PropType = 2)
                              {
                                    PropVal := StrGet(PropAddr, PropLen, "CP0")
                                    Return True
                              }
                              If (PropType = 3)
                              {
                                    PropyLen := PropLen // 2
                                    Loop %PropyLen%
                                          PropVal .= (A_Index > 1 ? " " : "") . NumGet(PropAddr + 0, (A_Index - 1) << 1, "Short")
                                    Return True
                              }
                              If (PropType = 4) || (PropType = 9)
                              {
                                    NumType := PropType = 4 ? "UInt" : "Int"
                                          PropyLen := PropLen // 4
                                          Loop %PropyLen%
                                                PropVal .= (A_Index > 1 ? " " : "") . NumGet(PropAddr + 0, (A_Index - 1) << 2, NumType)
                                    Return True
                              }
                              If (PropType = 5) || (PropType = 10)
                              {
                                    NumType := PropType = 5 ? "UInt" : "Int"
                                          PropyLen := PropLen // 8
                                          Loop %PropyLen%
                                                PropVal .= (A_Index > 1 ? " " : "") . NumGet(PropAddr + 0, (A_Index - 1) << 2, NumType)
                                          . "/" . NumGet(PropAddr + 4, (A_Index - 1) << 2, NumType)
                                    Return True
                              }
                              If (PropType = 1) || (PropType = 7)
                              {
                                    VarSetCapacity(PropVal, PropLen, 0)
                                    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &PropVal, "Ptr", PropAddr, "Ptr", PropLen)
                                    Return True
                              }
                              Return False
                        }
                        Gdip_RotatePathAtCenter(pPath, Angle, MatrixOrder:=1, withinBounds:=0, withinBkeepRatio:=1) {
                              Rect := Gdip_GetPathWorldBounds(pPath)
                              cX := Rect.x + (Rect.w / 2)
                              cY := Rect.y + (Rect.h / 2)
                              pMatrix := Gdip_CreateMatrix()
                              Gdip_TranslateMatrix(pMatrix, -cX , -cY)
                              Gdip_RotateMatrix(pMatrix, Angle, MatrixOrder)
                              Gdip_TranslateMatrix(pMatrix, cX, cY, MatrixOrder)
                              E := Gdip_TransformPath(pPath, pMatrix)
                              Gdip_DeleteMatrix(pMatrix)
                              If (withinBounds=1 && !E && Angle!=0)
                              {
                                    nRect := Gdip_GetPathWorldBounds(pPath)
                                    ncX := nRect.x + (nRect.w / 2)
                                    ncY := nRect.y + (nRect.h / 2)
                                    pMatrix := Gdip_CreateMatrix()
                                    Gdip_TranslateMatrix(pMatrix, -ncX , -ncY)
                                    sX := Rect.w / nRect.w
                                    sY := Rect.h / nRect.h
                                    If (withinBkeepRatio=1)
                                    {
                                          sX := min(sX, sY)
                                          sY := min(sX, sY)
                                    }
                                    Gdip_ScaleMatrix(pMatrix, sX, sY, MatrixOrder)
                                    Gdip_TranslateMatrix(pMatrix, ncX, ncY, MatrixOrder)
                                    If (sX!=0 && sY!=0)
                                          E := Gdip_TransformPath(pPath, pMatrix)
                                    Gdip_DeleteMatrix(pMatrix)
                              }
                              Return E
                        }
                        Gdip_ResetMatrix(hMatrix) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipResetMatrix", Ptr, hMatrix)
                        }
                        Gdip_RotateMatrix(hMatrix, Angle, MatrixOrder:=0) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipRotateMatrix", Ptr, hMatrix, "float", Angle, "Int", MatrixOrder)
                        }
                        Gdip_GetPathWorldBounds(pPath, hMatrix:=0, pPen:=0) {
                              rData := {}
                              VarSetCapacity(RectF, 16, 0)
                              status := DllCall("gdiplus\GdipGetPathWorldBounds", "UPtr", pPath, "UPtr", &RectF, "UPtr", hMatrix, "UPtr", pPen)
                              If (!status) {
                                    rData.x := NumGet(&RectF, 0, "float")
                                    , rData.y := NumGet(&RectF, 4, "float")
                                    , rData.w := NumGet(&RectF, 8, "float")
                                    , rData.h := NumGet(&RectF, 12, "float")
                              } Else {
                                    Return status
                              }
                              return rData
                        }
                        Gdip_ScaleMatrix(hMatrix, ScaleX, ScaleY, MatrixOrder:=0) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipScaleMatrix", Ptr, hMatrix, "float", ScaleX, "float", ScaleY, "Int", MatrixOrder)
                        }
                        Gdip_TranslateMatrix(hMatrix, offsetX, offsetY, MatrixOrder:=0) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipTranslateMatrix", Ptr, hMatrix, "float", offsetX, "float", offsetY, "Int", MatrixOrder)
                        }
                        Gdip_TransformPath(pPath, hMatrix) {
                              return DllCall("gdiplus\GdipTransformPath", "UPtr", pPath, "UPtr", hMatrix)
                        }
                        Gdip_SetMatrixElements(hMatrix, m11, m12, m21, m22, x, y) {
                              return DllCall("gdiplus\GdipSetMatrixElements", "UPtr", hMatrix, "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y)
                        }
                        Gdip_GetMatrixLastStatus(pMatrix) {
                              return DllCall("gdiplus\GdipGetLastStatus", "UPtr", pMatrix)
                        }
                        Gdip_AddPathBeziers(pPath, Points) {
                              iCount := CreatePointsF(PointsF, Points)
                              return DllCall("gdiplus\GdipAddPathBeziers", "UPtr", pPath, "UPtr", &PointsF, "int", iCount)
                        }
                        Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4) {
                              return DllCall("gdiplus\GdipAddPathBezier", "UPtr", pPath
                              , "float", x1, "float", y1, "float", x2, "float", y2
                              , "float", x3, "float", y3, "float", x4, "float", y4)
                        }
                        Gdip_AddPathLines(pPath, Points) {
                              iCount := CreatePointsF(PointsF, Points)
                              return DllCall("gdiplus\GdipAddPathLine2", "UPtr", pPath, "UPtr", &PointsF, "int", iCount)
                        }
                        Gdip_AddPathLine(pPath, x1, y1, x2, y2) {
                              return DllCall("gdiplus\GdipAddPathLine", "UPtr", pPath, "float", x1, "float", y1, "float", x2, "float", y2)
                        }
                        Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle) {
                              return DllCall("gdiplus\GdipAddPathArc", "UPtr", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
                        }
                        Gdip_AddPathPie(pPath, x, y, w, h, StartAngle, SweepAngle) {
                              return DllCall("gdiplus\GdipAddPathPie", "UPtr", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
                        }
                        Gdip_StartPathFigure(pPath) {
                              return DllCall("gdiplus\GdipStartPathFigure", "UPtr", pPath)
                        }
                        Gdip_ClosePathFigure(pPath) {
                              return DllCall("gdiplus\GdipClosePathFigure", "UPtr", pPath)
                        }
                        Gdip_ClosePathFigures(pPath) {
                              return DllCall("gdiplus\GdipClosePathFigures", "UPtr", pPath)
                        }
                        Gdip_DrawPath(pGraphics, pPen, pPath) {
                              return DllCall("gdiplus\GdipDrawPath", "UPtr", pGraphics, "UPtr", pPen, "UPtr", pPath)
                        }
                        Gdip_ClonePath(pPath) {
                              pPathClone := 0
                              DllCall("gdiplus\GdipClonePath", "UPtr", pPath, "UPtr*", pPathClone)
                              return pPathClone
                        }
                        Gdip_PathGradientCreateFromPath(pPath) {
                              pBrush := 0
                              DllCall("gdiplus\GdipCreatePathGradientFromPath", "Ptr", pPath, "PtrP", pBrush)
                              Return pBrush
                        }
                        Gdip_PathGradientSetCenterPoint(pBrush, X, Y) {
                              VarSetCapacity(POINTF, 8)
                              NumPut(X, POINTF, 0, "Float")
                              NumPut(Y, POINTF, 4, "Float")
                              Return DllCall("gdiplus\GdipSetPathGradientCenterPoint", "Ptr", pBrush, "Ptr", &POINTF)
                        }
                        Gdip_PathGradientSetCenterColor(pBrush, CenterColor) {
                              Return DllCall("gdiplus\GdipSetPathGradientCenterColor", "Ptr", pBrush, "UInt", CenterColor)
                        }
                        Gdip_PathGradientSetSurroundColors(pBrush, SurroundColors) {
                              Colors := StrSplit(SurroundColors, "|")
                              tColors := Colors.Length()
                              VarSetCapacity(ColorArray, 4 * tColors, 0)
                              Loop %tColors% {
                                    NumPut(Colors[A_Index], ColorArray, 4 * (A_Index - 1), "UInt")
                              }
                              Return DllCall("gdiplus\GdipSetPathGradientSurroundColorsWithCount", "Ptr", pBrush, "Ptr", &ColorArray
                              , "IntP", tColors)
                        }
                        Gdip_PathGradientSetSigmaBlend(pBrush, Focus, Scale:=1) {
                              Return DllCall("gdiplus\GdipSetPathGradientSigmaBlend", "Ptr", pBrush, "Float", Focus, "Float", Scale)
                        }
                        Gdip_PathGradientSetLinearBlend(pBrush, Focus, Scale:=1) {
                              Return DllCall("gdiplus\GdipSetPathGradientLinearBlend", "Ptr", pBrush, "Float", Focus, "Float", Scale)
                        }
                        Gdip_PathGradientSetFocusScales(pBrush, xScale, yScale) {
                              Return DllCall("gdiplus\GdipSetPathGradientFocusScales", "Ptr", pBrush, "Float", xScale, "Float", yScale)
                        }
                        Gdip_AddPathGradient(pGraphics, x, y, w, h, cX, cY, cClr, sClr, BlendFocus, ScaleX, ScaleY, Shape, Angle:=0) {
                              pPath := Gdip_CreatePath()
                              If (Shape=1)
                                    Gdip_AddPathRectangle(pPath, x, y, W, H)
                              Else
                                    Gdip_AddPathEllipse(pPath, x, y, W, H)
                              zBrush := Gdip_PathGradientCreateFromPath(pPath)
                              If (Angle!=0)
                                    Gdip_RotatePathGradientAtCenter(zBrush, Angle)
                              Gdip_PathGradientSetCenterPoint(zBrush, cX, cY)
                              Gdip_PathGradientSetCenterColor(zBrush, cClr)
                              Gdip_PathGradientSetSurroundColors(zBrush, sClr)
                              Gdip_PathGradientSetSigmaBlend(zBrush, BlendFocus)
                              Gdip_PathGradientSetLinearBlend(zBrush, BlendFocus)
                              Gdip_PathGradientSetFocusScales(zBrush, ScaleX, ScaleY)
                              E := Gdip_FillPath(pGraphics, zBrush, pPath)
                              Gdip_DeleteBrush(zBrush)
                              Gdip_DeletePath(pPath)
                              Return E
                        }
                        Gdip_CreatePathGradient(Points, WrapMode) {
                              Static Ptr := "UPtr"
                              iCount := CreatePointsF(PointsF, Points)
                              pPathGradientBrush := 0
                              DllCall("gdiplus\GdipCreatePathGradient", Ptr, &PointsF, "int", iCount, "int", WrapMode, "int*", pPathGradientBrush)
                              Return pPathGradientBrush
                        }
                        Gdip_PathGradientGetGammaCorrection(pPathGradientBrush) {
                              Static Ptr := "UPtr"
                              result := 0
                              E := DllCall("gdiplus\GdipGetPathGradientGammaCorrection", Ptr, pPathGradientBrush, "int*", result)
                              If E
                                    return -1
                              Return result
                        }
                        Gdip_PathGradientGetPointCount(pPathGradientBrush) {
                              Static Ptr := "UPtr"
                              result := 0
                              E := DllCall("gdiplus\GdipGetPathGradientPointCount", Ptr, pPathGradientBrush, "int*", result)
                              If E
                                    return -1
                              Return result
                        }
                        Gdip_PathGradientGetWrapMode(pPathGradientBrush) {
                              result := 0
                              E := DllCall("gdiplus\GdipGetPathGradientWrapMode", "UPtr", pPathGradientBrush, "int*", result)
                              If E
                                    return -1
                              Return result
                        }
                        Gdip_PathGradientGetRect(pPathGradientBrush) {
                              rData := {}
                              VarSetCapacity(RectF, 16, 0)
                              status := DllCall("gdiplus\GdipGetPathGradientRect", "UPtr", pPathGradientBrush, "UPtr", &RectF)
                              If (!status) {
                                    rData.x := NumGet(&RectF, 0, "float")
                                    , rData.y := NumGet(&RectF, 4, "float")
                                    , rData.w := NumGet(&RectF, 8, "float")
                                    , rData.h := NumGet(&RectF, 12, "float")
                              } Else {
                                    Return status
                              }
                              return rData
                        }
                        Gdip_PathGradientResetTransform(pPathGradientBrush) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipResetPathGradientTransform", Ptr, pPathGradientBrush)
                        }
                        Gdip_PathGradientRotateTransform(pPathGradientBrush, Angle, matrixOrder:=0) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipRotatePathGradientTransform", Ptr, pPathGradientBrush, "float", Angle, "int", matrixOrder)
                        }
                        Gdip_PathGradientScaleTransform(pPathGradientBrush, ScaleX, ScaleY, matrixOrder:=0) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipScalePathGradientTransform", Ptr, pPathGradientBrush, "float", ScaleX, "float", ScaleY, "int", matrixOrder)
                        }
                        Gdip_PathGradientTranslateTransform(pPathGradientBrush, X, Y, matrixOrder:=0) {
                              Static Ptr := "UPtr"
                              Return DllCall("gdiplus\GdipTranslatePathGradientTransform", Ptr, pPathGradientBrush, "float", X, "float", Y, "int", matrixOrder)
                        }
                        Gdip_PathGradientMultiplyTransform(pPathGradientBrush, hMatrix, matrixOrder:=0) {
                              Static Ptr := "UPtr"
                              Return DllCall("gdiplus\GdipMultiplyPathGradientTransform", Ptr, pPathGradientBrush, Ptr, hMatrix, "int", matrixOrder)
                        }
                        Gdip_PathGradientSetTransform(pPathGradientBrush, pMatrix) {
                              return DllCall("gdiplus\GdipSetPathGradientTransform", "UPtr", pPathGradientBrush, "UPtr", pMatrix)
                        }
                        Gdip_PathGradientGetTransform(pPathGradientBrush) {
                              pMatrix := 0
                              DllCall("gdiplus\GdipGetPathGradientTransform", "UPtr", pPathGradientBrush, "UPtr*", pMatrix)
                              Return pMatrix
                        }
                        Gdip_RotatePathGradientAtCenter(pPathGradientBrush, Angle, MatrixOrder:=1) {
                              Rect := Gdip_PathGradientGetRect(pPathGradientBrush)
                              cX := Rect.x + (Rect.w / 2)
                              cY := Rect.y + (Rect.h / 2)
                              pMatrix := Gdip_CreateMatrix()
                              Gdip_TranslateMatrix(pMatrix, -cX , -cY)
                              Gdip_RotateMatrix(pMatrix, Angle, MatrixOrder)
                              Gdip_TranslateMatrix(pMatrix, cX, cY, MatrixOrder)
                              E := Gdip_PathGradientSetTransform(pPathGradientBrush, pMatrix)
                              Gdip_DeleteMatrix(pMatrix)
                              Return E
                        }
                        Gdip_PathGradientSetGammaCorrection(pPathGradientBrush, UseGammaCorrection) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipSetPathGradientGammaCorrection", Ptr, pPathGradientBrush, "int", UseGammaCorrection)
                        }
                        Gdip_PathGradientSetWrapMode(pPathGradientBrush, WrapMode) {
                              Static Ptr := "UPtr"
                              return DllCall("gdiplus\GdipSetPathGradientWrapMode", Ptr, pPathGradientBrush, "int", WrapMode)
                        }
                        Gdip_PathGradientGetCenterColor(pPathGradientBrush) {
                              Static Ptr := "UPtr"
                              ARGB := 0
                              E := DllCall("gdiplus\GdipGetPathGradientCenterColor", Ptr, pPathGradientBrush, "uint*", ARGB)
                              If E
                                    return -1
                              Return Format("{1:#x}", ARGB)
                        }
                        Gdip_PathGradientGetCenterPoint(pPathGradientBrush, ByRef X, ByRef Y) {
                              Static Ptr := "UPtr"
                              VarSetCapacity(PointF, 8, 0)
                              E := DllCall("gdiplus\GdipGetPathGradientCenterPoint", Ptr, pPathGradientBrush, "UPtr", &PointF)
                              If !E
                              {
                                    x := NumGet(PointF, 0, "float")
                                    y := NumGet(PointF, 4, "float")
                              }
                              Return E
                        }
                        Gdip_PathGradientGetFocusScales(pPathGradientBrush, ByRef X, ByRef Y) {
                              Static Ptr := "UPtr"
                              x := 0
                              y := 0
                              Return DllCall("gdiplus\GdipGetPathGradientFocusScales", Ptr, pPathGradientBrush, "float*", X, "float*", Y)
                        }
                        Gdip_PathGradientGetSurroundColorCount(pPathGradientBrush) {
                              Static Ptr := "UPtr"
                              result := 0
                              E := DllCall("gdiplus\GdipGetPathGradientSurroundColorCount", Ptr, pPathGradientBrush, "int*", result)
                              If E
                                    return -1
                              Return result
                        }
                        Gdip_GetPathGradientSurroundColors(pPathGradientBrush) {
                              iCount := Gdip_PathGradientGetSurroundColorCount(pPathGradientBrush)
                              If (iCount=-1)
                                    Return 0
                              Static Ptr := "UPtr"
                              VarSetCapacity(sColors, 8 * iCount, 0)
                              DllCall("gdiplus\GdipGetPathGradientSurroundColorsWithCount", Ptr, pPathGradientBrush, Ptr, &sColors, "intP", iCount)
                              Loop %iCount%
                              {
                                    A := NumGet(&sColors, 8*(A_Index-1), "uint")
                                    printList .= Format("{1:#x}", A) ","
                              }
                              Return Trim(printList, ",")
                        }
                        Gdip_GetHistogram(pBitmap, whichFormat, ByRef newArrayA, ByRef newArrayB, ByRef newArrayC) {
                              Static sizeofUInt := 4
                              z := DllCall("gdiplus\GdipBitmapGetHistogramSize", "UInt", whichFormat, "UInt*", numEntries)
                              newArrayA := [], newArrayB := [], newArrayC := []
                              VarSetCapacity(ch0, numEntries * sizeofUInt, 0)
                              VarSetCapacity(ch1, numEntries * sizeofUInt, 0)
                              VarSetCapacity(ch2, numEntries * sizeofUInt, 0)
                              If (whichFormat=2)
                                    r := DllCall("gdiplus\GdipBitmapGetHistogram", "Ptr", pBitmap, "UInt", whichFormat, "UInt", numEntries, "Ptr", &ch0, "Ptr", &ch1, "Ptr", &ch2, "Ptr", 0)
                              Else If (whichFormat>2)
                                    r := DllCall("gdiplus\GdipBitmapGetHistogram", "Ptr", pBitmap, "UInt", whichFormat, "UInt", numEntries, "Ptr", &ch0, "Ptr", 0, "Ptr", 0, "Ptr", 0)
                              Loop %numEntries%
                              {
                                    i := A_Index - 1
                                    r := NumGet(&ch0+0, i * sizeofUInt, "UInt")
                                    newArrayA[i] := r
                                    If (whichFormat=2)
                                    {
                                          g := NumGet(&ch1+0, i * sizeofUInt, "UInt")
                                          b := NumGet(&ch2+0, i * sizeofUInt, "UInt")
                                          newArrayB[i] := g
                                          newArrayC[i] := b
                                    }
                              }
                              Return r
                        }
                        Gdip_DrawRoundedLine(G, x1, y1, x2, y2, LineWidth, LineColor) {
                              pPen := Gdip_CreatePen(LineColor, LineWidth)
                              Gdip_DrawLine(G, pPen, x1, y1, x2, y2)
                              Gdip_DeletePen(pPen)
                              pPen := Gdip_CreatePen(LineColor, LineWidth/2)
                              Gdip_DrawEllipse(G, pPen, x1-LineWidth/4, y1-LineWidth/4, LineWidth/2, LineWidth/2)
                              Gdip_DrawEllipse(G, pPen, x2-LineWidth/4, y2-LineWidth/4, LineWidth/2, LineWidth/2)
                              Gdip_DeletePen(pPen)
                        }
                        Gdip_CreateBitmapFromGdiDib(BITMAPINFO, BitmapData) {
                              Static Ptr := "UPtr"
                              pBitmap := 0
                              E := DllCall("gdiplus\GdipCreateBitmapFromGdiDib", Ptr, BITMAPINFO, Ptr, BitmapData, "UPtr*", pBitmap)
                              Return pBitmap
                        }
                        Gdip_DrawImageFX(pGraphics, pBitmap, dX:="", dY:="", sX:="", sY:="", sW:="", sH:="", matrix:="", pEffect:="", ImageAttr:=0, hMatrix:=0, Unit:=2) {
                              Static Ptr := "UPtr"
                              If !ImageAttr
                              {
                                    if !IsNumber(Matrix)
                                          ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
                                    else if (Matrix != 1)
                                          ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
                              } Else usrImageAttr := 1
                              if (sX="" && sY="")
                                    sX := sY := 0
                              if (sW="" && sH="")
                                    Gdip_GetImageDimensions(pBitmap, sW, sH)
                              if (!hMatrix && dX!="" && dY!="")
                              {
                                    hMatrix := dhMatrix := Gdip_CreateMatrix()
                                    Gdip_TranslateMatrix(dhMatrix, dX, dY, 1)
                              }
                              CreateRectF(sourceRect, sX, sY, sW, sH)
                              E := DllCall("gdiplus\GdipDrawImageFX"
                              , Ptr, pGraphics
                              , Ptr, pBitmap
                              , Ptr, &sourceRect
                              , Ptr, hMatrix ? hMatrix : 0
                              , Ptr, pEffect ? pEffect : 0
                              , Ptr, ImageAttr ? ImageAttr : 0
                              , "Uint", Unit)
                              If dhMatrix
                                    Gdip_DeleteMatrix(dhMatrix)
                              If (ImageAttr && usrImageAttr!=1)
                                    Gdip_DisposeImageAttributes(ImageAttr)
                              Return E
                        }
                        Gdip_BitmapApplyEffect(pBitmap, pEffect, x:="", y:="", w:="", h:="") {
                              If InStr(pEffect, "err-")
                                    Return pEffect
                              If (!x && !y && !w && !h)
                              {
                                    Gdip_GetImageDimensions(pBitmap, Width, Height)
                                    CreateRectF(RectF, 0, 0, Width, Height)
                              } Else CreateRectF(RectF, X, Y, W, H)
                              E := DllCall("gdiplus\GdipBitmapApplyEffect"
                              , "UPtr", pBitmap
                              , "UPtr", pEffect
                              , "UPtr", &RectF
                              , "UPtr", 0
                              , "UPtr", 0
                              , "UPtr", 0)
                              Return E
                        }
                        COM_CLSIDfromString(ByRef CLSID, String) {
                              VarSetCapacity(CLSID, 16, 0)
                              E := DllCall("ole32\CLSIDFromString", "WStr", String, "UPtr", &CLSID)
                              Return E
                        }
                        Gdip_CreateEffect(whichFX, paramA, paramB, paramC:=0) {
                              Static gdipImgFX := {1:"633C80A4-1843-482b-9EF2-BE2834C5FDD4", 2:"63CBF3EE-C526-402c-8F71-62C540BF5142", 3:"718F2615-7933-40e3-A511-5F68FE14DD74", 4:"A7CE72A9-0F7F-40d7-B3CC-D0C02D5C3212", 5:"D3A1DBE1-8EC4-4c17-9F4C-EA97AD1C343D", 6:"8B2DD6C3-EB07-4d87-A5F0-7108E26A9C5F", 7:"99C354EC-2A31-4f3a-8C34-17A803B33A25", 8:"1077AF00-2848-4441-9489-44AD4C2D7A2C", 9:"537E597D-251E-48da-9664-29CA496B70F8", 10:"74D29D05-69A4-4266-9549-3CC52836B632", 11:"DD6A0022-58E4-4a67-9D9B-D48EB881A53D"}
                              Ptr := A_PtrSize=8 ? "UPtr" : "UInt"
                              Ptr2 := A_PtrSize=8 ? "Ptr*" : "PtrP"
                                    pEffect := 0
                                    r1 := COM_CLSIDfromString(eFXguid, "{" gdipImgFX[whichFX] "}" )
                                    If r1
                                          Return "err-" r1
                                    If (A_PtrSize=4)
                                    {
                                          r2 := DllCall("gdiplus\GdipCreateEffect"
                                          , "UInt", NumGet(eFXguid, 0, "UInt")
                                          , "UInt", NumGet(eFXguid, 4, "UInt")
                                          , "UInt", NumGet(eFXguid, 8, "UInt")
                                          , "UInt", NumGet(eFXguid, 12, "UInt")
                                          , Ptr2, pEffect)
                                    } Else
                                    {
                                          r2 := DllCall("gdiplus\GdipCreateEffect"
                                          , Ptr, &eFXguid
                                          , Ptr2, pEffect)
                                    }
                                    If r2
                                          Return "err-" r2
                                    VarSetCapacity(FXparams, 16, 0)
                                    If (whichFX=1)
                                    {
                                          NumPut(paramA, FXparams, 0, "Float")
                                          NumPut(paramB, FXparams, 4, "Uchar")
                                    } Else If (whichFX=2)
                                    {
                                          NumPut(paramA, FXparams, 0, "Float")
                                          NumPut(paramB, FXparams, 4, "Float")
                                    } Else If (whichFX=5)
                                    {
                                          NumPut(paramA, FXparams, 0, "Int")
                                          NumPut(paramB, FXparams, 4, "Int")
                                    } Else If (whichFX=6)
                                    {
                                          NumPut(paramA, FXparams, 0, "Int")
                                          NumPut(paramB, FXparams, 4, "Int")
                                          NumPut(paramC, FXparams, 8, "Int")
                                    } Else If (whichFX=7)
                                    {
                                          NumPut(paramA, FXparams, 0, "Int")
                                          NumPut(paramB, FXparams, 4, "Int")
                                          NumPut(paramC, FXparams, 8, "Int")
                                    } Else If (whichFX=8)
                                    {
                                          NumPut(paramA, FXparams, 0, "Int")
                                          NumPut(paramB, FXparams, 4, "Int")
                                    } Else If (whichFX=9)
                                    {
                                          NumPut(paramA, FXparams, 0, "Int")
                                          NumPut(paramB, FXparams, 4, "Int")
                                          NumPut(paramC, FXparams, 8, "Int")
                                    } Else If (whichFX=11)
                                    {
                                          NumPut(paramA, FXparams, 0, "Int")
                                          NumPut(paramB, FXparams, 4, "Int")
                                          NumPut(paramC, FXparams, 8, "Int")
                                    }
                                    DllCall("gdiplus\GdipGetEffectParameterSize", Ptr, pEffect, "uint*", FXsize)
                                    r3 := DllCall("gdiplus\GdipSetEffectParameters", Ptr, pEffect, Ptr, &FXparams, "UInt", FXsize)
                                    If r3
                                    {
                                          Gdip_DisposeEffect(pEffect)
                                          Return "err-" r3
                                    }
                              Return pEffect
                        }
                        Gdip_DisposeEffect(pEffect) {
                              Static Ptr := "UPtr"
                              r := DllCall("gdiplus\GdipDeleteEffect", Ptr, pEffect)
                              Return r
                        }
                        GenerateColorMatrix(modus, bright:=1, contrast:=0, saturation:=1, alph:=1, chnRdec:=0, chnGdec:=0, chnBdec:=0) {
                              Static NTSCr := 0.308, NTSCg := 0.650, NTSCb := 0.095
                              matrix := ""
                              If (modus=2)
                              {
                                    LGA := (bright<=1) ? bright/1.5 - 0.6666 : bright - 1
                                    Ra := NTSCr + LGA
                                    If (Ra<0)
                                          Ra := 0
                                    Ga := NTSCg + LGA
                                    If (Ga<0)
                                          Ga := 0
                                    Ba := NTSCb + LGA
                                    If (Ba<0)
                                          Ba := 0
                                    matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|" alph "|0|" contrast "|" contrast "|" contrast "|0|1"
                              } Else If (modus=3)
                              {
                                    Ga := 0, Ba := 0, GGA := 0
                                    Ra := bright
                                    matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|25|0|" GGA+0.01 "|" GGA "|" GGA "|0|1"
                              } Else If (modus=4)
                              {
                                    Ra := 0, Ba := 0, GGA := 0
                                    Ga := bright
                                    matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|25|0|" GGA "|" GGA+0.01 "|" GGA "|0|1"
                              } Else If (modus=5)
                              {
                                    Ra := 0, Ga := 0, GGA := 0
                                    Ba := bright
                                    matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|25|0|" GGA "|" GGA "|" GGA+0.01 "|0|1"
                              } Else If (modus=6)
                              {
                                    matrix := "-1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|" alph "|0|1|1|1|0|1"
                              } Else If (modus=1)
                              {
                                    bL := bright, aL := alph
                                    G := contrast, sL := saturation
                                    sLi := 1 - saturation
                                    bLa := bright - 1
                                    If (sL>1)
                                    {
                                          z := (bL<1) ? bL : 1
                                          sL := sL*z
                                          If (sL<0.98)
                                                sL := 0.98
                                          y := z*(1 - sL)
                                          mA := z*(y*NTSCr + sL + bLa + chnRdec)
                                          mB := z*(y*NTSCr)
                                          mC := z*(y*NTSCr)
                                          mD := z*(y*NTSCg)
                                          mE := z*(y*NTSCg + sL + bLa + chnGdec)
                                          mF := z*(y*NTSCg)
                                          mG := z*(y*NTSCb)
                                          mH := z*(y*NTSCb)
                                          mI := z*(y*NTSCb + sL + bLa + chnBdec)
                                          mtrx:= mA "|" mB "|" mC "| 0 |0"
                                          . "|" mD "|" mE "|" mF "| 0 |0"
                                          . "|" mG "|" mH "|" mI "| 0 |0"
                                          . "| 0 | 0 | 0 |" aL "|0"
                                          . "|" G "|" G "|" G "| 0 |1"
                                    } Else
                                    {
                                          z := (bL<1) ? bL : 1
                                          tR := NTSCr - 0.5 + bL/2
                                          tG := NTSCg - 0.5 + bL/2
                                          tB := NTSCb - 0.5 + bL/2
                                          rB := z*(tR*sLi+bL*(1 - sLi) + chnRdec)
                                          gB := z*(tG*sLi+bL*(1 - sLi) + chnGdec)
                                          bB := z*(tB*sLi+bL*(1 - sLi) + chnBdec)
                                          rF := z*(NTSCr*sLi + (bL/2 - 0.5)*sLi)
                                          gF := z*(NTSCg*sLi + (bL/2 - 0.5)*sLi)
                                          bF := z*(NTSCb*sLi + (bL/2 - 0.5)*sLi)
                                          rB := rB*z+rF*(1 - z)
                                          gB := gB*z+gF*(1 - z)
                                          bB := bB*z+bF*(1 - z)
                                          If (rB<0)
                                                rB := 0
                                          If (gB<0)
                                                gB := 0
                                          If (bB<0)
                                                bB := 0
                                          If (rF<0)
                                                rF := 0
                                          If (gF<0)
                                                gF := 0
                                          If (bF<0)
                                                bF := 0
                                          mtrx:= rB "|" rF "|" rF "| 0 |0"
                                          . "|" gF "|" gB "|" gF "| 0 |0"
                                          . "|" bF "|" bF "|" bB "| 0 |0"
                                          . "| 0 | 0 | 0 |" aL "|0"
                                          . "|" G "|" G "|" G "| 0 |1"
                                    }
                                    matrix := StrReplace(mtrx, A_Space)
                              } Else If (modus=0)
                              {
                                    s1 := contrast
                                    s2 := saturation
                                    s3 := bright
                                    aL := alph
                                    s1 := s2*sin(s1)
                                    sc := 1-s2
                                    r := NTSCr*sc-s1
                                    g := NTSCg*sc-s1
                                    b := NTSCb*sc-s1
                                    rB := r+s2+3*s1
                                    gB := g+s2+3*s1
                                    bB := b+s2+3*s1
                                    mtrx := rB "|" r "|" r "| 0 |0"
                                    . "|" g "|" gB "|" g "| 0 |0"
                                    . "|" b "|" b "|" bB "| 0 |0"
                                    . "| 0 | 0 | 0 |" aL "|0"
                                    . "|" s3 "|" s3 "|" s3 "| 0 |1"
                                    matrix := StrReplace(mtrx, A_Space)
                              } Else If (modus=7)
                              {
                                    mtrx := "0|0|0|0|0"
                                    . "|0|0|0|0|0"
                                    . "|0|0|0|0|0"
                                    . "|1|1|1|25|0"
                                    . "|0|0|0|0|1"
                                    matrix := StrReplace(mtrx, A_Space)
                              }
                              Return matrix
                        }
                        Gdip_CompareBitmaps(pBitmapA, pBitmapB, accuracy:=25) {
                              If (accuracy>99)
                                    accuracy := 100
                              Else If (accuracy<5)
                                    accuracy := 5
                              Gdip_GetImageDimensions(pBitmapA, WidthA, HeightA)
                              Gdip_GetImageDimensions(pBitmapB, WidthB, HeightB)
                              If (accuracy!=100)
                              {
                                    pBitmap1 := Gdip_ResizeBitmap(pBitmapA, Floor(WidthA*(accuracy/100)), Floor(HeightA*(accuracy/100)), 0, 5)
                                    pBitmap2 := Gdip_ResizeBitmap(pBitmapB, Floor(WidthB*(accuracy/100)), Floor(HeightB*(accuracy/100)), 0, 5)
                              } Else
                              {
                                    pBitmap1 := pBitmapA
                                    pBitmap2 := pBitmapB
                              }
                              Gdip_GetImageDimensions(pBitmap1, Width1, Height1)
                              Gdip_GetImageDimensions(pBitmap2, Width2, Height2)
                              if (!Width1 || !Height1 || !Width2 || !Height2
                                    || Width1 != Width2 || Height1 != Height2)
                              Return -1
                              E1 := Gdip_LockBits(pBitmap1, 0, 0, Width1, Height1, Stride1, Scan01, BitmapData1)
                              E2 := Gdip_LockBits(pBitmap2, 0, 0, Width2, Height2, Stride2, Scan02, BitmapData2)
                              z := 0
                              Loop %Height1%
                              {
                                    y++
                                    Loop %Width1%
                                    {
                                          Gdip_FromARGB(Gdip_GetLockBitPixel(Scan01, A_Index-1, y-1, Stride1), A1, R1, G1, B1)
                                          Gdip_FromARGB(Gdip_GetLockBitPixel(Scan02, A_Index-1, y-1, Stride2), A2, R2, G2, B2)
                                          z += Abs(A2-A1) + Abs(R2-R1) + Abs(G2-G1) + Abs(B2-B1)
                                    }
                              }
                              Gdip_UnlockBits(pBitmap1, BitmapData1), Gdip_UnlockBits(pBitmap2, BitmapData2)
                              If (accuracy!=100)
                              {
                                    Gdip_DisposeImage(pBitmap1)
                                    Gdip_DisposeImage(pBitmap2)
                              }
                              Return z/(Width1*Width2*3*255/100)
                        }
                        Gdip_RetrieveBitmapChannel(pBitmap, channel) {
                              Gdip_GetImageDimensions(pBitmap, imgW, imgH)
                              If (!imgW || !imgH)
                              Return
                        If (channel=1)
                              matrix := GenerateColorMatrix(3)
                        Else If (channel=2)
                              matrix := GenerateColorMatrix(4)
                        Else If (channel=3)
                              matrix := GenerateColorMatrix(5)
                        Else If (channel=4)
                              matrix := GenerateColorMatrix(0,0.5,0,0.05)
                        Else Return
                              newBitmap := Gdip_CreateBitmap(imgW, imgH)
                        If !newBitmap
                              Return
                        G := Gdip_GraphicsFromImage(newBitmap, 7)
                        Gdip_GraphicsClear(G, "0xff000000")
                        Gdip_DrawImage(G, pBitmap, 0, 0, imgW, imgH, 0, 0, imgW, imgH, matrix)
                        Gdip_DeleteGraphics(G)
                        Return newBitmap
                  }
                  Gdip_RenderPixelsOpaque(pBitmap, pBrush:=0, alphaLevel:=0) {
                        Gdip_GetImageDimensions(pBitmap, imgW, imgH)
                        newBitmap := Gdip_CreateBitmap(imgW, imgH)
                        G := Gdip_GraphicsFromImage(newBitmap)
                        Gdip_SetInterpolationMode(G, 7)
                        If alphaLevel
                              matrix := GenerateColorMatrix(0, 0, 0, 1, alphaLevel)
                        Else
                              matrix := GenerateColorMatrix(0, 0, 0, 1, 25)
                        If pBrush
                              Gdip_FillRectangle(G, pBrush, 0, 0, imgW, imgH)
                        Gdip_DrawImage(G, pBitmap, 0, 0, imgW, imgH, 0, 0, imgW, imgH, matrix)
                        Gdip_DeleteGraphics(G)
                        Return newBitmap
                  }
                  Gdip_TestBitmapUniformity(pBitmap, HistogramFormat:=3, ByRef maxLevelIndex:=0, ByRef maxLevelPixels:=0) {
                        LevelsArray := []
                        maxLevelIndex := maxLevelPixels := nrPixels := 9
                        Gdip_GetImageDimensions(pBitmap, Width, Height)
                        Gdip_GetHistogram(pBitmap, HistogramFormat, LevelsArray, 0, 0)
                        Loop 256
                        {
                              nrPixels := Round(LevelsArray[A_Index - 1])
                              If (nrPixels>0)
                                    histoList .= nrPixels "." A_Index - 1 "|"
                        }
                        Sort histoList, NURD|
                        histoList := Trim(histoList, "|")
                        histoListSortedArray := StrSplit(histoList, "|")
                        maxLevel := StrSplit(histoListSortedArray[1], ".")
                        maxLevelIndex := maxLevel[2]
                        maxLevelPixels := maxLevel[1]
                        pixelsThreshold := Round((Width * Height) * 0.0005) + 1
                        If (Floor(histoListSortedArray[2])<pixelsThreshold)
                              Return 1
                        Else
                              Return 0
                  }
                  Gdip_SetAlphaChannel(pBitmap, pBitmapMask, invertAlphaMask:=0, replaceSourceAlphaChannel:=0, whichChannel:=1) {
                        static mCodeFunc := 0
                        if (mCodeFunc=0)
                        {
                              if (A_PtrSize=8)
                                    base64enc := "
                              (LTrim Join
                              2,x64:QVdBVkFVQVRVV1ZTRItsJGhJicuLTCR4SInWg/kBD4TZAQAAg/kCD4SyAAAAg/kDD4TRAQAAg/kEuBgAAAAPRMiDfCRwAQ+EowAAAEWFwA+OZgEAAEWNcP9NY8Ax7UG8/wAAAEqNHIUAAAAAMf9mkEWFyX5YQYP9AQ+E2QAAAEyNB
                              K0AAAAAMdIPH4AAAAAAR4sUA0KLBAZFidfT+EHB7xgPtsBCjYQ4Af///4XAD0jHQYHi////AIPCAcHgGEQJ0EOJBANJAdhBOdF1w0iNRQFMOfUPhOEAAABIicXrkYN8JHABuQgAAAAPhV3///9FhcAPjsMAAABBjXj/TWPAMdtOjRSFAAAA
                              AA8fgAAAAABFhcl+MUGD/QEPhLEAAABIjQSdAAAAAEUxwGYPH0QAAIsUBkGDwAHT+kGIVAMDTAHQRTnBdepIjUMBSDnfdGxIicPrvA8fQABIjRStAAAAAEUxwA8fRAAARYsUE4sEFkWJ19P4QcHvGA+2wEKNhDgB////RYnnhcAPSMdBgeL
                              ///8AQYPAAUEpx0SJ+MHgGEQJ0EGJBBNIAdpFOcF1ukiNRQFMOfUPhR////+4AQAAAFteX11BXEFdQV5BX8MPHwBIjRSdAAAAAEUxwA8fRAAAiwQWQYPAAdP499BBiEQTA0wB0kU5wXXo6Un///+5EAAAAOk6/v//McnpM/7//w==
                              )"
                              else
                                    base64enc := "
                              (LTrim Join
                              2,x86:VVdWU4PsBIN8JDABD4T1AQAAg3wkMAIPhBwBAACDfCQwAw+E7AEAAIN8JDAEuBgAAAAPRUQkMIlEJDCDfCQsAQ+EBgEAAItUJCCF0g+OiQAAAItEJCDHBCQAAAAAjSyFAAAAAI10JgCLRCQkhcB+XosEJItcJBgx/400hQAAAAAB8wN0JByDfCQ
                              oAXRjjXYAixOLBg+2TCQw0/iJ0cHpGA+2wI2ECAH///+5AAAAAIXAD0jBgeL///8Ag8cBAe7B4BgJwokTAes5fCQkdcKDBCQBiwQkOUQkIHWNg8QEuAEAAABbXl9dw420JgAAAACQixOLBg+2TCQw0/iJ0cHpGA+2wI2ECAH///+5AAAAAIXAD0jBuf8A
                              AACB4v///wAB7oPHASnBicjB4BgJwokTAes5fCQkdbnrlYN8JCwBx0QkMAgAAAAPhfr+//+LTCQghcl+hzH/i0QkIItsJCSJPCSLTCQwjTSFAAAAAI10JgCF7X42g3wkKAGLBCR0Sot8JByNFIUAAAAAMdsB1wNUJBiNtCYAAAAAiweDwwEB99P4iEIDA
                              fI53XXugwQkAYsEJDlEJCB1uYPEBLgBAAAAW15fXcONdCYAi1wkHMHgAjHSAcMDRCQYiceNtCYAAAAAiwODwgEB89P499CIRwMB9znVdeyDBCQBiwQkOUQkIA+Fa////+uwx0QkMBAAAADpJ/7//8dEJDAAAAAA6Rr+//8=
                              )"
                              mCodeFunc := Gdip_RunMCode(base64enc)
                        }
                        Gdip_GetImageDimensions(pBitmap, w, h)
                        Gdip_GetImageDimensions(pBitmapMask, w2, h2)
                        If (w2!=w || h2!=h || !pBitmap || !pBitmapMask)
                              Return 0
                        Gdip_LockBits(pBitmap, 0, 0, w, h, stride, iScan, iData)
                        Gdip_LockBits(pBitmapMask, 0, 0, w, h, stride, mScan, mData)
                        r := DllCall(mCodeFunc, "UPtr", iScan, "UPtr", mScan, "Int", w, "Int", h, "Int", invertAlphaMask, "Int", replaceSourceAlphaChannel, "Int", whichChannel)
                        Gdip_UnlockBits(pBitmapMask, mData)
                        Gdip_UnlockBits(pBitmap, iData)
                        return r
                  }
                  Gdip_BlendBitmaps(pBitmap, pBitmap2Blend, blendMode) {
                        static mCodeFunc := 0
                        if (mCodeFunc=0)
                        {
                              if (A_PtrSize=8)
                                    base64enc := "
                              (LTrim Join
                              2,x64:QVdBVkFVQVRVV1ZTSIHsiAAAAA8pdCQgDyl8JDBEDylEJEBEDylMJFBEDylUJGBEDylcJHBEi6wk8AAAAEiJlCTYAAAASInORYXAD46XBAAARYXJD46OBAAAQY1A/01jwGYP7+TzDxA9AAAAAEiJRCQQRA8o3EQPKNRFic5OjSSFAAAAAEQPKM9EDyjHSMdEJAgAAAAASItEJAhNiedmkGYP7/ZMjQSFAAAAAEUx0g8o7mYPH0QAAEKLDAaFyQ+E5QEAAEiLhCTYAAAAQYnJQcHpGEKLHACJ2MHoGE
                              E4wUQPQ8hFhMkPhPQBAACJ2InaD7btRA+228HoCMHqEIlEJBgPtscPtvpBicSJyA+2ycHoEA+2wEGD/QEPhAEBAABBg/0CD4QHAgAAQYP9Aw+EnQIAAEGD/QQPhPMCAABBg/0FD4RhAwAAQYP9Bg+E1wMAAEGD/QcPhJQEAABBg/0ID4TPBAAAQYP9CQ+ETAUAAEGD/QoPhEUGAABBg/0LD4RnBwAAQYP9DA+E6gYAAEGD/Q0PhMkHAABBg/0OD4T5CAAAQYP9Dw+EXQgAAEGD/RAPhKgJAABBg/0RD4TYCQ
                              AAQYP9Eg+FqQEAALr/AAAAOccPjkUKAAAp+mYP78kpwvMPKsq4/wAAAEE57A+OGQoAAEQp4GYP79Ip6PMPKtC4/wAAAEE5yw+O7AkAAEQp2GYP78ApyPMPKsDpVQEAAA8fADnHD42YAQAAZg/vyfMPKs9BOewPjXcBAABmD+/S80EPKtRBOcsPjU0BAABmD+/AZg/v2/NBDyrDDy/YdgTzD1jHDy/ZD4eWAAAA8w8swQ+2wMHgEA8v2onCD4ePAAAA8w8s2g+228HjCA8v2A+HigAAAPMPLMAPtsAJ0EHB4R
                              hBCcFBCdlGiQwGQYPCAU0B+EU51g+F//3//0iLfCQISI1HAUg5fCQQD4QbAgAASIlEJAjpyf3//2YPH4QAAAAAAEGDwgFCxwQGAAAAAE0B+EU51g+FwP3//+u/Zg8fRAAAMdIPL9oPKMsPhnH///8x2w8v2A8o0w+Gdv///zHADyjD6XP///9mLg8fhAAAAAAAD6/4Zg/vyWYP79JBD6/sZg/vwEEPr8uJ+L+BgICASA+vx0gPr+9ID6/PSMHoJ0jB7SfzDyrISMHpJ/MPKtXzDyrBDy/hDyjcdgXzQQ9YyQ
                              8v2g+G0P7///NBD1jQ6cb+//9mDx9EAABmD+/ADyjd8w8qwemw/v//Dx+EAAAAAABmD+/S8w8q1emF/v//Dx8AZg/vyfMPKsjpY/7//w8fAAHHZg/vyWYP79K6/wAAAIH//wAAAGYP78APTPpEAeWB7/8AAACB/f8AAAAPTOrzDyrPRAHZge3/AAAAgfn/AAAAD0zK8w8q1YHp/wAAAPMPKsHpS////2YPH4QAAAAAALv/AAAAZg/vyWYP79KDxwGJ2mYP78APKN4pwonQweAIKdCZ9/+J2jH/KcKJ0InaD0
                              jHKepBjWwkAfMPKsiJ0MHgCCnQmff9idopwonQidoPSMcpykGDwwHzDyrQidDB4Agp0JlB9/spww9I3/MPKsPpxf3//w8fADnHD44yAQAAZg/vyfMPKs9BOewPjhQBAABmD+/S80EPKtRBOcsPjvEAAABmD+/AZg/v2/NBDyrD6Zr+//8PHwAPKHQkIA8ofCQwuAEAAABEDyhEJEBEDyhMJFBEDyhUJGBEDyhcJHBIgcSIAAAAW15fXUFcQV1BXkFfww8fRAAAuv8AAABmD+/JZg/v0onTKfuJ1ynHifgPr8
                              NIY9hIaduBgICASMHrIAHDwfgfwfsHKdiJ0wX/AAAARCnj8w8qyInQKegPr8NIY9hIaduBgICASMHrIAHDwfgfwfsHKdgF/wAAAPMPKtCJ0CnKRCnYD6/CSGPQZg/vwEhp0oGAgIBIweogAcLB+B/B+gcp0AX/AAAA8w8qwOmu/f//Zg/vwEEPKNrzDyrB6ar9//9mD+/S8w8q1eno/v//Zg/vyfMPKsjpyf7//2YP78lmD+/SZg/vwAHHgf//AAAAuP8AAAAPT/hEAeWB/f8AAAAPT+jzDyrPRAHZgfn/AA
                              AAD0/I8w8q1fMPKsHpPv3//4P/fg+PRgEAAA+vx7+BgICAZg/vyQHASA+vx0jB6CfzDyrIQYP8fg+P5gAAAEEPr+y/gYCAgGYP79KNRC0ASA+vx0jB6CfzDyrQQYP7fn8hQQ+vy7+BgICAZg/vwI0ECUgPr8dIwegn8w8qwOnN/P//uv8AAACJ0CnKRCnYD6/CAcDp3/7//4P4fg+OVQEAALr/AAAAZg/vyYnTKcIp+w+v040EEkhj0Ehp0oGAgIBIweogAcLB+B/B+gcp0AX/AAAA8w8qyIP9fg+POQEAAE
                              SJ4L+BgICAZg/v0g+vxQHASA+vx0jB6CfzDyrQg/l+f4BEidi/gYCAgGYP78APr8EBwEgPr8dIwegn8w8qwOkr/P//uv8AAABmD+/SidAp6kQp4A+v0I0EEkhj0Ehp0oGAgIBIweogAcLB+B/B+gcp0AX/AAAA8w8q0On7/v//uv8AAABmD+/JidMpwin7D6/TjQQSSGPQSGnSgYCAgEjB6iABwsH4H8H6BynQBf8AAADzDyrI6Zn+//+6/wAAACnCOfoPjYgBAADzDxANAAAAALoAAP8AuP8AAAAp6EQ54A
                              +NYAEAAPMPEBUAAAAAuwD/AAC4/wAAACnIRDnYD404AQAA8w8QBQAAAAC4/wAAAOmA+v//D6/Hv4GAgIBmD+/JAcBID6/HSMHoJ/MPKsiD/X4Pjsf+//+4/wAAAGYP79KJwinoRCniD6/CAcBIY9BIadKBgICASMHqIAHCwfgfwfoHKdAF/wAAAPMPKtDpqf7//4nCZg/vyWYP79K7AAEAAMHiCCn7Zg/vwL8AAQAAKcKJ0Jn3+7v/AAAAPf8AAAAPT8NEKedBvAABAADzDyrIiejB4Agp6Jn3/z3/AAAAD0
                              /DRSnc8w8q0InIweAIKciZQff8Pf8AAAAPT8PzDyrA6Yj6//+NBHhmD+/JZg/v0rr+AQAAPf4BAABmD+/AD0/CLf8AAADzDyrIQo1EZQA9/gEAAA9Pwi3/AAAA8w8q0EKNBFk9/gEAAA9Pwi3/AAAA8w8qwOkz+v//McBmD+/A6U/5//8x22YP79Lpov7//zHSZg/vyel6/v//geKAAAAAiVQkHA+E+AAAAInCZg/vycHiCCnCuAABAAAp+I08AInQmff/uv8AAAA9/wAAAA9PwvMPKsiBZCQYgAAAAA+Fhg
                              EAAL//AAAAZg/v0on6KeqJ1cHlCInoQ41sJAEp0Jn3/SnHD0h8JBjzDyrXgeOAAAAAD4UjAQAAv/8AAABmD+/AifopykONTBsBidDB4Agp0Jn3+SnHD0j78w8qx+lq+f//jRQHZg/vyWYP79IPr8e/gYCAgGYP78BID6/HSMHoJwHAKcJEieAPr8XzDyrKQY0ULEgPr8dIwegnAcApwkSJ2A+vwfMPKtJBjRQLSA+vx0jB6CcBwCnC8w8qwukK+f//uv8AAACNfD8BZg/vySnCidDB4ggpwonQmff/v/8AAA
                              Apx4n4D0hEJBzzDyrI6QH///+JwoPHAWYP78m7/wAAAMHiCGYP79JmD+/AKcKJ0Jn3/0GNfCQBPf8AAAAPT8PzDyrIiejB4Agp6Jn3/z3/AAAAD0/DQYPDAfMPKtCJyMHgCCnImUH3+z3/AAAAD0/D8w8qwOlx+P//ichmD+/AweAIKci5AAEAAEQp2ZkByff5uv8AAAA9/wAAAA9PwvMPKsDpQ/j//4novwABAABmD+/SweAIRCnnKegB/5n3/7r/AAAAPf8AAAAPT8LzDyrQ6XX+//85xw+OgwAAACnHZg
                              /vyfMPKs9BOex+Z0SJ4GYP79Ip6PMPKtBBOct+RUEpy2YP78DzQQ8qw+nb9///Zg/vyWYP79JmD+/AMdIp+EEPKNsPSMJEKeUPSOpEKdnzDyrID0jK8w8q1fMPKsHpn/b//0Qp2WYP78DzDyrB6Zf3//9EKeVmD+/S8w8q1euZKfhmD+/J8w8qyOl4////KchmD+/ARCnY8w8qwOlp9///KehmD+/SRCng8w8q0Oni9f//KcJmD+/JidAp+PMPKsjptPX//5CQAAB/Qw==
                              )"
                              else
                                    base64enc := "
                              (LTrim Join
                              2,x86:VVdWU4PsMItcJEyF2w+OdAIAAItUJFCF0g+OaAIAAItEJEzHRCQkAAAAAMHgAolEJAiNtgAAAACLRCQki3QkRIlMJAQx/4n9weACAcYDRCRIiQQkjXQmAIsOhckPhPgBAACLBCSJz8HvGIsYifqJ2MHoGDjCD0LHiEQkFITAD4QUAgAAidqJz4nYweoIwe8QiVQkLA+218HoEIN8JFQBiVQkGA+204lUJByJ+g+2+g+21YlEJCgPtsmJVCQgD7bAD4QSAQAAg3wkVAIPhM8BAACDfCRUAw+EBAIAAI
                              N8JFQED4RRAgAAg3wkVAUPhM4CAACDfCRUBg+E8wIAAIN8JFQHD4R8AwAAg3wkVAgPhLoDAACDfCRUCQ+EfwQAAIN8JFQKD4RYBQAAg3wkVAsPhH4GAACDfCRUDA+EAAYAAIN8JFQND4TABgAAg3wkVA4PhPIHAACDfCRUDw+EWwcAAIN8JFQQD4R3CAAAg3wkVBEPhLAIAACDfCRUEg+FuAMAADn4D470CAAAu/8AAAApw4nYKfiJRCQMi1wkGIt8JCC4/wAAADn7D46/CAAAKdgp+IlEJBCLRCQcuv8AAA
                              A5yA+OlwgAACnCKcqJVCQE6VYDAACNdCYAkItcJBg5+A9O+InQOdMPTsOJfCQMiUQkEItEJBw5yInCD0/RiVQkBItcJAy4AAAAAItMJAS/AAAAAIXbD0nDi1wkEIXbiUQkDA9J+7sAAAAAhcmJ2g9J0cHgEIl8JBCJw8HnCIlUJAQPtsqB4wAA/wAPt/+LRCQUCdnB4BgJwQn5iQ6LRCQIg8UBAQQkAcY5bCRQD4Xo/f//g0QkJAGLTCQEi0QkJDlEJEwPhbH9//+DxDC4AQAAAFteX13DjXQmAMcGAAAAAO
                              u6D6/4u4GAgIAPr0wkHIn49+PB6geJVCQMi1QkGA+vVCQgidD344nIweoHiVQkEPfjweoHiVQkBOkj////jXQmAAHHuP8AAACLVCQYgf//AAAAD0z4A1QkIIH6/wAAAA9M0ANMJByNnwH///+B+f8AAACJXCQMD0zIjZoB////iVwkEI2BAf///4lEJATpzv7//420JgAAAAC6/wAAACn6idPB4wgp04najVgBidCZ9/u7/wAAALr/AAAAKcO4AAAAAA9JwytUJCCLXCQYiUQkDInQg8MBweAIKdCZ9/u7/w
                              AAALr/AAAAKcO4AAAAAA9JwynKi0wkHIlEJBCJ0IPBAcHgCCnQmff5uv8AAAApwrgAAAAAD0nCiUQkBOk//v//OfiLXCQYD034i0QkIDnDiXwkDA9Nw4lEJBCLRCQcOciJwg9M0YlUJATpEf7//2aQuv8AAAC7gYCAgCnCuP8AAAAp+InXD6/4ifj364n4wfgfAfrB+gcp0Lr/AAAAK1QkGAX/AAAAideJRCQMuP8AAAArRCQgD6/4ifj364n4wfgfAfrB+gcp0Lr/AAAAK1QkHAX/AAAAiUQkELj/AAAAKc
                              iJ0Q+vyInI9+uNHArB+R/B+wcp2Y2B/wAAAIlEJATpe/3//wH4u/8AAACLVCQcPf8AAAAPTtiLRCQYA0QkID3/AAAAiVwkDLv/AAAAD07YAcq4/wAAAIH6/wAAAA9OwolcJBCJRCQE6TL9//+D+H4Pj3QBAAAPr/i6gYCAgI0EP/fiweoHiVQkDItEJBiD+H4PjxgBAAAPr0QkILqBgICAAcD34sHqB4lUJBCLRCQcg/h+f08Pr8iNBAm6gYCAgPfiweoHiVQkBItEJAyFwHkIgUQkDP8AAACLRCQQhcB5CQ
                              X/AAAAiUQkEItEJASFwA+Jqfz//wX/AAAAiUQkBOmb/P//uv8AAAC4/wAAACtUJBwpyInRuoGAgIAPr8gByYnI9+qNBArB+R/B+AeJyinCjYL/AAAAiUQkBOuMg/9+D44+AQAAuv8AAAApwrj/AAAAKfgPr8K6gYCAgI0cAInY9+qJ2MH4HwHai1wkIMH6BynQBf8AAACJRCQMg/t+D48fAQAAi0QkGLqBgICAD6/DAcD34sHqB4lUJBCD+X4Pj1////8Pr0wkHOkJ////uv8AAAC4/wAAACtUJBgrRCQgD6
                              /CuoGAgICNHACJ2PfqidjB+B8B2sH6BynQBf8AAACJRCQQ6cL+//+6/wAAACnCuP8AAAAp+A+vwrqBgICAjRwAidj36onYwfgfAdrB+gcp0AX/AAAAiUQkDOlp/v//uv8AAAC7AAD/ACn6vwAAAAA5wrj/AAAAifoPTccPTd+/AP8AAIlEJAy4/wAAACtEJCA7RCQYuP8AAAAPTcIPTfqJRCQQuP8AAAApyDtEJBy4/wAAAA9NwolEJASJweln+///D6/HuoGAgICLXCQgAcD34sHqB4lUJAyD+34PjuH+//
                              +6/wAAALj/AAAAK1QkGCtEJCAPr8K6gYCAgI0cAInY9+qJ2MH4HwHawfoHKdAF/wAAAIlEJBDpvf7//4n6uwABAADB4ggp+onfKceJ0Jn3/7//AAAAido9/wAAAA9Px4t8JCArVCQYiUQkDIn4weAIKfiJ15n3/7//AAAAPf8AAAAPT8eJRCQQicjB4AgpyInZK0wkHJn3+br/AAAAPf8AAAAPTtCJVCQE6U36//+NFEe4/gEAAIt8JBiB+v4BAAAPT9CNmgH///+JXCQMi1wkII0Ue4H6/gEAAA9P0I2aAf
                              ///4lcJBCLXCQcjRRZgfr+AQAAD0/QjYIB////iUQkBOkf/f//i1QkKIHigAAAAIlUJAQPhPsAAACJ+sHiCCn6vwABAAApx4nQjTw/mff/v/8AAAA9/wAAAA9Px4lEJAyLfCQsgeeAAAAAD4VdAQAAuv8AAAArVCQgidDB4Agp0A+2141UEgGJVCQEmfd8JAS6/wAAACnCD0n6iXwkEIHjgAAAAA+FDAEAALr/AAAAKcqLTCQcidDB4AiNTAkBKdCZ9/m6/wAAACnCD0naiVwkBOlE+f//jRw4D6/HiVwkBL
                              uBgICAi3wkBPfjidCLVCQgwegHAcApx4tEJBiJfCQMiccPr8IB1/fjidDB6AcBwCnHi0QkHIl8JBCNPAgPr8H344nQwegHAcApx4l8JATpEPz//7r/AAAAKfqJ18HiCCn6jXwAAYnQmff/v/8AAAApx4tEJAQPSceJRCQM6f7+//+J+o1YAcHiCCn6v/8AAACJ0Jn3+4tcJCA9/wAAAA9Px4lEJAyJ2MHgCCnYi1wkGJmDwwH3+z3/AAAAD0/HiUQkEInIweAIKciLTCQcg8EB6f79//+JyMHgCCnIuQABAA
                              ArTCQcAcnp5/3//4t8JCC6AAEAACtUJBiJ+MHgCCn4jTwSmff/v/8AAAA9/wAAAA9Px4lEJBDpof7//4nCifspwyn6OfiLfCQgD07Ti1wkGIlUJAyJ2In6Kdop+Dn7i1wkHA9OwonKKdqJRCQQidgpyDnLD07CiUQkBOkD+///Kce4AAAAALsAAAAAD0nHiUQkDItEJCArRCQYD0nYK0wkHLgAAAAAD0nBiVwkEIlEJATpovf//ynKK1QkHIlUJATpvfr//ytEJCArRCQYiUQkEOk49///uv8AAAAp+inCiV
                              QkDOkJ9///
                              )"
                              mCodeFunc := Gdip_RunMCode(base64enc)
                        }
                        Gdip_GetImageDimensions(pBitmap, w, h)
                        Gdip_GetImageDimensions(pBitmap2Blend, w2, h2)
                        If (w2!=w || h2!=h || !pBitmap || !pBitmap2Blend)
                              Return 0
                        Gdip_LockBits(pBitmap, 0, 0, w, h, stride, iScan, iData)
                        Gdip_LockBits(pBitmap2Blend, 0, 0, w, h, stride, mScan, mData)
                        r := DllCall(mCodeFunc, "UPtr", iScan, "UPtr", mScan, "Int", w, "Int", h, "Int", blendMode)
                        Gdip_UnlockBits(pBitmap2Blend, mData)
                        Gdip_UnlockBits(pBitmap, iData)
                        return r
                  }
                  Gdip_BoxBlurBitmap(pBitmap, passes) {
                        static mCodeFunc := 0
                        if (mCodeFunc=0)
                        {
                              if (A_PtrSize=8)
                                    base64enc := "
                              (LTrim Join
                              2,x64:QVdBVkFVQVRVV1ZTSIPsWESLnCTAAAAASImMJKAAAABEicCJlCSoAAAARImMJLgAAABFhdsPjtoDAABEiceD6AHHRCQ8AAAAAEG+q6qqqkEPr/lBD6/BiXwkBInXg+8BiUQkJIn4iXwkOEiNdIEESPfYSIl0JEBIjTSFAAAAAI0EvQAAAABJY/lImEiJdCRISI1EBvxIiXwkCEiJRCQwRInI99hImEiJRCQQDx9EAABIi0QkQMdEJCAAAAAASIlEJBhIi0QkSEiD6ARIiUQkKItEJASFwA+OegEAAA8fQABEi4wkqAAAAEWFyQ+OPwMAAEiLRCQoTIt8JBgx9jHbRTHbRTHSRTHJRTHATAH4Mckx0mYPH0QAAEWJ1UQPtlADRYn
                              cRA+2WAJEAepEAeGJ3Q+2WAFEAdJBAeiJ9w+2MEkPr9ZBAflIg8AESMHqIYhQ/0KNFBlEieFJD6/WSMHqIYhQ/kGNFBhBiehJD6/WSMHqIYhQ/UGNFDFBiflJD6/WSMHqIYhQ/ESJ6kw5+HWJi3wkOEiLRCQwMfYx20gDRCQYRTHbRTHSRTHJRTHAMckx0g8fgAAAAABFiddED7ZQA0WJ3UQPtlgCRAH6RAHpQYncD7ZYAUQB0kUB4In1D7YwSQ+v1kEB6YPvAUiD6ARIweohiFAHQo0UGUSJ6UkPr9ZIweohiFAGQY0UGEWJ4EkPr9ZIweohiFAFQY0UMUGJ6UkPr9ZIweohiFAERIn6g///dYWLvCS4AAAASItcJAgBfCQgi0QkIEgB
                              XCQYO0QkBA+Miv7//0SLhCSoAAAAx0QkGAMAAADHRCQgAAAAAEWFwA+OiAEAAGYPH4QAAAAAAItUJASF0g+OpAAAAEhjRCQYMf8x9jHbSAOEJKAAAABFMdtFMdIxyUUxyUUxwDHSkEWJ10QPthBFid1ED7ZY/0QB+kQB6UGJ3A+2WP5EAdJFAeCJ9Q+2cP1JD6/WQQHpA7wkuAAAAEjB6iGIEEKNFBlEielJD6/WSMHqIYhQ/0GNFBhFieBJD6/WSMHqIYhQ/kGNFDFBielJD6/WSMHqIYhQ/UgDRCQIRIn6O3wkBHyAi0wkJIXJD4ioAAAATGNUJCRIY0QkGDH/MfYx20Ux20UxyUUxwEwB0DHJSAOEJKAAAAAx0g8fQABFid9ED7YYQ
                              YndD7ZY/0QB+kQB6UGJ9A+2cP5EAdpFAeCJ/Q+2eP1JD6/WQQHpSMHqIYgQjRQZSItMJBBJD6/WSQHKSMHqIYhQ/0GNFDBFieBJD6/WSMHqIYhQ/kGNFDlBielJD6/WSMHqIYhQ/UgByESJ+kSJ6UWF0nmEg0QkIAGLRCQgg0QkGAQ5hCSoAAAAD4WB/v//g0QkPAGLRCQ8OYQkwAAAAA+Fm/z//0iDxFhbXl9dQVxBXUFeQV/DZi4PH4QAAAAAAESLVCQ4RYXSD4j1/f//6Uz9//8=
                              )"
                              else
                                    base64enc := "
                              (LTrim Join
                              2,x86:VVdWU4PsPItsJGCLRCRYhe0PjncEAACLfCRcx0QkNAAAAAAPr/iD6AEPr0QkXIl8JCSLfCRUiUQkLItEJFCD7wGJfCQwi3wkVI0EuIlEJDiLRCQ4x0QkKAAAAACJRCQgi0QkJIXAD47pAQAAjXQmAIt0JFSF9g+OJAQAAMdEJAwAAAAAi0wkKDHtMf/HRCQYAAAAAANMJFAx9jHAx0QkFAAAAADHRCQQAAAAAI10JgCLVCQMD7ZZA4k0JIPBBA+2cf6JfCQEiVQkHAHCD7Z5/QHaiVwkDLurqqqqidCJbCQID7Zp/Pfji1wkEAMcJNHqiFH/idq7q6qqqgHyidD344tcJBQDXCQE0eqIUf6J2rurqqqqAfqJ0Pfj0eqIUf2LVCQ
                              YA1QkCAHqidD344scJItEJByJXCQQi1wkBNHqiVwkFItcJAiIUfyJXCQYO0wkIA+FWf///4tEJDDHBCQAAAAAMe0x/8dEJBwAAAAAi0wkIDH2x0QkGAAAAADHRCQUAAAAAIlEJAQxwI22AAAAAIscJA+2Uf+JdCQIg+kED7ZxAol8JAyJFCSNFBgDFCSJ0LqrqqqqD7Z5AYlsJBD34g+2KYNsJAQB0eqIUQOLVCQUA1QkCAHyidC6q6qqqvfi0eqIUQKLVCQYA1QkDAH6idC6q6qqqvfi0eqIUQGLVCQcA1QkEAHqidC6q6qqqvfiidiLXCQIiVwkFItcJAzR6ogRi1QkBIlcJBiLXCQQiVwkHIP6/w+FVf///4t8JFwBfCQoAXwkIItE
                              JCg7RCQkD4wb/v//i0QkUItcJFTHRCQoAAAAAPfYiUQkDIXbD44IAgAAjXQmAJCLVCQkhdIPjugAAAAx9otMJAzHRCQIAAAAADHtx0QkGAAAAAAx/zHAx0QkFAAAAAD32cdEJBAAAAAAiTQkjXYAi1QkCA+2cQOJfCQEixwkD7Z5AYlUJCABwgHyiXQkCL6rqqqqidCJXCQcD7ZZAvfmi3QkHItEJBCJHCSJ6w+2KQHwiXQkEIt0JAzR6ohRA4sUJAHCidC6q6qqqvfii0QkFANEJATR6ohRAonCAfqJ0Lqrqqqq9+KLRCQYiVwkGAHY0eqIUQGJwgHqidC6q6qqqvfii0QkINHqiBGLVCQEA0wkXIlUJBSNFDE5VCQkD49M////i0wkL
                              IXJD4jrAAAAMfbHRCQQAAAAAItMJCwx7cdEJBwAAAAAK0wkDDH/McDHRCQYAAAAAMdEJBQAAAAAiTQkjXQmAJCLHCSLVCQQiXwkBA+2cQMPtnkBiWwkCIlcJCAPtlkCiXQkEA+2KYkcJInTAcIB8r6rqqqqidD35ot0JCCLRCQUAfCJdCQUi3QkDNHqiFEDixQkAcKJ0Lqrqqqq9+KLRCQYA0QkBNHqiFECicIB+onQuquqqqr34otEJBwDRCQI0eqIUQGJwgHqidC6q6qqqvfiidjR6ogRi1QkBCtMJFyJVCQYi1QkCAHOiVQkHA+JTf///4NEJCgBi0QkKINsJAwEOUQkVA+F/f3//4NEJDQBi0QkNDlEJGAPhcL7//+DxDxbXl9dw4
                              20JgAAAACNdgCLfCQwhf8PiI/9///ppvz//w==
                              )"
                              mCodeFunc := Gdip_RunMCode(base64enc)
                        }
                        Gdip_GetImageDimensions(pBitmap,w,h)
                        Gdip_LockBits(pBitmap,0,0,w,h,stride,iScan,iData)
                        r := DllCall(mCodeFunc, "UPtr",iScan, "Int",w, "Int",h, "Int",stride, "Int",passes)
                        Gdip_UnlockBits(pBitmap,iData)
                        return r
                  }
                  Gdip_RunMCode(mcode) {
                        static e := {1:4, 2:1}
                        , c := (A_PtrSize=8) ? "x64" : "x86"
                              if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
                                    return
                              if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", StrLen(m3), "uint", e[m1], "ptr", 0, "uintp", s, "ptr", 0, "ptr", 0))
                                    return
                              p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
                              DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
                              if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", StrLen(m3), "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
                                    return p
                              DllCall("GlobalFree", "ptr", p)
                        }
                        calcIMGdimensions(imgW, imgH, givenW, givenH, ByRef ResizedW, ByRef ResizedH) {
                              PicRatio := Round(imgW/imgH, 5)
                              givenRatio := Round(givenW/givenH, 5)
                              If (imgW <= givenW) && (imgH <= givenH)
                              {
                                    ResizedW := givenW
                                    ResizedH := Round(ResizedW / PicRatio)
                                    If (ResizedH>givenH)
                                    {
                                          ResizedH := (imgH <= givenH) ? givenH : imgH
                                          ResizedW := Round(ResizedH * PicRatio)
                                    }
                              } Else If (PicRatio > givenRatio)
                              {
                                    ResizedW := givenW
                                    ResizedH := Round(ResizedW / PicRatio)
                              } Else
                              {
                                    ResizedH := (imgH >= givenH) ? givenH : imgH
                                    ResizedW := Round(ResizedH * PicRatio)
                              }
                        }
                        GetWindowRect(hwnd, ByRef W, ByRef H) {
                              size := VarSetCapacity(rect, 16, 0)
                              er := DllCall("dwmapi\DwmGetWindowAttribute"
                              , "UPtr", hWnd
                              , "UInt", 9
                              , "UPtr", &rect
                              , "UInt", size
                              , "UInt")
                              If er
                                    DllCall("GetWindowRect", "UPtr", hwnd, "UPtr", &rect, "UInt")
                              r := []
                              r.x1 := NumGet(rect, 0, "Int"), r.y1 := NumGet(rect, 4, "Int")
                              r.x2 := NumGet(rect, 8, "Int"), r.y2 := NumGet(rect, 12, "Int")
                              r.w := Abs(max(r.x1, r.x2) - min(r.x1, r.x2))
                              r.h := Abs(max(r.y1, r.y2) - min(r.y1, r.y2))
                              W := r.w
                              H := r.h
                        Return r
                  }
                  Gdip_BitmapConvertGray(pBitmap, hue:=0, vibrance:=-40, brightness:=1, contrast:=0, KeepPixelFormat:=0) {
                        Gdip_GetImageDimensions(pBitmap, Width, Height)
                        If (KeepPixelFormat=1)
                              PixelFormat := Gdip_GetImagePixelFormat(pBitmap, 1)
                        If StrLen(KeepPixelFormat)>3
                              PixelFormat := KeepPixelFormat
                        newBitmap := Gdip_CreateBitmap(Width, Height, PixelFormat)
                        G := Gdip_GraphicsFromImage(newBitmap, InterpolationMode)
                        If (hue!=0 || vibrance!=0)
                              pEffect := Gdip_CreateEffect(6, hue, vibrance, 0)
                        matrix := GenerateColorMatrix(2, brightness, contrast)
                        If pEffect
                        {
                              E := Gdip_DrawImageFX(G, pBitmap, 0, 0, 0, 0, Width, Height, matrix, pEffect)
                              Gdip_DisposeEffect(pEffect)
                        } Else
                        E := Gdip_DrawImage(G, pBitmap, 0, 0, Width, Height, 0, 0, Width, Height, matrix)
                        Gdip_DeleteGraphics(G)
                        Return newBitmap
                  }
                  Gdip_BitmapSetColorDepth(pBitmap, bitsDepth, useDithering:=1) {
                        ditheringMode := (useDithering=1) ? 9 : 1
                        If (useDithering=1 && bitsDepth=16)
                              ditheringMode := 2
                        Colors := 2**bitsDepth
                        If bitsDepth Between 2 and 4
                              bitsDepth := "40s"
                        If bitsDepth Between 5 and 8
                              bitsDepth := "80s"
                        If (bitsDepth="BW")
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x30101, ditheringMode, 2, 2, 2, 2, 0, 0)
                        Else If (bitsDepth=1)
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x30101, ditheringMode, 1, 2, 1, 2, 0, 0)
                        Else If (bitsDepth="40s")
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x30402, ditheringMode, 1, Colors, 1, Colors, 0, 0)
                        Else If (bitsDepth="80s")
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x30803, ditheringMode, 1, Colors, 1, Colors, 0, 0)
                        Else If (bitsDepth=16)
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x21005, ditheringMode, 1, Colors, 1, Colors, 0, 0)
                        Else If (bitsDepth=24)
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x21808, 2, 1, 0, 0, 0, 0, 0)
                        Else If (bitsDepth=32)
                              E := Gdip_BitmapConvertFormat(pBitmap, 0x26200A, 2, 1, 0, 0, 0, 0, 0)
                        Else
                              E := -1
                        Return E
                  }
                  Gdip_BitmapConvertFormat(pBitmap, PixelFormat, DitherType, DitherPaletteType, PaletteEntries, PaletteType, OptimalColors, UseTransparentColor:=0, AlphaThresholdPercent:=0) {
                        VarSetCapacity(hPalette, 4 * PaletteEntries + 8, 0)
                        NumPut(PaletteType, &hPalette, 0, "uint")
                        NumPut(PaletteEntries, &hPalette, 4, "uint")
                        NumPut(0, &hPalette, 8, "uint")
                        Static Ptr := "UPtr"
                        E1 := DllCall("gdiplus\GdipInitializePalette", "UPtr", &hPalette, "uint", PaletteType, "uint", OptimalColors, "Int", UseTransparentColor, Ptr, pBitmap)
                        E2 := DllCall("gdiplus\GdipBitmapConvertFormat", Ptr, pBitmap, "uint", PixelFormat, "uint", DitherType, "uint", DitherPaletteType, "uPtr", &hPalette, "float", AlphaThresholdPercent)
                        E := E1 ? E1 : E2
                        Return E
                  }
                  Gdip_GetImageThumbnail(pBitmap, W, H) {
                        DllCall("gdiplus\GdipGetImageThumbnail"
                        ,"UPtr",pBitmap
                        ,"UInt",W
                        ,"UInt",H
                        ,"UPtr*",pThumbnail
                        ,"UPtr",0
                        ,"UPtr",0)
                        Return pThumbnail
                  }
                  ConvertRGBtoHSL(R, G, B) {
                        SetFormat, float, 0.5
                        R := (R / 255)
                        G := (G / 255)
                        B := (B / 255)
                        Min := min(R, G, B)
                        Max := max(R, G, B)
                        del_Max := Max - Min
                        L := (Max + Min) / 2
                        if (del_Max = 0)
                        {
                              H := S := 0
                        } else
                        {
                              if (L < 0.5)
                                    S := del_Max / (Max + Min)
                              else
                                    S := del_Max / (2 - Max - Min)
                              del_R := (((Max - R) / 6) + (del_Max / 2)) / del_Max
                              del_G := (((Max - G) / 6) + (del_Max / 2)) / del_Max
                              del_B := (((Max - B) / 6) + (del_Max / 2)) / del_Max
                              if (R = Max)
                              {
                                    H := del_B - del_G
                              } else
                              {
                                    if (G = Max)
                                          H := (1 / 3) + del_R - del_B
                                    else if (B = Max)
                                          H := (2 / 3) + del_G - del_R
                              }
                              if (H < 0)
                                    H += 1
                              if (H > 1)
                                    H -= 1
                        }
                        return [abs(round(h*360)), abs(s), abs(l)]
                  }
                  ConvertHSLtoRGB(H, S, L) {
                        H := H/360
                        if (S == 0)
                        {
                              R := L*255
                              G := L*255
                              B := L*255
                        } else
                        {
                              if (L < 0.5)
                                    var_2 := L * (1 + S)
                              else
                                    var_2 := (L + S) - (S * L)
                              var_1 := 2 * L - var_2
                              R := 255 * ConvertHueToRGB(var_1, var_2, H + (1 / 3))
                              G := 255 * ConvertHueToRGB(var_1, var_2, H)
                              B := 255 * ConvertHueToRGB(var_1, var_2, H - (1 / 3))
                        }
                        Return [round(R), round(G), round(B)]
                  }
                  ConvertHueToRGB(v1, v2, vH) {
                        vH := ((vH<0) ? ++vH : vH)
                        vH := ((vH>1) ? --vH : vH)
                        return ((6 * vH) < 1) ? (v1 + (v2 - v1) * 6 * vH)
                        : ((2 * vH) < 1) ? (v2)
                        : ((3 * vH) < 2) ? (v1 + (v2 - v1) * ((2 / 3) - vH) * 6)
                        : v1
                  }
                  Gdip_ErrrorHandler(errCode, throwErrorMsg, additionalInfo:="") {
                        Static errList := {1:"Generic_Error", 2:"Invalid_Parameter"
                              , 3:"Out_Of_Memory", 4:"Object_Busy"
                              , 5:"Insufficient_Buffer", 6:"Not_Implemented"
                              , 7:"Win32_Error", 8:"Wrong_State"
                              , 9:"Aborted", 10:"File_Not_Found"
                              , 11:"Value_Overflow", 12:"Access_Denied"
                              , 13:"Unknown_Image_Format", 14:"Font_Family_Not_Found"
                              , 15:"Font_Style_Not_Found", 16:"Not_TrueType_Font"
                              , 17:"Unsupported_GdiPlus_Version", 18:"Not_Initialized"
                              , 19:"Property_Not_Found", 20:"Property_Not_Supported"
                              , 21:"Profile_Not_Found", 100:"Unknown_Wrapper_Error"}
                              If !errCode
                              Return
                        aerrCode := (errCode<0) ? 100 : errCode
                        If errList.HasKey(aerrCode)
                              GdipErrMsg := "GDI+ ERROR: " errList[aerrCode] " [CODE: " aerrCode "]" additionalInfo
                        Else
                              GdipErrMsg := "GDI+ UNKNOWN ERROR: " aerrCode additionalInfo
                        If (throwErrorMsg=1)
                              MsgBox, % GdipErrMsg
                        Return GdipErrMsg
                  }
                  LoadGDIplus(){
                        VarSetCapacity(startInput, A_PtrSize = 8 ? 24 : 16, 0)
                        startInput := Chr(1)
                        HModuleGdip := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
                        DllCall("gdiplus\GdiplusStartup", "Ptr*", pToken, "Ptr", &startInput, "Ptr", 0)
                        ProcBitBlt := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "gdi32", "Ptr"), "AStr", "BitBlt", "Ptr")
                        ProcCreateBitmap := DllCall("GetProcAddress", "Ptr", HModuleGdip, "AStr", "GdipCreateBitmapFromHBITMAP", "Ptr")
                        ProcBitmapLock := DllCall("GetProcAddress", "Ptr", HModuleGdip, "AStr", "GdipBitmapLockBits", "Ptr")
                        ProcBitmapUnlock := DllCall("GetProcAddress", "Ptr", HModuleGdip, "AStr", "GdipBitmapUnlockBits", "Ptr")
                        ProcDisposeImage := DllCall("GetProcAddress", "Ptr", HModuleGdip, "AStr", "GdipDisposeImage", "Ptr")
                        Ptr := A_PtrSize ? "UPtr" : "UInt"
                              PtrA := Ptr . "*"
                              MCode_ImageSearch := "8b44243883ec205355565783f8010f857a0100008b7c2458897c24143b7c24600f8db50b00008b44244c8b5c245c8b4c24448b7424548be80fafef896c242490897424683bf30f8d0a0100008d64240033c033db8bf5896c241c895c2420894424183b4424480f8d0401000033c08944241085c90f8e9d0000008b5424688b7c24408beb8d34968b54246403df8d4900b803000000803c18008b442410745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424108b7c24408b4c24444083c50483c30483c604894424103bc17c818b5c24208b74241c0374244c8b44241840035c24508974241ce92dffffff8b6c24688b5c245c8b4c244445896c24683beb8b6c24240f8c06ffffff8b44244c8b7c24148b7424544703e8897c2414896c24243b7c24600f8cd5feffffe96b0a00008b4424348b4c246889088b4424388b4c24145f5e5d890833c05b83c420c383f8020f85870100008b7c24604f897c24103b7c24580f8c310a00008b44244c8b5c245c8b4c24448bef0fafe8f7d8894424188b4424548b742418896c24288d4900894424683bc30f8d0a0100008d64240033c033db8bf5896c2420895c241c894424243b4424480f8d0401000033c08944241485c90f8e9d0000008b5424688b7c24408beb8d34968b54246403df8d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c241c8b7424200374244c8b44242440035c245089742420e92dffffff8b6c24688b5c245c8b4c244445896c24683beb8b6c24280f8c06ffffff8b7c24108b4424548b7424184f03ee897c2410896c24283b7c24580f8dd5feffffe9db0800008b4424348b4c246889088b4424388b4c24105f5e5d890833c05b83c420c383f8030f85650100008b7c24604f897c24103b7c24580f8ca10800008b44244c8b6c245c8b5c24548b4c24448bf70faff04df7d8896c242c897424188944241c8bff896c24683beb0f8c020100008d64240033c033db89742424895c2420894424283b4424480f8d76ffffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff8b6c24688b5c24548b4c24448b7424184d896c24683beb0f8d0affffff8b7c24108b44241c4f03f0897c2410897424183b7c24580f8c580700008b6c242ce9d4feffff83f8040f85670100008b7c2458897c24103b7c24600f8d340700008b44244c8b6c245c8b5c24548b4c24444d8bf00faff7896c242c8974241ceb098da424000000008bff896c24683beb0f8c020100008d64240033c033db89742424895c2420894424283b4424480f8d06feffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff8b6c24688b5c24548b4c24448b74241c4d896c24683beb0f8d0affffff8b44244c8b7c24104703f0897c24108974241c3b7c24600f8de80500008b6c242ce9d4feffff83f8050f85890100008b7c2454897c24683b7c245c0f8dc40500008b5c24608b6c24588b44244c8b4c2444eb078da42400000000896c24103beb0f8d200100008be80faf6c2458896c241c33c033db8bf5896c2424895c2420894424283b4424480f8d0d01000033c08944241485c90f8ea60000008b5424688b7c24408beb8d34968b54246403dfeb0a8da424000000008d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424240374244c8b44242840035c245089742424e924ffffff8b7c24108b6c241c8b44244c8b5c24608b4c24444703e8897c2410896c241c3bfb0f8cf3feffff8b7c24688b6c245847897c24683b7c245c0f8cc5feffffe96b0400008b4424348b4c24688b74241089088b4424385f89305e5d33c05b83c420c383f8060f85670100008b7c2454897c24683b7c245c0f8d320400008b6c24608b5c24588b44244c8b4c24444d896c24188bff896c24103beb0f8c1a0100008bf50faff0f7d88974241c8944242ceb038d490033c033db89742424895c2420894424283b4424480f8d06fbffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff8b6c24108b74241c0374242c8b5c24588b4c24444d896c24108974241c3beb0f8d02ffffff8b44244c8b7c246847897c24683b7c245c0f8de60200008b6c2418e9c2feffff83f8070f85670100008b7c245c4f897c24683b7c24540f8cc10200008b6c24608b5c24588b44244c8b4c24444d896c241890896c24103beb0f8c1a0100008bf50faff0f7d88974241c8944242ceb038d490033c033db89742424895c2420894424283b4424480f8d96f9ffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b803000000803c18008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff8b6c24108b74241c0374242c8b5c24588b4c24444d896c24108974241c3beb0f8d02ffffff8b44244c8b7c24684f897c24683b7c24540f8c760100008b6c2418e9c2feffff83f8080f85640100008b7c245c4f897c24683b7c24540f8c510100008b5c24608b6c24588b44244c8b4c24448d9b00000000896c24103beb0f8d200100008be80faf6c2458896c241c33c033db8bf5896c2424895c2420894424283b4424480f8d9dfcffff33c08944241485c90f8ea60000008b5424688b7c24408beb8d34968b54246403dfeb0a8da424000000008d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb604068d0c103bf97f422bc23bf87c3c8b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424240374244c8b44242840035c245089742424e924ffffff8b7c24108b6c241c8b44244c8b5c24608b4c24444703e8897c2410896c241c3bfb0f8cf3feffff8b7c24688b6c24584f897c24683b7c24540f8dc5feffff8b4424345fc700ffffffff8b4424345e5dc700ffffffffb85ff0ffff5b83c420c3,4c894c24204c89442418488954241048894c24085355565741544155415641574883ec188b8424c80000004d8bd94d8bd0488bda83f8010f85b3010000448b8c24a800000044890c24443b8c24b80000000f8d66010000448bac24900000008b9424c0000000448b8424b00000008bbc2480000000448b9424a0000000418bcd410fafc9894c24040f1f84000000000044899424c8000000453bd00f8dfb000000468d2495000000000f1f800000000033ed448bf933f6660f1f8400000000003bac24880000000f8d1701000033db85ff7e7e458bf4448bce442bf64503f7904d63c14d03c34180780300745a450fb65002438d040e4c63d84c035c2470410fb64b028d0411443bd07f572bca443bd17c50410fb64b01450fb650018d0411443bd07f3e2bca443bd17c37410fb60b450fb6108d0411443bd07f272bca443bd17c204c8b5c2478ffc34183c1043bdf7c8fffc54503fd03b42498000000e95effffff8b8424c8000000448b8424b00000008b4c24044c8b5c2478ffc04183c404898424c8000000413bc00f8c20ffffff448b0c24448b9424a000000041ffc14103cd44890c24894c2404443b8c24b80000000f8cd8feffff488b5c2468488b4c2460b85ff0ffffc701ffffffffc703ffffffff4883c418415f415e415d415c5f5e5d5bc38b8424c8000000e9860b000083f8020f858c010000448b8c24b800000041ffc944890c24443b8c24a80000007cab448bac2490000000448b8424c00000008b9424b00000008bbc2480000000448b9424a0000000418bc9410fafcd418bc5894c2404f7d8894424080f1f400044899424c8000000443bd20f8d02010000468d2495000000000f1f80000000004533f6448bf933f60f1f840000000000443bb424880000000f8d56ffffff33db85ff0f8e81000000418bec448bd62bee4103ef4963d24903d3807a03007460440fb64a02418d042a4c63d84c035c2470410fb64b02428d0401443bc87f5d412bc8443bc97c55410fb64b01440fb64a01428d0401443bc87f42412bc8443bc97c3a410fb60b440fb60a428d0401443bc87f29412bc8443bc97c214c8b5c2478ffc34183c2043bdf7c8a41ffc64503fd03b42498000000e955ffffff8b8424c80000008b9424b00000008b4c24044c8b5c2478ffc04183c404898424c80000003bc20f8c19ffffff448b0c24448b9424a0000000034c240841ffc9894c240444890c24443b8c24a80000000f8dd0feffffe933feffff83f8030f85c4010000448b8c24b800000041ffc944898c24c8000000443b8c24a80000000f8c0efeffff8b842490000000448b9c24b0000000448b8424c00000008bbc248000000041ffcb418bc98bd044895c24080fafc8f7da890c24895424048b9424a0000000448b542404458beb443bda0f8c13010000468d249d0000000066660f1f84000000000033ed448bf933f6660f1f8400000000003bac24880000000f8d0801000033db85ff0f8e96000000488b4c2478458bf4448bd6442bf64503f70f1f8400000000004963d24803d1807a03007460440fb64a02438d04164c63d84c035c2470410fb64b02428d0401443bc87f63412bc8443bc97c5b410fb64b01440fb64a01428d0401443bc87f48412bc8443bc97c40410fb60b440fb60a428d0401443bc87f2f412bc8443bc97c27488b4c2478ffc34183c2043bdf7c8a8b842490000000ffc54403f803b42498000000e942ffffff8b9424a00000008b8424900000008b0c2441ffcd4183ec04443bea0f8d11ffffff448b8c24c8000000448b542404448b5c240841ffc94103ca44898c24c8000000890c24443b8c24a80000000f8dc2feffffe983fcffff488b4c24608b8424c8000000448929488b4c2468890133c0e981fcffff83f8040f857f010000448b8c24a800000044890c24443b8c24b80000000f8d48fcffff448bac2490000000448b9424b00000008b9424c0000000448b8424a00000008bbc248000000041ffca418bcd4489542408410fafc9894c2404669044899424c8000000453bd00f8cf8000000468d2495000000000f1f800000000033ed448bf933f6660f1f8400000000003bac24880000000f8df7fbffff33db85ff7e7e458bf4448bce442bf64503f7904d63c14d03c34180780300745a450fb65002438d040e4c63d84c035c2470410fb64b028d0411443bd07f572bca443bd17c50410fb64b01450fb650018d0411443bd07f3e2bca443bd17c37410fb60b450fb6108d0411443bd07f272bca443bd17c204c8b5c2478ffc34183c1043bdf7c8fffc54503fd03b42498000000e95effffff8b8424c8000000448b8424a00000008b4c24044c8b5c2478ffc84183ec04898424c8000000413bc00f8d20ffffff448b0c24448b54240841ffc14103cd44890c24894c2404443b8c24b80000000f8cdbfeffffe9defaffff83f8050f85ab010000448b8424a000000044890424443b8424b00000000f8dc0faffff8b9424c0000000448bac2498000000448ba424900000008bbc2480000000448b8c24a8000000428d0c8500000000898c24c800000044894c2404443b8c24b80000000f8d09010000418bc4410fafc18944240833ed448bf833f6660f1f8400000000003bac24880000000f8d0501000033db85ff0f8e87000000448bf1448bce442bf64503f74d63c14d03c34180780300745d438d040e4c63d84d03da450fb65002410fb64b028d0411443bd07f5f2bca443bd17c58410fb64b01450fb650018d0411443bd07f462bca443bd17c3f410fb60b450fb6108d0411443bd07f2f2bca443bd17c284c8b5c24784c8b542470ffc34183c1043bdf7c8c8b8c24c8000000ffc54503fc4103f5e955ffffff448b4424048b4424088b8c24c80000004c8b5c24784c8b54247041ffc04103c4448944240489442408443b8424b80000000f8c0effffff448b0424448b8c24a800000041ffc083c10444890424898c24c8000000443b8424b00000000f8cc5feffffe946f9ffff488b4c24608b042489018b442404488b4c2468890133c0e945f9ffff83f8060f85aa010000448b8c24a000000044894c2404443b8c24b00000000f8d0bf9ffff8b8424b8000000448b8424c0000000448ba424900000008bbc2480000000428d0c8d00000000ffc88944240c898c24c80000006666660f1f840000000000448be83b8424a80000000f8c02010000410fafc4418bd4f7da891424894424084533f6448bf833f60f1f840000000000443bb424880000000f8df900000033db85ff0f8e870000008be9448bd62bee4103ef4963d24903d3807a03007460440fb64a02418d042a4c63d84c035c2470410fb64b02428d0401443bc87f64412bc8443bc97c5c410fb64b01440fb64a01428d0401443bc87f49412bc8443bc97c41410fb60b440fb60a428d0401443bc87f30412bc8443bc97c284c8b5c2478ffc34183c2043bdf7c8a8b8c24c800000041ffc64503fc03b42498000000e94fffffff8b4424088b8c24c80000004c8b5c247803042441ffcd89442408443bac24a80000000f8d17ffffff448b4c24048b44240c41ffc183c10444894c2404898c24c8000000443b8c24b00000000f8ccefeffffe991f7ffff488b4c24608b4424048901488b4c246833c0448929e992f7ffff83f8070f858d010000448b8c24b000000041ffc944894c2404443b8c24a00000000f8c55f7ffff8b8424b8000000448b8424c0000000448ba424900000008bbc2480000000428d0c8d00000000ffc8890424898c24c8000000660f1f440000448be83b8424a80000000f8c02010000410fafc4418bd4f7da8954240c8944240833ed448bf833f60f1f8400000000003bac24880000000f8d4affffff33db85ff0f8e89000000448bf1448bd6442bf64503f74963d24903d3807a03007460440fb64a02438d04164c63d84c035c2470410fb64b02428d0401443bc87f63412bc8443bc97c5b410fb64b01440fb64a01428d0401443bc87f48412bc8443bc97c40410fb60b440fb60a428d0401443bc87f2f412bc8443bc97c274c8b5c2478ffc34183c2043bdf7c8a8b8c24c8000000ffc54503fc03b42498000000e94fffffff8b4424088b8c24c80000004c8b5c24780344240c41ffcd89442408443bac24a80000000f8d17ffffff448b4c24048b042441ffc983e90444894c2404898c24c8000000443b8c24a00000000f8dcefeffffe9e1f5ffff83f8080f85ddf5ffff448b8424b000000041ffc84489442404443b8424a00000000f8cbff5ffff8b9424c0000000448bac2498000000448ba424900000008bbc2480000000448b8c24a8000000428d0c8500000000898c24c800000044890c24443b8c24b80000000f8d08010000418bc4410fafc18944240833ed448bf833f6660f1f8400000000003bac24880000000f8d0501000033db85ff0f8e87000000448bf1448bce442bf64503f74d63c14d03c34180780300745d438d040e4c63d84d03da450fb65002410fb64b028d0411443bd07f5f2bca443bd17c58410fb64b01450fb650018d0411443bd07f462bca443bd17c3f410fb603450fb6108d0c10443bd17f2f2bc2443bd07c284c8b5c24784c8b542470ffc34183c1043bdf7c8c8b8c24c8000000ffc54503fc4103f5e955ffffff448b04248b4424088b8c24c80000004c8b5c24784c8b54247041ffc04103c44489042489442408443b8424b80000000f8c10ffffff448b442404448b8c24a800000041ffc883e9044489442404898c24c8000000443b8424a00000000f8dc6feffffe946f4ffff8b442404488b4c246089018b0424488b4c2468890133c0e945f4ffff"
                              if ( A_PtrSize == 8 )
                                    MCode_ImageSearch := SubStr(MCode_ImageSearch,InStr(MCode_ImageSearch,",")+1)
                              else
                                    MCode_ImageSearch := SubStr(MCode_ImageSearch,1,InStr(MCode_ImageSearch,",")-1)
                              VarSetCapacity(ImageSearchMCode, LEN := StrLen(MCode_ImageSearch)//2, 0)
                              Loop, %LEN%
                                    NumPut("0x" . SubStr(MCode_ImageSearch,(2*A_Index)-1,2), ImageSearchMCode, A_Index-1, "uchar")
                              MCode_ImageSearch := ""
                              DllCall("VirtualProtect", Ptr,&ImageSearchMCode, Ptr,VarSetCapacity(ImageSearchMCode), "uint",0x40, PtrA,0)
                        return
                  }
                  EncodeBitmapTo64string(pBitmap){
                        DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
                        VarSetCapacity(ci, nSize)
                        DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
                        pMCodec := &ci+416
                        DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
                        DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pMCodec, "uint", 0)
                        DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
                        pData := DllCall("GlobalLock", "ptr",hData, "uptr")
                        nSize := DllCall("GlobalSize", "uint",pData)
                        VarSetCapacity(Bin, nSize, 0)
                        DllCall("RtlMoveMemory", "ptr",&Bin , "ptr",pData , "uint",nSize)
                        DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
                        DllCall("GlobalUnlock", "ptr",hData)
                        DllCall("GlobalFree", "ptr",hData)
                        DllCall("Crypt32.dll\CryptBinaryToString", "ptr",& Bin, "uint",nSize, "uint",0x01, "ptr",0, "uint*",base64Length)
                        VarSetCapacity(base64, base64Length*2, 0)
                        DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",&base64, "uint*",base64Length), Bin := ""
                        VarSetCapacity(Bin, 0)
                        VarSetCapacity(base64, -1)
                        return base64
                  }
                  BitmapFromBase64(BitLock, Type, B64){
                        VarSetCapacity(B64Len, 0)
                        , DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", StrLen(B64), "UInt", 0x01, "Ptr", 0, "UIntP", B64Len, "Ptr", 0, "Ptr", 0)
                        , VarSetCapacity(B64Dec, B64Len, 0)
                        , DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", StrLen(B64), "UInt", 0x01, "Ptr", &B64Dec, "UIntP", B64Len, "Ptr", 0, "Ptr", 0)
                        , pStream := DllCall("Shlwapi.dll\SHCreateMemStream", "Ptr", &B64Dec, "UInt", B64Len, "UPtr")
                        , DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "PtrP", pBitmap)
                        , ObjRelease(pStream)
                        if Type
                              DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "UInt", pBitmap, "UInt*", hBitmap, "Int", 0XFFFFFFFF)
                        , Gdip_DisposeImage(pBitmap)
                        if (BitLock && !Type) {
                              Gdip_GetImageDimensions(pBitmap,nWidth,nHeight)
                              , Gdip_LockBits(pBitmap,0,0,nWidth,nHeight,nStride,nScan,nBitmapData)
                        return Object := {Stride: nStride,Scan: nScan,Width: nWidth,Height: nHeight, Bitmap: (Type ? hBitmap : pBitmap)}
                  } Else
                  return Type ? hBitmap : pBitmap
            }
            PrintScreenData(){
                  If (ini.Compatibility.2 = 1)
                        PrintScreenPW()
                  Else
                        PrintScreenDC()
            }
            PrintScreenPW(){
                  static PWWinID, WinTitle, WinX, WinY, WinW, WinH, ClientWidth, ClientHeight, Area, hBitmap
                  if ( !WinID && FindProcessesID ) {
                        WinID := WinExist("ahk_ID " FindProcessesID)
                        PWWinID := WinID
                        WinExist( GameInfo )
                        WinGetClass, WindowClass
                        WinGet , WinExE, ProcessName
                        Process, Exist , %WinExE%
                        WinGetTitle, WindowTitle
                        WindowInfo:={ID: WinID, Title: WindowTitle, Class: WindowClass, IDClassNN: WinID, Exe: WinExE, pID: errorlevel}
                        Area := DllCall("CreateCompatibleDC","Ptr",0,"Ptr")
                  }
                  if !WinExist( "ahk_id" PWWinID ) {
                        Macro := 0
                        SetTimer, Button2, On
                        MsgBox, % "Game Not Found"
                        Return
                  }
                  WinGetTitle, WindowTitle
                  WinGetPos, GetWinX, GetWinY, GetWinW, GetWinH
                  if (WindowTitle != WinTitle || GetWinX != WinX || GetWinY != WinY || GetWinW != WinW || GetWinH != WinH ) {
                        If (WindowTitle != WinTitle){
                              NewName := StrSplit(WindowTitle, "-")
                              If (NewName.2)
                                    NewName := Trim(NewName.2)
                              Else
                                    NewName := WindowTitle
                              GuiControl, Main:, WindowTitle, %NewName%
                              WindowInfo.Title := NewName
                        }
                        WinTitle:=WindowTitle, WinX:=GetWinX, WinY:=GetWinY, WinW:=GetWinW, WinH:=GetWinH
                        VarSetCapacity(rect,16), DllCall("GetClientRect","Ptr",PWWinID,"Ptr",&rect), ClientWidth := NumGet(rect,8,"int"), ClientHeight := NumGet(rect,12,"int")
                        DllCall("DeleteObject", "Ptr",hBitmap),VarSetCapacity(bi,40,0),NumPut(40,bi,0,"int"),NumPut(ClientWidth,bi,4,"int"),NumPut(-ClientHeight,bi,8,"int"),NumPut(1,bi,12,"short"),NumPut(32,bi,14,"short")
                        hBitmap := DllCall("CreateDIBSection","Ptr",0,"Ptr",&bi,"int",0,"Ptr*",PrintScan,"Ptr",0,"int",0,"Ptr")
                        DllCall("SelectObject","Ptr",Area,"Ptr",hBitmap,"Ptr")
                        ScanBit := PrintScan
                        StrideBit := ClientWidth*4
                        PNGScanWidth := ClientWidth
                        PNGScanHeight := ClientHeight
                        WindowInfo.HBITMAP:= hBitmap
                        WindowInfo.Window :={x: WinX , y: WinY, w: WinW, h: WinH}
                        WindowInfo.Client :={w: ClientWidth, h: ClientHeight}
                        WindowInfo.ClassNN:={x: Round((WinW-ClientWidth)/2), y: Round(WinH-ClientHeight-(WinW-ClientWidth)/2), w: ClientWidth, h: ClientHeight}
                  }
                  DllCall("PrintWindow","Ptr",PWWinID,"Ptr",Area,"int",1)
                  Return
            }
            PrintScreenDC(){
                  static DCWinID, WinTitle, WinX, WinY, WinW, WinH, ClientWidth, ClientHeight, Area, hBitmap
                  if ( !WinID && FindProcessesID ) {
                        WinID := WinExist("ahk_ID " FindProcessesID)
                        DCWinID := WinID
                        WinExist( GameInfo )
                        WinGetClass, WindowClass
                        WinGet , WinExE, ProcessName
                        Process, Exist , %WinExE%
                        WinGetTitle, WindowTitle
                        WindowInfo:={ID: WinID, Title: WindowTitle, Class: WindowClass, IDClassNN: WinID, Exe: WinExE, pID: errorlevel}
                        Area := DllCall("CreateCompatibleDC","Ptr",0,"Ptr")
                  }
                  if !WinExist( "ahk_id" DCWinID ) {
                        Macro := 0
                        SetTimer, Button2, On
                        MsgBox, % "Game Not Found"
                        Return
                  }
                  WinGetTitle, WindowTitle
                  WinGetPos, GetWinX, GetWinY, GetWinW, GetWinH
                  if (WindowTitle != WinTitle || GetWinX != WinX || GetWinY != WinY || GetWinW != WinW || GetWinH != WinH ) {
                        If (WindowTitle != WinTitle){
                              NewName := StrSplit(WindowTitle, "-")
                              If (NewName.2)
                                    NewName := Trim(NewName.2)
                              Else
                                    NewName := WindowTitle
                              GuiControl, Main:, WindowTitle, %NewName%
                              WindowInfo.Title := NewName
                        }
                        WinTitle:=WindowTitle, WinX:=GetWinX, WinY:=GetWinY, WinW:=GetWinW, WinH:=GetWinH
                        VarSetCapacity(rect,16), DllCall("GetClientRect","Ptr",DCWinID,"Ptr",&rect), ClientWidth := NumGet(rect,8,"int"), ClientHeight := NumGet(rect,12,"int")
                        DllCall("DeleteObject", "Ptr",hBitmap),VarSetCapacity(bi,40,0),NumPut(40,bi,0,"int"),NumPut(ClientWidth,bi,4,"int"),NumPut(-ClientHeight,bi,8,"int"),NumPut(1,bi,12,"short"),NumPut(32,bi,14,"short")
                        hBitmap := DllCall("CreateDIBSection","Ptr",0,"Ptr",&bi,"int",0,"Ptr*",PrintScan,"Ptr",0,"int",0,"Ptr")
                        DllCall("SelectObject","Ptr",Area,"Ptr",hBitmap,"Ptr")
                        ScanBit := PrintScan
                        StrideBit := ClientWidth*4
                        PNGScanWidth := ClientWidth
                        PNGScanHeight := ClientHeight
                        WindowInfo.HBITMAP:= hBitmap
                        WindowInfo.Window :={x: WinX , y: WinY, w: WinW, h: WinH}
                        WindowInfo.Client :={w: ClientWidth, h: ClientHeight}
                        WindowInfo.ClassNN:={x: Round((WinW-ClientWidth)/2), y: Round(WinH-ClientHeight-(WinW-ClientWidth)/2), w: ClientWidth, h: ClientHeight}
                  }
                  hDC := DllCall("GetDC","Ptr",DCWinID,"Ptr",0,"int",0)
                  DllCall(ProcBitBlt,"Ptr",Area,"int",0,"int",0,"int",ClientWidth,"int",ClientHeight,"Ptr",hDC,"int",0,"int",0,"uint",0xCC0020)
                  DllCall("DeleteDC","Ptr",hDC)
                  Return
            }
            ResizeBitmap(pBitmap, givenW, givenH,InterpolationMode:=""){
                  Gdip_GetImageDimensions(pBitmap, Width, Height)
                  ResizeBitmap := Gdip_CreateBitmap(givenW, givenH)
                  G := Gdip_GraphicsFromImage(ResizeBitmap, InterpolationMode)
                  Gdip_DrawImageRect(G, pBitmap, 0, 0, givenW, givenH)
                  Gdip_DeleteGraphics(G)
                  Gdip_SaveBitmapToFile(ResizeBitmap, "Out.png")
                  Return ResizeBitmap
            }
            Gdip_CropImage(pBitmap, x, y, w, h) {
                  pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
                  Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
                  Gdip_DeleteGraphics(G2)
                  return pBitmap2
            }
            CorToDec(hex,ByRef Out:=""){
                  hex := "FF" SubStr(hex, 2)
                  , VarSetCapacity(Out, 66, 0)
                  , val := DllCall("msvcrt.dll\_wcstoui64", "Str", hex, "UInt", 0, "UInt", 16, "CDECL Int64")
                  , DllCall("msvcrt.dll\_i64tow", "Int64", val, "Str", Out, "UInt", 10, "CDECL")
                  return Out
            }
            GetColorDecimal(X, Y){
                  If ( ScanBit && StrideBit && X>=0 && Y>=0 && X < PNGScanWidth && Y < PNGScanHeight )
                        return NumGet(ScanBit + 0, X * 4 + Y * StrideBit, "UInt")
            }
            GetColorHex(X, Y){
                  If ( ScanBit && StrideBit && X>=0 && Y>=0 && X < PNGScanWidth && Y < PNGScanHeight )
                        return "#" SubStr(Format("{1:#x}", NumGet(ScanBit + 0, X * 4 + Y * StrideBit, "UInt")), 5)
            }
            GetColorDiff(x, y, CorArry){
                  If ( ScanBit && StrideBit && X>=0 && Y>=0 && X < PNGScanWidth && Y < PNGScanHeight ){
                        Color := Format("0x{:06X}", NumGet(ScanBit + 0, X * 4 + Y * StrideBit, "UInt") & 0xFFFFFF)
                        R := (0xff0000 & Color) >> 16, G := (0x00ff00 & Color) >> 8, B := 0x0000ff & Color
                        CorDiff := sqrt((CorArry.R - R)**2+(CorArry.G - G)**2+(CorArry.B - B)**2)
                        Return CorDiff
                  }
            }
            LockedBitsSearch(hStride,hScan,nStride,nScan,nWidth,nHeight,ByRef x:="",ByRef y:="",slx1:=0,sly1:=0,slx2:=0,sly2:=0,Variation:=0,SearchDirection:=1){
                  If ( slx2 < slx1 )
                        return -3001
                  If ( sly2 < sly1 )
                        return -3002
                  If ( slx2-slx1 == 0 )
                        return -3005
                  If ( sly2-sly1 == 0 )
                        return -3006
                  E := DllCall( &ImageSearchMCode,"int*",x,"int*",y,Ptr,hScan, Ptr,nScan,"int",nWidth,"int",nHeight,"int",hStride,"int",nStride,"int",slx1,"int",sly1,"int",slx2,"int",sly2,"int",Variation,"int",SearchDirection,"cdecl int")
                  Return ( E == "" ? -3007 : E )
            }
            MultiLockedBitsSearch(hStride,hScan,nStride,nScan,nWidth,nHeight,ByRef OutputList="",OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,SearchDirection=1,Instances=0,LineDelim="`n",CoordDelim=","){
                  OutputList := ""
                  OutputCount := !Instances
                  InnerX1 := OuterX1 , InnerY1 := OuterY1
                  InnerX2 := OuterX2 , InnerY2 := OuterY2
                  iX := 1, stepX := 1, iY := 1, stepY := 1
                  Modulo := Mod(SearchDirection,4)
                  If ( Modulo > 1 )
                        iY := 2, stepY := 0
                  If !Mod(Modulo,3)
                        iX := 2, stepX := 0
                  P := "Y", N := "X"
                  If ( SearchDirection > 4 )
                        P := "X", N := "Y"
                  iP := i%P%, iN := i%N%
                  While (!(OutputCount == Instances) && (0 == LockedBitsSearch(hStride,hScan,nStride,nScan,nWidth,nHeight,FoundX,FoundY,OuterX1,OuterY1,OuterX2,OuterY2,Variation,SearchDirection))){
                        OutputCount++
                        OutputList .= LineDelim FoundX CoordDelim FoundY
                        Outer%P%%iP% := Found%P%+step%P%
                        Inner%N%%iN% := Found%N%+step%N%
                        Inner%P%1 := Found%P%
                        Inner%P%2 := Found%P%+1
                        While (!(OutputCount == Instances) && (0 == LockedBitsSearch(hStride,hScan,nStride,nScan,nWidth,nHeight,FoundX,FoundY,InnerX1,InnerY1,InnerX2,InnerY2,Variation,SearchDirection))){
                              OutputCount++
                              OutputList .= LineDelim FoundX CoordDelim FoundY
                              Inner%N%%iN% := Found%N%+step%N%
                        }
                  }
                  OutputList := SubStr(OutputList,1+StrLen(LineDelim))
                  OutputCount -= !Instances
                  Return OutputCount
            }
            ObjectAdd(Object, Add){
                  for k, v in Add
                        Object[k] := v
            }
            range(start, stop:="", step:=1){
                  static range := { _NewEnum: Func("_RangeNewEnum") }
                  if !step
                        throw "range(): Parameter 'step' must not be 0 or blank"
                  if (stop == "")
                        stop := start, start := 0
                  if (step > 0 ? start < stop : start > stop)
                        return { base: range, start: start, stop: stop, step: step }
            }
            _RangeNewEnum(r){
                  static enum := { "Next": Func("_RangeEnumNext") }
                  return { base: enum, r: r, i: 0 }
            }
            _RangeEnumNext(enum, ByRef k, ByRef v:=""){
                  stop := enum.r.stop, step := enum.r.step, k := enum.r.start + step*enum.i
                  if (ret := step > 0 ? k < stop : k > stop)
                        enum.i += 1
                  return ret
            }
            SearchPNG(ND,x,y,sx,sy,Tole:=0,ByRef Found:="",Mode:=1,Draw:=0,AreaDraw:=0){
                  If !( ScanBit && ND.Scan )
                        Return Found:=-1001
                  If Tole not between 0 and 255
                        return Found:=-1002
                  If ( ( x < 0 ) || ( y < 0 ) )
                        return Found:=-1003
                  If Mode not between 1 and 8
                        return Found:=-1004
                  OutX := ( !sx ? PNGScanWidth - ND.Width +1 : sx - ND.Width +1 )
                  OutY := ( !sy ? PNGScanHeight - ND.Height+1 : sy - ND.Height+1 )
                  If ( OutX > (sx-ND.Width+1) )
                        return Found:=-3003
                  If ( OutY > (sy-ND.Height+1) )
                        return Found:=-3004
                  Info := LockedBitsSearch(StrideBit,ScanBit,ND.Stride,ND.Scan,ND.Width,ND.Height,FoundX,FoundY,x,y,OutX,OutY,Tole,Mode)
                  if (AreaDraw = 1)
                        DrawRectangle(x+WindowInfo.ClassNN.x,y+WindowInfo.ClassNN.y,sx-x,sy-y,"0xffffffff")
                  if (Info == 0 && Draw = 1){
                        DrawRectangle(FoundX+WindowInfo.ClassNN.x, FoundY+WindowInfo.ClassNN.y, ND.Width, ND.Height ,"0xffFF0000")
                        DrawRectangle(FoundX+WindowInfo.ClassNN.x, FoundY+WindowInfo.ClassNN.y, 1, 1 ,"0xffffff00")
                  }
                  if (Info == 0)
                        Found := {1: 0, 2: FoundX, 3: FoundY}
                  else
                        Found := {1: 1}
                  return
            }
            MultiSearchPNG(ND,x,y,sx,sy,Tole:=0,ByRef Found:="",Mode:=1,Draw:=0,AreaDraw:=0){
                  If !( ScanBit && ND.Scan )
                        Return Found:=-1001
                  If Tole not between 0 and 255
                        return Found:=-1002
                  If ( ( x < 0 ) || ( y < 0 ) )
                        return Found:=-1003
                  If Mode not between 1 and 8
                        return Found:=-1004
                  OutX := ( !sx ? PNGScanWidth - ND.Width +1 : sx - ND.Width +1 )
                  OutY := ( !sy ? PNGScanHeight - ND.Height+1 : sy - ND.Height+1 )
                  If ( OutX > (sx-ND.Width+1) )
                        return Found:=-3003
                  If ( OutY > (sy-ND.Height+1) )
                        return Found:=-3004
                  Info := MultiSearchHP(StrideBit,ScanBit,ND.Stride,ND.Scan,ND.Width,ND.Height,Found,x,y,OutX,OutY,Tole,Mode)
                  if (Info != 0)
                        Found := {1: 1}
                  return
            }
            MultiSearchHP(hStride,hScan,nStride,nScan,nWidth,nHeight,ByRef OutputList="",OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,SearchDirection=1){
                  OutputList := []
                  OutputCount := 0
                  InnerX1 := OuterX1 , InnerY1 := OuterY1
                  InnerX2 := OuterX2 , InnerY2 := OuterY2
                  iX := 1, stepX := 27, iY := 1, stepY := 4
                  Modulo := Mod(SearchDirection,4)
                  If ( Modulo > 1 )
                        iY := 2, stepY := 0
                  If !Mod(Modulo,3)
                        iX := 2, stepX := 0
                  P := "Y", N := "X"
                  If ( SearchDirection > 4 )
                        P := "X", N := "Y"
                  iP := i%P%, iN := i%N%
                  While (0 == LockedBitsSearch(hStride,hScan,nStride,nScan,nWidth,nHeight,FoundX,FoundY,OuterX1,OuterY1,OuterX2,OuterY2,Variation,SearchDirection)){
                        if (GetColorDecimal(FoundX+1, FoundY+1) != "4278190080"){
                              OutputCount++
                              OutputList[OutputCount] := {x:FoundX, y:FoundY}
                              Outer%P%%iP% := Found%P%+step%P%
                              Inner%N%%iN% := Found%N%+step%N%
                        } Else {
                              Outer%P%%iP% := Found%P%+1
                              Inner%N%%iN% := Found%N%+1
                        }
                        Inner%P%1 := Found%P%
                        Inner%P%2 := Found%P%+1
                        While (0 == LockedBitsSearch(hStride,hScan,nStride,nScan,nWidth,nHeight,FoundX,FoundY,InnerX1,InnerY1,InnerX2,InnerY2,Variation,SearchDirection)){
                              if (GetColorDecimal(FoundX+1, FoundY+1) != "4278190080"){
                                    OutputCount++
                                    OutputList[OutputCount] := {x:FoundX, y:FoundY}
                              }
                              Inner%N%%iN% := Found%N%+step%N%
                        }
                  }
                  Return (OutputCount = 0 ? 1 : 0)
            }
            DrawCircle(x, y, Cor:=0xffff0000){
                  if (WindowInfo.Title = "Tibia - Dinos")
                        WAx := WindowInfo.Window.x+WindowInfo.ClassNN.x, WAy := WindowInfo.Window.y+WindowInfo.ClassNN.y
                  Else
                        WAx := WindowInfo.Window.x, WAy := WindowInfo.Window.y
                  pBrush := Gdip_BrushCreateSolid(0xff000000)
                  Gdip_FillEllipse(gDrawCircle, pBrush, x-3, y-3, 4, 4)
                  Gdip_DeleteBrush(pBrush)
                  pBrush := Gdip_BrushCreateSolid(Cor)
                  Gdip_FillEllipse(gDrawCircle, pBrush, x-2, y-2, 2, 2)
                  Gdip_DeleteBrush(pBrush)
                  UpdateLayeredWindow(InDraw, hdcDrawCircle, WAx, WAy, WindowInfo.Window.w, WindowInfo.Window.h)
                  Return
            }
            DrawRectangle(x, y, w, h, Cor:=0xffff0000){
                  if (WindowInfo.Title = "Tibia")
                        WAx := WindowInfo.Window.x+WindowInfo.ClassNN.x, WAy := WindowInfo.Window.y+WindowInfo.ClassNN.y
                  Else
                        WAx := WindowInfo.Window.x, WAy := WindowInfo.Window.y
                  pPen := Gdip_CreatePen(Cor, 1)
                  Gdip_DrawRectangle(gDrawCircle, pPen, x-1, y-1, w+1, h+1)
                  Gdip_DeletePen(pPen)
                  UpdateLayeredWindow(InDraw, hdcDrawCircle, WAx, WAy, WindowInfo.Window.w, WindowInfo.Window.h)
                  Return
            }
            ControlDoubleClick(X, Y, windowID="", WinText="", ExcludeTitle="", ExcludeText=""){
                  WinTitle := "ahk_id " windowID
                  hwnd:=ControlFromPoint(X, Y, WinTitle, WinText, cX, cY, ExcludeTitle, ExcludeText)
                  PostMessage, 0x201, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd%
                  PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd%
                  PostMessage, 0x203, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd%
                  PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd%
            }
            ControlFromPoint(X, Y, WinTitle="", WinText="", ByRef cX="", ByRef cY="", ExcludeTitle="", ExcludeText=""){
                  static EnumChildFindPointProc=0
                  if !EnumChildFindPointProc
                        EnumChildFindPointProc := RegisterCallback("EnumChildFindPoint","Fast")
                  if !(target_window := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
                        return false
                  VarSetCapacity(rect, 16)
                  DllCall("GetWindowRect","uint",target_window,"uint",&rect)
                  VarSetCapacity(pah, 36, 0)
                  NumPut(X + NumGet(rect,0,"int"), pah,0,"int")
                  NumPut(Y + NumGet(rect,4,"int"), pah,4,"int")
                  DllCall("EnumChildWindows","uint",target_window,"uint",EnumChildFindPointProc,"uint",&pah)
                  control_window := NumGet(pah,24) ? NumGet(pah,24) : target_window
                  DllCall("ScreenToClient","uint",control_window,"uint",&pah)
                  cX:=NumGet(pah,0,"int"), cY:=NumGet(pah,4,"int")
                  return control_window
            }
            EnumChildFindPoint(aWnd, lParam){
                  if !DllCall("IsWindowVisible","uint",aWnd)
                        return true
                  VarSetCapacity(rect, 16)
                  if !DllCall("GetWindowRect","uint",aWnd,"uint",&rect)
                        return true
                  pt_x:=NumGet(lParam+0,0,"int"), pt_y:=NumGet(lParam+0,4,"int")
                  rect_left:=NumGet(rect,0,"int"), rect_right:=NumGet(rect,8,"int")
                  rect_top:=NumGet(rect,4,"int"), rect_bottom:=NumGet(rect,12,"int")
                  if (pt_x >= rect_left && pt_x <= rect_right && pt_y >= rect_top && pt_y <= rect_bottom)
                  {
                        center_x := rect_left + (rect_right - rect_left) / 2
                        center_y := rect_top + (rect_bottom - rect_top) / 2
                        distance := Sqrt((pt_x-center_x)**2 + (pt_y-center_y)**2)
                        update_it := !NumGet(lParam+24)
                        if (!update_it)
                        {
                              rect_found_left:=NumGet(lParam+8,0,"int"), rect_found_right:=NumGet(lParam+8,8,"int")
                              rect_found_top:=NumGet(lParam+8,4,"int"), rect_found_bottom:=NumGet(lParam+8,12,"int")
                              if (rect_left >= rect_found_left && rect_right <= rect_found_right
                                    && rect_top >= rect_found_top && rect_bottom <= rect_found_bottom)
                              update_it := true
                              else if (distance < NumGet(lParam+28,0,"double")
                                    && (rect_found_left < rect_left || rect_found_right > rect_right
                              || rect_found_top < rect_top || rect_found_bottom > rect_bottom))
                              update_it := true
                        }
                        if (update_it)
                        {
                              NumPut(aWnd, lParam+24)
                              DllCall("RtlMoveMemory","uint",lParam+8,"uint",&rect,"uint",16)
                              NumPut(distance, lParam+28, 0, "double")
                        }
                  }
                  return true
            }
            SaveInI(id){
                  try {
                        Loop % id.Length(){
                              arrayS.= id[A_Index] . "|"
                        }
                        StringTrimRight, arrayS, arrayS, 1
                        StringReplace, Save, % id.1, %A_SPACE%,, All
                        iniwrite, %arrayS%, %settingsFile%, Options, %Save%
                  } catch e {
                        MsgBox, 4112, Error - SaveInI, % e
                  }
            }
            GetHDSerial(){
                  try {
                        static HDD := []
                        for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_DiskDrive") {
                              HDD[A_Index, "Model"] := objItem.Model
                              HDD[A_Index, "Name"] := objItem.Name
                              HDD[A_Index, "SerialNumber"] := objItem.SerialNumber
                        }
                        return HDD
                  } catch e {
                        MsgBox, 4112, Error - GetHDSerial, % e
                  }
            }
            GetProcessorID(){
                  try {
                        objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
                        WQLQuery = Select * From Win32_Processor
                        colCPU := objWMIService.ExecQuery(WQLQuery)._NewEnum
                        While colCPU[objCPU]
                        {
                        Return objCPU.ProcessorId
                  }
            } catch e {
                  MsgBox, 4112, Error - GetProcessorID, % e
            }
      }
      IsValidEmail(emailstr){
            static regex
            regex := "is)^(?:""(?:\\\\.|[^""])*""|[^@]+)@(?=[^()]*(?:\([^)]*\)"
            . "[^()]*)*\z)(?![^ ]* (?=[^)]+(?:\(|\z)))(?:(?:[a-z\d() ]+(?:[a-z\d() -]*[()a-"
            . "z\d])?\.)+[a-z\d]{2,6}|\[(?:(?:1?\d\d?|2[0-4]\d|25[0-4])\.){3}(?:1?\d\d?|"
            . "2[0-4]\d|25[0-4])\]) *\z"
            return RegExMatch(emailstr, regex) != 0
      }
      WinHTTP(Body) {
            WinHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            WinHTTP.Open("POST", Data.ServerIPPort)
            WinHTTP.SetRequestHeader("Content-Type", "application/json")
            WinHTTP.Send(Body)
            Return JsonToAHK(WinHTTP.ResponseText)
      }
      GetUserDetail(Info:="") {
            If (Data.Conditions.ProtectionZone == 1 || Data.Conditions.ProtectionZone == ""){
                  try {
                        Fieldemail := OBJGet.Config.Edit01
                        FieldPassword := OBJGet.Config.Edit02
                        idioma := OBJGet.Ling
                        UID := OBJGet.UID
                        Body = {"type": "GameLicenca","uID": "%UID%","email": "%Fieldemail%","password": "%FieldPassword%","game": "Tibia","idioma": "%idioma%"}
                        JsonCrack := "{""Type"":200,""idDiscord"":""496413537955086346"",""InviteCode"":""3f3cf3"",""FriendsInvited"":0,""RewardsToRedeem"":0,""licenseEndDate"":""CRACKED"",""customEndDate"":0,""mensagemPC"":"""",""Token"":""""}"
                        userData := JsonToAHK(JsonCrack)
                        If (userData.Type = 200){
                              If (Dados.userDataTempo != userData.licenseEndDate) {
                                    Dados.userDataTempo := userData.licenseEndDate
                                    Dados.catchMalandros := 0
                              }
                              userData.email := FieldEmail
                              userData.password := FieldPassword
                              Dados.Disconnect := 0
                              Dados.catchDisconnect := 0
                              if (Macro == 1)
                                    GuiControl, Main:, TimeRemaining, % " " userData.licenseEndDate
                        } else {
                              SetTimer, Button2, On
                              ImageSearchMCode := ""
                        ExitApp
                  }
            } catch e {
                  If (InStr(e.Message, "0x80072EE2") || InStr(e.Message, "0x80072EFD") || InStr(e.Message, "0x80072F78") || InStr(e.Message, "0x80072EFE")) {
                        if (Info == "Start"){
                              Dados.Loop := 0
                                    Dados.Disconnect := 1
                              ImageSearchMCode := ""
                              MsgBox, % e.Message "`nFile: " e.File
                        ExitApp
                  }
                  if (Dados.catchDisconnect > 4) {
                        Dados.Disconnect := 1
                  }
                  Dados.catchDisconnect++
                  Return
            }
            SetTimer, Button2, On
            Dados.Disconnect := 1
            ImageSearchMCode := ""
            MsgBox, % e.Message "`nFile: " e.File
            ExitApp
      }
}
This paste expires in <1 hour. Public IP access. Share whatever you see with others in seconds with Context.Terms of ServiceReport this