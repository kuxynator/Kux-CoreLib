local TranslationProgressWindow = {}

local designer = {
	root_name = "Kux-CoreLib-TranslationProgressWindow"
}

function show(player, entry, current, max)
	-- Prüfen ob schon offen
	local frame = player.gui.left[designer.root_name]
	if not frame then
		frame = player.gui.left.add{
			type = "frame",
			name = designer.root_name,
			caption = "Translation Progress"
		}
		frame.add{ type = "scroll-pane", name = "content_scrollpane" }.style.maximal_height = 400
	end

	local scroll = frame.content_scrollpane
	local row = scroll["row-"..entry]
	if not row then
		-- Neue Zeile
		row = scroll.add{ type = "flow", name = "row-"..entry }
		row.style.horizontal_spacing = 8

		-- Name-Label
		local nameLabel = row.add{ type = "label", caption = entry }
		nameLabel.style.width = 150

		-- Current-Label
		local currentLabel = row.add{ type = "label", name = "current", caption = tostring(current) }
		currentLabel.style.width = 50

		-- Progressbar
		local bar = row.add{ type = "progressbar", name = "bar", value = current / max }
		bar.style.width = 100

		-- Max-Label
		local maxLabel = row.add{ type = "label", name = "max", caption = tostring(max) }
		maxLabel.style.width = 50
	end

	if current < max then
		row.current.caption = tostring(current)
		row.bar.value = current / max
		row.max.caption = tostring(max)
	else
		row.destroy()
		if #scroll.children == 0 then frame.destroy() end
	end

end

function TranslationProgressWindow.show(entry, current, max)
	for _, player in pairs(game.players) do
		if player.valid then
			show(player, entry, current, max)
		end
	end
end

return TranslationProgressWindow