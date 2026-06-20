--[[
    Cascade UI Library - 100% Full Feature Master Integration Script
    (loadstring 동적 로드 방식)
    이 예제 스크립트는 모든 컴포넌트(20종), 다중 섹션/탭 구성, 동적 페이지 라우팅, 
    창 옵션 실시간 제어, 알림 시스템, 중첩 탭, 레이아웃 스택(VStack/HStack)을 포함합니다.
--]]

--// 1. loadstring을 사용하여 HeNo-exp 리포지토리의 Cascade UI 라이브러리를 동적으로 로드합니다.
local cascade = loadstring(game:HttpGet("https://raw.githubusercontent.com/HeNo-exp/library/refs/heads/main/Cascade-Sequoia-Library-Unminified.lua"))()

local services = {
	UserInputService = game:GetService("UserInputService"),
	GuiService = game:GetService("GuiService"),
	TweenService = game:GetService("TweenService"),
	HttpService = game:GetService("HttpService"),
}

--// 전역 설정 변수
local minimizeKeybind = Enum.KeyCode.RightControl

--// 공통 UI 도우미 함수 (타이틀/서브타이틀이 포함된 좌우 1행 레이아웃 생성)
local function titledRow(parent, title, subtitle)
	local row = parent:Row({
		SearchIndex = title,
	})

	row:Left():TitleStack({
		Title = title,
		Subtitle = subtitle,
	})

	return row
end

--// 2. 메인 애플리케이션 인스턴스 생성
local app = cascade.New({
	WindowPill = true,             -- 모바일 최소화 복구용 필(Pill) UI 활성화
	Theme = cascade.Themes.Dark,   -- 기본 다크 모드 테마 (cascade.Themes.Light 도 가능)
	Accent = cascade.Accents.Blue, -- 기본 포인트 색상 (cascade.Accents.Yellow, Green, Graphite 등 가능)
})

-- UI 상태 덤프 및 복사를 위한 녹화기 시작
local recorder = cascade.AppRecorder.new(app)
recorder:Start()

--// 3. 메인 윈도우 생성
local window = app:Window({
	Title = "Cascade Sequoia",
	Subtitle = "Full-Featured API Integration Studio",
	-- 모바일/PC 디바이스 환경에 따라 창 크기 동적 조절
	Size = services.UserInputService.TouchEnabled and UDim2.fromOffset(550, 325) or UDim2.fromOffset(850, 600),
	Draggable = true,
	Resizable = true,
	UIBlur = true,
})

-- 단축키 입력을 통한 창 최소화/최소화 해제 이벤트 처리
services.UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == minimizeKeybind and not gameProcessedEvent then
		window.Minimized = not window.Minimized
	end
end)

window.Destroying:Connect(function()
	print("Cascade 윈도우가 닫혔습니다. 녹화기를 중지합니다.")
	recorder:Stop()
end)


-- =========================================================================
-- [섹션 1] BASIC INPUTS (기본 조작 도구 접기 비활성화 섹션)
-- =========================================================================
local basicSection = window:Section({
	Title = "Basic Inputs",
	Disclosure = false, -- 접기 비활성화
})

----------------------------------------------------
-- [탭 1] Controls (토글, 텍스트 필드, 키바인드, 버튼, 컬러픽커)
-- ----------------------------------------------------
local controlsTab = basicSection:Tab({
	Selected = true,
	Title = "Controls",
	Icon = cascade.Symbols.switch2, 
})
local form1 = controlsTab:Form()

do -- Toggle (Off/On)
	local rowOff = titledRow(
		form1,
		"Toggle (Off)",
		"우수한 디자인의 토글 스위치입니다."
	)
	rowOff:Right():Toggle({
		Value = false,
		ValueChanged = function(self, value)
			print("Toggle Off -> Value:", value)
		end,
	})

	local rowOn = titledRow(form1, "Toggle (On)", "초기 활성화 상태(True)를 지닌 토글 스위치입니다.")
	rowOn:Right():Toggle({
		Value = true,
		ValueChanged = function(self, value)
			print("Toggle On -> Value:", value)
		end,
	})
end

do -- TextField (텍스트 필드)
	local row = titledRow(
		form1,
		"Text Field",
		"사용자가 텍스트를 기입하거나 수정할 수 있는 입력 창입니다."
	)
	row:Right():TextField({
		Value = "Label Text",
		Placeholder = "Type something...",
		ValueChanged = function(self, value)
			print("TextField Saved (Focus Lost):", value)
		end,
		TextChanged = function(self, value)
			print("TextField Real-time Typing:", value)
		end,
	})
end

