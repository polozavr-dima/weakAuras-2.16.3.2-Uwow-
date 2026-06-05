if not WeakAuras.IsCorrectVersion() then return end

local Type, Version = "WeakAurasSortedDropdown", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Tooltip frame reused across all dropdowns
local tooltipFrame = tooltipFrame or CreateFrame("GameTooltip", "WeakAurasSortedDropdownTooltip", UIParent, "GameTooltipTemplate")

local function ShowAffixTooltip(item)
  local key = item.userdata and item.userdata.value
  if not key then return end
  -- Strip icon texture codes from the display name for the tooltip title
  local displayText = item.label and item.label:GetText() or ""
  local cleanName = displayText:gsub("|T.-|t%s*", "")
  local desc = WeakAuras.mythic_plus_affix_descs and WeakAuras.mythic_plus_affix_descs[key]
  if not desc then return end
  tooltipFrame:SetOwner(item.frame, "ANCHOR_RIGHT")
  tooltipFrame:SetText(cleanName, 1, 0.82, 0, true)
  tooltipFrame:AddLine(desc, 1, 1, 1, true)
  tooltipFrame:Show()
end

local function HideAffixTooltip()
  tooltipFrame:Hide()
end

local function Constructor()
  local DropDownConstructor = AceGUI.WidgetRegistry["Dropdown"];
  if (not DropDownConstructor) then
    return nil;
  end
  local widget = DropDownConstructor();
  if (not widget) then
    return nil;
  end

  local oldSetList = widget.SetList
  widget.SetList = function(self, list, _, itemType)
    local orderTable = {};
    for k, v in pairs(list) do
      tinsert(orderTable, { key = k, value = v });
    end

    local order = {};

    -- Sort alphabetically by display value (strips icon texture codes for comparison)
    table.sort(orderTable, function(a, b)
      local va = tostring(a.value):gsub("|T.-|t%s*", "")
      local vb = tostring(b.value):gsub("|T.-|t%s*", "")
      return va < vb;
    end);

    for i, item in ipairs(orderTable) do
      order[i] = item.key;
    end

    oldSetList(self, list, order, itemType)

    -- Attach tooltip handlers to each pullout item (for affix descriptions)
    if self.pullout and WeakAuras.mythic_plus_affix_descs then
      for _, pulloutItem in self.pullout:IterateItems() do
        if pulloutItem.userdata and pulloutItem.userdata.value ~= nil then
          if WeakAuras.mythic_plus_affix_descs[pulloutItem.userdata.value] then
            pulloutItem:SetOnEnter(ShowAffixTooltip)
            pulloutItem:SetOnLeave(HideAffixTooltip)
          end
        end
      end
    end
  end

  widget.type = Type;

  return widget;
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
