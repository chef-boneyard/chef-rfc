# Generate https://chef.github.io/chef-rfc/ , using metadata from
# individual RFCs to build an index.

require 'metadown'
require 'pygments'
require 'erubis'

class HTMLwithPygments < Metadown::Renderer
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  rescue Exception
    Pygments.highlight(code, lexer: 'text')
  end
end

POSTAMBLE=<<-EOF.freeze
    </div>
  </body>
</html>
EOF

PREAMBLE=<<-EOF.freeze
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable = no">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/foundation-essential/6.2.2/css/foundation.min.css">
    <style>
      a { color: #f18b21; }
      a:hover, a:focus { color: #3f5364; }
    </style>
    <title>Chef RFCs</title>
  </head>
  <body>
    <div class="row medium-12 columns">
      <header class="clearfix">
        <div class="left">
          <a href="/chef-rfc"><h1>Chef RFCs</h1></a>
        </div>
      </header>
EOF

INDEX=<<-EOF.freeze
<section class="rfcs">
<table>
<tr>
  <th>Number</th>
  <th>Title</th>
  <th>Author</th>
  <th>Type</th>
  <th>Status</th>
  <th>Tracking</th>
</tr>
<% for item in metadata -%>
<tr>
  <td><a href="<%= item["Filename"] %>"><%= item["RFC"] %></a></td>
  <td><a href="<%= item["Filename"] %>"><%= item["Title"] %></a></td>
  <td><%= item["Author"] %></td>
  <td><%= item["Type"] %></td>
  <td><%= item["Status"] %></td>
  <td><%= item["Tracking"] %></td>
</tr>
<% end -%>
</table>
</section>
EOF

namespace :pages do
  desc "Generate GitHub Pages for RFCs"
  task :generate do
    sh("git worktree add -b gh-pages gh-pages origin/gh-pages") unless File.directory?("gh-pages")
    metadata = []
    renderer = Redcarpet::Markdown.new(HTMLwithPygments, :fenced_code_blocks => true)
    Dir[File.join(File.dirname(__FILE__), "..", "rfc*.md")].each do |rfc|
      name = File.basename(rfc, ".md")
      target = name + ".html"
      output = Metadown.render(File.read(rfc), renderer)
      output.metadata ||= {}
      output.metadata["Filename"] = target
      number, title = name.match(/rfc(\d*)-(.+)/)[1,2]
      output.metadata["Title"] ||= title.split("-").map(&:capitalize).join(" ")
      output.metadata["RFC"] ||= number
      metadata << output.metadata
      File.open(File.join("gh-pages", target), "w") {|fh| fh.write(PREAMBLE + output.output + POSTAMBLE) }
    end
    eruby = Erubis::EscapedEruby.new(INDEX)
    File.open(File.join("gh-pages", "index.html"), "w") {|fh| fh.write(PREAMBLE + eruby.result(binding()) + POSTAMBLE) }
  end
  puts "Now enter the gh-pages directory and git diff etc"
  puts "The site will get updated when you commit and push the gh-pages branch with your changes"
end
