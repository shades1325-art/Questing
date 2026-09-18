-- Fast Story configuration boundary.
--
-- Fast Story is the only supported story behavior.  Its operational
-- policies are mandatory and intentionally have no GUI toggles.

local StoryConfig = {}

-- Keep the existing BetterQuesting option index centralized.  No additional
-- story GUI indexes are allocated.
StoryConfig.gui = {
    relogOnStop = 1,
}

StoryConfig.highLevelTeam = true
StoryConfig.autoRotate = true
StoryConfig.autoHeal = true

function StoryConfig.configureGui()
    -- Preserve the existing BetterQuesting option and default behavior.
    setOption(StoryConfig.gui.relogOnStop, true)
    setOptionName(StoryConfig.gui.relogOnStop, "Relog on stop")
    setOptionDescription(
        StoryConfig.gui.relogOnStop,
        "Relog the account after the BetterQuesting script is stopped."
    )
end

function StoryConfig.read()
    local config = {
        highLevelTeam = StoryConfig.highLevelTeam,
        autoRotate = StoryConfig.autoRotate,
        autoHeal = StoryConfig.autoHeal,
    }

    StoryConfig.current = config
    return config
end

function StoryConfig.getCurrent()
    return StoryConfig.current
end

return StoryConfig
