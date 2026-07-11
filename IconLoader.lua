--[[
    Cascade UI Library 1.4.0 - Ultra Lag-Free Infinite Viewer (2x Large Icons)
--]]

--// 1. Cascade UI 라이브러리 동적 로드
local cascade = loadstring(game:HttpGet("https://raw.githubusercontent.com/HeNo-exp/library/refs/heads/main/Cascade-Sequoia-Library-Unminified.lua"))()

local services = {
	UserInputService = game:GetService("UserInputService"),
}

--// 전역 설정 변수
local minimizeKeybind = Enum.KeyCode.RightControl
local currentChunkPage = 1
local chunkSize = 60 

--// 2. 전체 대용량 에셋 기호 테이블을 인덱싱 가능한 배열로 재구조화
local masterSymbolsArray = {}
for iconName, assetId in pairs(cascade.Symbols) do
	table.insert(masterSymbolsArray, { Name = iconName, Asset = assetId })
end
table.sort(masterSymbolsArray, function(a, b) return a.Name:lower() < b.Name:lower() end)

--// ----------------------------------------------------
--// 3. Custom Component 등록 (아이콘 2배 대형화 패치)
--// ----------------------------------------------------
cascade.RegisterComponent("CustomCard", function(self, properties)
	local create = cascade.Creator.Create
	
	-- 격격화되고 심플한 초고속 모던 프레임 생성 (높이를 52 -> 68로 상향하여 대형 아이콘 수용) ★
	local cardFrame = create("Frame")({
		Name = properties.Name or "CustomCard",
		Size = UDim2.new(1, 0, 0, 68), -- 높이 확장
		BackgroundColor3 = Color3.fromRGB(34, 34, 38),
		BorderSizePixel = 0,
		Parent = properties.Parent or self.__container or self.__instance or self,
		
		create("UICorner")({ CornerRadius = UDim.new(0, 6) }),
		create("UIPadding")({
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
		}),

		-- 1) 내부 배치: 좌측 아이콘 이미지 (오리지널 26px 대비 정확히 2배인 52px로 대형화) ★★★
		create("Frame")({
			Name = "ImageSurface",
			Size = UDim2.fromOffset(52, 52), -- 52px로 2배 확대
			Position = UDim2.new(0, 0, 0.5, -26), -- 세로축 정중앙 (-26 오프셋 보정)
			BackgroundTransparency = 1,

			create("Frame")({
				Name = "Surface",
				Size = UDim2.fromOffset(50, 50), -- 서피스 박스도 50px로 확대
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(44, 44, 48),
				BorderSizePixel = 0,

				create("UICorner")({ CornerRadius = UDim.new(0, 10) }), -- 크기에 맞게 라운딩을 10px로 확대

				create("ImageLabel")({
					Name = "Image",
					Size = UDim2.fromOffset(40, 40), -- 실제 이미지 크기를 40px로 2배 확대 ★
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = properties.Asset,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ImageColor3 = Color3.fromRGB(255, 255, 255),
				})
			})
		})
	})

	-- 2) 내부 배치: 중앙 타이틀 텍스트 스택 (아이콘 크기에 겹치지 않게 가로 배치 보정)
	self:TitleStack({
		Title = properties.IconName,
		Subtitle = "cascade.Symbols." .. properties.IconName,
		Position = UDim2.new(0, 64, 0.5, -18), -- X 오프셋을 48에서 64로 우측 이동 ★
		Parent = cardFrame.__instance,
	})

	-- 3) 내부 배치: 우측 고속 복사 버튼
	self:Button({
		Label = "Copy",
		State = "Primary",
		Position = UDim2.new(1, -90, 0.5, -14),
		Size = UDim2.new(0, 80, 0, 28),
		Parent = cardFrame.__instance,
		Pushed = function()
			if setclipboard then
				setclipboard("cascade.Symbols." .. properties.IconName)
				app:Notification({ 
					Title = "Copied",
					Subtitle = properties.IconName .. " 주소가 복사되었습니다.",
					AppIcon = properties.Asset,
					Duration = 2,
				})
			end
		end
	})

	return cardFrame
end)

--// 4. 메인 프레임워크 초기화
local app = cascade.New({
	WindowPill = true,             -- 숨김용 알약 인프라 마운트
	Theme = cascade.Themes.Dark,   -- 마코토 다크 오크 인터페이스
	Accent = cascade.Accents.Blue, -- 틴트 컬러 바인딩
})

--// 5. 메인 윈도우 생성
local window = app:Window({
	Title = "SF Core Navigator",
	Subtitle = "Total Database: " .. #masterSymbolsArray .. " Symbols",
	Searching = true,
	Draggable = true,
	Resizable = true,
	CanExit = true,
	CanMinimize = true,
	CanZoom = true,
	UIBlur = true,
	Dropshadow = true,
	Size = UDim2.fromOffset(800, 600),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
})

--// 앱 상태 녹화 레코더 가동
local recorder = cascade.AppRecorder.new(app)
recorder:Start()

