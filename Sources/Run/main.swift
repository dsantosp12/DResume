import App
import LeafProvider

let config = try Config()
try config.setup()
try config.addProvider(LeafProvider.Provider.self)

let drop = try Droplet(config)
try drop.setup()

try drop.run()
