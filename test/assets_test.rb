require_relative 'helper'

require 'tilt'
require 'tilt/sass'
require 'tilt/coffee'

setup do
  app :bare do
    plugin(:assets, {
      path: './test/dummy/assets',
      css_engine: 'scss',
      js_engine: 'coffee',
      headers: {
        "Cache-Control"             => 'public, max-age=2592000, no-transform',
        'Connection'                => 'keep-alive',
        'Age'                       => '25637',
        'Strict-Transport-Security' => 'max-age=31536000',
        'Content-Disposition'       => 'inline'
      }
    })

    assets_opts[:css] = ['app', '../raw.css']
    assets_opts[:js]  = { head: ['app'] }

    route do |r|
      r.assets

      r.is 'test' do
        response.write assets :css
        response.write assets [:js, :head]
      end
    end
  end
end

scope 'assets' do
  test 'config' do |app|
    assert app.assets_opts[:path] == './test/dummy/assets'
    assert app.assets_opts[:css].include? 'app'
  end

  test 'middleware/render' do |app|
    assert body('/assets/css/app.css')['color: red']
    assert body('/assets/css/raw.css')['color: blue']
    assert body('/assets/js/head/app.js')['console.log']
  end

  test 'instance_methods' do |app|
    html = body '/test'
    assert html['link']
    assert html['script']
  end
end
