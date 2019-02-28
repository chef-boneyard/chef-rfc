#
# Author:: Thom May (thom@may.lt)
# Author:: Nathen Harvey (nathenharvey@google.com)
# Copyright:: Copyright (c) 2015-2019, Chef Software, Inc
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rake'
require 'tomlrb'

SOURCE = File.join(File.dirname(__FILE__), "..", "ADVOCATES.toml")
TARGET = File.join(File.dirname(__FILE__), "..", "ADVOCATES.md")

task :default => :generate

namespace :advocates do
  desc "Generate MarkDown version of ADVOCATES file"
  task :generate do
    advocates = Tomlrb.load_file SOURCE
    out = "<!-- This is a generated file. Please do not edit directly -->\n"
    out << "<!-- Modify ADVOCATES.toml file and run `rake advocates:generate` to regenerate -->\n\n"
    out << "# " + advocates["Preamble"]["title"] + "\n\n"
    out <<  advocates["Preamble"]["text"] + "\n"
    out << "# " + advocates["Org"]["Lead"]["title"] + "\n\n"
    out << person_data(advocates["people"].fetch(advocates["Org"]["Lead"]["person"])) + "\n\n"
    out << "## " + advocates["Org"]["Ombudsperson"]["title"] + "\n\n"
    out << person_data(advocates["people"].fetch(advocates["Org"]["Ombudsperson"]["person"])) + "\n\n"
    out << "## Advocates\n\n"
    out << components(advocates["people"], advocates["Org"]["Advocates"])
    File.open(TARGET, "w") { |fn|
      fn.write out
    }
  end
end

def components(list, cmp)
  out = ""
  cmp.each do |k,v|
    out << "\n#### #{v['title'].gsub('#','\\#')}\n"
    out << advocates(list, v['advocates'])
  end
  out
end

def advocates(list, people)
  o = ""
  people.each do |p|
    o << person_data(list.fetch(p)) + "\n"
  end
  o
end

def person_data(person)
  if person.has_key?("GitHub")
    out = "* [#{person["Name"]}](https://github.com/#{person["GitHub"]})"
  else
    out =  "* #{person["Name"]}"
  end
  out << "\n  * Slack - #{person["Slack"]}" if person.has_key?("Slack")
  out << "\n  * [@#{person["Twitter"]}](https://twitter.com/#{person["Twitter"]})" if person.has_key?("Twitter")
  out << "\n  * [#{person["email"]}](mailto:#{person["email"]})" if person.has_key?("email")
  out << "\n  * #{person["phone"]}" if person.has_key?("phone")
  out << "\n  * [ServerFault](#{person["ServerFault"]})" if person.has_key?("ServerFault")
  out << "\n  * [StackOverflow](#{person["StackOverflow"]})" if person.has_key?("StackOverflow")
  out
end
