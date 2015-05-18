require 'spec_helper'
require 'pry'

describe Her::JsonApi::Collection do
  before do
    Her::API.setup :url => "https://api.example.com" do |connection|
      connection.use Her::Middleware::JsonApiParser
      connection.adapter :test do |stub|
        stub.post("/users", data: [
          {
            type: 'users',
            attributes: {
              name: "Jeremy Lin",
            },
          }, {
            type: 'users',
            attributes: {
              name: "Steph Curry",
            },
          },
        ]) do |env|
          [ 
            201,
            {},
            {
              data: [
                {
                  id:    1,
                  type: 'users',
                  attributes: {
                    name: 'Jeremy Lin',
                  },
                }, {
                  id:    2,
                  type: 'users',
                  attributes: {
                    name: 'Steph Curry',
                  },
                },
              ]
            }.to_json
          ] 
        end

        stub.patch("/users", data: [
          {
            type: 'users',
            id: 1,
            attributes: {
              name: "Jeremy Line",
            },
          }, {
            type: 'users',
            id: 2,
            attributes: {
              name: "Stephen Curry",
            },
          },
        ]) do |env|
          [ 
            200,
            {},
            {
              data: [
                {
                  id:    1,
                  type: 'users',
                  attributes: {
                    name: 'Jeremy Line',
                  },
                },
                {
                  id:    2,
                  type: 'users',
                  attributes: {
                    name: 'Stephen Curry',
                  },
                },
              ]
            }.to_json
          ] 
        end

        stub.delete("/users") { |env|
          [ 204, {}, {}, ] 
        }
      end

    end

    spawn_model("Foo::User", Her::JsonApi::Model)
    class Foo::UserCollection
      include Her::JsonApi::Collection
    end

  end

  context 'class macros' do
    it 'bulk creates a collection of models' do
      jeremy = Foo::User.new(name: 'Jeremy Lin')
      curry = Foo::User.new(name: 'Steph Curry')
      collection = Foo::UserCollection.create(jeremy, curry)
      expect(collection.class).to eql(Foo::UserCollection)
      expect(collection.map(&:attributes)).to match_array([
        {
          'id' => 1,
          'name' => 'Jeremy Lin',
        },
        {
          'id' => 2, 
          'name' => 'Steph Curry'
        }
      ])
    end

    it 'bulk updates a collection of models' do
      jeremy = Foo::User.new(id: 1, name: 'Jeremy Line')
      curry = Foo::User.new(id: 2, name: 'Stephen Curry')
      collection = Foo::UserCollection.update(jeremy, curry)
      expect(collection.class).to eql(Foo::UserCollection)
      expect(collection.map(&:attributes)).to match_array([
        {
          'id' => 1,
          'name' => 'Jeremy Line',
        },
        {
          'id' => 2, 
          'name' => 'Stephen Curry'
        }
      ])
    end
  end

  context 'instance methods' do
    it 'bulk creates models' do
      jeremy = Foo::User.new(name: 'Jeremy Lin')
      curry = Foo::User.new(name: 'Steph Curry')
      collection = Foo::UserCollection.new(jeremy, curry).create
      expect(collection.class).to eql(Foo::UserCollection)
      expect(collection.map(&:attributes)).to match_array([
        {
          'id' => 1,
          'name' => 'Jeremy Lin',
        },
        {
          'id' => 2, 
          'name' => 'Steph Curry'
        }
      ])
    end

    it 'bulk updates models' do
      jeremy = Foo::User.new(id: 1, name: 'Jeremy Line')
      curry = Foo::User.new(id: 2, name: 'Stephen Curry')
      collection = Foo::UserCollection.new(jeremy, curry).update
      expect(collection.class).to eql(Foo::UserCollection)
      expect(collection.map(&:attributes)).to match_array([
        {
          'id' => 1,
          'name' => 'Jeremy Line',
        },
        {
          'id' => 2, 
          'name' => 'Stephen Curry'
        }
      ])
    end
  end

  #it 'bulk destroys a collection of Foo::User' do
  #  user = Foo::User.find(1)
  #  expect(user.destroy).to be_destroyed
  #end
end
