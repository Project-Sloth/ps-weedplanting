Locales = json.decode(LoadResourceFile(Config.Resource, ('locales/%s.json'):format(Config.Lang)))

if not Locales then
    Locales = json.decode(LoadResourceFile(Config.Resource, ('locales/en.json')))
end
