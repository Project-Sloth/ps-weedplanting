MySQL.ready(function()
    -- Check if casino_rooms table exists
    local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM `weedplants` LIMIT 1')

    if not success then
        utils.print('Creating weedplants table')

        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `weedplants` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `coords` longtext NOT NULL CHECK (json_valid(`coords`)),
                `time` int(255) NOT NULL,
                `fertilizer` longtext NOT NULL CHECK (json_valid(`fertilizer`)),
                `water` longtext NOT NULL CHECK (json_valid(`water`)),
                `gender` varchar(45) NOT NULL,
                PRIMARY KEY (`id`)
            );
        ]])
    end
end)