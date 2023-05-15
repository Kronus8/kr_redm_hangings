Config = {}

--[[ Global ]]--
Config.ActDist = 2.0 -- Distance to perform action/draw prompts

--[[ Hanging ]]--

Config.Hanging = {
    Animation = {
        Dict = 'script_re@public_hanging@criminal_male',
        Name = 'intro_idle',
        RequestDict = function()
            RequestAnimDict(Config.Hanging.Animation.Dict)
            while not HasAnimDictLoaded(Config.Hanging.Animation.Dict) do
                Citizen.Wait(5)
            end
        end
    },
    Locations = {
       {
            RopeHang = vector3(0.0, 0.0, 2.5), 
            Location = vector3(-315.134, 733.651, 120.606),
            Heading = 100.645
        }
    }
}