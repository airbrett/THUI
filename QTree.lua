--The Hankinator's UI library

function qtree_create(maxdepth, bucketsize, left, top, right, bottom, depth)
	qtree = {}

	qtree.left = left
	qtree.top = top
	qtree.right = right
	qtree.bottom = bottom

	qtree.bucketsize = bucketsize
	qtree.maxdepth = maxdepth

	qtree.elements = {}

	if depth == nil then
		qtree.depth = 0
	else
		qtree.depth = depth
	end

	return qtree
end


function qtree_subdivide(qtree)
	local midx = qtree.left + (qtree.right - qtree.left)/2
	local midy = qtree.top + (qtree.bottom - qtree.top)/2

	qtree.nw = qtree_create(qtree.maxdepth, qtree.bucketsize, qtree.left, qtree.top, midx, midy, qtree.depth+1)
	qtree.ne = qtree_create(qtree.maxdepth, qtree.bucketsize, midx, qtree.top, qtree.right, midy, qtree.depth+1)
	qtree.sw = qtree_create(qtree.maxdepth, qtree.bucketsize, qtree.left, midy, midx, qtree.bottom, qtree.depth+1)
	qtree.se = qtree_create(qtree.maxdepth, qtree.bucketsize, midx, midy, qtree.right, qtree.bottom, qtree.depth+1)
	
	for k,v in pairs(qtree.elements) do
		qtree_insert(qtree.nw, v)
		qtree_insert(qtree.ne, v)
		qtree_insert(qtree.sw, v)
		qtree_insert(qtree.se, v)
	end
	
	qtree.elements = nil
end

function _qtree_overlaps(qtree, element)
	if qtree.left > element.x + element.width or qtree.right < element.x or qtree.top > element.y + element.height or qtree.bottom < element.y then
		return false
	end
	
	return true
end

function _qtree_point_within(qtree, x, y)
	if qtree.left > x or qtree.right < x or qtree.top > y or qtree.bottom < y then
		return false
	end
	
	return true
end

function qtree_insert(qtree, element)
	--check if we are at a leaf
	if qtree.elements ~= nil then
		if _qtree_overlaps(qtree, element) then
			table.insert(qtree.elements, element)
			
			if #qtree.elements >= qtree.bucketsize and qtree.depth < qtree.maxdepth then
				qtree_subdivide(qtree)
			end
		end
	else
		qtree_insert(qtree.nw, element)
		qtree_insert(qtree.ne, element)
		qtree_insert(qtree.sw, element)
		qtree_insert(qtree.se, element)
	end
end

function qtree_lookup(qtree, x, y)
	--check if we are at a leaf
	if qtree.elements ~= nil then
		return qtree.elements
	else
		if _qtree_point_within(qtree.nw, x, y) then
			return qtree_lookup(qtree.nw, x, y)
		elseif _qtree_point_within(qtree.ne, x, y) then
			return qtree_lookup(qtree.ne, x, y)
		elseif _qtree_point_within(qtree.sw, x, y) then
			return qtree_lookup(qtree.sw, x, y)
		elseif _qtree_point_within(qtree.se, x, y) then
			return qtree_lookup(qtree.se, x, y)
		end
	end
end

--For debugging
function _qtree_draw(qtree)
	context:DrawRect(qtree.left, qtree.top, qtree.right - qtree.left, qtree.bottom - qtree.top, 1)

	if qtree.nw ~= nil then
		_qtree_draw(qtree.nw)
	end
	if qtree.ne ~= nil then
		_qtree_draw(qtree.ne)
	end
	if qtree.sw ~= nil then
		_qtree_draw(qtree.sw)
	end
	if qtree.se ~= nil then
		_qtree_draw(qtree.se)
	end
end