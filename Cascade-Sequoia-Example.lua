--[[
    Cascade UI Library 1.4.0 - 100% Full Master Integration Script (with Tag & Gradient features)
    v1.2
    
    [포함된 기능 목록]
    - 신규 태그 및 그라데이션 기능 (Window, PageSection, TitleStack 연동)
    - 내장형(Built-in) JnKie 키 시스템 연동
    - 창 속성 정밀 제어 (Draggable, UIBlur, Dropshadow 등 15종 옵션)
    - RegisterComponent를 이용한 커스텀 위젯(CustomCard) 제작
    - 모든 기본 컴포넌트 (버튼, 입력칸, 컬러픽커, 드롭다운 등)
    - 데이터 시각화 차트 (BarChart, LineChart, PieChart)
    - 다이내믹 라우팅(다중 화면 전환) 및 중첩 탭(Nested Tabs)
    - 스택 레이아웃 (VStack, HStack) 및 세이브/로드(AppRecorder)
--]]

--// 1. Cascade UI 라이브러리 동적 로드 (GitHub URL 사용)
local cascade = loadstring(game:HttpGet("https://raw.githubusercontent.com/HeNo-exp/library/refs/heads/main/Cascade-Sequoia-Library-Unminified.lua"))()

local services = {
	UserInputService = game:GetService("UserInputService"),
	GuiService = game:GetService("GuiService"),
	TweenService = game:GetService("TweenService"),
	HttpService = game:GetService("HttpService"),
}

--// 전역 설정 변수
local minimizeKeybind = Enum.KeyCode.RightControl

--// ----------------------------------------------------
--// 2. Custom Component 등록 (RegisterComponent API)
--// ----------------------------------------------------
cascade.RegisterComponent("CustomCard", function(self, properties)
	local create = cascade.Creator.Create
	
	-- 선언형 인스턴스 빌더(Creator.Create) 사용
	local cardFrame = create("Frame")({
		Name = properties.Name or "CustomCard",
		Size = properties.Size or UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Color3.fromRGB(38, 38, 42),
		BorderSizePixel = 0,
		Parent = properties.Parent or self.__container, -- 부모 컨테이너에 자동 배치
		
		create("UICorner")({ CornerRadius = UDim.new(0, 8) }),
		create("UIPadding")({
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		})
	})

	-- 자식 요소로 라벨들 배치
	self:Label({
		Text = "<b>" .. (properties.Title or "Custom Card") .. "</b>",
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = cardFrame.__instance,
		TextSize = 14,
	})
	
	self:Label({
		Text = properties.Description or "Registered custom component card description.",
		TextColor3 = Color3.fromRGB(160, 160, 165),
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 0, 0, 22),
		Parent = cardFrame.__instance,
		TextSize = 11,
	})

	return cardFrame
end)

--// 공통 UI 도우미 함수 (타이틀/서브타이틀이 포함된 좌우 1행 레이아웃 생성 - 태그 매개변수 추가)
local function titledRow(parent, title, subtitle, tagText, tagColor)
	local row = parent:Row({
		SearchIndex = title,
	})
	row:Left():TitleStack({
		Title = title,
		Subtitle = subtitle,
		TitleTag = tagText,
		TitleTagColor = tagColor,
	})
	return row
end

--// 3. 메인 애플리케이션 초기화
local app = cascade.New({
	WindowPill = true,             -- 모바일 최소화 복구용 알약(Pill) UI 활성화
	Theme = cascade.Themes.Dark,   -- 기본 다크 모드 테마
	Accent = cascade.Accents.Blue, -- 기본 파란색 악센트
})

