require 'sinatra/base'
require 'sinatra/session'

require 'httparty'
require 'leaf'
require 'leaf/array'

include Leaf::ViewHelpers::Base

class RMUirc < Sinatra::Base
class Log
  include HTTParty

  base_uri 'http://rmuapi.heroku.com/'
  format :json
end
end

class RMUirc
  register Sinatra::Session

  set :public, File.expand_path( File.dirname(__FILE__) + '/public')

  set :session_fail, '/login'
  set :session_secret, 'babot is my'

  enable :inline_templates

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
    
    def page_size
      50
    end

    def parse_links(line)
      link_re = %r{((?:(?:ftp|http|https|gopher|mailto|news|nntp|telnet|wais|file|prospero|aim|webcal):(?:(?:[A-Za-z0-9$_.+!*(),;\/?:@&~=-])|%[A-Fa-f0-9]{2}){2,}(?:#(?:[a-zA-Z0-9][a-zA-Z0-9$_.+!*(),;\/?:@&~=%-]*))?(?:[A-Za-z0-9$_+!*();\/?:~-])))}
      line.gsub(link_re, '<a href="\1">\1</a>')
    end
  end


## LOGIN LOGIc
#
  get '/login' do
    erb :lili
  end
  post '/login' do
    if params[:secret].eql? 'rmu1337'
      session_start!
      session[:secret] = params[:secret]
      
      redirect '/'
    else
      redirect '/login'
    end
  end
##
  get '/logout' do
    session_end!

    redirect '/'
  end
#
## LOGIN LOGIc

  get '/old' do
    session!

    @body = File.open( File.expand_path(File.dirname(__FILE__)+'/archive.html') ) {|f| f.read }
    
    erb :archive
  end

  get '/' do
    session!
    session[:log] = Log.get('/irc/log') if !session[:log]

    page = params[:page] ? params[:page] : 1

    erb :logs, :locals => { 
      :collection => session[:log].reverse.paginate({
        :page => page,
        :per_page => 50
      }) 
    }
  end
end

__END__

@@ login
%content{ :style => 'text-align: center'}
  %form{ :name => 'input', :action => 'login', :method => 'POST'}
    %input{ :type => 'text', :name => 'secret', :value => 'our little secret'}

    %input{ :type => 'submit', :value => 'submit'}

@@ lili
<div id='content' style='text-align: center'>
  <form name='input' action='login' method='POST'>
    <input type='text' name='secret' value='our little secret' />
    
    <input type='submit' value='submit' />
  </form
</div>