do -- Keybind Field (단축키 필드)
	local row = titledRow(
		form1,
		"Keybind Field",
		"단축키로 설정할 키보드 입력을 바인드합니다."
	)
	row:Right():KeybindField({
		Value = Enum.KeyCode.E,
		ValueChanged = function(self, value)
			print("Keybind Saved to:", value)
		end,
		BindPressed = function(self, value, inputComplete, gameProcessedEvent)
			if not inputComplete or gameProcessedEvent then return end
			print("바인드된 키를 입력함! Key:", value)
		end,
	})
end

do -- Color Picker (네이티브 컬러 픽커)
	local row = titledRow(
		form1,
		"Color Picker",
		"정밀한 각도 보정이 적용된 RGB/알파 팝업 컬러 픽커입니다."
	)
	row:Right():ColorPicker({
		Title = "Choose Tint Color",
		Value = Color3.fromRGB(0, 122, 255),
		Transparency = 0.2, 
		ValueChanged = function(self, color, transparency)
			print("Color Picker Updated -> Color:", color, " | Transparency:", transparency)
		end,
	})
end

do -- Push Buttons (동작 버튼 3가지 형태)
	local row = titledRow(form1, "Push Buttons", "상태와 기능에 맞게 3가지 디자인을 제공하는 일반 버튼들입니다.")
	row:Right():Button({
		Label = "Primary",
		State = "Primary",
		Pushed = function(self) print("Primary Pushed") end,
	})
	row:Right():Button({
		Label = "Secondary",
		State = "Secondary",
		Pushed = function(self) print("Secondary Pushed") end,
	})
	row:Right():Button({
		Label = "Destructive",
		State = "Destructive",
		Pushed = function(self) print("Destructive Pushed") end,
	})
end

----------------------------------------------------
-- [탭 2] Adjusts (슬라이더, 기본 및 필드형 증감기)
-- ----------------------------------------------------
local adjustmentsTab = basicSection:Tab({
	Title = "Adjusts", 
	Icon = cascade.Symbols.sliderHorizontal3,
})
local form2 = adjustmentsTab:Form()

do -- Slider (슬라이더)
	local row = titledRow(form2, "Sleek Slider", "마우스 드래그로 조절하는 슬라이더입니다.")
	row:Right():Symbol({ Image = cascade.Symbols.sunMin })
	row:Right():Slider({
		Minimum = 0,
		Maximum = 1,
		Value = 0.5,
		ValueChanged = function(self, value) print("Slider value ->", value) end,
	})
	row:Right():Symbol({ Image = cascade.Symbols.sunMax })
end

do -- Stepper
	local row = titledRow(form2, "Basic Stepper", "증감 버튼을 이용하여 값을 1씩 더하거나 빼주는 도구입니다.")
	local label = row:Right():Label({ Text = "0" })
	row:Right():Stepper({
		Minimum = -10,
		Maximum = 10,
		Value = 0,
		Step = 1,
		ValueChanged = function(self, value)
			label.Text = tostring(value)
		end,
	})
end

do -- Stepper (필드 결합형 증감기)
	local row = titledRow(form2, "Stepper (Fielded)", "숫자를 직접 기입할 수도 있는 증감 선택기입니다.")
	row:Right():Stepper({
		Fielded = true, 
		Minimum = 0,
		Maximum = 100,
		Value = 50,
		Step = 5,
		ValueChanged = function(self, value) print("Fielded Stepper Changed:", value) end,
	})
end


-- =========================================================================
-- [섹션 2] NESTED TABS (계층 구조 폴더형 중첩 탭 섹션)
-- =========================================================================
local nestedSection = window:Section({
	Title = "Nested Folders",
	Disclosure = true, 
})

local rootTab = nestedSection:Tab({
	Title = "Root Folder",
	Icon = cascade.Symbols.folder,
})
rootTab:Form():Row():Left():Label({ Text = "1단계 [Root Folder] 화면입니다.", TextXAlignment = Enum.TextXAlignment.Left })

local subTab1 = rootTab:Tab({
	Title = "Sub-level 1",
	Icon = cascade.Symbols.doc,
})
subTab1:Form():Row():Left():Label({ Text = "2단계 [Sub-level 1] 화면입니다.", TextXAlignment = Enum.TextXAlignment.Left })

local subTab2 = subTab1:Tab({
	Title = "Sub-level 2",
	Icon = cascade.Symbols.doc,
})
subTab2:Form():Row():Left():Label({ Text = "3단계 [Sub-level 2] 화면입니다.", TextXAlignment = Enum.TextXAlignment.Left })

