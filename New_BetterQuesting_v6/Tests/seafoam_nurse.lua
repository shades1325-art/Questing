
function onPathAction()
    if getPokemonHealthPercent(1) ~= 100 then
        return talkToNpcOnCell(59,13)
    else
        return moveToNormalGround()
    end
end

function onBattleAction() run() end