--// 4. 메인 윈도우 생성 (모든 매개변수 포함 & 빌트인 키 시스템 & 태그 추가)
local window = app:Window({
	-- [Cascade 전용 창 설정]
	Title = "Cascade Sequoia Master",                 -- 창 상단 대제목
	Subtitle = "100% Full-Featured UI Hub",           -- 창 상단 소제목 (없으면 숨김)
	Searching = true,                                 -- 페이지 내부 검색 기능 활성화 여부
	Draggable = true,                                 -- 드래그하여 창 이동 활성화 여부
	Resizable = true,                                 -- 창 모서리를 드래그하여 크기 조절 활성화 여부
	CanExit = true,                                   -- 우측 상단 닫기(X) 버튼 활성화 여부
	CanMinimize = true,                               -- 우측 상단 최소화(-) 버튼 활성화 여부
	CanZoom = true,                                   -- 우측 상단 최대화(+) 버튼 활성화 여부
	Maximized = false,                                -- 처음 실행 시 최대화 상태 시작 여부
	Minimized = false,                                -- 처음 실행 시 최소화 상태 시작 여부
	Dropshadow = true,                                -- 창 외부 그림자(Dropshadow) 효과 여부
	UIBlur = true,                                    -- 창 배경 아크릴/유리 질감 블러 효과 여부
	
	-- [신규 태그 기능 옵션]
	TitleTag = "PREMIUM",                             -- 대제목 옆 태그 텍스트
	TitleTagColor = Color3.fromRGB(255, 45, 85),      -- 단색 (핑크)
	SubtitleTag = "V1.4.0",                           -- 소제목 옆 태그 텍스트
	SubtitleTagColor = {                              -- 테이블 배열로 전달 시 그라데이션 처리 (핑크 -> 오렌지)
		Color3.fromHex("#FF2D55"),
		Color3.fromHex("#FF9500")
	},
	
	-- [Roblox Frame 공통 속성]
	Size = UDim2.fromOffset(850, 600),                -- 인증 완료 후 복구될 기본 창 크기
	Position = UDim2.fromScale(0.5, 0.5),             -- 화면 상 창의 배치 위치
	AnchorPoint = Vector2.new(0.5, 0.5),              -- 창의 기준점 (가운데 정렬)
	ZIndex = 1,                                       -- 렌더링 우선순위
	Visible = true,                                   -- 창 노출 여부
	
	--[[ [빌트인 키 시스템 설정 (JnKie API 기반)]
	KeySystem = {
		Service = "YOUR_SERVICE_NAME",                 -- JnKie 대시보드 내 서비스 이름
		Identifier = "YOUR_USER_ID",                   -- JnKie 대시보드 내 유저 고유 ID
		Provider = "Mixed",                            -- 사용할 프로바이더 이름 ("Mixed", "Linkvertise" 등)
		OnVerified = function()
			-- 키 검증 통과 후 실행될 콜백
			print("키 인증 성공! 메인 기능 잠금이 풀렸습니다.")
			app:Notification({
				Title = "Authenticated",
				Subtitle = "환영합니다! 모든 프리미엄 기능이 잠금 해제되었습니다.",
				AppIcon = cascade.Symbols.checkmark,
				Duration = 5,
			})
		end,
	} ]]
})

--// 5. 어플리케이션 세이브/로드 녹화기(AppRecorder) 구동
local recorder = cascade.AppRecorder.new(app)
recorder:Start()

-- 단축키 입력을 통한 창 최소화 이벤트 처리
services.UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == minimizeKeybind and not gameProcessedEvent then
		window.Minimized = not window.Minimized
	end
end)

window.Destroying:Connect(function()
	print("Cascade 윈도우 닫힘. 녹화기를 중지합니다.")
	recorder:Stop()
end)


-- =========================================================================
-- [섹션 1] BASIC INPUTS (조작용 컴포넌트)
-- =========================================================================
local basicSection = window:Section({ Title = "Basic Inputs", Disclosure = false })
local controlsTab = basicSection:Tab({ Selected = true, Title = "Controls", Icon = cascade.Symbols.switch2 })
local form1 = controlsTab:Form()

do -- Toggle & TextField
	local rowToggle = titledRow(form1, "Toggle Switch", "스위치 형태의 활성/비활성 제어기입니다.")
	rowToggle:Right():Toggle({ Value = true, ValueChanged = function(self, value) print("Toggle value:", value) end })

	local rowText = titledRow(form1, "Text Field", "입력 상자에 값을 입력할 수 있습니다.")
	rowText:Right():TextField({ Value = "Hello Cascade", Placeholder = "Enter text...", ValueChanged = function(self, value) print("Text Saved:", value) end })
end

do -- Keybind & Color Picker
	local rowKey = titledRow(form1, "Keybind Capture", "클릭 후 아무 키나 입력하여 단축키를 바인딩합니다.")
	rowKey:Right():KeybindField({ Value = Enum.KeyCode.G, ValueChanged = function(self, value) print("New bind key:", value) end })

	-- 컬러 픽커 라우에 파란색 단색 "POPUP" 태그 추가
	local rowColor = titledRow(form1, "Color Picker", "정교한 알파값 지원 RGB 팝업 컬러 픽커입니다.", "POPUP", Color3.fromRGB(0, 122, 255))
	rowColor:Right():ColorPicker({ Title = "Accent Tint Color", Value = Color3.fromRGB(0, 122, 255), Transparency = 0.1, ValueChanged = function(self, color, trans) print("Color changed:", color) end })
