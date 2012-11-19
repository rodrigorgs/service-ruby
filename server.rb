#!/usr/bin/env ruby

# Rodrigo Rocha, November 19th, 2012

require 'sinatra'
require 'data_mapper'
require 'json'

###################################################

database_url = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/database.db"
DataMapper::setup(:default, database_url)

class Item
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :done, Boolean

	validates_uniqueness_of :name
end

DataMapper.finalize
# DataMapper.auto_migrate!
DataMapper.auto_upgrade!


###################################################

get '/' do
	"Hello World"
end

#######################################################

get '/item' do
	content_type :json

	items = Item.all
	items.to_json
end

get '/item/:id' do
	content_type :json

	item = Item.get(params[:id].to_i)
	halt(404, 'Not Found') if item.nil?

	item.to_json
end

post '/item' do
	content_type :json

	attrs = JSON.parse(request.body.read)
	attrs = attrs.inject({ }) { |x, (k,v)| x[k.to_sym] = v; x }
	attrs.delete(:id)

	item = Item.create(attrs)
	# TODO: error if was not created
	response.status = 201
end

put '/item/:id' do
	content_type :json

	item = Item.get(params[:id].to_i)
	halt(404, 'Not Found') if item.nil?

	attrs = JSON.parse(request.body.read)
	attrs = attrs.inject({ }) { |x, (k,v)| x[k.to_sym] = v; x }
	attrs.delete(:id)
	
	p attrs
	item.update!(attrs)
end

delete '/item/:id' do
	content_type :json

	item = Item.get(params[:id].to_i)
	halt(404, 'Not Found') if item.nil?
	item.destroy!
end
