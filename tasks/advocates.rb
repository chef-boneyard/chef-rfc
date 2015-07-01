#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2008, 2010 Opscode, Inc.
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
    out = "<!-- This is a generated file. Please do not edit directly -->\n\n"
    out << "# " + advocates["Preamble"]["title"] + "\n\n"
    out <<  advocates["Preamble"]["text"] + "\n"
    out << "# " + advocates["Org"]["Lead"]["title"] + "\n\n"
    out << person(advocates["people"], advocates["Org"]["Lead"]["person"]) + "\n\n"
    out << components(advocates["people"], advocates["Org"]["Components"])
    File.open(TARGET, "w") { |fn|
      fn.write out
    }
  end
end

def components(list, cmp)
  out = "## " + cmp.delete("title") + "\n\n"
  out << cmp.delete("text") + "\n" if cmp.has_key?("text")
  if cmp.has_key?("lieutenant")
    out << "### Lieutenant\n\n"
    out << person(list, cmp.delete("lieutenant")) + "\n\n"
  end
  out << advocates(list, cmp.delete("advocates")) + "\n" if cmp.has_key?("advocates")
  cmp.delete("paths")
  cmp.each {|k,v| out << components(list, v) }
  out
end

def advocates(list, people)
  o = "### Advocates\n\n"
  people.each do |p|
    o << person(list, p) + "\n"
  end
  o
end

def person(list, person)
  "* [#{list[person]["Name"]}](https://github.com/#{list[person]["GitHub"]})"
end
