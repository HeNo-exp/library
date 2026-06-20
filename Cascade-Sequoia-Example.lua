
local cascadeUrl = "https://raw.githubusercontent.com/HeNo-exp/library/refs/heads/main/Cascade-Sequoia-Library-Unminified.lua"
local cascade = loadstring(game:HttpGet(cascadeUrl))()

local services = {
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"),
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

--// 3. 메인 어플리케이션 인스턴스 생성
local app = cascade.New({
	WindowPill = true,             -- 모바일용 알약(Pill) UI 활성화
	Theme = cascade.Themes.Dark,   -- 기본 다크 모드 테마
	Accent = cascade.Accents.Blue, -- 기본 파란색 악센트
})

--// 4. 어플리케이션 세이브/로드 녹화기(AppRecorder) 구동
local recorder = cascade.AppRecorder.new(app)
recorder:Start()

--// 2. 메인 애플리케이션 초기화
local app = cascade.New({
	WindowPill = false,            -- 모바일 최소화 복구용 필(Pill) UI 숨김
	Theme = cascade.Themes.Dark,   -- 테마 설정 (Light / Dark)
	Accent = cascade.Accents.Blue, -- 포인트 강조 색상 설정
})
--// 3. 메인 윈도우 생성 (사용 가능한 모든 매개변수 포함)
local window = app:Window({
	-- [Cascade 전용 창 설정]
	Title = "My Premium Hub",                         -- 창 상단 대제목
	Subtitle = "Premium script management console",    -- 창 상단 소제목 (없으면 숨김)
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
	
	-- [Roblox Frame 공통 속성]
	Size = UDim2.fromOffset(850, 530),                 -- 인증 완료 후 복구될 기본 창 크기
	Position = UDim2.fromScale(0.5, 0.5),             -- 화면 상 창의 배치 위치
	AnchorPoint = Vector2.new(0.5, 0.5),               -- 창의 기준점 (가운데 정렬)
	ZIndex = 1,                                       -- 렌더링 우선순위 레이어 레이아웃 순서
	Visible = true,                                   -- 창 노출 여부
	
	-- [빌트인 키 시스템 설정]
	KeySystem = {
		Service = "YOUR_SERVICE_NAME",                 -- JnKie 대시보드 내 서비스 이름
		Identifier = "YOUR_USER_ID",                    -- JnKie 대시보드 내 유저 고유 ID (숫자 문자열)
		Provider = "Mixed",                             -- 사용할 광고/체크포인트 프로바이더 이름 ("Mixed", "Linkvertise" 등)
		OnVerified = function()
			-- 키 검증 통과 후 실행될 콜백 함수
			print("키 인증에 성공하여 메인 기능 잠금이 풀렸습니다!")
			
			-- 여기에 인증 완료 시 스포너 알림 등을 추가할 수 있습니다.
			app:Notification({
				Title = "Authenticated",
				Subtitle = "환영합니다! 프리미엄 툴 사용 권한이 부여되었습니다.",
				Duration = 5,
			})
		end,
	}
})

-- RightControl 키를 누르면 최소화 토글
services.UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == minimizeKeybind and not gameProcessedEvent then
		window.Minimized = not window.Minimized
	end
end)


-- =========================================================================
-- [섹션 1] BASIC INPUTS (조작용 컴포넌트)
-- =========================================================================
local basicSection = window:Section({
	Title = "Basic Inputs",
	Disclosure = false, -- 접기 비활성화
})

local controlsTab = basicSection:Tab({
	Selected = true,
	Title = "Controls",
	Icon = cascade.Symbols.switch2, 
})
local form1 = controlsTab:Form()

do -- Toggle & TextField
	local rowToggle = titledRow(form1, "Toggle Switch", "스위치 형태의 활성/비활성 제어기입니다.")
	rowToggle:Right():Toggle({
		Value = true,
		ValueChanged = function(self, value) print("Toggle value:", value) end,
	})

	local rowText = titledRow(form1, "Text Field", "입력 상자에 값을 입력할 수 있습니다.")
	rowText:Right():TextField({
		Value = "Hello Cascade",
		Placeholder = "Enter text...",
		ValueChanged = function(self, value) print("Text Saved:", value) end,
	})
end

do -- Keybind & Color Picker
	local rowKey = titledRow(form1, "Keybind Capture", "클릭 후 아무 키나 입력하여 단축키를 바인딩합니다.")
	rowKey:Right():KeybindField({
		Value = Enum.KeyCode.G,
		ValueChanged = function(self, value) print("New bind key:", value) end,
	})

	local rowColor = titledRow(form1, "Color Picker", "정교한 알파값 지원 RGB 팝업 컬러 픽커입니다.")
	rowColor:Right():ColorPicker({
		Title = "Accent Tint Color",
		Value = Color3.fromRGB(0, 122, 255),
		Transparency = 0.1,
		ValueChanged = function(self, color, trans) print("Color changed:", color, "Trans:", trans) end,
	})
end