end

do -- Buttons
	-- 버튼 라우에 태그 추가 (색상을 비워두었으므로 기본 고급 블루 그라데이션 적용)
	local rowBtn = titledRow(form1, "Action Buttons", "사용처에 어울리는 상태별 버튼입니다.", "NEW")
	rowBtn:Right():Button({ Label = "Primary", State = "Primary", Pushed = function() print("Primary Pushed") end })
	rowBtn:Right():Button({ Label = "Secondary", State = "Secondary", Pushed = function() print("Secondary Pushed") end })
	rowBtn:Right():Button({ Label = "Destructive", State = "Destructive", Pushed = function() print("Destructive Pushed") end })
end


-- =========================================================================
-- [섹션 2] ADJUSTS & SELECTORS (수치 조절 & 선택상자)
-- =========================================================================
local adjustSection = window:Section({ Title = "Adjusts & Selectors", Disclosure = true })
local selectorsTab = adjustSection:Tab({ Title = "Adjust & Select", Icon = cascade.Symbols.sliderHorizontal3 })
local form2 = selectorsTab:Form()

do -- Slider & Steppers
	local rowSlider = titledRow(form2, "Slider Value", "마우스 드래그를 이용한 범위 수치 조절")
	rowSlider:Right():Slider({ Minimum = 0, Maximum = 100, Value = 50, ValueChanged = function(self, value) print("Slider value:", value) end })

	local rowStep = titledRow(form2, "Fielded Stepper", "증감 버튼 및 수치 수동 입력을 지원하는 스태퍼")
	rowStep:Right():Stepper({ Fielded = true, Minimum = 0, Maximum = 10, Value = 5, Step = 0.5, ValueChanged = function(self, value) print("Stepper value:", value) end })
end

do -- Radio & Dropdowns
	local rowRadio = titledRow(form2, "Radio Group", "다지선다형 단일 옵션 선택 컴포넌트")
	rowRadio:Right():RadioButtonGroup({ Options = { "Option 1", "Option 2", "Option 3" }, Value = 1, ValueChanged = function(self, val) print("Radio Selected:", self.Options[val]) end })

	local rowSingleDrop = titledRow(form2, "Single Dropdown", "드롭다운 리스트 형식의 단일 선택 상자")
	rowSingleDrop:Right():PopUpButton({ Options = { "Item A", "Item B", "Item C" }, Value = 2, ValueChanged = function(self, value) print("Dropdown choice:", self.Options[value]) end })

	local rowMultiDrop = titledRow(form2, "Multi Dropdown", "체크박스 기반의 다중 선택 상자")
	rowMultiDrop:Right():PopUpButton({
		Options = { "Choice A", "Choice B", "Choice C" }, Maximum = 2, Value = { 1 },
		ValueChanged = function(self, selected) print("Multi Dropdown Selection changed.") end,
	})
	
	local rowPullDown = titledRow(form2, "Pull Down Actions", "클릭 시 액션 리스트 메뉴를 여는 상자")
	rowPullDown:Right():PullDownButton({ Options = { "Action 1", "Action 2" }, Label = "Menu", ValueChanged = function(self, value) print("Action:", self.Options[value]) end })
end


-- =========================================================================
-- [섹션 3] NESTED TABS & ROUTING (중첩 탭 & 다중 페이지 전환)
-- =========================================================================
local navigationSection = window:Section({ Title = "Sidebar Directories", Disclosure = true })

-- 부모 탭 (Root)
local rootTab = navigationSection:Tab({ Title = "Root Directory", Icon = cascade.Symbols.folder })
rootTab:Form():Row():Left():Label({ Text = "이 화면은 상위 탭인 [Root Directory]의 폼입니다.", TextXAlignment = Enum.TextXAlignment.Left })

-- 자식 탭 (Sub-level 1)
local subTab1 = rootTab:Tab({ Title = "Sub-level Folder", Icon = cascade.Symbols.folder })
subTab1:Form():Row():Left():Label({ Text = "자식 계층 탭 [Sub-level Folder]의 폼 화면입니다.", TextXAlignment = Enum.TextXAlignment.Left })

-- 손자 탭 (Sub-level 2) - 동적 라우팅 페이지 적용
local subTab2 = subTab1:Tab({ Title = "Nested Page Router", Icon = cascade.Symbols.network })
local routePageA = app:Page()
local routePageB = app:Page()