-- 단축키 바인딩
services.UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == minimizeKeybind and not gameProcessedEvent then
		window.Minimized = not window.Minimized
	end
end)


-- =========================================================================
-- [메인 컨트롤 엔진 구성]
-- =========================================================================
local matrixSection = window:Section({ Title = "Asset Matrix", Disclosure = false })
local explorerTab = matrixSection:Tab({ Selected = true, Title = "Icon Directory", Icon = cascade.Symbols.squareSplit2x1 })
local formMain = explorerTab:Form()

-- 1) 상단 컨트롤러 레이아웃 폼
local fPagination = formMain:PageSection({ Title = "Chunk Page Segment" }):Form()

-- 2) 하단 실제 아이콘이 리렌더링될 메인 리스트 컨테이너 폼
local listHeaderGroup = formMain:PageSection({ Title = "Initializing..." })
local fList = listHeaderGroup:Form()

-- [렉 원천 봉쇄 핵심 함수] 프레임 드랍 및 투명 로딩을 우회하는 페이징 처리기
local function renderSymbolChunk(pageNumber)
	-- 기존 렌더링된 요소 중 CustomCard만 안전하게 소멸
	for _, child in ipairs(fList.__instance:GetChildren()) do
		if child:IsA("GuiObject") and child.Name == "CustomCard" then
			child:Destroy()
		end
	end
	
	local startIndex = ((pageNumber - 1) * chunkSize) + 1
	local endIndex = math.min(startIndex + chunkSize - 1, #masterSymbolsArray)
	
	-- 상단 상태 지표 타이틀 문자열 변경
	listHeaderGroup.Title = "Active Inventory Scope (Index: " .. startIndex .. " ~ " .. endIndex .. " )"
	
	-- 제한 임계값만큼 화면에 카드 배포
	for i = startIndex, endIndex do
		local symbolData = masterSymbolsArray[i]
		if symbolData then
			fList:CustomCard({
				IconName = symbolData.Name,
				Asset = symbolData.Asset,
			})
		end
	end
end

do -- 상단 네비게이션 제어 유틸 바인딩
	local rowControl = fPagination:Row()
	rowControl:Left():TitleStack({
		Title = "Chunk Controller",
		Subtitle = "전체 " .. math.ceil(#masterSymbolsArray / chunkSize) .. "페이지 중에서 탐색할 덩어리를 선택합니다."
	})
	
	-- 이전 페이지 버튼
	rowControl:Right():Button({
		Label = "◀ Prev",
		State = "Secondary",
		Pushed = function()
			if currentChunkPage > 1 then
				currentChunkPage = currentChunkPage - 1
				renderSymbolChunk(currentChunkPage)
			end
		end
	})
	
	-- 다음 페이지 버튼
	rowControl:Right():Button({
		Label = "Next ▶",
		State = "Primary",
		Pushed = function()
			local maxPage = math.ceil(#masterSymbolsArray / chunkSize)
			if currentChunkPage < maxPage then
				currentChunkPage = currentChunkPage + 1
				renderSymbolChunk(currentChunkPage)
			end
		end
	})
	
	-- [고속 서칭 엔진] 인스턴스 과부하를 우회하는 강제 일치 탐색 텍스트 필드
	local rowSearch = fPagination:Row()
	rowSearch:Left():TitleStack({ Title = "Engine Keywords Match", Subtitle = "6천여 개의 수많은 아이콘 중에서 찾고 싶은 키워드를 매칭합니다." })
	rowSearch:Right():TextField({
		Placeholder = "검색 텍스트 입력 (예: battery, gear, folder)...",
		TextChanged = function(self, text)
			if text == "" then
				renderSymbolChunk(currentChunkPage)
				return
			end
			
			local query = text:lower()
			local matchesCount = 0
			
			for _, child in ipairs(fList.__instance:GetChildren()) do
				if child:IsA("GuiObject") and child.Name == "CustomCard" then 
					child:Destroy() 
				end
			end
			
			for _, data in ipairs(masterSymbolsArray) do
				if data.Name:lower():find(query) then
					matchesCount = matchesCount + 1
					fList:CustomCard({ IconName = data.Name, Asset = data.Asset })
					if matchesCount >= chunkSize then break end -- 검색 결과도 최대 청크사이즈까지만 표기하여 과부하 방지
				end
			end
			listHeaderGroup.Title = "Filtered Query Results (Found: " .. matchesCount .. ")"
		end
	})
end

--// 최초 1페이지 고속 마운트 수행
renderSymbolChunk(currentChunkPage)

--// 리소스 해제 연동
window.Destroying:Connect(function()
	recorder:Stop()
	table.clear(masterSymbolsArray)
end)

--// 시스템 복구 정상 런타임 완료 알림
app:Notification({
	Title = "Memory Restructured",
	Subtitle = "성공! 디스플레이 메모리 제한 우회 및 로딩 패치가 완료되었습니다.",
	AppIcon = cascade.Symbols.checkmark,
	Duration = 4,
})