do -- 3종류 스타일 버튼
	local rowBtn = titledRow(form1, "Action Buttons", "사용처에 어울리는 상태별 버튼입니다.")
	rowBtn:Right():Button({
		Label = "Primary",
		State = "Primary",
		Pushed = function() print("Primary Pushed") end,
	})
	rowBtn:Right():Button({
		Label = "Secondary",
		State = "Secondary",
		Pushed = function() print("Secondary Pushed") end,
	})
	rowBtn:Right():Button({
		Label = "Destructive",
		State = "Destructive",
		Pushed = function() print("Destructive Pushed") end,
	})
end


-- =========================================================================
-- [섹션 2] ADJUSTS & SELECTORS (수치 조절 & 선택상자)
-- =========================================================================
local adjustSection = window:Section({
	Title = "Adjusts & Selectors",
	Disclosure = true, -- 접기 활성화
})

local selectorsTab = adjustSection:Tab({
	Title = "Adjust & Select",
	Icon = cascade.Symbols.sliderHorizontal3,
})
local form2 = selectorsTab:Form()

do -- Slider & Steppers
	local rowSlider = titledRow(form2, "Slider Value", "마우스 드래그를 이용한 범위 수치 조절")
	rowSlider:Right():Slider({
		Minimum = 0,
		Maximum = 100,
		Value = 50,
		ValueChanged = function(self, value) print("Slider value:", value) end,
	})

	local rowStep = titledRow(form2, "Fielded Stepper", "증감 버튼 및 수치 수동 입력을 지원하는 스태퍼")
	rowStep:Right():Stepper({
		Fielded = true,
		Minimum = 0,
		Maximum = 10,
		Value = 5,
		Step = 0.5,
		ValueChanged = function(self, value) print("Stepper value:", value) end,
	})
end

do -- Radio Buttons & Dropdowns
	local rowRadio = titledRow(form2, "Radio Group", "다지선다형 단일 옵션 선택 컴포넌트")
	rowRadio:Right():RadioButtonGroup({
		Options = { "Option 1", "Option 2", "Option 3" },
		Value = 1,
		ValueChanged = function(self, val) print("Radio Selected:", self.Options[val]) end,
	})

	local rowDropdown = titledRow(form2, "Multi Dropdown", "드롭다운 리스트 형식의 다중 선택 상자")
	rowDropdown:Right():PopUpButton({
		Options = { "Choice A", "Choice B", "Choice C" },
		Maximum = 2, -- 최대 2개 선택 가능
		Value = { 1 },
		ValueChanged = function(self, selected) 
			print("Dropdown Selection changed.")
		end,
	})
end


-- =========================================================================
-- [섹션 3] NESTED TABS & ROUTING (중첩 탭 & 다중 페이지 전환)
-- =========================================================================
local navigationSection = window:Section({
	Title = "Sidebar Directories",
	Disclosure = true,
})

-- 부모 탭 (Root)
local rootTab = navigationSection:Tab({
	Title = "Root Directory",
	Icon = cascade.Symbols.folder,
})
local rootForm = rootTab:Form()
rootForm:Row():Left():Label({ Text = "이 화면은 상위 탭인 [Root Directory]의 폼입니다.", TextXAlignment = Enum.TextXAlignment.Left })

-- 자식 탭 (Sub-level 1)
local subTab1 = rootTab:Tab({
	Title = "Sub-level Folder",
	Icon = cascade.Symbols.folder,
})
local sub1Form = subTab1:Form()
sub1Form:Row():Left():Label({ Text = "자식 계층 탭 [Sub-level Folder]의 폼 화면입니다.", TextXAlignment = Enum.TextXAlignment.Left })

-- 손자 탭 (Sub-level 2) - 동적 라우팅 페이지 적용
local subTab2 = subTab1:Tab({
	Title = "Nested Page Router",
	Icon = cascade.Symbols.network,
})

-- 두 개의 가상 페이지 생성
local routePageA = app:Page()
local routePageB = app:Page()

-- Page A 설계
do
	local fA = routePageA:Form()
	local r = fA:Row()
	r:Left():TitleStack({ Title = "Dynamic Page A", Subtitle = "라우팅 시스템의 홈 화면입니다." })
	r:Right():Button({
		Label = "Go to Page B",
		State = "Primary",
		Pushed = function() subTab2:Navigate(routePageB) end,
	})
end

-- Page B 설계
do
	local fB = routePageB:Form()
	local r = fB:Row()
	r:Left():TitleStack({ Title = "Dynamic Page B", Subtitle = "Page A로부터 라우팅 이동 완료된 페이지입니다." })
	r:Right():Button({
		Label = "Back to Page A",
		State = "Secondary",
		Pushed = function() subTab2:Navigate(routePageA) end,
	})
end

-- 손자 탭의 초기 노출 화면은 pageA로 세팅
subTab2:Navigate(routePageA)


-- =========================================================================
-- [섹션 4] TEXT, GRAPHICS & CUSTOMS (글자, 그래픽 판넬, 커스텀 위젯)
-- =========================================================================
local designSection = window:Section({
	Title = "Text & Graphics Design",
	Disclosure = true,
})

