--The Hankinator's UI library

--[[
qtree = {}
	
qtree.left = 0
qtree.top = 0
qtree.right = 100
qtree.bottom = 100

qtree_subdivide(qtree, 4)
--]]
function qtree_subdivide(qtree, depth)
	qtree.x = qtree.left + ((qtree.right - qtree.left) / 2)
	qtree.y = qtree.top + ((qtree.bottom - qtree.top) / 2)
	
	qtree.nw = {left=qtree.left, right=qtree.x, top=qtree.top, bottom=qtree.y}
	qtree.ne = {left=qtree.x, right=qtree.right, top=qtree.top, bottom=qtree.y}
	qtree.se = {left=qtree.x, right=qtree.right, top=qtree.y, bottom=qtree.bottom}
	qtree.sw = {left=qtree.left, right=qtree.x, top=qtree.y, bottom=qtree.bottom}
	
	if depth > 0 then
		qtree_subdivide(qtree.nw, depth - 1)
		qtree_subdivide(qtree.ne, depth - 1)
		qtree_subdivide(qtree.se, depth - 1)
		qtree_subdivide(qtree.sw, depth - 1)
	else
		qtree.elements = {}
	end
end

function qtree_insert(qtree, element)
	--check if we are at a leaf
	if qtree.elements ~= nil then
		table.insert(qtree.elements, element)
	else
		if element.x < qtree.x then
			if element.y + element.height > qtree.y then
				qtree_insert(qtree.sw, element)
			end
			
			if element.y < qtree.y then
				qtree_insert(qtree.nw, element)
			end
		end
		
		if element.x + element.width >= qtree.x then
			if element.y + element.height > qtree.y then
				qtree_insert(qtree.se, element)
			end
			
			if element.y < qtree.y then
				qtree_insert(qtree.ne, element)
			end
		end
	end
end

function qtree_lookup(qtree, x, y)
	--check if we are at a leaf
	if qtree.elements ~= nil then
		return qtree.elements
	else
		if x < qtree.x then
			if y < qtree.y then
				return qtree_lookup(qtree.nw, x, y)
			else
				return qtree_lookup(qtree.sw, x, y)
			end
		end
		
		if x >= qtree.x then
			if y < qtree.y then
				return qtree_lookup(qtree.ne, x, y)
			else
				return qtree_lookup(qtree.se, x, y)
			end
		end
	end
end