local subTab3 = subTab2:Tab({
	Title = "Sub-level 3",
	Icon = cascade.Symbols.doc,
})
subTab3:Form():Row():Left():Label({ Text = "4단계 [Sub-level 3] 화면입니다.", TextXAlignment = Enum.TextXAlignment.Left })


-- =========================================================================
-- [섹션 3] SELECTORS (드롭다운 및 다중 선택 리스트 섹션)
-- =========================================================================
local selectorSection = window:Section({
	Title = "Selectors",
	Disclosure = true,
})

local menusTab = selectorSection:Tab({
	Title = "Selection", 
	Icon = cascade.Symbols.listBullet,
})
local form3 = menusTab:Form()

do -- Radio Button Group
	local row = titledRow(form3, "Radio Buttons", "단 하나의 옵션만 활성화 가능한 라디오 선택 그룹입니다.")
	local radioButtonGroup = row:Right():RadioButtonGroup({
		Options = { "Option 1", "Option 2" },
		Value = 1,
		ValueChanged = function(self, value) print("Radio changed:", self.Options[value]) end,
	})
	radioButtonGroup:Option("Option 3")
end

do -- Pop Up Button (단일 선택 드롭다운)
	local row = titledRow(form3, "Dropdown (Single)", "리스트 중 하나의 아이템을 단일 선택합니다.")
	local popUpButton = row:Right():PopUpButton({
		Options = { "Item One", "Item Two", "Item Three" },
		Value = 2,
		ValueChanged = function(self, value) print("Dropdown choice:", self.Options[value]) end,
	})
	popUpButton:Option("Item Four")
end

do -- Pop Up Button (다중 선택 드롭다운)
	local row = titledRow(form3, "Dropdown (Multi)", "체크박스 형태로 다중 선택할 수 있는 드롭다운입니다.")
	local multiDropdown = row:Right():PopUpButton({
		Options = { "One", "Two", "Three" },
		Maximum = 2, 
		ValueChanged = function(self, value)
			print("Selected indices:")
			for _, idx in ipairs(value or {}) do print(" -> " .. tostring(self.Options[idx])) end
		end,
	})
	multiDropdown:Option("Four")
	multiDropdown.Value = { 1, 3 } 
end

do -- Pull Down Button
	local row = titledRow(form3, "Pull Down Actions", "클릭하면 액션 리스트 메뉴를 여는 버튼입니다.")
	local pullDownButton = row:Right():PullDownButton({
		Options = { "Action One", "Action Two" },
		Label = "Options Menu",
		ValueChanged = function(self, value) print("PullDown Action:", self.Options[value]) end,
	})
	pullDownButton:Option("Action Three")
end


-- =========================================================================
-- [섹션 4] LAYOUTS & STACKS (VStack / HStack 및 그래픽스 데모)
-- =========================================================================
local layoutSection = window:Section({
	Title = "Layouts & Stacks",
	Disclosure = true,
})

local stackTab = layoutSection:Tab({
	Title = "Stacks",
	Icon = cascade.Symbols.squareSplit2x1,
})
local form4 = stackTab:Form()