local designTab = designSection:Tab({
	Title = "Aesthetic Showcase",
	Icon = cascade.Symbols.squareSplit2x1,
})
local form3 = designTab:Form()

do -- 다양한 텍스트 라벨 (Label, RichText, PageSection)
	local textHeader = form3:PageSection({
		Title = "Typography Examples",
		Subtitle = "오직 글자로만 이루어진 정적 텍스트 컴포넌트"
	})
	local fText = textHeader:Form()

	fText:Row():Left():Label({
		Text = "• 일반 텍스트 라벨",
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	fText:Row():Left():Label({
		Text = "<b>[SYSTEM]</b> Status: <font color='#00FF00'>Online</font> (RichText 활성화)",
		RichText = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

do -- 이미지 서피스 및 커스텀 컴포넌트 출력
	local graphicHeader = form3:PageSection({
		Title = "Graphical Panels & Custom Cards"
	})
	local fGraph = graphicHeader:Form()

	-- ImageSurface
	local rowSurface = fGraph:Row()
	rowSurface:Left():ImageSurface({
		Image = cascade.Symbols.house,
		SurfaceColor = Color3.fromRGB(0, 122, 255),
		Gradient = true, -- 그라디언트 채색
	})
	rowSurface:Left():TitleStack({
		Title = "Mac-style Blue Image Panel",
		Subtitle = "둥근 카드 형태에 그라디언트를 채색한 레이아웃입니다."
	})

	-- 앞서 등록했던 커스텀 컴포넌트(CustomCard) 호출
	local rowCustom = fGraph:Row()
	rowCustom:Left():CustomCard({
		Title = "My Custom Registered Component Card",
		Description = "cascade.RegisterComponent를 통해 등록된 카드 위젯이 성공적으로 렌더링되었습니다."
	})
end


-- =========================================================================
-- [섹션 5] UTILITIES & RECORDER (상태 관리 및 백업)
-- =========================================================================
local utilitySection = window:Section({
	Title = "App Utility System",
	Disclosure = true,
})

local utilityTab = utilitySection:Tab({
	Title = "Theme & Data State",
	Icon = cascade.Symbols.gear,
})
local form4 = utilityTab:Form()

do -- 실시간 테마 / 포인트 색상 전환
	local groupTheme = form4:PageSection({ Title = "Global App Theme Settings" })
	local fTheme = groupTheme:Form()

	titledRow(fTheme, "Dark/Light Theme", "어플리케이션의 테마 스타일을 변경합니다."):Right():RadioButtonGroup({
		Options = { "Dark", "Light" },
		Value = app.Theme._id == "Dark" and 1 or 2,
		ValueChanged = function(self, value)
			app.Theme = cascade.Themes[self.Options[value]]
		end,
	})
	
	titledRow(fTheme, "Accent Accent", "포인트 강조 색상을 변경합니다."):Right():RadioButtonGroup({
		Options = { "Blue", "Yellow", "Green", "Graphite" },
		Value = app.Accent._id == "Blue" and 1 or (app.Accent._id == "Yellow" and 2 or (app.Accent._id == "Green" and 3 or 4)),
		ValueChanged = function(self, value)
			app.Accent = cascade.Accents[self.Options[value]]
		end,
	})
end

do -- 알림 토스트 & AppRecorder를 사용한 설정 덤프
	local groupSave = form4:PageSection({ Title = "System Notifications & State Dumper" })
	local fSave = groupSave:Form()

	local notifyRow = titledRow(fSave, "Spawn Stack Toast", "맥 스타일의 슬라이드 토스트 알림창을 생성합니다.")
	notifyRow:Right():Button({
		Label = "Trigger Notification",
		State = "Primary",
		Pushed = function()
			app:Notification({
				Title = "Task Completed",
				Subtitle = "All diagnostic functions completed successfully.",
				App = "Diagnostic Tool",
				AppIcon = cascade.Symbols.checkmark,
				Duration = 4,
			})
		end,
	})

	-- JSON 데이터 출력 텍스트 필드
	local dumpOutput = titledRow(fSave, "Dump Data Display", "덤프된 세이브 키 JSON 문자열이 이곳에 출력됩니다."):Right():TextField({
		Value = "",
		Placeholder = "No data dumped yet."
	})

	local dumpRow = titledRow(fSave, "UI Value Backup Tool", "현재 활성화된 모든 UI 위젯 상태를 세이브 키로 내보냅니다.")
	dumpRow:Right():Button({
		Label = "Export State to Clipboard",
		State = "Secondary",
		Pushed = function()
			-- recorder 객체를 통해 모든 상태를 JSON으로 덤프
			local data = recorder:Dump()
			dumpOutput.Value = data
			
			if setclipboard then
				setclipboard(data)
				app:Notification({
					Title = "Clipboard Export",
					Subtitle = "UI 상태 데이터 복사가 완료되었습니다.",
					Duration = 3,
				})
			end
		end,
	})
end
