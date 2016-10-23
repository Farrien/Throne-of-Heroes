modifier_movespeed_new_thirst = class({})

function modifier_movespeed_new_thirst:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_movespeed_new_thirst:GetModifierMoveSpeed_Max( params )
    return 2000
end

function modifier_movespeed_new_thirst:GetModifierMoveSpeed_Limit( params )
    return 2000
end

function modifier_movespeed_new_thirst:IsHidden()
    return true
end