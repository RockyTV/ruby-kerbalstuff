0.2.2 (December 15, 2014)
* Documented the whole gem
* Changed RuntimeError raising to ArgumentError
* Renamed gem to 'kerbalstuff'



0.2.1 (November 20, 2014)
* Added support for **POST** methods (Login, CreateMod, UpdateMod)
* All methods now return an array containing the info you need. Example: `["name=test", "id=1337"]`



0.2.0 (October 25, 2014)
* Added support for KerbalStuff **browse** methods
* Added links to Mod.background and ModVersion.download_path