do -- VStack & HStack Demonstration
	local row = form4:Row()
	row:Left():TitleStack({
		Title = "Layout Stack",
		Subtitle = "VStack과 HStack을 중첩하여 복잡한 버튼/레이블 그리드를 배치합니다."
	})

	-- 세로 정렬 스택 생성
	local vstack = row:Right():VStack({
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	vstack:Label({ Text = "This is inside a VStack" })

	-- 가로 정렬 스택 생성 (HStack)
	local hstack = vstack:HStack({
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	hstack:Button({
		Label = "Stack Btn 1",
		State = "Secondary",
		Pushed = function() print("Stack Button 1 clicked") end,
	})
	hstack:Button({
		Label = "Stack Btn 2",
		State = "Secondary",
		Pushed = function() print("Stack Button 2 clicked") end,
	})
end

do -- ImageSurface Demonstration
	local row = titledRow(form4, "Image Surface", "로컬 또는 rbxassetid 이미지를 렌더링하고 그라디언트를 씌웁니다.")
	row:Right():ImageSurface({
		Image = "rbxassetid://10844787019", -- 돋보기나 집 아이콘 등의 에셋 ID
		Gradient = true,
		SurfaceColor = Color3.fromRGB(0, 122, 255),
	})
end


-- =========================================================================
-- [섹션 5] SYSTEM & ROUTING (시스템 설정 및 페이지 이동 섹션)
-- =========================================================================
local systemSection = window:Section({
	Title = "System Settings",
	Disclosure = true,
})

local settingsTab = systemSection:Tab({
	Title = "Settings", 
	Icon = cascade.Symbols.gear,
})

do -- Appearance
	local pageSection = settingsTab:PageSection({ Title = "Appearance settings" })
	local form = pageSection:Form()

	titledRow(form, "App Theme Toggle", "테마를 라이트/다크 모드로 동적 전환합니다."):Right():RadioButtonGroup({
		Options = { "Dark", "Light" },
		Value = app.Theme._id == "Dark" and 1 or 2,
		ValueChanged = function(self, value)
			app.Theme = cascade.Themes[self.Options[value]]
		end,
	})
	
	titledRow(form, "App Accent Toggle", "강조 포인트 색상을 동적으로 전환합니다."):Right():RadioButtonGroup({
		Options = { "Blue", "Yellow", "Green", "Graphite" },
		Value = app.Accent._id == "Blue" and 1 or (app.Accent._id == "Yellow" and 2 or (app.Accent._id == "Green" and 3 or 4)),
		ValueChanged = function(self, value)
			app.Accent = cascade.Accents[self.Options[value]]
		end,
	})
end

do -- Window Behaviors
	local pageSection = settingsTab:PageSection({ Title = "Window Control Variables" })
	local form = pageSection:Form()

	titledRow(form, "Draggable", "창 드래그 이동 활성화 여부"):Right():Toggle({
		Value = window.Draggable,
		ValueChanged = function(self, value) window.Draggable = value end,
	})

	titledRow(form, "Resizable", "창 크기 조절 활성화 여부"):Right():Toggle({
		Value = window.Resizable,
		ValueChanged = function(self, value) window.Resizable = value end,
	})

	titledRow(form, "UI Background Blur", "윈도우 배경 유리 재질 블러 효과"):Right():Toggle({
		Value = window.UIBlur,
		ValueChanged = function(self, value) window.UIBlur = value end,
	})
end

do -- Toast Notification
	local pageSection = settingsTab:PageSection({ Title = "Toast System" })
	local form = pageSection:Form()

	titledRow(form, "Minimize shortcut key", "창 최소화에 사용될 글로벌 단축키를 입력합니다."):Right():KeybindField({
		Value = minimizeKeybind,
		ValueChanged = function(self, value) minimizeKeybind = value end,
	})

	local notifyRow = titledRow(form, "Notify Spawner", "스택 알림창을 트리거합니다.")
	notifyRow:Right():Button({
		Label = "Show Success Alert",
		State = "Primary",
		Pushed = function(self)
			app:Notification({
				Title = "Success",
				Subtitle = "설정이 저장소에 올바르게 저장되었습니다.",
				App = "System",
				AppIcon = cascade.Symbols.checkmark,
				Duration = 5,
			})
		end,
	})
end

do -- JSON App State Dump
	local pageSection = settingsTab:PageSection({ Title = "JSON App State Capture" })
	local form = pageSection:Form()

	local dumpField = titledRow(form, "JSON String Data", "JSON 데이터가 여기에 노출됩니다."):Right():TextField({
		Value = "",
		Placeholder = "No data dumped yet.",
	})

	titledRow(form, "Dump Current UI State", "현재 UI 설정들의 값을 JSON 형식으로 내보냅니다."):Right():Button({
		Label = "Dump App State",
		State = "Secondary",
		Pushed = function(self)
			local jsonDump = recorder:Dump()
			dumpField.Value = jsonDump
			if setclipboard then
				setclipboard(jsonDump)
			end
		end,
	})
end

----------------------------------------------------
-- [탭 5] Routing (네비게이션 다중 화면 이동 데모)
-- ----------------------------------------------------
local routingTab = systemSection:Tab({
	Title = "Routing", 
	Icon = cascade.Symbols.network,
})

local pageA = app:Page()
local pageB = app:Page()

-- Page A (홈 페이지 화면)
do
	local formA = pageA:Form()
	local row = formA:Row()
	row:Left():ImageSurface({
		Image = cascade.Symbols.house,
		SurfaceColor = Color3.fromRGB(0, 122, 255),
	})
	row:Left():TitleStack({
		Title = "Home (Page A)",
		Subtitle = "이동 버튼을 클릭하면 Page B로 화면이 라우팅 전환됩니다.",
	})
	row:Right():Button({
		Label = "Go to Page B",
		State = "Primary",
		Pushed = function() routingTab:Navigate(pageB) end,
	})
end

-- Page B (서브 페이지 화면)
do
	local formB = pageB:Form()
	local row = titledRow(formB, "Sub-Page (Page B)", "라우팅 기술을 통하여 새로운 폼 페이지를 노출하고 있습니다.")
	row:Right():Button({
		Label = "Back to Page A",
		State = "Secondary",
		Pushed = function() routingTab:Navigate(pageA) end,
	})
end

routingTab:Navigate(pageA)