do -- Page A 설계
	local fA = routePageA:Form()
	local r = fA:Row()
	r:Left():TitleStack({ Title = "Dynamic Page A", Subtitle = "라우팅 시스템의 홈 화면입니다." })
	r:Right():Button({ Label = "Go to Page B", State = "Primary", Pushed = function() subTab2:Navigate(routePageB) end })
end

do -- Page B 설계
	local fB = routePageB:Form()
	local r = fB:Row()
	r:Left():TitleStack({ Title = "Dynamic Page B", Subtitle = "Page A로부터 라우팅 이동 완료된 페이지입니다." })
	r:Right():Button({ Label = "Back to Page A", State = "Secondary", Pushed = function() subTab2:Navigate(routePageA) end })
end

subTab2:Navigate(routePageA)


-- =========================================================================
-- [섹션 4] GRAPHICS, LAYOUTS & CUSTOMS (그래픽, 스택, 커스텀 위젯)
-- =========================================================================
local designSection = window:Section({ Title = "Design & Layouts", Disclosure = true })
local designTab = designSection:Tab({ Title = "Aesthetic Showcase", Icon = cascade.Symbols.squareSplit2x1 })
local form3 = designTab:Form()

do -- 다양한 텍스트 라벨 (Label, RichText)
	local textHeader = form3:PageSection({ Title = "Typography Examples" })
	local fText = textHeader:Form()
	fText:Row():Left():Label({ Text = "• 일반 텍스트 라벨", TextXAlignment = Enum.TextXAlignment.Left })
	fText:Row():Left():Label({ Text = "<b>[SYSTEM]</b> Status: <font color='#00FF00'>Online</font> (RichText 활성화)", RichText = true, TextXAlignment = Enum.TextXAlignment.Left })
end

do -- 이미지 서피스 및 앞서 등록한 "커스텀 컴포넌트"
	-- PageSection에 그린-민트 그라데이션 태그 추가
	local graphicHeader = form3:PageSection({
		Title = "Graphical Panels & Custom Cards",
		TitleTag = "CUSTOM",
		TitleTagColor = {
			Color3.fromHex("#34C759"),
			Color3.fromHex("#00C7B4")
		}
	})
	local fGraph = graphicHeader:Form()

	local rowSurface = fGraph:Row()
	rowSurface:Left():ImageSurface({ Image = cascade.Symbols.house, SurfaceColor = Color3.fromRGB(0, 122, 255), Gradient = true })
	rowSurface:Left():TitleStack({ Title = "Mac-style Image Panel", Subtitle = "카드 형태에 그라디언트를 채색한 레이아웃" })

	-- API로 제작한 커스텀 컴포넌트 호출
	local rowCustom = fGraph:Row()
	rowCustom:Left():CustomCard({
		Title = "My Custom Registered Component Card",
		Description = "cascade.RegisterComponent를 통해 등록된 커스텀 카드 위젯입니다."
	})
end

do -- VStack & HStack 레이아웃 시스템
	local stackHeader = form3:PageSection({ Title = "Stack Grid System" })
	local fStack = stackHeader:Form()
	local row = fStack:Row()
	row:Left():TitleStack({ Title = "Layout Stack", Subtitle = "VStack/HStack을 중첩하여 배치한 그리드입니다." })

	local vstack = row:Right():VStack({ Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })
	vstack:Label({ Text = "This is inside a VStack" })

	local hstack = vstack:HStack({ Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })
	hstack:Button({ Label = "Stack Btn 1", State = "Secondary", Pushed = function() print("Stack Button 1 clicked") end })
	hstack:Button({ Label = "Stack Btn 2", State = "Secondary", Pushed = function() print("Stack Button 2 clicked") end })
end


-- =========================================================================
-- [섹션 5] CHARTS & DATA VISUALIZATION (데이터 시각화 차트)
-- =========================================================================
local chartSection = window:Section({ Title = "Data Visualization", Disclosure = true })
local chartTab = chartSection:Tab({ Title = "Charts", Icon = cascade.Symbols.pieChart })
local chartForm = chartTab:Form()

