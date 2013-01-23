require 'stuff-classifier'

module Coach
end

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/coach/*.rb") { |file| require file }