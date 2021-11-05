require "./bulk"
require "./counter"
require "./engine"
require "http/client"
require "option_parser"
require "colorize"
require "json"
require "csv"
require "log"

# :nodoc:
VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
backend = Log::IOBackend.new(File.new("./frightcrawler.log", "a+"))
Log.setup(:info, backend)

game_format : String = ""
sf_id : String = ""
csv_file : Nil.class | String = Nil

puts INTRO, VERSION

OptionParser.parse do |parser|
  parser.on("-g GAME_FORMAT", "Set game format") { |_game_format| game_format = _game_format }
  parser.on("-f CSV_FILE", "Path to CSV file") { |_csv_file| csv_file = _csv_file }
  parser.on("-i SCRYFALL_ID", "Get card info") { |_sf_id| sf_id = _sf_id }
  parser.on("-b", "Redownload bulk data") { Bulk::Puller.force_bulk_enable }
  parser.on("-h", "--help", "Print documentation") do
    parser.banner = "Usage: frightcrawler -g modern -f PATH/TO/FILE"
    parser.separator("Supported CSV layouts: Helvault, Helvault Pro, AetherHub.")
    parser.separator("Supported formats: standard, future, historic, gladiator, pioneer, modern, legacy, pauper,\nvintage, penny, commander, brawl, historicbrawl, paupercommander, duel, oldschool, premodern.")
    puts parser
    exit
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option"
    STDERR.puts parser
    exit(1)
  end
end

if !sf_id.empty?
  puts Engine.card_info("#{sf_id}")
end

if game_format != ""
  puts "\n  * Using #{game_format} format list"
end

# :nodoc:
INTRO = "
▓░░░█▀▀░█▀▀▄░░▀░░█▀▀▀░█░░░░▀█▀░
▓░░░█▀░░█▄▄▀░░█▀░█░▀▄░█▀▀█░░█░░
▓░░░▀░░░▀░▀▀░▀▀▀░▀▀▀▀░▀░░▀░░▀░░
▓░█▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
▓░█░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
▓░▀▀▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀"

# :nodoc:
T1 = Time.monotonic

if csv_file != Nil
  Engine.validate_csv("#{csv_file}", "#{game_format}")
end

# :nodoc:
T2 = Time.monotonic

if csv_file == Nil && sf_id == "" && game_format == ""
  puts "\nNo data provided. Exiting."
end