do -- BarChart (막대 차트)
	local row = chartForm:Row()
	row:Left():BarChart({
		Title = "Monthly Active Users",
		Subtitle = "막대 그래프를 통한 월별 활성 유저 통계입니다.",
		Height = 180,
		Data = {
			{ Label = "Jan", Value = 120, Color = Color3.fromRGB(0, 122, 255) },
			{ Label = "Feb", Value = 150, Color = Color3.fromRGB(255, 149, 0) },
			{ Label = "Mar", Value = 220, Color = Color3.fromRGB(52, 199, 89) },
			{ Label = "Apr", Value = 180, Color = Color3.fromRGB(175, 82, 222) },
		}
	})
end

do -- LineChart (선형 차트)
	local row = chartForm:Row()
	row:Left():LineChart({
		Title = "Performance Metrics",
		Subtitle = "선형 차트를 통하여 시간에 따른 성능 변화를 보여줍니다.",
		Height = 180,
		Color = Color3.fromRGB(0, 122, 255),
		Data = { 20, 35, 40, 30, 55, 75, 60 },
		Labels = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" },
	})
end

do -- PieChart (원형/도넛 차트)
	local row = chartForm:Row()
	row:Left():PieChart({
		Title = "Storage Usage",
		Subtitle = "파이 차트를 이용한 저장소 점유율 (도넛 스타일)",
		Size = 140,
		Donut = true,
		Align = "Left",
		Data = {
			{ Label = "System", Value = 45, Color = Color3.fromRGB(255, 59, 48) },
			{ Label = "Apps", Value = 25, Color = Color3.fromRGB(255, 149, 0) },
			{ Label = "Media", Value = 15, Color = Color3.fromRGB(255, 204, 0) },
			{ Label = "Free", Value = 15, Color = Color3.fromRGB(52, 199, 89) },
		}
	})
end


-- =========================================================================
-- [섹션 6] UTILITIES & RECORDER (테마 변경 및 세이브 백업)
-- =========================================================================
local utilitySection = window:Section({ Title = "App Utility System", Disclosure = true })
local utilityTab = utilitySection:Tab({ Title = "Theme & Data State", Icon = cascade.Symbols.gear })
local form4 = utilityTab:Form()

do -- 실시간 테마 / 포인트 색상 전환
	local groupTheme = form4:PageSection({ Title = "Global App Theme Settings" })
	local fTheme = groupTheme:Form()

	titledRow(fTheme, "Dark/Light Theme", "어플리케이션의 테마 스타일을 변경합니다."):Right():RadioButtonGroup({
		Options = { "Dark", "Light" }, Value = app.Theme._id == "Dark" and 1 or 2,
		ValueChanged = function(self, value) app.Theme = cascade.Themes[self.Options[value]] end,
	})
	
	titledRow(fTheme, "Accent Color", "포인트 강조 색상을 변경합니다."):Right():RadioButtonGroup({
		Options = { "Blue", "Yellow", "Green", "Graphite" }, Value = 1,
		ValueChanged = function(self, value) app.Accent = cascade.Accents[self.Options[value]] end,
	})
end

do -- 알림 토스트 & AppRecorder를 사용한 JSON 상태 덤프
	local groupSave = form4:PageSection({ Title = "System Notifications & State Dumper" })
	local fSave = groupSave:Form()

	titledRow(fSave, "Minimize shortcut key", "창을 숨기거나 띄울 전역 단축키"):Right():KeybindField({
		Value = minimizeKeybind, ValueChanged = function(self, value) minimizeKeybind = value end,
	})

	local notifyRow = titledRow(fSave, "Spawn Stack Toast", "맥 스타일의 토스트 알림창을 트리거합니다.")
	notifyRow:Right():Button({
		Label = "Trigger Notification", State = "Primary",
		Pushed = function()
			app:Notification({ Title = "Task Completed", Subtitle = "All functions completed successfully.", AppIcon = cascade.Symbols.checkmark, Duration = 4 })
		end,
	})

	local dumpOutput = titledRow(fSave, "Dump Data Display", "덤프된 세이브 키 JSON 데이터 출력"):Right():TextField({ Value = "", Placeholder = "No data dumped yet." })
	local dumpRow = titledRow(fSave, "UI Value Backup Tool", "현재 활성화된 모든 UI 위젯 상태를 추출합니다.")
	dumpRow:Right():Button({
		Label = "Export State", State = "Secondary",
		Pushed = function()
			local data = recorder:Dump()
			dumpOutput.Value = data
			if setclipboard then
				setclipboard(data)
				app:Notification({ Title = "Export Success", Subtitle = "UI 상태 데이터가 클립보드에 복사되었습니다.", Duration = 3 })
			end
		end,
	})
end
